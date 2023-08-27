varying vec2 texcoord;
flat float glcolor;

#ifdef REFLECTIONS_ENABLED
	varying vec3 normal;
#endif

#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif

#if defined BLOOM_ENABLED && defined REFLECTIONS_ENABLED
	#define BLOOM_AND_REFLECTIONS
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	// bloom
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_CLOUD_BRIGHTNESS);
	#endif
	
	
	// fog
	#ifdef FOG_ENABLED
		#ifdef BLOOM_ENABLED
			applyFog(color.rgb, colorForBloom.rgb);
		#else
			applyFog(color.rgb);
		#endif
	#endif
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color.rgb = debugOutput;
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_AND_REFLECTIONS
		/* DRAWBUFFERS:024 */
		gl_FragData[1] = colorForBloom;
		gl_FragData[2] = vec4(normal, 1.0);
	#elif defined BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#elif defined REFLECTIONS_ENABLED
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(normal, 1.0);
	#endif
}

#endif



#ifdef VSH

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	gl_Position = ftransform();
	
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	#ifdef FOG_ENABLED
		vec4 position = gl_Vertex;//gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
		getFogData(position.xyz);
	#endif
	
	glcolor = gl_Color.r;
	
	normal = gl_NormalMatrix * gl_Normal;
	
}

#endif
