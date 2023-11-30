#ifdef FIRST_PASS
	
	#ifdef SHADOWS_ENABLED
		
		#if SHADOW_FILTERING == 1
			const int SHADOW_OFFSET_COUNT = 9;
			const float SHADOW_OFFSET_WEIGHTS_TOTAL = 1.0 + 0.94 * 8;
			const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
				vec3( 0.0,  0.0, 1.0 ),
				vec3( 0.7,  0.0, 0.94),
				vec3( 0.0,  0.7, 0.94),
				vec3(-0.7,  0.0, 0.94),
				vec3( 0.0, -0.7, 0.94),
				vec3( 0.5,  0.5, 0.94),
				vec3(-0.5,  0.5, 0.94),
				vec3( 0.5, -0.5, 0.94),
				vec3(-0.5, -0.5, 0.94)
			);
		#elif SHADOW_FILTERING == 2
			const int SHADOW_OFFSET_COUNT = 17;
			const float SHADOW_OFFSET_WEIGHTS_TOTAL = 1.0 + 0.94 * 8 + 0.78 * 8;
			const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
				vec3( 0.0 ,  0.0 , 1.0 ),
				vec3( 0.5 ,  0.0 , 0.94),
				vec3( 0.0 ,  0.5 , 0.94),
				vec3(-0.5 ,  0.0 , 0.94),
				vec3( 0.0 , -0.5 , 0.94),
				vec3( 0.35,  0.35, 0.94),
				vec3(-0.35,  0.35, 0.94),
				vec3( 0.35, -0.35, 0.94),
				vec3(-0.35, -0.35, 0.94),
				vec3( 0.38,  0.92, 0.78),
				vec3( 0.92,  0.38, 0.78),
				vec3( 0.92, -0.38, 0.78),
				vec3( 0.38, -0.92, 0.78),
				vec3(-0.38, -0.92, 0.78),
				vec3(-0.92, -0.38, 0.78),
				vec3(-0.92,  0.38, 0.78),
				vec3(-0.38,  0.92, 0.78)
			);
		#elif SHADOW_FILTERING == 3
			const int SHADOW_OFFSET_COUNT = 33;
			const float SHADOW_OFFSET_WEIGHTS_TOTAL = 1.0 + 0.94 * 8 + 0.78 * 8 + 0.57 * 8 + 0.37 * 8;
			const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
				vec3( 0.0 ,  0.0 , 1.0 ),
				vec3( 0.5 ,  0.0 , 0.94),
				vec3( 0.0 ,  0.5 , 0.94),
				vec3(-0.5 ,  0.0 , 0.94),
				vec3( 0.0 , -0.5 , 0.94),
				vec3( 0.35,  0.35, 0.94),
				vec3(-0.35,  0.35, 0.94),
				vec3( 0.35, -0.35, 0.94),
				vec3(-0.35, -0.35, 0.94),
				vec3( 0.38,  0.92, 0.78),
				vec3( 0.92,  0.38, 0.78),
				vec3( 0.92, -0.38, 0.78),
				vec3( 0.38, -0.92, 0.78),
				vec3(-0.38, -0.92, 0.78),
				vec3(-0.92, -0.38, 0.78),
				vec3(-0.92,  0.38, 0.78),
				vec3(-0.38,  0.92, 0.78),
				vec3( 1.5 ,  0.0 , 0.57),
				vec3( 0.0 ,  1.5 , 0.57),
				vec3(-1.5 ,  0.0 , 0.57),
				vec3( 0.0 , -1.5 , 0.57),
				vec3( 1.06,  1.06, 0.57),
				vec3(-1.06,  1.06, 0.57),
				vec3( 1.06, -1.06, 0.57),
				vec3(-1.06, -1.06, 0.57),
				vec3( 0.76,  1.84, 0.37),
				vec3( 1.84,  0.76, 0.37),
				vec3( 1.84, -0.76, 0.37),
				vec3( 0.76, -1.84, 0.37),
				vec3(-0.76, -1.84, 0.37),
				vec3(-1.84, -0.76, 0.37),
				vec3(-1.84,  0.76, 0.37),
				vec3(-0.76,  1.84, 0.37)
			);
		#endif
		
	#endif
	
