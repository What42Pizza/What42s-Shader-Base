//--------------------------------------------------//
//        Post-Processing 2 (anything noisy)        //
//--------------------------------------------------//



varying vec2 texcoord;
flat vec2 lightCoord;

#ifdef SUNRAYS_ENABLED
	flat float sunraysAmountMult;
#endif



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
		sunraysAmount *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
		sunraysAmount *= sunraysAmountMult;
		
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

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
	lightPos /= lightPos.z;
	lightCoord = lightPos.xy * 0.5 + 0.5;
	
	#ifdef SUNRAYS_ENABLED
		sunraysAmountMult = getSunraysAmountMult();
	#endif
	
}

#endif
