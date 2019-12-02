:- use_module(library(random)).
:- [utils].

%Calculate board score

:- dynamic cell/2.
:- dynamic count/1.
:- dynamic max/1.

%values(Board, [IceScore,BlackScore]).


value(Board, [IceScore,BlackScore]):-
    value(Board, 0, IceScore),
    value(Board, 1, BlackScore).

value(Board, Player, HighestScore) :-
    get_inner_board(Board, InnerBoard),
    get_player_piece(Player, PlayerPiece),
    \+ clearCells,
    set_max,
    iterate_board(InnerBoard, InnerBoard, PlayerPiece, 0, 0), !,
    max(Max),
    HighestScore is Max.
    
iterate_board(_InnerBoard, [], _Piece, _X, _Y).

iterate_board(InnerBoard, [Head|Tail], Piece, X, Y) :-
    iterate_line(InnerBoard, Head, Piece, X, Y),
    NewX is 0,
    NewY is Y + 1,
    iterate_board(InnerBoard, Tail, Piece, NewX, NewY).

iterate_line(_InnerBoard, [], _Piece, _X, _Y).

iterate_line(InnerBoard, [Piece|Tail], Piece, X, Y) :-
    asserta(cell(X, Y)), 
    set_count,
    update_count,
    \+aux_value(InnerBoard, Piece, X, Y), 
    update_max,
    NewX is X + 1,
    iterate_line(InnerBoard, Tail, Piece, NewX, Y).    

iterate_line(InnerBoard, [_Head|Tail], Piece, X, Y) :-
    NewX is X + 1,
    iterate_line(InnerBoard, Tail, Piece, NewX, Y). 

aux_value(Board, Piece, X, Y) :-
	random(0, 4, Dir),                                  %Random direction between 0 and 3
	nextcell(Dir, X, Y, NewX, NewY),
    get_piece(Board, NewX, NewY, NewPiece),
    NewPiece == Piece,
    update_count,
	asserta(cell(NewX, NewY)),
    aux_value(Board, Piece, NewX, NewY),!.

nextcell(Dir, X, Y, X1, Y1) :-
	(	next(Dir, X, Y, X1, Y1));
	(   Dir1 is (Dir+3) mod 4,
	    next(Dir1, X, Y, X1, Y1));
	(   Dir2 is (Dir+1) mod 4,
	    next(Dir2, X, Y, X1, Y1));
	(   Dir3 is (Dir+2) mod 4,
	    next(Dir3, X, Y, X1, Y1)).
 
% 0 => Up
next(0, X, Y, X, Y1) :-
	Y > 0,
	Y1 is Y - 1,
	\+cell(X, Y1).
 
% 1 => Right
next(1, X, Y, X1, Y) :-
	X < 5,
	X1 is X + 1,
	\+cell(X1, Y).
 
% 2 => Down
next(2, X, Y, X, Y1) :-
	Y < 5,
	Y1 is Y + 1,
	\+cell(X, Y1).
 
% 3 => Left
next(3, X, Y, X1, Y) :-
	X > 0,
	X1 is X - 1,
	\+cell(X1, Y).

clearCells :-
	cell(X, Y),
	retract(cell(X, Y)),
	fail.

update_count :-
    count(Count),
    NewCount is Count + 1,
    retract(count(Count)),
    asserta(count(NewCount)).

set_count :-   
    \+count(_Count),
    asserta(count(0)).

set_count :-   
    count(Count),
    retract(count(Count)),
    asserta(count(0)).

set_max :-
    \+max(_Max),
    asserta(max(0)).

set_max :-
    max(Max),
    retract(max(Max)),
    asserta(max(0)).

update_max :-
    \+max(_Max),
    count(Count),
    asserta(max(Count)).

update_max :-
    max(Max),
    count(Count),
    Count > Max,
    retract(max(Max)),
    asserta(max(Count)).

