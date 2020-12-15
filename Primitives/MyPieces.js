/**
 * MyPieces
 * @constructor
 */

var AniState = {Circ:1,Lin1Piece:2,Lin2Pieces1:3,Lin2Pieces2:4,Done:5};

class MyPieces extends CGFobject{
    constructor(scene) {
        super(scene);
        this.scene = scene;
        this.blackPieces = [];
        this.icePieces = [];
        this.blackPiecesAnimation = [];
        this.icePiecesAnimation = [];
        this.animatedPieces = [];
        this.aniState = AniState.Circ;
        this.piece = new MySphere(scene,"piece",1,20,20);
        this.transScale = 2.22222;
        this.animationTime = 0;
        this.initPieces();
        this.initMaterials();
    };

    display(){


        this.scene.pushMatrix();
        
        this.blackMaterial.apply();
        for(var i = 0; i < this.blackPieces.length;i++){
            if(this.blackPieces[i][0] == 0){
                this.scene.registerForPick(this.blackPieces[i][1], this);
            }
            else if(this.blackPieces[i][0] == 7){
                this.scene.registerForPick(7-this.blackPieces[i][1] + 12, this);
            }
            else if(this.blackPieces[i][1] == 0){
                this.scene.registerForPick(7-this.blackPieces[i][0] + 18, this);
            }
            else if(this.blackPieces[i][1] == 7){
                this.scene.registerForPick(this.blackPieces[i][0] + 6, this);
            }
            this.scene.pushMatrix();
            this.scene.translate(this.blackPieces[i][1],0.2,this.blackPieces[i][0]);
            this.scene.scale(0.40,0.2,0.40);
            this.piece.display();
            this.scene.popMatrix();
        }
        this.iceMaterial.apply();
        for(var i = 0; i < this.icePieces.length;i++){
            if(this.icePieces[i][0] == 0){
                this.scene.registerForPick(this.icePieces[i][1], this);
            }
            else if(this.icePieces[i][0] == 7){
                this.scene.registerForPick(7-this.icePieces[i][1] + 12, this);
            }
            else if(this.icePieces[i][1] == 0){
                this.scene.registerForPick(7-this.icePieces[i][0] + 18, this);
            }
            else if(this.icePieces[i][1] == 7){
                this.scene.registerForPick(this.icePieces[i][0] + 6, this);
            }
            this.scene.pushMatrix();
            this.scene.translate(this.icePieces[i][1],0.2,this.icePieces[i][0]);
            this.scene.scale(0.40,0.2,0.40);
            this.piece.display();
            this.scene.popMatrix();
        }

        for(var i = 0; i < this.animatedPieces.length;i++){
            if(i == 0){
                if(this.scene.game.ani_pTurn == "icePlayer")
                    this.iceMaterial.apply();
                else
                    this.blackMaterial.apply();
            }
            else if(i == 1){
                if(this.scene.game.ani_PieceColor == "i")
                    this.iceMaterial.apply();
                else
                    this.blackMaterial.apply();
            }

            this.scene.pushMatrix();
            this.scene.translate(this.animatedPieces[i][2]*this.transScale+1,this.animatedPieces[i][1]+0.3,this.animatedPieces[i][0]*this.transScale+1);
            this.piece.display();
            this.scene.popMatrix();
        }

        this.scene.popMatrix();
    }


