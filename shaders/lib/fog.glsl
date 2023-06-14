void applyFog(inout vec3 color, inout vec3 bloomColor) {
	
	// NOTE: it's kinda more realistic if you only depthtex0 is sampled, the reason depthTex1 is sampled is because it looks more vanilla
	vec3 screenPos;
	if (isEyeInWater == 0) {
		screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
	} else {
		screenPos = vec3(texcoord, texture2D(depthtex1, texcoord).r);
	}
	vec3 viewPos = screenToView(screenPos);
	vec3 playerPos = viewToPlayer(viewPos);
	
	vec3 playerPosForFog = playerPos;
	playerPosForFog.y /= FOG_HEIGHT_SCALE;
	float fog = length(playerPosForFog);
	if (texture2D(colortex3, texcoord).r > 0.5) {
		fog /= FOG_EXTRA_CLOUDS_DISTANCE;
	}
	
	vec3 skyColor;
	vec3 bloomSkyColor;
	if (isEyeInWater == 0) {
		// not in liquid
		fog /= far;
		fog = (fog - 1.0) / (1.0 - mix(FOG_START, FOG_RAIN_START, betterRainStrength)) + 1.0;
		fog = clamp(fog, 0.0, 1.0);
		fog = pow(fog, mix(FOG_CURVE, FOG_RAIN_CURVE, betterRainStrength));
		skyColor = texture2D(colortex4, texcoord).rgb;
		bloomSkyColor = texture2D(colortex5, texcoord).rgb;
	} else if (isEyeInWater == 1) {
		// in water
		fog /= FOG_WATER_DISTANCE;
		fog = clamp(fog, 0.0, 1.0);
		fog = pow(fog, FOG_WATER_CURVE);
		skyColor = vec3(0.0, 0.2, 1.0);
		bloomSkyColor = skyColor;
	} else if (isEyeInWater == 2) {
		// in lava
		fog = 1.0;
		skyColor = vec3(0.8, 0.2, 0.1);
		bloomSkyColor = skyColor;
	} else if (isEyeInWater == 3) {
		// in powdered snow
		fog /= FOG_WATER_DISTANCE * 0.025;
		fog = clamp(fog, 0.0, 1.0);
		fog = pow(fog, FOG_WATER_CURVE);
		skyColor = vec3(0.7, 0.85, 1.0);
		bloomSkyColor = skyColor;
	}
	
	color = mix(color, skyColor, fog);
	bloomColor = mix(bloomColor, bloomSkyColor, fog);
	
}