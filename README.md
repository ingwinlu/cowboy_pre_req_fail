# cowboy_pre_req_fail

Example showing silent fail of cowboy after upgrading to recent pre-6 version without updating the callback handler.
The handler is still providing the old Req field in the callbacks.
Cowboy is failing silently which is not expected behaviour.

```
[winlu@virtualArch cowboy_pre_req_fail]$ make shell
 GEN    shell
Erlang/OTP 19 [erts-8.2] [source] [64-bit] [smp:2:2] [async-threads:10] [hipe] [kernel-poll:false]

Eshell V8.2  (abort with ^G)
1> application:ensure_all_started(cowboy_pre_req_fail).
{ok,[crypto,cowlib,asn1,public_key,ssl,ranch,cowboy,
     cowboy_pre_req_fail]}
2> l(gun).
{module,gun}
3> application:ensure_all_started(gun).
{ok,[gun]}
4> ranch:info().
[{cowboy_ref,[{pid,<0.86.0>},
              {ip,{0,0,0,0}},
              {port,8080},
              {num_acceptors,100},
              {max_connections,1024},
              {active_connections,0},
              {all_connections,0},
              {transport,ranch_tcp},
              {transport_options,[{connection_type,supervisor},
                                  {port,8080}]},
              {protocol,cowboy_clear},
              {protocol_options,#{connection_type => supervisor,
                                  env => #{dispatch => [{'_',[],[{[],[],cowboy_pre_req_fail_app,[]}]}]}}}]}]
5> {ok, GunPid} = gun:open("127.0.0.1", 8080, #{retry=>0}).
{ok,<0.198.0>}
6> {ok, http} = gun:await_up(GunPid).
{ok,http}
7> gun:ws_upgrade(GunPid, "/").
#Ref<0.0.1.394>
8> erlang:process
process_display/2  process_flag/2     process_flag/3     process_info/1
process_info/2     processes/0
8> erlang:process
process_display/2  process_flag/2     process_flag/3     process_info/1
process_info/2     processes/0
8> receive
8>   Msg -> Msg
8> after 5000 -> timeout
8> end.
{gun_down,<0.198.0>,http,closed,[],[]}
9> ranch:info().
[{cowboy_ref,[{pid,<0.86.0>},
              {ip,{0,0,0,0}},
              {port,8080},
              {num_acceptors,100},
              {max_connections,1024},
              {active_connections,0},
              {all_connections,0},
              {transport,ranch_tcp},
              {transport_options,[{connection_type,supervisor},
                                  {port,8080}]},
              {protocol,cowboy_clear},
              {protocol_options,#{connection_type => supervisor,
                                  env => #{dispatch => [{'_',[],[{[],[],cowboy_pre_req_fail_app,[]}]}]}}}]}]
10> q().
ok
11> [winlu@virtualArch cowboy_pre_req_fail]$ vim README.md
```
