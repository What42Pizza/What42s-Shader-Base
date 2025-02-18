#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#if DOF_ENABLED == 1
	#include "/lib/depth_of_field.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb;
	
	
	
	// ======== DEPTH OF FIELD ========
	
	#if DOF_ENABLED == 1
		doDOF(color  ARGS_IN);
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
