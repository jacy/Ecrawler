-module(db).
-behaviour(gen_server).

-export([start_link/0, stop/0, providers/0,save_or_update_result/3,save_result/2,
		 load_result/2]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-include("crawler.hrl").

%% ==========================Public API======================================
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() -> gen_server:cast(?MODULE, stop).

save_result(_, []) -> ok;
save_result(Id, [#lottery{drawno=N,result=R} | T]) ->
	save_or_update_result(Id, N, R),
	save_result(Id, T).
	
save_or_update_result(ProviderId, Drawno, Result) ->
	execute(<<"insert into `result` (`provider_id`,`drawno`,`result`) values(?,?,?) on duplicate key update `result`=?">>,
			[ProviderId, Drawno, Result, Result]).

load_result(ProviderId, Drawno) ->
	{ _, _, _, Result, _ } = execute(<<"select `provider_id`,`drawno`,`result` from `result` where `provider_id`=? and `drawno`=?">>,[ProviderId, Drawno]),
	Result.
	
providers() ->
	Result = execute(<<"select `id`,`name`,`type`,`url`,`interval` from provider order by `interval`,`id`">>),
	emysql_util:as_record(Result, provider, record_info(fields, provider)).

%% ==========================Private API======================================
execute(Sql) ->
	emysql:execute(db_pool, Sql).
execute(Sql, Arg) ->
	emysql:execute(db_pool, Sql, Arg).

%% =========================Callbacke=======================================
init([]) ->
	process_flag(trap_exit,true),
	crypto:start(),
	application:start(emysql),
	emysql:add_pool(db_pool, 20,
		"erlang", "111111", "localhost", 3306,
		"lottery", utf8),
	io:format("********Database is staring*****~n"),
  	{ok, []}.

handle_call(Msg, _From, State) ->
  io:format("********Database receive unknown call Msg:~p*****~n",[Msg]),
  {reply, ok, State}.

handle_cast(stop, State) -> {stop, normal, State};
handle_cast(Msg, State) -> 
	io:format("********Database receive unknown cast Msg:~p*****~n",[Msg]),
	{noreply, State}.

handle_info(Msg, State) ->
	io:format("********Database receive unknown Msg:~p ~n*****~n",[Msg]),
	{noreply, State}.

terminate(_Reason, _State) ->
	emysql:remove_pool(emysql),
	io:format("********Database connection is stopping*****~n"),
	ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.