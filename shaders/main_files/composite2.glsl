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
	uint rng = rngStart;
	
	
	
	// ======== BLOOM CALCULATIONS ========
	
	#ifdef BLOOM_ENABLED
		float depth = toLinearDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
		float sizeMult = inversesqrt(depth * far);
		
		vec3 bloomAddition = vec3(0.0);
		for (int i = 0; i < BLOOM_COMPUTE_COUNT; i++) {
			bloomAddition += getBloomAddition(sizeMult, rng);
		}
		bloomAddition *= (1.0 / BLOOM_COMPUTE_COUNT) * BLOOM_AMOUNT;
		#ifdef NETHER
			bloomAddition *= BLOOM_NETHER_MULT;
		#endif
		noisyAdditions += bloomAddition;
		
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
	
	
	
	/* DRAWBUFFERS:5 */
	gl_FragData[0] = vec4(noisyAdditions, 1.0);
	
	#ifdef BLOOM_SHOW_ADDITION
		/* RENDERTARGETS:5,11 */
		gl_FragData[1] = vec4(bloomAddition, 1.0);
		
	#elif defined BLOOM_SHOW_FILTERED_TEXTURE
		/* RENDERTARGETS:5,11 */
		gl_FragData[1] = vec4(texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb, 1.0);
		
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
