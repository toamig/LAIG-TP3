var GameMode = {PVP:1,PVB:2,BVB:3};

/**
 * Game class, representing the game logic.
 */
class Game {
    /**
     * @constructor
     */
    constructor(scene) {
        this.scene = scene;
        this.inited = false;
        this.mode = GameMode.PVP;
        this.pieces = this.scene.graph.primitives['pieces'];
        this.server = new Connection();
        this.botLevel = 1;
        this.points = [0,0];
        this.pieceSelected = false;
        this.selectedPiece = null;
        this.initBoard();
    }

    start(){
        if(this.mode == GameMode.BVB){
            this.botAction = true;
        }
        this.inited = true;
    }

    initBoard() {
        if(this.inMovie){
            this.inMovie = false;
        }
        if(this.animationRunning == true){
            this.ani_FinalAction = "reset";
        }
        else{
            this.botAction = false;
            this.terminated = false;
            this.winner = 'none';
            this.boards = [];
            this.movesArray = [];
            this.validMoves = [];
            this.validIDs = [];
            this.boardIndex = 0;
            this.playerTurn = "icePlayer";
            this.tempPTurn = "none";
            this.animationRunning = false;
            let reply = function(data) {
                this.boards.push(data);
                this.pieces.storePieces(data);
                if(this.mode == GameMode.BVB){
                    this.botAction = true;
                }
                if(this.scene.gameInterface){
                this.scene.gameInterface.resetTimer();
                }
                dispatchEvent(new CustomEvent('gameLoaded', { detail: data }));
            };
            let request = this.server.createRequest('initial_board', null, reply.bind(this));
            return this.server.prologRequest(request);
        }

    }

    updateScore(){
        let reply = function(data) {
            this.points = data;
            dispatchEvent(new CustomEvent('gameLoaded', { detail: data }));
        };
        let request = this.server.createRequest('score', this.getBoardString(), reply.bind(this));
        return this.server.prologRequest(request);
    }

    select(command){
        if(!this.inited){
            return;
        }

        var jsonCommand = JSON.stringify(command);
        var icePieces = JSON.stringify(this.pieces.icePieces);
        var blackPieces = JSON.stringify(this.pieces.blackPieces);

        var c;

        if(this.playerTurn == "icePlayer" && (c = icePieces.indexOf(jsonCommand)) != -1){
            this.pieceSelected = true;
            this.selectedPiece = command;
            this.updateValidMoves();
        }
        else if(this.playerTurn == "blackPlayer" && (c = blackPieces.indexOf(jsonCommand)) != -1){
            this.pieceSelected = true;
            this.selectedPiece = command;
            this.updateValidMoves();
        }
        else{
            return;
        }
    }

    move(command){

        if(!this.inited){
            return;
        }

        this.updateScore();
        let reply = function(data) {
            this.addBoard(data);
            dispatchEvent(new CustomEvent('gameLoaded', { detail: data }));
        };
        let startX = this.selectedPiece[1];
        let startY = this.selectedPiece[0];
        if(startX == 0 || startX == 7){
            var steps = Math.abs(command[1] - startX);
            if(startY != command[0]){
                this.pieceSelected = false;
                return false;
            }
        }
        if(startY == 0 || startY == 7){
            var steps = Math.abs(command[0] - startY);
            if(startX != command[1]){
                this.pieceSelected = false;
                return false;
            }
        }
        let move = [startX,startY,steps];
        let request = this.server.createRequest('move', [this.getMoveString(move),this.getBoardString()], reply.bind(this));
        //this.setupAnimationVars(direction, coord);
        this.pieceSelected = false;
        return this.server.prologRequest(request);
        
    }

    setupAnimationVars(direction, coord){
        let currTurn = this.movesArray.length-1;
        this.ani_Dir = direction
        this.ani_Index = parseInt(coord);
        this.ani_firstIte = true;
        this.ani_term = false;
        this.ani_changeT = false;
        this.ani_winner = "none";
        this.calcBoardDif(this.ani_Dir, this.ani_Index-1, this.boards[currTurn]);

        this.animationRunning = true;
    }

    setupAnimationVarsMovie(direction, coord, currTurn){
        this.ani_Dir = direction
        this.ani_Index = parseInt(coord);
        this.ani_firstIte = true;
        this.ani_term = false;
        this.ani_changeT = false;
        this.ani_winner = "none";
        this.ani_ValidMoves = [];
        this.calcBoardDif(this.ani_Dir, this.ani_Index-1, this.boards[currTurn]);

        this.animationRunning = true;
    }

