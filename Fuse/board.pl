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
% PLAYABLE SPACE -> ' '
% UNPLAYABLE SPACE (BORDERS) -> 'X'
% PERIMETER SPACE -> 'P'
% HUMAN PLAYER -> 0 OR 1 (Ice and Black)
% CPU PLAYER -> 2 OR 3  



%gameState(Board,Score,Player,GameMode).
boardInit([
        ['X','P','P','P','P','P','P','X'],
        ['P',' ',' ',' ',' ',' ',' ','P'],
        ['b',' ',' ',' ',' ',' ',' ','P'],
        ['P',' ',' ',' ',' ',' ',' ','P'],
        ['P',' ',' ',' ',' ',' ',' ','P'],
        ['P',' ',' ',' ',' ',' ',' ','P'],
        ['P',' ',' ',' ',' ',' ',' ','P'],
        ['X','P','P','P','P','P','P','X']
        ]).


board_init_phase([
        ['X','b','i','b','b','i','i','X'],
        ['b',' ',' ',' ',' ',' ',' ','b'],
        ['i',' ',' ',' ',' ',' ',' ','i'],
        ['i',' ',' ',' ',' ',' ',' ','b'],
        ['b',' ',' ',' ',' ',' ',' ','i'],
        ['b',' ',' ',' ',' ',' ',' ','b'],
        ['i',' ',' ',' ',' ',' ',' ','i'],
        ['X','i','b','b','i','b','i','X']
        ]).

board_first_move([
        ['X','b','i','b','b','i','i','X'],
        ['b',' ',' ',' ',' ',' ',' ','b'],
        ['i',' ',' ',' ',' ',' ',' ','i'],
        ['b',' ',' ',' ','i',' ','b','P'],
        ['i',' ',' ',' ',' ',' ',' ','i'],
        ['b',' ',' ',' ',' ','b',' ','b'],
        ['i',' ',' ',' ',' ',' ',' ','i'],
        ['X','i','b','b','i','b','i','X']
        ]).

board_second_move([
        ['X','b','i','b','P','i','i','X'],
        ['b',' ',' ',' ',' ',' ',' ','b'],
        ['i',' ',' ',' ',' ',' ',' ','i'],
        ['P',' ',' ',' ','b',' ',' ','b'],
        ['b',' ',' ',' ','i',' ',' ','i'],
        ['b',' ',' ',' ',' ',' ',' ','b'],
        ['i',' ',' ',' ',' ',' ',' ','i'],
        ['X','i','b','b','i','b','i','X']
        ]).

board_final_phase([
        ['X','P','P','P','P','i','P','X'],
        ['P',' ',' ','b','b','b',' ','P'],
        ['P',' ','i',' ','i','i','b','P'],
        ['P','b','b','b','b','b','i','P'],
        ['P',' ',' ',' ','i','b','i','P'],
        ['P','b','i',' ','i','i','i','P'],
        ['P',' ',' ',' ','b','i',' ','P'],
        ['X','P','P','P','P','P','P','X']
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


