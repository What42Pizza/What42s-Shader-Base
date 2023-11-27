//--------------------------------------------------//
//        Post-Processing 2 (anything noisy)        //
//--------------------------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#ifdef BLOOM_ENABLED
	#include "/lib/bloom.glsl"
#endif
#ifdef SUNRAYS_ENABLED
	#include "/lib/sunrays.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 noisyAdditions = vec3(0.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	#include "/utils/var_rng.glsl"
	
	
	
	// ======== BLOOM CALCULATIONS ========
	
	#ifdef BLOOM_ENABLED
		
		vec3 bloomAddition = getBloomAddition(rng  ARGS_IN);
		noisyAdditions += bloomAddition;
		
		#ifdef BLOOM_SHOW_ADDITION
			debugOutput += bloomAddition;
		#endif
		#ifdef BLOOM_SHOW_FILTERED_TEXTURE
			debugOutput += texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
		#endif
		
	#endif
	
	
	
	// ======== SUNRAYS ========
	
	#ifdef SUNRAYS_ENABLED
		
		float sunraysAmount = 0.0;
		for (int i = 0; i < SUNRAYS_COMPUTE_COUNT; i ++) {
			sunraysAmount += getSunraysAmount(rng  ARGS_IN);
		};
		sunraysAmount /= SUNRAYS_COMPUTE_COUNT;
		
		#include "/import/isSun.glsl"
		vec3 sunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
		vec3 sunraysAddition = sunraysAmount * sunraysColor;
		
		noisyAdditions += sunraysAddition;
		
		#ifdef SUNRAYS_SHOW_ADDITION
			debugOutput += sunraysAddition;
		#endif
		
	#endif
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:03 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(noisyAdditions, 1.0);
	
}

#endif



#ifdef VSH

#ifdef SUNRAYS_ENABLED
	#include "/lib/sunrays.glsl"
#endif

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	#ifdef SUNRAYS_ENABLED
		calculateLightCoord(ARG_IN);
		calculateSunraysAmount(ARG_IN);
	#endif
	
}

#endif