#endif



//float getSkyBrightnessMult(float lightDot  ARGS_OUT) {
//	const float curve = 3.0;
//	const float finalFactor = 1.0 / (1.0 - 1.0 / (curve * 10.0 + 1.0));
//	return (1.0 - 1.0 / (max(lightDot, 0.0) * curve * 10.0 + 1.0)) * finalFactor;
//}





#ifdef FSH



vec3 getShadowPos(vec3 viewPos, float lightDot  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec4 playerPos = gbufferModelViewInverse * startMat(viewPos);
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; // convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos);
	float bias = 0.05
		+ 0.01 / (lightDot + 0.03)
		+ distortFactor * distortFactor * 0.5;
	shadowPos = distort(shadowPos, distortFactor); // apply shadow distortion
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= bias * 0.02; // apply shadow bias
	return shadowPos;
}

vec3 getLessBiasedShadowPos(vec3 viewPos  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec4 playerPos = gbufferModelViewInverse * startMat(viewPos);
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; // convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor); // apply shadow distortion
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= 0.005 * distortFactor; // apply shadow bias
	return shadowPos;
}



float getSkyBrightness(vec3 viewPos  ARGS_OUT) {
	
	vec3 normal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
	
	#include "/import/shadowLightPosition.glsl"
	float lightDot = dot(normalize(shadowLightPosition), normal);
	
	#ifdef SHADOWS_ENABLED
		float skyBrightness = 0;
		if (lightDot > 0.0) {
			// surface is facing towards shadowLightPosition
			
			#if SHADOW_FILTERING == 0
				vec3 shadowPos = getShadowPos(viewPos, lightDot  ARGS_IN);
			#else
				vec3 shadowPos = getLessBiasedShadowPos(viewPos  ARGS_IN);
			#endif
			float offsetMult = length(shadowPos.xy * 2.0 - 1.0);
			offsetMult = offsetMult * SHADOW_OFFSET_INCREASE + SHADOW_OFFSET_MIN;
			
			vec3 offsetShadowPos = shadowPos;
			#include "/utils/var_rng.glsl"
			vec2 noise = randomVec2(rng);
			offsetShadowPos.xy += noise * offsetMult * 0.2;
			
			#if SHADOW_FILTERING == 0
				
				// no filtering
				if (texture2D(shadowtex0, offsetShadowPos.xy).r >= offsetShadowPos.z) {
					skyBrightness += 1.0;
				}
				
			#else
				
				// filtered
				// tactic: just absorb the shadow acne and average it out, then multiply and clamp to get back to 1.0
				// actually I don't think that's how this works
				// the problem is that the offset pos goes inside the block half the time (especially when lightDot is low), which gets counted as 'in shadow'
				for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
					if (texture2D(shadowtex0, offsetShadowPos.xy + SHADOW_OFFSETS[i].xy * offsetMult).r >= offsetShadowPos.z) {
						float currentShadowWeight = SHADOW_OFFSETS[i].z;
						skyBrightness += currentShadowWeight;
					}
				}
				skyBrightness /= SHADOW_OFFSET_WEIGHTS_TOTAL;
				#ifdef TAA_ENABLED
					const float shadowMult1 = 1.4; // for when lightDot is 1.0 (sun is directly facing surface)
					const float shadowMult2 = 2.2; // for when lightDot is 0.0 (sun is angled relative to surface)
				#else
					const float shadowMult1 = 2.0; // for when lightDot is 1.0 (sun is directly facing surface)
					const float shadowMult2 = 3.0; // for when lightDot is 0.0 (sun is angled relative to surface)
				#endif
				skyBrightness = min(skyBrightness * (shadowMult2 - lightDot * (shadowMult2 - shadowMult1)), 1.0);
				
			#endif
			
		}
	#else
		float skyBrightness = 0.95;
	#endif
	
	skyBrightness *= max(lightDot, 0.0);
	
	return skyBrightness;
}



#endif