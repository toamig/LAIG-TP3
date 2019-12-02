:- use_module(library(between)).
:- [interface].


%WHEN CORRECT LINE REPLACE THE ELEMENT
replace([BoardHead|BoardTail], X, 0, Piece, [NewBoardHead|BoardTail]) :-
    replace_element(BoardHead, X, Piece, NewBoardHead), !.

%REACH CORRECT LINE
replace([BoardHead|BoardTail], X, Y, Piece, [BoardHead|NewBoardTail]) :-
    Y > 0,
    Y1 is Y-1,
    replace(BoardTail, X, Y1, Piece, NewBoardTail).


%REPLACE ELEMENT
replace_element([_|LineTail], 0, Piece, [Piece|LineTail]) :- !.

%COPY LINEHEAD TO NEW LIST
replace_element([LineHead|LineTail], X, Piece, [LineHead|NewBoardTail]) :-
    X > 0,
    X1 is X-1,
    replace_element(LineTail, X1, Piece, NewBoardTail).

     
check_till_position_right(TargetX,_,TargetX,_).
check_till_position_right(StartX,StartY,TargetX,Board):-
    X is StartX + 1,
    get_piece(Board,X,StartY,Piece),
    (Piece == ' ' ; X == TargetX),
    check_till_position_right(X,StartY,TargetX,Board).

check_till_position_left(TargetX,_,TargetX,_).
check_till_position_left(StartX,StartY,TargetX,Board):-
    X is StartX - 1,
    get_piece(Board,X,StartY,Piece),
    (Piece == ' ' ; X == TargetX),
    check_till_position_left(X,StartY,TargetX,Board).

check_till_position_up(_,TargetY,TargetY,_).
check_till_position_up(StartX,StartY,TargetY,Board):-
    Y is StartY - 1,
    get_piece(Board,StartX,Y,Piece),
    (Piece == ' ' ; Y == TargetY),
    check_till_position_up(StartX,Y,TargetY,Board).

check_till_position_down(_,TargetY,TargetY,_).
check_till_position_down(StartX,StartY,TargetY,Board):-
    Y is StartY + 1,
    get_piece(Board,StartX,Y,Piece),
    (Piece == ' ' ; Y == TargetY),
    check_till_position_down(StartX,Y,TargetY,Board).



push_piece_right(Board,TargetX,TargetY,Piece,NewBoard):-
    get_piece(Board,TargetX,TargetY,PushedPiece),
    replace(Board,TargetX,TargetY,Piece,AuxBoard),
    NewX is TargetX + 1,
    NewX =< 6,
    ((PushedPiece == ' ',
    append(AuxBoard,[],NewBoard));
    push_piece_right(AuxBoard,NewX,TargetY,PushedPiece,NewBoard)).

push_piece_down(Board,TargetX,TargetY,Piece,NewBoard):-
    get_piece(Board,TargetX,TargetY,PushedPiece),
    replace(Board,TargetX,TargetY,Piece,AuxBoard),
    NewY is TargetY + 1,
    NewY =< 6,
    ((PushedPiece == ' ',
    append(AuxBoard,[],NewBoard));
    push_piece_down(AuxBoard,TargetX,NewY,PushedPiece,NewBoard)).

push_piece_up(Board,TargetX,TargetY,Piece,NewBoard):-
    get_piece(Board,TargetX,TargetY,PushedPiece),
    replace(Board,TargetX,TargetY,Piece,AuxBoard),
    NewY is TargetY - 1,
    NewY =< 6,
    ((PushedPiece == ' ',
    append(AuxBoard,[],NewBoard));
    push_piece_up(AuxBoard,TargetX,NewY,PushedPiece,NewBoard)).

push_piece_left(Board,TargetX,TargetY,Piece,NewBoard):-
    get_piece(Board,TargetX,TargetY,PushedPiece),
    replace(Board,TargetX,TargetY,Piece,AuxBoard),
    NewX is TargetX - 1,
    NewX =< 6,
    ((PushedPiece == ' ',
    append(AuxBoard,[],NewBoard));
    push_piece_left(AuxBoard,NewX,TargetY,PushedPiece,NewBoard)).



aux_move(Board, 0, StartY, Steps, Piece, NewBoard) :-
    get_piece(Board, Steps, StartY, PushedPiece),
    ((PushedPiece == ' ', replace(Board, Steps, StartY, Piece, NewBoard), !);
    push_piece_right(Board, Steps, StartY, Piece, NewBoard)).

