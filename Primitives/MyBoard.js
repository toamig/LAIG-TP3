/**
 * MyBoard
 * @constructor
 * @param scene - Reference to MyScene object
 * @param inner - The "tube" radius
 * @param outer - Radius of the "circular axis" of the torus
 * @param slices - Torus slices
 * @param loops - Torus loops
 */

class MyBoard extends CGFobject {
	constructor(scene, id) {
		super(scene);
		this.id = id;
		this.cell = new MyPlane(scene, 'cell', 30, 30);
	};


	display(){

		for(var i = 0; i < 6; i++) {

			for(var j = 0; j < 6; j++) {

				this.scene.pushMatrix();
				this.scene.translate(i, 0, j);
				this.cell.display();
				this.scene.popMatrix();

			}

		}

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