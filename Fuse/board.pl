:- use_module(library(lists)).
:- use_module(library(random)).%%for random numbers
:- [utils].
:- [logic].
:- [game].
:- [tests].
:- [score].
:- [ai].
:- [boards].
% BLACK PIECE -> 'b'
% ICE PIECE -> 'i'
% KING BLACK PIECE -> 'B'
% KING ICE PIECE -> 'I'
% PLAYABLE SPACE -> '-'
% UNPLAYABLE SPACE (BORDERS) -> 'x'
% PERIMETER SPACE -> 'p'
% HUMAN PLAYER -> 0 OR 1 (Ice and Black)
% CPU PLAYER -> 2 OR 3  



%gameState(Board,Score,Player,GameMode).
boardInit([
        ['x','p','p','p','p','p','p','x'],
        ['p','-','-','-','-','-','-','p'],
        ['b','-','-','-','-','-','-','p'],
        ['p','-','-','-','-','-','-','p'],
        ['p','-','-','-','-','-','-','p'],
        ['p','-','-','-','-','-','-','p'],
        ['p','-','-','-','-','-','-','p'],
        ['x','p','p','p','p','p','p','x']
        ]).


board_init_phase([
        ['x','b','i','b','b','i','i','x'],
        ['b','-','-','-','-','-','-','b'],
        ['i','-','-','-','-','-','-','i'],
        ['i','-','-','-','-','-','-','b'],
        ['b','-','-','-','-','-','-','i'],
        ['b','-','-','-','-','-','-','b'],
        ['i','-','-','-','-','-','-','i'],
        ['x','i','b','b','i','b','i','x']
        ]).

board_first_move([
        ['x','b','i','b','b','i','i','x'],
        ['b','-','-','-','-','-','-','b'],
        ['i','-','-','-','-','-','-','i'],
        ['b','-','-','-','i','-','b','p'],
        ['i','-','-','-','-','-','-','i'],
        ['b','-','-','-','-','b','-','b'],
        ['i','-','-','-','-','-','-','i'],
        ['x','i','b','b','i','b','i','x']
        ]).

board_second_move([
        ['x','b','i','b','p','i','i','x'],
        ['b','-','-','-','-','-','-','b'],
        ['i','-','-','-','-','-','-','i'],
        ['p','-','-','-','b','-','-','b'],
        ['b','-','-','-','i','-','-','i'],
        ['b','-','-','-','-','-','-','b'],
        ['i','-','-','-','-','-','-','i'],
        ['x','i','b','b','i','b','i','x']
        ]).

board_final_phase([
        ['x','p','p','p','p','i','p','x'],
        ['p','-','-','b','b','b','-','p'],
        ['p','-','i','-','i','i','b','p'],
        ['p','b','b','b','b','b','i','p'],
        ['p','-','-','-','i','b','i','p'],
        ['p','b','i','-','i','i','i','p'],
        ['p','-','-','-','b','i','-','p'],
        ['x','p','p','p','p','p','p','x']
        ]).



%%% VIEW BOARD

print_board([]).
print_board([H|T]) :-
    print_list(H),
    print_board(T).

print_list([]) :-
    nl.
print_list([H|T]) :-
    write(H),
    write(' | '),
    print_list(T).

%%%

display_game(_Board,1):-
    display_game_name,
    print_board(_Board).

%initial_placement(List).


initial_placement([X,Y|List], 0, 0, [X,Y|List], _Iteration):-
    last_two(List,Char,Char2),
    \+ (X == Y,X==Char2),
    \+ (Char2 == Char, Char2 == X).
    %((X == Y, X \== Char2);(Char2 == Char, X \== Char);(X \== Y)).

initial_placement(List, B, I, FinalList, Iteration):-
    random(0,2,RandomNumber),
    Iteration < 2,
    IterationAux is Iteration + 1,
    ((RandomNumber == 1, NewB is B - 1, NewI is I);(
    NewB is B, NewI is I - 1)),
    append([RandomNumber], List, ListAux),
    initial_placement(ListAux ,NewB, NewI, FinalList, IterationAux).

initial_placement([X,Y], B, I, FinalList, 2):-
    random(0,2,RandomNumber),
    (X \== RandomNumber;
    Y \== RandomNumber),
    ((RandomNumber == 1,NewB is B - 1, NewI is I);
    (NewB is B, NewI is I - 1)),
    (append([RandomNumber], [X,Y], ListAux),
    NewB >= 0,
    NewI >= 0,
    initial_placement(ListAux, NewB, NewI, FinalList, 3));
    initial_placement([X,Y], B, I, FinalList, 2).