    calcBoardDif(dir, index, oldBoard){
        let count;
        let cell;
        this.ani_PiecesCoords = [];
        switch (dir) {
            case "l":
                count = 0;
                cell = oldBoard[18-index][count];
                while(cell == " "){
                    count++;
                    cell = oldBoard[18-index][count];
                }
                if(oldBoard[18-index][count+1] == " "){
                    this.ani_PiecesCoords.push([18-index+1,count+1], [18-index+1, count+2]);
                    this.ani_PieceColor = oldBoard[18-index][count];
                }
                else{
                    this.ani_PiecesCoords.push([18-index+1,count]);
                }
                this.ani_nSpaces = count;
                break;

            case "r":
                count = 18;
                cell = oldBoard[18-index][count];
                while(cell == " "){
                    count--;
                    cell = oldBoard[18-index][count];
                }
                if(oldBoard[18-index][count-1] == " "){
                    this.ani_PiecesCoords.push([18-index+1,count+1], [18-index+1, count]);
                    this.ani_PieceColor = oldBoard[18-index][count];
                }
                else{
                    this.ani_PiecesCoords.push([18-index+1, count+2]);
                }
                this.ani_nSpaces = 18-count;
                break;

            case "u":
                count = 0;
                cell = oldBoard[count][index];
                while(cell == " "){
                    count++;
                    cell = oldBoard[count][index];
                }
                if(oldBoard[count+1][index] == " "){
                    this.ani_PiecesCoords.push([count+1,index+1], [count+2, index+1]);
                    this.ani_PieceColor = oldBoard[count][index];
                }
                else{
                    this.ani_PiecesCoords.push([count,index+1]);
                }
                this.ani_nSpaces = count;
                break;

            case "d":
                count = 18;
                cell = oldBoard[count][index];
                while(cell == " "){
                    count--;
                    cell = oldBoard[count][index];
                }
                if(oldBoard[count-1][index] == " "){
                    this.ani_PiecesCoords.push([count+1,index+1], [count, index+1]);
                    this.ani_PieceColor = oldBoard[count][index];
                }
                else{
                    this.ani_PiecesCoords.push([count+2, index+1]);
                }
                this.ani_nSpaces = 18-count;
                break;     
        }

        this.ani_pTurn = this.playerTurn;
        if(this.tempPTurn != "none"){
            this.ani_pTurn = this.tempPTurn;
            this.tempPTurn = "none";
        }

    }

    undo(){ 
        if(!this.animationRunning){
            if(!this.inMovie){
                if(this.boardIndex > 0){
                    this.boards.pop();
                    this.movesArray.pop();
                    this.boardIndex--;
                    this.pieces.storePieces(this.boards[this.boardIndex]);
                    this.nextTurn();
                }
            }
        }
        else{
            this.ani_FinalAction = "undo";
        }
    }

    gameover(){
        let reply = function(data) {
            console.log(data);
            this.winner = data;
            if(this.winner == 'i' || this.winner == 'b' || this.winner == 'tie' ){
                if(!this.animationRunning){
                    this.terminated = true;
                    this.validIDs = [];
                    //this.showWinner();
                }
                else{
                    this.terminated = false;
                    this.ani_term = true;
                }
            }
            dispatchEvent(new CustomEvent('gameLoaded', { detail: data }));
        };
        let request = this.server.createRequest('game_over', [this.getBoardString()], reply.bind(this));
        return this.server.prologRequest(request);
    }

    timeout(){
        if(this.playerTurn == "icePlayer"){
            // this.winner = "blackPlayer";
            this.winner = "b";

        }
        else{
            // this.winner = "icePlayer";
            this.winner = "b";
        }
        this.terminated = true;
        this.validIDs = [];
    }

    playBot(){
        this.tempPTurn = this.playerTurn;
        let reply = function(data) {
            let command = data[0][0] + data[0][1];
            this.movesArray.push(command);
            let direction = command.charAt(0);
            let coord = command.substr(1);
            this.setupAnimationVars(direction, coord);
            this.addBoard(data[1]);
            dispatchEvent(new CustomEvent('gameLoaded', { detail: data }));
        };
        let request = this.server.createRequest('play_bot', [this.playerTurn,this.botLevel,this.getBoardString()], reply.bind(this));
        return this.server.prologRequest(request);
    }

    updateValidMoves() {
        let reply = function(data) {
            if(!this.animationRunning){
                this.validMoves = data;
                this.validIDs = [];
                this.validMoves.forEach(element => {
                    this.validIDs.push(this.getValidId(element));
                });
            }
            else{
                this.ani_ValidMoves = data;
            }

            dispatchEvent(new CustomEvent('gameLoaded', { detail: data }));
        };
        if (this.playerTurn == "icePlayer"){
            var player = 1
        }
        else{
            var player = 2;
        }
        let request = this.server.createRequest('valid_moves', [this.getBoardString(),JSON.stringify(this.selectedPiece)], reply.bind(this));
        this.server.prologRequest(request);
    }

    getBoardString() {
        return JSON.stringify(this.boards[this.boardIndex]);
    }

    getMoveString(move){
        return JSON.stringify(move);
    }

    botTurn(){
        if(this.botAction && !this.terminated && !this.animationRunning){
            this.botAction = false;
            this.playBot();
        }
    }

    nextTurn(){
        if(!this.animationRunning){
            this.changeTurn();
            if(this.mode == GameMode.BVB || (this.mode == GameMode.PVB && this.playerTurn == "blackPlayer")){
                this.botAction = true;
            }
        }
        else{
            this.ani_changeT = true;
        }

    }