    update(deltaTime) {
        if(this.scene.game.animationRunning){
            
            //Init the animation
            if(this.scene.game.ani_firstIte){
                this.removePiecesAnimation();
                this.aniState = AniState.Circ;

                this.calcAnimationVals();

                let timePerCell = 0.3;
                let timeCircular = 3.0;

                this.circAnimation = new CircularAnimation("circular", timeCircular, [this.centerArcPoint[0],0,this.centerArcPoint[1]], this.radius, 180, 180);
                
                if(this.scene.game.ani_PiecesCoords.length == 1){
                    this.linAnimation1 = new LinearAnimation("linear1piece", timePerCell*(this.nSpaces), [[this.endArcPoint[0],0,this.endArcPoint[1]],[this.endTranslate1Point[0],0,this.endTranslate1Point[1]]]);
                    this.aniPieces = 1;
                    this.scene.game.ani_totalTime = timeCircular + timePerCell*(this.nSpaces);
                }
                else{
                    this.linAnimation1 = new LinearAnimation("linear1piece", timePerCell*(this.nSpaces), [[this.endArcPoint[0],0,this.endArcPoint[1]],[this.midTranslate1Point[0],0,this.midTranslate1Point[1]]]);
                    this.linAnimation2 = new LinearAnimation("linear2piece", timePerCell*(this.nSpaces), [[this.endTranslate1Point[0],0,this.endTranslate1Point[1]],[this.endTranslate1Point[0],0.001,this.endTranslate1Point[1]]]);
                    this.linAnimation3 = new LinearAnimation("linear3piece", timePerCell, [[this.midTranslate1Point[0],0,this.midTranslate1Point[1]],[this.endTranslate1Point[0],0,this.endTranslate1Point[1]]]);
                    this.linAnimation4 = new LinearAnimation("linear4piece", timePerCell, [[this.endTranslate1Point[0],0,this.endTranslate1Point[1]],[this.endTranslate2Point[0],0,this.endTranslate2Point[1]]]);
                    this.linAnimation5 = new LinearAnimation("linear5piece", timeCircular, [[this.endTranslate1Point[0],0,this.endTranslate1Point[1]],[this.endTranslate1Point[0],0.001,this.endTranslate1Point[1]]]);
                    this.aniPieces = 2;
                    this.scene.game.ani_totalTime = timeCircular + timePerCell*(this.nSpaces+2);
                }

                this.scene.game.ani_firstIte = false;
            }

            this.updateAnimations(deltaTime);
            this.animationTime += deltaTime;

            //Term the animation
            if(this.aniState == AniState.Done){
                //Atualizar visualmente as valid moves
                this.scene.game.validMoves = this.scene.game.ani_ValidMoves;
                this.scene.game.validIDs = [];
                this.scene.game.validMoves.forEach(element => {
                    this.scene.game.validIDs.push(this.scene.game.getValidId(element));
                });

                this.animationTime = 0;
                this.reinsertPiecesAnimation();
                this.blackPiecesAnimation = [];
                this.icePiecesAnimation = [];
                this.scene.game.animationRunning = false;

                if(this.scene.game.inMovie){
                    this.storePiecesMovie(this.scene.game.boards[this.scene.game.movieIndex]);
                }

                //Jogo terminou
                if(this.scene.game.ani_term){
                    this.scene.game.terminated = true;
                    this.scene.game.validIDs = [];
                    this.scene.game.showWinner();
                }

                if(this.scene.game.ani_changeT){
                    this.scene.game.changeTurn();
                    if(this.scene.game.mode == GameMode.BVB || (this.scene.game.mode == GameMode.PVB && this.scene.game.playerTurn == "blackPlayer")){
                        this.scene.game.botAction = true;
                    }
                }

                switch (this.scene.game.ani_FinalAction){
                    case "undo":
                        this.scene.game.undo();
                        break;
                    case "reset":
                        this.scene.game.initBoard();
                        break;
                }

                this.scene.game.ani_FinalAction = "none";
            }
        }
	}



    updateAnimations(deltaTime){
        this.animatedPieces = [];

        this.updateAniState();

        switch(this.aniState){
            case AniState.Circ:
                this.circAnimation.update(deltaTime);
                let newCircPos = this.circAnimation.applyPieces(this.dirVec, this.angleVec);
                this.animatedPieces.push(newCircPos);
                if(this.aniPieces == 2){
                    this.linAnimation5.update(deltaTime);
                    let newCircPos2 = this.linAnimation5.applyPieces();
                    this.animatedPieces.push(newCircPos2);
                }
                break;
            case AniState.Lin1Piece:
                this.linAnimation1.update(deltaTime);
                let newPos = this.linAnimation1.applyPieces();
                this.animatedPieces.push(newPos);
                break;
            case AniState.Lin2Pieces1:
                this.linAnimation1.update(deltaTime);
                this.linAnimation2.update(deltaTime);
                let newPos1 = this.linAnimation1.applyPieces();
                this.animatedPieces.push(newPos1);
                let newPos2 = this.linAnimation2.applyPieces();
                this.animatedPieces.push(newPos2);
                break;
            case AniState.Lin2Pieces2:
                this.linAnimation3.update(deltaTime);
                this.linAnimation4.update(deltaTime);
                let newPos3 = this.linAnimation3.applyPieces();
                this.animatedPieces.push(newPos3);
                let newPos4 = this.linAnimation4.applyPieces();
                this.animatedPieces.push(newPos4);
                break; 
            case AniState.Done:
                break;
        }

    }


