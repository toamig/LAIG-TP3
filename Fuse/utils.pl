:- use_module(library(clpfd)).
:- use_module(library(lists)).
%GETS THE PLAYER'S CORRESPONDING PIECE

get_player_piece(0,'i').

get_player_piece(1,'b').

get_player_piece(2,'i').

get_player_piece(3, 'b').

%get_adversary(Player,Adversary)
get_adversary(Player,Adversary):-
    Aux is Player mod 2,
    AuxAdversary is Aux + 1,
    Adversary is AuxAdversary mod 2.
    
%% Rotates a given matrix N times clockwise 

rotate_clockwise(Matrix, N, Rotated) :-
    N_mod_4 #= N mod 4,
    rotate_clockwise_(N_mod_4, Matrix, Rotated).

rotate_clockwise_(0, M, M).
rotate_clockwise_(1, M, R) :-
    transpose(M, R0),
    maplist(reverse, R0, R).
rotate_clockwise_(2, M, R) :-
    reverse(M, R0),
    maplist(reverse, R0, R).
rotate_clockwise_(3, M, R) :-
    transpose(M, R0),
    reverse(R0, R).

%% Gets the last two elements of a list

either(Variable,TryOne,TryTwo):-
    Variable == TryOne;
    Variable == TryTwo.

last_two([X,Y],X,Y).

last_two([_|Tail],Char,Char2) :-
    last_two(Tail,Char,Char2).

% choose_starting_player(GameMode,Player)
choose_starting_player(1,Player) :-
    Player = 0.

choose_starting_player(2,Player)  :-
    Player = 0.

choose_starting_player(3,Player) :-
    Player = 2.
% change_player(Player,GameMode,NewPlayer).
change_player(0,1,1).
change_player(1,1,0).
change_player(0,2,3).
change_player(3,2,0).
change_player(2,3,3).
change_player(3,3,2).
%%get_line_board_right(N, Board, Line) :-

%Prints a given list of moves

print_list_of_moves([]).

print_list_of_moves([Head|Tail]) :-
    print_board(Head),
    nl,
    print_list_of_moves(Tail).

%Gets the borders of a given Board

get_borders(Board, Borders) :-
    get_top_border(Board, TopBorder),
    append([], TopBorder, AuxList1),
    get_right_border(Board, RightBorder),
    append(AuxList1, RightBorder, AuxList2),
    get_bottom_border(Board, BottomBorder),
    append(AuxList2, BottomBorder, AuxList3),
    get_left_border(Board, LeftBorder),
    append(AuxList3, LeftBorder, Borders).


get_top_border(Board, TopBorder) :-
    get_board_head(Board, TopBorder).

get_right_border(Board, RightBorder) :-
    rotate_clockwise(Board, 3, RotatedBoard),
    get_board_head(RotatedBoard, RightBorder).

get_bottom_border(Board, BottomBorder) :-
    rotate_clockwise(Board, 2, RotatedBoard),
    get_board_head(RotatedBoard, BottomBorder).

get_left_border(Board, LeftBorder) :-
    rotate_clockwise(Board, 1, RotatedBoard),
    get_board_head(RotatedBoard, LeftBorder).

get_board_head([BoardHead|_], BoardHead).

%Gets the piece in those coordinates for a given board

get_piece(Mat, Col, Row, Val) :- 
    between(0, 7, Row),
    between(0, 7, Col),
    nth0(Row, Mat, ARow), 
    nth0(Col, ARow, Val).

%Removes head of a list

remove_head([_|Tail], Tail).

%Gets the inner board (6 x 6) of a given board

get_inner_board(Board, InnerBoard) :-
    remove_head(Board, AuxBoard),
    rotate_clockwise(AuxBoard, 1, RotatedAux),
    remove_head(RotatedAux, AuxBoard2),
    rotate_clockwise(AuxBoard2, 1, RotatedAux2),
    remove_head(RotatedAux2, AuxBoard3),
    rotate_clockwise(AuxBoard3, 1, RotatedAux3),
    remove_head(RotatedAux3, AuxBoard4),
    rotate_clockwise(AuxBoard4, 1, InnerBoard).



