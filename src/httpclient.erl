-module(httpclient).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-define(REQ_HEADER, [{"User-Agent","Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20100101 Firefox/21.0"},
				 {"Connection","close"}]).
-define(SSL_OPTION,[{ssl,[{verify,0}]}]).
-include("crawler.hrl").

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


crawler() ->
	[spawn(fun() -> crawler(P) end) || P <- db:providers()].

crawler(#provider{} = Provider) ->
	Url = binary_to_list(Provider#provider.url),
	io:format("crawler Url: ~p ~n",[Url]),
	case ibrowse:send_req(Url, ?REQ_HEADER, get, [], ?SSL_OPTION, 30000) of
		{ok, _Status, _Headers, Body} ->
			io:format("body ~p ~n",[Body]);
		{error, Msg} ->
		    io:format("crawler error ~p ~n",[Msg]);
		Err ->
		   io:format("unknow error ~p ~n",[Err])
    end.
%%===============================================
init([]) ->
	ssl:start(),
	ibrowse:start(),
	spawn(fun crawler/0),
	{ok,[]}.
	

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
	ibrowse:stop(),
	io:format("********Http client is stopping*****").

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.