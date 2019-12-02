:- use_module(library(random)).
:- use_module(library(lists)).
:- [utils].

choose_move(Board, Player, 1, Move) :-
    random_ai(Board, Player, Move).

choose_move(Board, Player, 2, Move) :-
    value(Board,Player,Value),
    minimax(7, Board, Player, Value, Move).

choose_move(Board, Player, 3, Move) :-
    minimax(23, Board, Player, Value, Move).

random_ai(Board, Player, NewBoard):-
    valid_moves(Board,Player,ListofMoves),
    length(ListofMoves,Number),
    random(0,Number,RandomNumber),
    nth0(RandomNumber,ListofMoves,NewBoard).

random_ai(Board, Player, Board).

bot_turn(Board, Player, Depth, NewBoard) :-
    nl, write('Player '), write(Player), write(' turn:'),nl,
    valid_moves(Board, Player, Moves),
    get_winning_move(Moves, Player, WinningMove),
    NewBoard = WinningMove, !.
  
bot_turn(Board, Player, Depth, NewBoard) :-
    nl, write('Player '), write(Player), write(' turn:'),nl,
    valid_moves(Board, Player, Moves),
    minmax(Depth, Player, Board, NewBoard), !.


minimax( Pos, Player, BestSucc, Val)  :-
    moves( Pos, Player, PosList), !,               % Legal moves in Pos produce PosList
    best( PosList, Player, BestSucc, Val);
    staticval( Pos, Val).                           % Pos has no successors: evaluate statically 
  
best([Pos], Player, Pos, Val)  :-
    minimax( Pos, Player, _, Val), !.
  
best([Pos1 | PosList], BestPos, BestVal)  :-
    minimax( Pos1, _, Val1),
    best( PosList, Pos2, Val2),
    betterof( Pos1, Val1, Pos2, Val2, BestPos, BestVal).
  
betterof( Pos0, Val0, Pos1, Val1, Pos0, Val0)  :-        % Pos0 better than Pos1
    min_to_move( Pos0),                                    % MIN to move in Pos0
    Val0 > Val1, !                                         % MAX prefers the greater value
    ;
    max_to_move( Pos0),                                    % MAX to move in Pos0
    Val0 < Val1, !.                                % MIN prefers the lesser value 
  
betterof( Pos0, Val0, Pos1, Val1, Pos1, Val1).    



%RETURNS IF THERE IS A WINNING MOVE 
get_winning_move([], _, _) :- !, fail.

get_winning_move([Head|NextPlays], Player, Board) :-
    get_player_piece(Player, Piece),
    game_over(Head, Piece), 
    Board = Head.
    
get_winning_move([Head|NextPlays], Player, Board) :-
    get_player_piece(Player, Piece),
    get_winning_move(NextPlays, Board).

/* Uses:
   move(+Pos, -Move) :-
      Move is a legal move in position Pos.

   move(+Move, +Pos, -Pos1) :-
      Making Move in position Pos results in position Pos1.

   value(+Pos, -V) :-
      V is the static value of position Pos for player 1.
      Should be between -999 and +999, where +999 is best for player 1.
*/

minimax(Board, NewBoard, Depth) :- minimax(Depth, Pos, 1, _, NewBoard).

/* minimax(+Depth, +Position, +Player, -BestValue, -BestMove) :-
      Chooses the BestMove from the from the current Position
      using the minimax algorithm searching Depth ply ahead.
      Player indicates if this move is by player (1) or opponent (-1).
*/
minimax(0, Board, Player, Value, _) :- 
      value(Board,Player,Value).
minimax(D, Board, Player, Value, NewBoard) :-
      D > 0, 
      D1 is D - 1,
      valid_moves(Board,Player,Moves),
      minimax(Moves, Board, D1, Player, -1000, nil, Value, NewBoard).


/* minimax(+Moves,+Position,+Depth,+Player,+Value0,+Move0,-BestValue,-BestMove)
      Chooses the Best move from the list of Moves from the current Position
      using the minimax algorithm searching Depth ply ahead.
      Player indicates if we are currently minimizing (-1) or maximizing (1).
      Move0 records the best move found so far and Value0 its value.
*/
minimax([], _, _, _, Value, Best, Value, Best).
minimax([Move|Moves],Position,D,Player, Value0,Move0,BestValue,BestMove):-
      move(Move, Position, Position1), 
      get_adversary(Player,Opponent),
      minimax(D, Position1, Opponent, OppValue, _OppMove), 
      Value is -OppValue,
      ( Value > Value0 ->        
        minimax(Moves,Position,D,Player, Value ,Move ,BestValue,BestMove)
      ; minimax(Moves,Position,D,Player, Value0,Move0,BestValue,BestMove)
      ). 
      
