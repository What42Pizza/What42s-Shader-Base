//--------------------------------------------------//
//        Post-Processing 2 (anything noisy)        //
//--------------------------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/bloom.glsl"
#include "/lib/sunrays.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 noisyAdditions = vec3(0.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	uint rng = rngStart;
	
	
	
	// ======== BLOOM CALCULATIONS ========
	
	#ifdef BLOOM_ENABLED
		
		vec3 bloomAddition = getBloomAddition(rng);
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
			sunraysAmount += getSunraysAmount(rng);
		};
		sunraysAmount /= SUNRAYS_COMPUTE_COUNT;
		
		vec3 sunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
		vec3 sunraysAddition = sunraysAmount * sunraysColor;
		
		noisyAdditions += sunraysAddition;
		
		#ifdef SUNRAYS_SHOW_ADDITION
			debugOutput += sunraysAddition;
		#endif
		
	#endif
	
	
	
	/* DRAWBUFFERS:03 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(noisyAdditions, 1.0);
}

#endif



#ifdef VSH

#include "/lib/sunrays.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	#ifdef SUNRAYS_ENABLED
		calculateLightCoord();
		calculateSunraysAmount();
	#endif
	
}

#endif
