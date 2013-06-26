-module(ecrawler_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ecrawler_sup:start_link().

stop(_State) ->
    exit(whereis(ecrawler_sup), shutdown).
