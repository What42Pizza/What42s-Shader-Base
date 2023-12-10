float getFogDistanceMult(ARG_OUT) {
	#include "/import/isEyeInWater.glsl"
	#include "/import/invFar.glsl"
	#if MC_VERSION >= 11300
		float airMult = invFar;
	#else
		float airMult = invFar * 0.9;
	#endif
	float[4] allDistanceMults = float[4] (airMult, 1.0 / FOG_WATER_END, 1.0 / FOG_LAVA_END, 1.0 / FOG_POWDERED_SNOW_END);
	return allDistanceMults[isEyeInWater];
}

float getFogStart(float airFogStart  ARGS_OUT) {
	#include "/import/isEyeInWater.glsl"
	float[4] allFogStarts = float[4] (airFogStart, FOG_WATER_START, FOG_LAVA_START, FOG_POWDERED_SNOW_START);
	return allFogStarts[isEyeInWater];
}

float getFogEnd(float airFogEnd  ARGS_OUT) {
	#include "/import/isEyeInWater.glsl"
	float[4] allFogEnds = float[4] (airFogEnd, 1.0, 1.0, 1.0);
	return allFogEnds[isEyeInWater];
}

float getFogMin(float airFogMin  ARGS_OUT) {
	#include "/import/isEyeInWater.glsl"
	float[4] allFogMins = float[4] (airFogMin, FOG_WATER_MIN, FOG_LAVA_MIN, FOG_POWDERED_SNOW_MIN);
	return allFogMins[isEyeInWater];
}



float getFogAmount(float fogDistance  ARGS_OUT) {
	
	float fogAmount = fogDistance * getFogDistanceMult(ARG_IN);
	
	#include "/import/betterRainStrength.glsl"
	float airFogStart = mix(FOG_AIR_START, FOG_AIR_RAIN_START, betterRainStrength);
	float airFogEnd = mix(FOG_AIR_END, FOG_AIR_RAIN_END, betterRainStrength);
	float fogStart = getFogStart(airFogStart  ARGS_IN);
	float fogEnd = getFogEnd(airFogEnd  ARGS_IN);
	fogAmount = percentThroughClamped(fogAmount, fogStart, fogEnd);
	
	float airFogMin = mix(FOG_AIR_MIN, FOG_AIR_RAIN_MIN, betterRainStrength);
	float fogMin = getFogMin(airFogMin  ARGS_IN);
	fogAmount = max(fogAmount, fogMin);
	
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 0) {
		#if FOG_CURVE == 2
			fogAmount = pow2(fogAmount);
		#elif FOG_CURVE == 3
			fogAmount = pow3(fogAmount);
		#elif FOG_CURVE == 4
			fogAmount = pow4(fogAmount);
		#elif FOG_CURVE == 5
			fogAmount = pow5(fogAmount);
		#endif
	}
	
	return fogAmount;
}
