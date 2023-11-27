#ifdef FSH



vec4 getSkylightPercents(ARG_OUT) {
	#include "/import/rawSkylightPercents.glsl"
	vec4 skylightPercents = rawSkylightPercents;
	#include "/import/rainStrength.glsl"
	skylightPercents.xzw *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT);
	return skylightPercents;
}



vec3 getBasicLighting(float blockBrightness, float ambientBrightness  ARGS_OUT) {
	// cel shading experiments
	//blockBrightness = round(blockBrightness * 5) / 5;
	//skyBrightness = round(skyBrightness * 5) / 5;
	//ambientBrightness = round(ambientBrightness * 5) / 5;
	
	vec4 skylightPercents = getSkylightPercents(ARG_IN);
	vec3 ambientLight = getAmbientLight(skylightPercents, ambientBrightness);
	
	#ifdef BLOCKLIGHT_FLICKERING_ENABLED
		#include "/import/blockFlickerAmount.glsl"
		blockBrightness *= blockFlickerAmount;
	#endif
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	
	vec3 total = smoothMax(blockLight, ambientLight, LIGHT_SMOOTHING);
	return total;
}



#endif