    calcAnimationVals(){

        let dir = this.scene.game.ani_Dir;
        if(this.scene.game.ani_pTurn == "icePlayer")
            this.startArcPoint = [0,0];
        else
            this.startArcPoint = [0,20];

        this.endTranslate1Point = this.scene.game.ani_PiecesCoords[0];

        if(this.scene.game.ani_PiecesCoords.length == 2){
            switch (dir){
                case "l":
                    this.midTranslate1Point = [this.scene.game.ani_PiecesCoords[0][0], this.scene.game.ani_PiecesCoords[0][1]-1];
                    this.endTranslate2Point = [this.scene.game.ani_PiecesCoords[0][0], this.scene.game.ani_PiecesCoords[0][1]+1];
                    break;
                case "r":
                    this.midTranslate1Point = [this.scene.game.ani_PiecesCoords[0][0], this.scene.game.ani_PiecesCoords[0][1]+1];
                    this.endTranslate2Point = [this.scene.game.ani_PiecesCoords[0][0], this.scene.game.ani_PiecesCoords[0][1]-1];
                    break;
                case "u":
                    this.midTranslate1Point = [this.scene.game.ani_PiecesCoords[0][0]-1, this.scene.game.ani_PiecesCoords[0][1]];
                    this.endTranslate2Point = [this.scene.game.ani_PiecesCoords[0][0]+1, this.scene.game.ani_PiecesCoords[0][1]];
                    break;
                case "d":
                    this.midTranslate1Point = [this.scene.game.ani_PiecesCoords[0][0]+1, this.scene.game.ani_PiecesCoords[0][1]];
                    this.endTranslate2Point = [this.scene.game.ani_PiecesCoords[0][0]-1, this.scene.game.ani_PiecesCoords[0][1]];
                    break;
            }
        }
        
        this.nSpaces = this.scene.game.ani_nSpaces;
        let index = this.scene.game.ani_Index;
        switch (dir){
            case "l":
                this.endArcPoint = [20-index, 0];
                break;
            case "r":
                this.endArcPoint = [20-index, 20];
                break;
            case "u":
                this.endArcPoint = [0, index];
                break;
            case "d":
                this.endArcPoint = [20, index];
                break;
        }


        this.centerArcPoint = [((this.endArcPoint[0]+this.startArcPoint[0])/2.0),((this.endArcPoint[1]+this.startArcPoint[1])/2.0)];
        this.radius = Math.sqrt(Math.pow((this.centerArcPoint[0]-this.startArcPoint[0]),2) + Math.pow((this.centerArcPoint[1]-this.startArcPoint[1]),2));

        let startEndVec = [this.endArcPoint[0]-this.startArcPoint[0], 0, this.endArcPoint[1]-this.startArcPoint[1]];
        let tempVec = [0,0,0];
        this.rotVecY(tempVec, startEndVec, [0,0,0], Math.PI/2);
        let vecLength = Math.sqrt(Math.pow(tempVec[0],2)+Math.pow(tempVec[1],2)+Math.pow(tempVec[2],2));
        this.dirVec = tempVec;
        
        this.angleVec = Math.atan(tempVec[0]/tempVec[2]);

        if((Math.round(tempVec[2]) == 0.0) && tempVec[0] > 0) {
            this.angleVec = -Math.PI/2;
        }



    }

    removePiecesAnimation(){
        for(let i = 0; i < this.blackPieces.length; i++){
            for(let j = 0; j < this.scene.game.ani_PiecesCoords.length; j++){
                if(this.blackPieces[i][0] == this.scene.game.ani_PiecesCoords[j][0] && this.blackPieces[i][1] == this.scene.game.ani_PiecesCoords[j][1]){
                    this.blackPieces.splice(i,1);
                    i--;
                    break;
                }
            }
        }
        for(let i = 0; i < this.icePieces.length; i++){
            for(let j = 0; j < this.scene.game.ani_PiecesCoords.length; j++){
                if(this.icePieces[i][0] == this.scene.game.ani_PiecesCoords[j][0] && this.icePieces[i][1] == this.scene.game.ani_PiecesCoords[j][1]){
                    this.icePieces.splice(i,1);
                    i--;
                    break;
                }
            }
        }
    }

    reinsertPiecesAnimation(){
        for(let i = 0; i < this.blackPiecesAnimation.length; i++){
            this.blackPieces.push(this.blackPiecesAnimation[i]);
        }
        for(let i = 0; i < this.icePiecesAnimation.length; i++){
            this.icePieces.push(this.icePiecesAnimation[i]);
        }
    }

    addBlackPiece(x,y){
        this.blackPieces.push([x,y]);
    }

    addicePiece(x,y){
        this.icePieces.push([x,y]);
    }

    initPieces(){
        this.icePieces = [];
        this.blackPieces = [];
    }

