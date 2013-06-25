-module(db).
-behaviour(gen_server).

-export([start_link/0, stop/0, providers/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-include("crawler.hrl").

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


stop() -> gen_server:cast(?MODULE, stop).

providers() ->
	Result = emysql:execute(db_pool,<<"select `id`,`name`,`type`,`url`,`interval`,`status` from provider order by `interval`,`id`">>),
	emysql_util:as_record(Result, provider, record_info(fields, provider)).

%% ================================================================

init([]) ->
	io:format("********Going to start Database*****"),
	crypto:start(),
	application:start(emysql),
	Result = emysql:add_pool(db_pool, 20,
		"erlang", "111111", "localhost", 3306,
		"lottery", utf8),
	io:format("********Database is staring:~p*****", [Result]),
  	{ok, []}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(stop, State) -> {stop, normal, State};
handle_cast(_Msg, State) -> {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
	application:stop(emysql),
	crypto:stop(),
	unregister(?MODULE),
	io:format("********Database connection is stopping*****").

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.