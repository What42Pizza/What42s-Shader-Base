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
	
	vec3 playerPos = texelFetch(colortex10, texelcoord, 0).rgb;
	
	
	
	// ======== BLOOM CALCULATIONS ========
	
	#ifdef BLOOM_ENABLED
		float sizeMult = inversesqrt(length(playerPos));
		
		vec3 bloomAddition = vec3(0.0);
		for (int i = 0; i < BLOOM_COMPUTE_COUNT; i++) {
			bloomAddition += getBloomAddition(sizeMult, frameCounter + i);
		}
		bloomAddition *= (1.0 / BLOOM_COMPUTE_COUNT) * BLOOM_AMOUNT * 0.3;
		#ifdef NETHER
			bloomAddition *= BLOOM_NETHER_MULT;
		#endif
		noisyAdditions += bloomAddition;
		
	#endif
	
	
	
	// ======== SUNRAYS ========
	
	#ifdef SUNRAYS_ENABLED
		
		vec4 sunraysData = getCachedSunraysData();
		vec3 sunraysColor = sunraysData.xyz;
		float sunraysAmount = sunraysData.w;
		
		float sunraysAddition = 0.0;
		for (int i = 0; i < SUNRAYS_COMPUTE_COUNT; i ++) {
			sunraysAddition += getSunraysAddition(frameCounter + i);
		};
		sunraysAddition /= SUNRAYS_COMPUTE_COUNT;
		sunraysAddition *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
		
		if (shadowLightPosition.b > 0.0) {
			vec4 sunlightPercents = getCachedSkylightPercents();
			sunraysAddition *= max(sunlightPercents.z, sunlightPercents.w) * 0.8;
		}
		noisyAdditions += sunraysAddition * sunraysAmount * 0.3 * sunraysColor;
		
	#endif
	
	
	
	/* DRAWBUFFERS:8 */
	gl_FragData[0] = vec4(noisyAdditions, 1.0);
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
