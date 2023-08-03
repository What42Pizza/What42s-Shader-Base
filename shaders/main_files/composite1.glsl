//--------------------------------------------------//
//        Post-Processing 2 (anything noisy)        //
//--------------------------------------------------//



varying vec2 texcoord;
varying vec2 lightCoord;



#ifdef FSH

#include "/lib/bloom.glsl"
#include "/lib/sunrays.glsl"

void main() {
	vec3 noisyAdditions = vec3(0.0);
	vec3 debugOutput;
	uint rng = rngStart;
	
	
	
	// ======== BLOOM CALCULATIONS ========
	
	#ifdef BLOOM_ENABLED
		
		vec3 bloomAddition = getBloomAddition(rng);
		noisyAdditions += bloomAddition;
		
		#ifdef BLOOM_SHOW_ADDITION
			#define HAS_DEBUG_OUT
			debugOutput = bloomAddition;
		#endif
		
		#ifdef BLOOM_SHOW_FILTERED_TEXTURE
			#define HAS_DEBUG_OUT
			debugOutput = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
		#endif
		
	#endif
	
	
	
	// ======== SUNRAYS ========
	
	#ifdef SUNRAYS_ENABLED
		
		vec4 sunraysData = getSunraysData();
		vec3 sunraysColor = sunraysData.xyz;
		float sunraysAmount = sunraysData.w;
		
		float sunraysAddition = 0.0;
		for (int i = 0; i < SUNRAYS_COMPUTE_COUNT; i ++) {
			sunraysAddition += getSunraysAddition(rng);
		};
		sunraysAddition /= SUNRAYS_COMPUTE_COUNT;
		sunraysAddition *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
		
		noisyAdditions += sunraysAddition * sunraysAmount * sunraysColor;
		
	#endif
	
	
	
	/* DRAWBUFFERS:3 */
	gl_FragData[0] = vec4(noisyAdditions, 1.0);
	#ifdef HAS_DEBUG_OUT
		/* DRAWBUFFERS:37 */
		gl_FragData[1] = vec4(debugOutput, 1.0);
	#endif
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
	lightPos /= lightPos.z;
	lightCoord = lightPos.xy * 0.5 + 0.5;
	
}

#endif