    changeTurn(){
        if(this.playerTurn == "icePlayer"){
            this.playerTurn = "blackPlayer";
        }
        else{
            this.playerTurn = "icePlayer";
        }


    }


    play(pickId){
        if(!this.animationRunning && this.inited){
            if(this.mode == GameMode.PVP || (this.mode == GameMode.PVB && this.playerTurn == "icePlayer")){
                let command = this.pickingTranslator(pickId);

                if(pickId > 0 && pickId <= 24){
                    this.select(command);
                }
                else if(pickId <= 60 && this.pieceSelected){
                    this.move(command);
                }
            }
        }
    }

    async playGameMovie(){
        this.inMovie = true;
        this.terminated = true;
        this.validMoves = [];
        this.validIDs = [];
        this.playerTurn = "icePlayer";
        this.animationRunning = false;
        this.pieces.storePieces(this.boards[0]);

        for(let i = 1; i < this.boards.length; i++){
            this.movieIndex = i;
            let command = this.movesArray[i-1];
            let direction = command.charAt(0);
            let coord = command.substr(1);
            this.setupAnimationVarsMovie(direction, coord, i-1);
            await this.sleep(this.ani_totalTime*1100);
            this.pieces.storePiecesMovie(this.boards[i]);
            this.changeTurn();
        
        }
        this.inMovie = false;
        this.playerTurn = "icePlayer";
    }

    addBoard(board){
        if(board != null && board != []){
            this.boardIndex++;
            this.boards.push(board);
            this.pieces.storePieces(board);
            this.gameover();
            this.nextTurn();
        }
    }

    pickingTranslator(index) {
        let command;
        switch (index) {
            case 1:
                command = [0,1];
                break;
            case 2:
                command = [0,2];
                break;
            case 3:
                command = [0,3];
                break;
            case 4:
                command = [0,4];
                break;
            case 5:
                command = [0,5];
                break;
            case 6:
                command = [0,6];
                break;
            case 7:
                command = [1,7];
                break;
            case 8:
                command = [2,7];
                break;
            case 9:
                command = [3,7];
                break;
            case 10:
                command = [4,7];
                break;
            case 11:
                command = [5,7];
                break;
            case 12:
                command = [6,7];
                break;
            case 13:
                command = [7,6];
                break;
            case 14:
                command = [7,5];
                break;
            case 15:
                command = [7,4];
                break;
            case 16:
                command = [7,3];
                break;
            case 17:
                command = [7,2];
                break;
            case 18:
                command = [7,1];
                break;
            case 19:
                command = [6,0];
                break;
            case 20:
                command = [5,0];
                break;
            case 21:
                command = [4,0];
                break;
            case 22:
                command = [3,0];
                break;
            case 23:
                command = [2,0];
                break;
            case 24:
                command = [1,0];
                break;
            case 25:
                command = [1,1];
                break;
            case 26:
                command = [1,2];
                break;
            case 27:
                command = [1,3];
                break;
            case 28:
                command = [1,4];
                break;
            case 29:
                command = [1,5];
                break;
            case 30:
                command = [1,6];
                break;
            case 31:
                command = [2,1];
                break;
            case 32:
                command = [2,2];
                break;
            case 33:
                command = [2,3];
                break;
            case 34:
                command = [2,4];
                break;
            case 35:
                command = [2,5];
                break;
            case 36:
                command = [2,6];
                break;
            case 37:
                command = [3,1];
                break;
            case 38:
                command = [3,2];
                break;
            case 39:
                command = [3,3];
                break;
            case 40:
                command = [3,4];
                break;
            case 41:
                command = [3,5];
                break;
            case 42:
                command = [3,6];
                break;
            case 43:
                command = [4,1];
                break;
            case 44:
                command = [4,2];
                break;
            case 45:
                command = [4,3];
                break;
            case 46:
                command = [4,4];
                break;
            case 47:
                command = [4,5];
                break;
            case 48:
                command = [4,6];
                break;
            case 49:
                command = [5,1];
                break;
            case 50:
                command = [5,2];
                break;
            case 51:
                command = [5,3];
                break;
            case 52:
                command = [5,4];
                break;
            case 53:
                command = [5,5];
                break;
            case 54:
                command = [5,6];
                break;
            case 55:
                command = [6,1];
                break;
            case 56:
                command = [6,2];
                break;
            case 57:
                command = [6,3];
                break;
            case 58:
                command = [6,4];
                break;
            case 59:
                command = [6,5];
                break;
            case 60:
                command = [6,6];
                break;
        }
        return command;
    }

    getValidId(move) {
        let id;
        switch (move[0]) {
            case "u":
                id = 0*19 + move[1];
                break;
            case "d":
                id = 1*19 + move[1];
                break;
            case "l":
                id = 2*19 + 20 - move[1];
                break;
            case "r":
                id = 3*19 + 20 - move[1];
                break;                                            
        }
        return id;
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

}