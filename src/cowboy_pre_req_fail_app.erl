-module(cowboy_pre_req_fail_app).
-behaviour(application).

-export([start/2, stop/1]).
-export([init/2, websocket_handle/3, websocket_info/3]).

-record(state, {
          ref
         }).


-define(TO_CLIENT, to_client).
-define(COWBOY_LISTENER_REF, cowboy_ref).

start(_Type, _Args) ->
    ok = startup_cowboy(),
    cowboy_pre_req_fail_sup:start_link().

stop(_State) ->
    ok.


startup_cowboy() ->
    Dispatch = cowboy_router:compile([
                                      {'_', [{"/", ?MODULE, []}]}
                                     ]),
    {ok, _} = cowboy:start_clear(?COWBOY_LISTENER_REF, 100,
                                 [{port, 8080}],
                                 #{env => #{dispatch => Dispatch}}
                                ),
    ok.



init(Req, [Ref]) ->
    {cowboy_websocket, Req, #state{ref=Ref}, 60000}.

websocket_handle({text, Msg}, Req, State = #state{ref=Ref}) ->
    ok = rsfo_message_pool:recv(self(), Ref, Msg),
    {ok, Req, State};
websocket_handle(_Frame, Req, State) ->
    {ok, Req, State}.

websocket_info({?TO_CLIENT, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
    {ok, Req, State}.
