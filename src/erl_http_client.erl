-module(erl_http_client).
-compile(export_all).

demo() ->
	inets:start(),
	httpc:request(get,
				  {	"http://www.google.com", 
				   	[
					 {"connection", "close"}
					]
				  },
				  [],
				  []).