    storePieces(board){
        this.initPieces();
        for(var i = 0; i < board.length;i++){
            for(var j = 0; j < board[0].length;j++){
                if(board[j][i] == "b"){
                    if(!this.scene.game.animationRunning)
                        this.addBlackPiece(j,i);
                    else{
                        let toAdd = true;
                        for(let k = 0; k < this.scene.game.ani_PiecesCoords.length; k++){
                            if(j+1 == this.scene.game.ani_PiecesCoords[k][0] && i+1 == this.scene.game.ani_PiecesCoords[k][1]){
                                this.blackPiecesAnimation.push([j+1,i+1]);
                                toAdd = false;
                            }
                        }
                        if(toAdd)
                            this.addBlackPiece(j,i);
                    }
                        
                }
                else if(board[j][i] == "i"){
                    if(!this.scene.game.animationRunning)
                        this.addicePiece(j,i);
                    else{
                        let toAdd = true;
                        for(let k = 0; k < this.scene.game.ani_PiecesCoords.length; k++){
                            if(j+1 == this.scene.game.ani_PiecesCoords[k][0] && i+1 == this.scene.game.ani_PiecesCoords[k][1]){
                                this.icePiecesAnimation.push([j+1,i+1]);
                                toAdd = false;
                            }
                        }
                        if(toAdd)
                            this.addicePiece(j,i);
                    }

                }
            }
        }
    }

    storePiecesMovie(board){
        if(board != undefined){
            this.initPieces();
            for(var i = 0; i < board.length;i++){
                for(var j = 0; j < board[0].length;j++){
                    if(board[j][i] == "b"){
                        this.addBlackPiece(j+1,i+1);     
                    }
                    else if(board[j][i] == "i"){
                        this.addicePiece(j+1,i+1);
                    }
                }
            }
        }
    }

    initMaterials(){
        this.blackMaterial = new CGFappearance(this.scene);
        this.blackMaterial.setShininess(1);
        this.blackMaterial.setEmission(0, 0, 0, 0);
        this.blackMaterial.setAmbient(0.1, 0.1, 0.1, 1);
        this.blackMaterial.setDiffuse(0.1, 0.1, 0.1, 1);
        this.blackMaterial.setSpecular(0.1, 0.1, 0.1, 1);

        this.iceMaterial = new CGFappearance(this.scene);
        this.iceMaterial.setShininess(1);
        this.iceMaterial.setEmission(0, 0, 0, 0);
        this.iceMaterial.setAmbient(0.1, 0.1, 0.1, 1);
        this.iceMaterial.setDiffuse(1, 1, 1, 1);
        this.iceMaterial.setSpecular(1, 1, 1, 1);
        
    }

    // updateAniState(){
    //     switch(this.aniState){
    //         case AniState.Circ:
    //             if(this.circAnimation.terminated)
    //                 if(this.scene.game.ani_PiecesCoords.length == 1)
    //                     this.aniState = AniState.Lin1Piece;
    //                 else
    //                     this.aniState = AniState.Lin2Pieces1;
    //             break;
    //         case AniState.Lin1Piece:
    //             if(this.linAnimation1.terminated)
    //                 this.aniState = AniState.Done;
    //             break;
    //         case AniState.Lin2Pieces1:
    //             if(this.linAnimation1.terminated && this.linAnimation2.terminated)
    //                 this.aniState = AniState.Lin2Pieces2;
    //             break;
    //         case AniState.Lin2Pieces2:
    //             if(this.linAnimation3.terminated && this.linAnimation4.terminated)
    //                 this.aniState = AniState.Done;
    //             break;
    //         case AniState.Done:
    //             break;
    //     }
    // }


    rotVecY(out, a, b, c){

        let p = [], r=[];
      
        //Translate point to the origin
        p[0] = a[0] - b[0];
        p[1] = a[1] - b[1];
        p[2] = a[2] - b[2];
      
        //perform rotation
        r[0] = p[2]*Math.sin(c) + p[0]*Math.cos(c);
        r[1] = p[1];
        r[2] = p[2]*Math.cos(c) - p[0]*Math.sin(c);
      
        //translate to correct position
        out[0] = r[0] + b[0];
        out[1] = r[1] + b[1];
        out[2] = r[2] + b[2];
      
        return out;
    }

    changeCoords(s, t){
	}
	
	/**
	 * @method updateTexCoords
	 * Updates the list of texture coordinates of the torus
	 * @param {Array} coords - Array of texture coordinates
	 */
	updateTexCoords(coords) {
		this.texCoords = [...coords];
		this.updateTexCoordsGLBuffers();
	}

}