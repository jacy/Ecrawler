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
	provider(),
	load_result(),
	save_or_update_result().
 
%%%%%%%%%%%%%%%%%%%%
%%% ACTUAL TESTS %%%
%%%%%%%%%%%%%%%%%%%%
provider() -> 
	?assertMatch([#provider{
				   id =  10001,
				   name = <<"Australia">>,
				   type = <<"KENO">>,
				   url = <<"https://www.acttab.com.au/interbet/kenoreswin;1372346560">>,
				   interval = 240
				  }],
				 db:providers()).

load_result() ->
	?assertMatch([[10001,<<"7060">>,<<"1,56">>]],db:load_result(10001,"7060")).

save_or_update_result() ->
	Drawno = "noexist_draw_no",
	Result = "11,22",
	?assertMatch([],db:load_result(10001, Drawno)),
	db:save_or_update_result(10001, Drawno, Result),
	BinaryDrawno = list_to_binary(Drawno),
	BinaryResult = list_to_binary(Result),
	?assertMatch([[10001,BinaryDrawno,BinaryResult]],db:load_result(10001, Drawno)),
	
	NewResult = "22,333,444",
	BinaryNewResult = list_to_binary(NewResult),
	db:save_or_update_result(10001, Drawno, NewResult),
	?assertMatch([[10001,BinaryDrawno,BinaryNewResult]],db:load_result(10001, Drawno)).


