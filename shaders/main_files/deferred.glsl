varying vec2 texcoord;



#ifdef FSH

#ifdef SSAO_ENABLED
	#include "/lib/ssao.glsl"
#endif

void main() {
	vec3 color = texture2D(MAIN_BUFFER, texcoord).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	vec3 colorCopy = color;
	
	
	
	// ======== SSAO ========
	
	#ifdef SSAO_ENABLED
		float aoFactor = getAoFactor();
		color *= 1.0 - aoFactor * AO_AMOUNT;
		#ifdef SSAO_SHOW_AMOUNT
			debugOutput = vec3(1.0 - aoFactor);
		#endif
	#endif
	
	
	
	/* DRAWBUFFERS:05 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(colorCopy, 1.0);
}

#endif



#ifdef VSH

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();
}

#endif
