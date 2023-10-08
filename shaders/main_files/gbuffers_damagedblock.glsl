#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = color;
}

#endif



#ifdef VSH

#ifdef ISOMETRIC_RENDERING_ENABLED
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#ifdef ISOMETRIC_RENDERING_ENABLED
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
}

#endif
