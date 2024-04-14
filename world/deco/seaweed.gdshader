shader_type canvas_item;

uniform float offset = 0.0;

void vertex() {
	
	VERTEX.x +=  sin(TIME+offset) * 3.0 * (1.0-UV.y);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
