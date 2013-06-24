-module(db).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
	crypto:start(),
	application:start(emysql),
	emysql:add_pool(db_pool, 20,
		"time_voyager", "111111", "localhost", 3306,
		"corewallet", utf8),
	 { _, _, _, Result, _ } = emysql:execute(db_pool,<<"select * from user">>),
	
	io:format("Test select from user:~n~p~n", [Result]),
  	{ok, []}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
	application:stop(emysql),
	crypto:stop(),
	unregister(?MODULE),
	io:format("********Database connection is stopping*****").

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.