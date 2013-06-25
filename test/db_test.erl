-module(db_test).
-include_lib("eunit/include/eunit.hrl").
-include("crawler.hrl").
-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TESTS DESCRIPTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Any function ending with test_ tells EUnit that it should return a list of tests
start_stop_test_() ->
	{
	 	setup,
		fun start/0,
		fun stop/1,
		fun(_) ->  fun() -> all() end  end
	}.
 
%%%%%%%%%%%%%%%%%%%%%%%
%%% SETUP FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
start() ->
	{ok,Pid} = db:start_link(), 
	Pid.
 
stop(_) ->
	db:stop().

all() ->
	provider().
 
%%%%%%%%%%%%%%%%%%%%
%%% ACTUAL TESTS %%%
%%%%%%%%%%%%%%%%%%%%
provider() -> 
	?assertMatch([#provider{
				   id =  10001,
				   name = <<"Australia">>,
				   type = <<"KENO">>,
				   url = <<"https://www.acttab.com.au/interbet/kenoreswin;1372346560">>,
				   interval = 240,
				   status = 1
				  }],
				 db:providers()).