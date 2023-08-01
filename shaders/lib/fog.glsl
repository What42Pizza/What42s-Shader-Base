varying float fogAmount;
varying vec3 fogSkyColor;
varying vec3 fogBloomSkyColor;



#ifdef FSH

void applyFog(inout vec3 color, inout vec3 colorForBloom) {
	vec3 colorMix;
	vec3 bloomColorMix;
	if (isEyeInWater == 0) {
		colorMix = getSkyColor();
		bloomColorMix = colorMix * sqrt(BLOOM_SKY_BRIGHTNESS);
	} else {
		colorMix = fogSkyColor;
		bloomColorMix = fogBloomSkyColor;
	}
	color.rgb = mix(color.rgb, colorMix, fogAmount);
	colorForBloom.rgb = mix(colorForBloom.rgb, bloomColorMix, fogAmount);
}

#endif



#ifdef VSH

void getFogData(vec3 playerPos) {
	
	playerPos.y /= FOG_HEIGHT_SCALE;
	fogAmount = length(playerPos);
	#ifdef SHADER_CLOUDS
		fogAmount /= FOG_EXTRA_CLOUDS_DISTANCE;
	#endif
	
	if (isEyeInWater == 0) {
		// not in liquid
		fogAmount /= far * 0.9;
		fogAmount = (fogAmount - 1.0) / (1.0 - mix(FOG_START, FOG_RAIN_START, betterRainStrength)) + 1.0;
		fogAmount = clamp(fogAmount, 0.0, 1.0);
		fogAmount = pow(fogAmount, mix(FOG_CURVE, FOG_RAIN_CURVE, betterRainStrength));
		
	} else if (isEyeInWater == 1) {
		// in water
		fogAmount /= FOG_WATER_DISTANCE;
		fogAmount = clamp(fogAmount, 0.1, 1.0);
		fogAmount = pow(fogAmount, FOG_WATER_CURVE);
		fogSkyColor = vec3(0.0, 0.2, 1.0);
		fogBloomSkyColor = fogSkyColor;
		
	} else if (isEyeInWater == 2) {
		// in lava
		fogAmount = 1.0;
		fogSkyColor = vec3(0.8, 0.2, 0.1);
		fogBloomSkyColor = fogSkyColor;
		
	} else if (isEyeInWater == 3) {
		// in powdered snow
		fogAmount /= FOG_WATER_DISTANCE * 0.025;
		fogAmount = clamp(fogAmount, 0.0, 1.0);
		fogAmount = pow(fogAmount, FOG_WATER_CURVE);
		fogSkyColor = vec3(0.7, 0.85, 1.0);
		fogBloomSkyColor = fogSkyColor;
		
	}
	
}

#endif
