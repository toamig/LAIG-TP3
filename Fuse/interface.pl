display_game_name :- 
    nl, 
    write(' ______   __  __     ______     ______    '), nl,
    write('/\\  ___\\ /\\ \\/\\ \\   /\\  ___\\   /\\  ___\\   '), nl,
    write('\\ \\  __\\ \\ \\ \\_\\ \\  \\ \\___  \\  \\ \\  __\\   '), nl,
    write(' \\ \\_\\    \\ \\_____\\  \\/\\_____\\  \\ \\_____\\ '), nl,
    write('  \\/_/     \\/_____/   \\/_____/   \\/_____/ '), nl, 
    nl.

%GET INPUT FROM USER
get_input(Variable,Char):-
    format('~w: ',Variable),
    read(Char),
    number(Char).

%SELECT GAME MODE
select_mode(GameMode,Level1,Level2):-
    nl,
    write('1 - Player vs Player'), nl,
    write('2 - Player vs Computer'), nl,
    write('3 - Computer vs Computer'), nl,
    read(GameMode),
    ((GameMode == 1,
    Level1 is 0,
    Level2 is 0);
    (GameMode == 2,
    choose_ai_level(Level1),
    Level2 is 0);
    (GameMode == 3,
    choose_ai_level(Level1),
    choose_ai_level(Level2))),
    nl.

greet_player(Player):-
    nl,
    format('Player ~w Turn',Player),
    nl.

choose_ai_level(Level):-
    write('Choose Ai Level from 1 to 3: '),
    read(Level),
    nl.


%START GAME
play:-
    display_game_name,
    select_mode(GameMode,CPU1,CPU2),
    select_board(Board),
    choose_starting_player(GameMode,Player),
    game_loop(Board, Player, GameMode,CPU1,CPU2).
