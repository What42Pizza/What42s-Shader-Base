vec3 getShadowPos(vec3 viewPos, float lightDot  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec4 playerPos = gbufferModelViewInverse * startMat(viewPos);
	#if PIXELATED_SHADOWS > 0
		#include "/import/cameraPosition.glsl"
		playerPos.xyz += cameraPosition;
		playerPos.xyz = floor(playerPos.xyz * PIXELATED_SHADOWS + 0.001) / PIXELATED_SHADOWS;
		playerPos.xyz -= cameraPosition;
	#endif
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; // convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos);
	float bias =
		0.05
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
	#if PIXELATED_SHADOWS > 0
		#include "/import/cameraPosition.glsl"
		playerPos.xyz += cameraPosition;
		playerPos.xyz = floor(playerPos.xyz * PIXELATED_SHADOWS + 0.001) / PIXELATED_SHADOWS;
		playerPos.xyz -= cameraPosition;
	#endif
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; // convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor); // apply shadow distortion
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= 0.005 * distortFactor; // apply shadow bias
	return shadowPos;
}



float sampleShadow(vec3 viewPos, float lightDot  ARGS_OUT) {
	// surface is facing away from shadowLightPosition
	if (lightDot < 0.0) return 0.0;
	
	#if SHADOW_FILTERING == 2
		
		
		
		// basic filtering
		
		vec3 floatShadowPos = getShadowPos(viewPos, lightDot  ARGS_IN);
		
		float noiseMult = length(floatShadowPos.xy * 2.0 - 1.0);
		noiseMult = noiseMult * SHADOW_OFFSET_INCREASE + SHADOW_OFFSET_MIN;
		noiseMult *= SHADOWS_NOISE * 2.0;
		#if PIXELATED_SHADOWS > 0
			noiseMult *= 24.0 / PIXELATED_SHADOWS;
		#endif
		#include "/utils/var_rng.glsl"
		vec2 noise = randomVec2(rng);
		noise = noise * noise * noiseMult;
		floatShadowPos.xy += noise;
		
		floatShadowPos.xy *= shadowMapResolution;
		int calcDatasIndex = 0;
		
		// sample 2x2 grid and treat sample off/on result as 0/1 bit in calcDatasIndex
		ivec2 samplePos = ivec2(floatShadowPos.xy);
		calcDatasIndex += int(texelFetch(shadowtex0, samplePos, 0).r >= floatShadowPos.z);
		samplePos.x += (fract(floatShadowPos.x) > 0.5) ? 1 : -1;
		calcDatasIndex += int(texelFetch(shadowtex0, samplePos, 0).r >= floatShadowPos.z) * 2;
		samplePos.y += (fract(floatShadowPos.y) > 0.5) ? 1 : -1;
		calcDatasIndex += int(texelFetch(shadowtex0, samplePos, 0).r >= floatShadowPos.z) * 4;
		samplePos.x += (fract(floatShadowPos.x) > 0.5) ? -1 : 1;
		calcDatasIndex += int(texelFetch(shadowtex0, samplePos, 0).r >= floatShadowPos.z) * 8;
		
		// basically marching squares
		const vec3[16] allCalcDatas = vec3[16] (
			vec3(0.0, 0.0, 0.0),
			vec3(1.0, -1.0, -1.0),
			vec3(0.0, 1.0, -1.0),
			vec3(1.0, 0.0, -1.0),
			vec3(-1.0, 1.0, 1.0),
			vec3(0.0, 1.0, -1.0),
			vec3(0.0, 1.0, 0.0),
			vec3(1.0, 1.0, -1.0),
			vec3(0.0, -1.0, 1.0),
			vec3(1.0, -1.0, 0.0),
			vec3(1.0, -1.0, -1.0),
			vec3(2.0, -1.0, -1.0),
			vec3(0.0, 0.0, 1.0),
			vec3(1.0, -1.0, 1.0),
			vec3(0.0, 1.0, 1.0),
			vec3(1.0, 0.0, 0.0)
		);
		vec3 calcData = allCalcDatas[calcDatasIndex];
		
		float xt = abs(fract(floatShadowPos.x) - 0.5);
		float yt = abs(fract(floatShadowPos.y) - 0.5);
		float shadowBrightness = calcData.x + xt * calcData.y + yt * calcData.z;
		if (calcDatasIndex == 5 || calcDatasIndex == 10) {
			shadowBrightness = 1.0 - abs(shadowBrightness);
		}
		shadowBrightness = clamp(shadowBrightness, 0.0, 1.0);
		
		return shadowBrightness;
		
		
		
	#elif SHADOW_FILTERING == 3
		
		
		
		// legacy filtering
		
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
		
		vec3 shadowPos = getLessBiasedShadowPos(viewPos  ARGS_IN);
		float offsetMult = length(shadowPos.xy * 2.0 - 1.0);
		offsetMult = offsetMult * SHADOW_OFFSET_INCREASE + SHADOW_OFFSET_MIN;
		vec3 offsetShadowPos = shadowPos;
		#include "/utils/var_rng.glsl"
		vec2 noise = randomVec2(rng);
		offsetShadowPos.xy += noise * offsetMult * 0.2;
		
		float shadowBrightness = 0.0;
		for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
			if (texture2D(shadowtex0, offsetShadowPos.xy + SHADOW_OFFSETS[i].xy * offsetMult).r >= offsetShadowPos.z) {
				float currentShadowWeight = SHADOW_OFFSETS[i].z;
				shadowBrightness += currentShadowWeight;
			}
		}
		shadowBrightness /= SHADOW_OFFSET_WEIGHTS_TOTAL;
		#if TAA_ENABLED == 1
			const float shadowMult1 = 1.4; // for when lightDot is 1.0 (sun is directly facing surface)
			const float shadowMult2 = 2.2; // for when lightDot is 0.0 (sun is angled relative to surface)
		#else
			const float shadowMult1 = 2.0; // for when lightDot is 1.0 (sun is directly facing surface)
			const float shadowMult2 = 3.0; // for when lightDot is 0.0 (sun is angled relative to surface)
		#endif
		return min(shadowBrightness * (shadowMult2 - lightDot * (shadowMult2 - shadowMult1)), 1.0);
		
		
		
	#elif SHADOW_FILTERING == 1
		
		// no filtering, smooth edges
		vec3 shadowPos = getShadowPos(viewPos, lightDot  ARGS_IN);
		return (texture2D(shadowtex0, shadowPos.xy).r >= shadowPos.z) ? 1.0 : 0.0;
		
	#else
		
		// no filtering, pixelated edges
		vec3 shadowPos = getShadowPos(viewPos, lightDot  ARGS_IN);
		return (texelFetch(shadowtex0, ivec2(shadowPos.xy * shadowMapResolution), 0).r >= shadowPos.z) ? 1.0 : 0.0;
		
	#endif
}
