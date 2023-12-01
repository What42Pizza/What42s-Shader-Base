#ifdef FIRST_PASS
	varying float fogAmount;
	varying vec3 fogSkyColor;
	#ifdef BLOOM_ENABLED
		varying vec3 fogBloomSkyColor;
	#endif
#endif





#ifdef FSH

#include "/utils/getSkyColor.glsl"

#ifdef BLOOM_ENABLED
	void applyFog(inout vec3 color, inout vec3 colorForBloom  ARGS_OUT) {
		vec3 colorMix;
		vec3 bloomColorMix;
		#include "/import/isEyeInWater.glsl"
		if (isEyeInWater == 0) {
			colorMix = getSkyColor(ARG_IN);
			bloomColorMix = colorMix * sqrt(BLOOM_SKY_BRIGHTNESS);
		} else {
			colorMix = fogSkyColor;
			bloomColorMix = fogBloomSkyColor;
		}
		color.rgb = mix(color.rgb, colorMix, fogAmount);
		colorForBloom.rgb = mix(colorForBloom.rgb, bloomColorMix, fogAmount);
	}
#else
	void applyFog(inout vec3 color  ARGS_OUT) {
		vec3 colorMix;
		#include "/import/isEyeInWater.glsl"
		if (isEyeInWater == 0) {
			colorMix = getSkyColor(ARG_IN);
		} else {
			colorMix = fogSkyColor;
		}
		color.rgb = mix(color.rgb, colorMix, fogAmount);
	}
#endif



#endif





#ifdef VSH

void getFogData(vec3 playerPos  ARGS_OUT) {
	
	playerPos.y /= FOG_HEIGHT_SCALE;
	fogAmount = length(playerPos);
	#ifdef SHADER_GBUFFERS_CLOUDS
		fogAmount /= FOG_EXTRA_CLOUDS_DISTANCE;
	#endif
	
	
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 0) { // not in liquid
		#include "/import/invFar.glsl"
		#if MC_VERSION >= 11300
			fogAmount *= invFar;
		#else
			fogAmount *= invFar / 0.9;
		#endif
		#include "/import/betterRainStrength.glsl"
		float fogStart = mix(FOG_START, FOG_RAIN_START, betterRainStrength);
		fogAmount = (fogAmount - 1.0) / (1.0 - fogStart) + 1.0;
		fogAmount = clamp(fogAmount, 0.0, 1.0);
		#if FOG_CURVE == 2
			fogAmount = pow2(fogAmount);
		#elif FOG_CURVE == 3
			fogAmount = pow3(fogAmount);
		#elif FOG_CURVE == 4
			fogAmount = pow4(fogAmount);
		#elif FOG_CURVE == 5
			fogAmount = pow5(fogAmount);
		#endif
		
		
	} else if (isEyeInWater == 1) { // in water
		fogAmount /= FOG_WATER_DISTANCE;
		fogAmount = clamp(fogAmount, 0.2, 1.0);
		#if FOG_WATER_CURVE == 2
			fogAmount = pow2(fogAmount);
		#elif FOG_WATER_CURVE == 3
			fogAmount = pow3(fogAmount);
		#elif FOG_WATER_CURVE == 4
			fogAmount = pow4(fogAmount);
		#elif FOG_WATER_CURVE == 5
			fogAmount = pow5(fogAmount);
		#endif
		fogSkyColor = vec3(0.0, 0.2, 1.0);
		#ifdef BLOOM_ENABLED
			fogBloomSkyColor = fogSkyColor;
		#endif
		
		
	} else if (isEyeInWater == 2) { // in lava
		fogAmount = 1.0;
		fogSkyColor = vec3(0.8, 0.25, 0.1);
		#ifdef BLOOM_ENABLED
			fogBloomSkyColor = fogSkyColor;
		#endif
		
		
	} else if (isEyeInWater == 3) { // in powdered snow
		fogAmount /= FOG_WATER_DISTANCE * 0.025;
		fogAmount = clamp(fogAmount, 0.0, 1.0);
		#if FOG_WATER_CURVE == 2
			fogAmount = pow2(fogAmount);
		#elif FOG_WATER_CURVE == 3
			fogAmount = pow3(fogAmount);
		#elif FOG_WATER_CURVE == 4
			fogAmount = pow4(fogAmount);
		#elif FOG_WATER_CURVE == 5
			fogAmount = pow5(fogAmount);
		#endif
		fogSkyColor = vec3(0.7, 0.85, 1.0);
		#ifdef BLOOM_ENABLED
			fogBloomSkyColor = fogSkyColor;
		#endif
		
		
	}
	
}

#endif
