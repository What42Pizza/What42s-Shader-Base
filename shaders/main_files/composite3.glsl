//---------------------------------//
//        Post-Processing 4        //
//---------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/depth_of_field.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	
	
	
	// ======== DEPTH OF FIELD ========
	#ifdef DOF_ENABLED
		doDOF(color);
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
