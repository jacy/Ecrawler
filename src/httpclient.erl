-module(httpclient).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


	

%%===============================================
init([]) ->
	{ibrowse:start(),[]}.
	

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
	inets:stop(),
	io:format("********Http client is stopping*****").

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.