initial_placement([X,Y], B, I, FinalList, 2):-
    random(0, 2, RandomNumber),
    X =:= RandomNumber,
    Y =:= RandomNumber,
    ((RandomNumber == 0, NewB is B - 1, NewI is I);
    (NewB is B, NewI is I - 1)),
    (((RandomNumber == 1,
    append([0],[X,Y],ListAux));
    append([1],[X,Y],ListAux)),
    NewB >= 0,
    NewI >= 0,
    initial_placement(ListAux, NewB, NewI, FinalList, 3));
    initial_placement([X,Y], B, I, FinalList, 2).

initial_placement([X,Y|List], B, I, FinalList, Iteration):-
    random(0, 2, RandomNumber),
    (X \== RandomNumber;
    Y \== RandomNumber),
    ((RandomNumber == 1,NewB is B - 1, NewI is I);
    (NewB is B, NewI is I - 1)),
    (append([RandomNumber], [X,Y|List], ListAux),
    NewB >= 0,
    NewI >= 0,
    initial_placement(ListAux, NewB, NewI, FinalList, Iteration));
    initial_placement([X,Y|List], B, I, FinalList, Iteration).

initial_placement([X,Y|List], B, I, FinalList, Iteration):-
    random(0, 2, RandomNumber),
    X =:= RandomNumber,
    Y =:= RandomNumber,
    ((RandomNumber == 0, NewB is B - 1, NewI is I);
    (NewB is B, NewI is I - 1)),
    (((RandomNumber == 1,
    append([0], [X,Y|List], ListAux));
    append([1], [X,Y|List], ListAux)),
    NewB >= 0,
    NewI >= 0,
    initial_placement(ListAux, NewB, NewI, FinalList, Iteration));
    initial_placement([X,Y|List], B, I, FinalList, Iteration).

%% b piece -> 1
%% i piece -> 0



%Associate the random output to the piece
% rngToPiece(0, 'i').
% rngToPiece(1, 'b').

% initial_placement(List, ListAux) :-
%     random(0,2,RandomNumber),               %Gerador de um número de 0 a 1
%     initialPlacementAux(RandomNumber, 12, 12, 0, 1, List).


% initialPlacementAux(_, 0, 0, _, _, []).

% initialPlacementAux(0, IceNum, BlackNum, 0, 0, [1|Tail]) :-
%     random(0,2,RandomNumber),               
%     BlackNum > 0,
%     NewBlackNum is BlackNum - 1,
%     initialPlacementAux(RandomNumber, IceNum, NewBlackNum, 1, 0, Tail).

% initialPlacementAux(0, IceNum, BlackNum, 1, 1, [0|Tail]) :- 
%     random(0,2,RandomNumber),  
%     IceNum > 0,             
%     NewIceNum is IceNum - 1,
%     initialPlacementAux(RandomNumber, NewIceNum, BlackNum, 0, 1, Tail).

% initialPlacementAux(0, IceNum, BlackNum, 0, 1, [0|Tail]) :-
%     random(0,2,RandomNumber),
%     IceNum > 0,                          
%     NewIceNum is IceNum - 1,
%     initialPlacementAux(RandomNumber, NewIceNum, BlackNum, 0, 0, Tail).

% initialPlacementAux(0, IceNum, BlackNum, 1, 0, [0|Tail]) :- 
%     random(0,2,RandomNumber), 
%     IceNum > 0,                         
%     NewIceNum is IceNum - 1,
%     initialPlacementAux(RandomNumber, NewIceNum, BlackNum, 0, 1, Tail).

% initialPlacementAux(1, IceNum, BlackNum, 1, 1, [0|Tail]) :-
%     random(0,2,RandomNumber),    
%     IceNum > 0,                      
%     NewIceNum is IceNum - 1,
%     initialPlacementAux(RandomNumber, NewIceNum, BlackNum, 0, 1, Tail).

% initialPlacementAux(1, IceNum, BlackNum, 0, 1, [1|Tail]) :-
%     random(0,2,RandomNumber), 
%     BlackNum > 0,              
%     NewBlackNum is BlackNum - 1,
%     initialPlacementAux(RandomNumber, IceNum, NewBlackNum, 1, 0, Tail).

% initialPlacementAux(1, IceNum, BlackNum, 1, 0, [1|Tail]) :-
%     random(0,2,RandomNumber), 
%     BlackNum > 0,              
%     NewBlackNum is BlackNum - 1,
%     initialPlacementAux(RandomNumber, IceNum, NewBlackNum, 1, 1, Tail).



%%move(InitialX, initialY, )


