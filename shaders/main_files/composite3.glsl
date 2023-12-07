//---------------------------------//
//        Post-Processing 4        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#if DOF_ENABLED == 1
	#include "/lib/depth_of_field.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== DEPTH OF FIELD ========
	
	#if DOF_ENABLED == 1
		doDOF(color  DEBUG_ARGS_IN  ARGS_IN);
	#endif
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
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
