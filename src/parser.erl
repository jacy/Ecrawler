-module(parser).
-compile(export_all).
-include_lib("xmerl/include/xmerl.hrl").
-include("crawler.hrl").


parse(10001, Body) ->
	case extract(Body, "<input[^>]*name=\"kr\"[^>]*value=\"([^\"]*)\"") of
		nomatch -> io:format("Can not parse content for KENO:Australia with body ~n ~p ~n", [Body]);
		Value -> keno_australia(Value)
	end.

keno_australia(Data) ->
	Lotterys =split(Data, ":"),
	lists:map(fun(Item) ->
					  [H | R] = split(Item, ";"),
					  [Drawno | _] = split(H, ","),
					  #lottery{drawno= Drawno,result= sort_string_as_inter(R)}
				end,Lotterys).


sort_string_as_inter(R) ->
	Results = split(R, ","),
	SortedResult = lists:sort(fun(A,B) ->
					   list_to_integer(A) =< list_to_integer(B)
					   end, Results),
	string:join(SortedResult,",").
	


%% =====================================================================
%% Parser Utils
%% =====================================================================
timestamp_millisecs() ->
	{MegaSecs,Secs,MicroSecs} = now(),
        ((MegaSecs*1000000 + Secs)*1000000 + MicroSecs)/1000. 

split(Data, Delimiter) ->
	split(Data, Delimiter,list).

split(Data, Delimiter,ReturnType) ->
	case re:split(Data, Delimiter, [{return,ReturnType},trim]) of
		[Data] -> [Data];
		Items -> Items
	end.

extract(Content,Regex) ->
	extract(Content,Regex,1).

extract(Content,Regex,ReturnGroup) ->
	case re:run(Content, Regex,[global,{capture,[ReturnGroup],list}]) of
		nomatch -> 
			nomatch;
		{match,[[Result]]} -> Result
	end.

	