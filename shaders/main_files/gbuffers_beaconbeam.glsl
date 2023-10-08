#ifdef FIRST_PASS
	varying vec2 texcoord;
	flat float glcolor_alpha;
#endif



#ifdef FSH

void main() {
	vec4 color = vec4(texture2D(MAIN_BUFFER, texcoord).rgb, glcolor_alpha);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	color.rgb *= 1.3;
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = color;
	#endif
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
	
	glcolor_alpha = gl_Color.a;
	
}

#endif
