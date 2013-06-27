-module(crawler).
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-define(REQ_HEADER, [{"User-Agent","Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20100101 Firefox/21.0"},{"Connection","close"}]).
-define(SSL_OPTION,[{ssl,[{verify,0}]}]).
-include("crawler.hrl").

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


crawler() ->
	[spawn(fun() -> crawler(P,1) end) || P <- db:providers()].

crawler(#provider{url = U, id=Id, interval=Interval} = P, Count) ->
	Url = binary_to_list(U),
	io:format("~p Crawl ~pth round for url: ~p ~n",[nowstring(),Count, Url]),
	case ibrowse:send_req(Url, ?REQ_HEADER, get, [], ?SSL_OPTION, 30000) of
		{ok, _Status, _Headers, Body} ->
			Results = parser:parse(Id, Body),
			db:save_result(Id, Results),
			io:format("Get lotters: ~n ~p ~n",[Results]);
		{error, Msg} ->
			io:format("Crawl get error ~p ~n",[Msg]);
		Err ->
			io:format("Crawl get unknow error ~p ~n",[Err])
    end,
	timer:sleep(Interval * 1000),
	crawler(P, Count + 1).
%%===============================================
init([]) ->
	ssl:start(),
	ibrowse:start(),
	spawn(fun crawler/0),
	{ok,[]}.

nowstring() ->
	{Y,Mon,D} = date(),
	{H,M,S} = time(),
	lists:concat([Y,"-",Mon,"-",D," ",H,":",M,":",S," "]).

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
	io:format("********Http client is stopping*****~n"),
	ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.