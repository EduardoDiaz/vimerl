-module(indenter).

-compile(export_all).

read_file(File) ->
    {ok, Bin} = file:read_file(File),
    binary_to_list(Bin).

tokenize_file(File) ->
    tokenize_source(read_file(File)).

tokenize_source(Source) ->
    eat_shebang(tokenize(Source)).

tokenize(Source) ->
    {ok, Tokens, _} = erl_scan:string(Source),
    Tokens.

eat_shebang([{'#', N}, {'!', N} | Tokens]) ->
    lists:dropwhile(fun(T) -> line(T) == N end, Tokens);
eat_shebang(Tokens) -> Tokens.

take_tokens_block(Tokens, N) when N < 1 ->
    error(badarg, [Tokens, N]);
take_tokens_block(Tokens, N) ->
    PrevToks = lists:reverse(lists:takewhile(fun(T) -> line(T) < N end, Tokens)),
    lists:reverse(lists:takewhile(fun(T) -> type(T) /= dot end, PrevToks)).

type(Token) -> element(1, Token).

line(Token) -> element(2, Token).

%%% ----------------------------------------------------------------------------
%%% Tests
%%% ----------------------------------------------------------------------------

-define(TEST_SOURCE, "
#!/usr/bin/env escript

%%%
%%% Comment
%%%

-define(FOO, 666).

foo(N) -> % Shit!
    ?FOO + 1.

bar() ->
    Y = 123, % Line 14
    {ok, Y}.
").

tokenize_source_test() ->
    io:format("~p~n", [tokenize_source(?TEST_SOURCE)]).

take_tokens_block_test() ->
    io:format("~p~n", [take_tokens_block(tokenize_source(?TEST_SOURCE), 14)]).