aux_move(Board, StartX, 0, Steps, Piece, NewBoard) :-
    get_piece(Board, StartX, Steps, PushedPiece),
    ((PushedPiece == ' ', replace(Board, StartX, Steps, Piece, NewBoard), !);
    push_piece_down(Board, StartX, Steps, Piece, NewBoard)).

aux_move(Board, StartX, 7, Steps, Piece, NewBoard) :-
    Target is 7 - Steps,
    get_piece(Board, StartX, Target, PushedPiece),
    ((PushedPiece == ' ', replace(Board, StartX, Target, Piece, NewBoard), !);
    push_piece_up(Board, StartX, Target, Piece, NewBoard)).

aux_move(Board, 7, StartY, Steps, Piece, NewBoard) :-
    Target is 7 - Steps,
    get_piece(Board, Target, StartY, PushedPiece),
    ((PushedPiece == ' ', replace(Board, Target, StartY, Piece, NewBoard), !);
    push_piece_left(Board, Target, StartY, Piece, NewBoard)).


move([0, StartY, Steps], Board, NewBoard) :-
    between(1, 6, Steps),
    between(1, 6, StartY),
    check_till_position_right(0, StartY, Steps, Board),
    get_piece(Board, 0, StartY, Piece),
    (Piece == 'i' ; Piece == 'b'),
    aux_move(Board, 0, StartY, Steps, Piece, AuxBoard),
    replace(AuxBoard, 0, StartY, 'P', NewBoard).

move([StartX, 0, Steps], Board, NewBoard) :-
    between(1, 6, Steps),
    between(1, 6, StartX),
    check_till_position_down(StartX, 0, Steps, Board),
    get_piece(Board, StartX, 0, Piece),
    (Piece == 'i' ; Piece == 'b'),
    aux_move(Board, StartX, 0, Steps, Piece, AuxBoard),
    replace(AuxBoard, StartX, 0, 'P', NewBoard).

move([StartX, 7, Steps], Board, NewBoard) :-
    between(1, 6, Steps),
    between(1, 6, StartX),
    Target is 7 - Steps,
    check_till_position_up(StartX, 7, Target, Board),
    get_piece(Board, StartX, 7, Piece),
    (Piece == 'i' ; Piece == 'b'),
    aux_move(Board, StartX, 7, Steps, Piece, AuxBoard),
    replace(AuxBoard, StartX, 7, 'P', NewBoard).

move([7, StartY, Steps], Board, NewBoard) :-
    between(1, 6, Steps),
    between(1, 6, StartY),
    get_piece(Board, 7, StartY, Piece),
    Target is 7 - Steps,
    check_till_position_left(7, StartY, Target, Board),
    (Piece == 'i' ; Piece == 'b'),
    aux_move(Board, 7, StartY, Steps, Piece, AuxBoard),
    replace(AuxBoard, 7, StartY, 'P', NewBoard).


%game_loop

%game_loop(Board, Score, Player, GameMode) :-
    %possibleMoves(Board, Score),


%possibleMoves


valid_moves(Board, Player, ListOfMoves) :-
    get_player_piece(Player, PlayerPiece),
    setof(NewBoard, X^Y^Steps^(move([X, Y, Steps], Board, NewBoard), get_piece(Board, X, Y, Piece), Piece == PlayerPiece), ListOfMoves).

valid_moves(Board, ListOfMoves) :-
    setof(NewBoard, X^Y^Steps^move([X, Y, Steps], Board, NewBoard), ListOfMoves).

    
game_over(Board,Winner):-
    \+valid_moves(Board,  _ListOfMoves),
    value(Board,[IceScore,BlackScore]),
    IceScore > BlackScore,
    Winner = 'i',
    print_board(Board),
    nl,nl,
    write('The Ice Pieces Won'),
    nl.
    

game_over(Board,Winner):-
    \+valid_moves(Board, _ListOfMoves),
    value(Board,[IceScore,BlackScore]),
    IceScore < BlackScore,
    Winner = 'b',
    print_board(Board),
    nl,nl,
    write('The Black Pieces Won'),
    nl.

game_over(Board,Winner):-
    \+valid_moves(Board,  _ListOfMoves),
    value(Board,[IceScore,BlackScore]),
    IceScore == BlackScore,
    Winner = 'Tie',
    print_board(Board),
    nl,nl,
    write('The game ended as a tie!'),
    nl.

