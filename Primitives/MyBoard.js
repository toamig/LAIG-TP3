/**
 * MyBoard
 * @constructor
 * @param scene - Reference to MyScene object
 * @param id - Object id
 */

class MyBoard extends CGFobject {
	constructor(scene, id) {
		super(scene);
		this.id = id;
		this.cell = new MyPlane(scene, 'cell', 30, 30);
		this.cellTex = new CGFtexture(this.scene, "../scenes/images/cell.jpg");
		this.borderCellTex = new CGFtexture(this.scene, "../scenes/images/borderCell.png");
		this.cellMat = new CGFappearance(this.scene);
		this.cellMat.setDiffuse(1, 1, 1, 1);
		this.cellMat.setSpecular(1, 1, 1, 1);
		this.cellMat.setTexture(this.cellTex);
		this.borderCellMat = new CGFappearance(this.scene);
		this.borderCellMat.setDiffuse(1, 1, 1, 1);
		this.borderCellMat.setSpecular(1, 1, 1, 1);
		this.borderCellMat.setTexture(this.borderCellTex);
		
	};


	display(){

		this.scene.pushMatrix();
		this.scene.translate(1, 0, 1);

		this.borderCellMat.apply();
		for(var i = 0; i < 6; i++){
			this.scene.registerForPick(i+1, this);
			this.scene.pushMatrix();
			this.scene.translate(i, 0, -1);
			this.cell.display();
			this.scene.popMatrix();
		}
		for(var i = 0; i < 6; i++){
			this.scene.registerForPick(i+7, this);
			this.scene.pushMatrix();
			this.scene.translate(6, 0, i);
			this.cell.display();
			this.scene.popMatrix();
		}
		for(var i = 0; i < 6; i++){
			this.scene.registerForPick(i+13, this);
			this.scene.pushMatrix();
			this.scene.translate(5-i, 0, 6);
			this.cell.display();
			this.scene.popMatrix();
		}
		for(var i = 0; i < 6; i++){
			this.scene.registerForPick(i+19, this);
			this.scene.pushMatrix();
			this.scene.translate(-1, 0, 5-i);
			this.cell.display();
			this.scene.popMatrix();
		}

		this.cellMat.apply();
		for(var i = 0; i < 6; i++) {
			for(var j = 0; j < 6; j++) {

				this.scene.registerForPick(25+(i + 6*j), this);
				this.scene.pushMatrix();
				this.scene.translate(i, 0, j);
				this.cell.display();
				this.scene.popMatrix();

			}
		}

		this.scene.popMatrix();
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