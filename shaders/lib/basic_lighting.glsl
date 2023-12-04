#ifdef FSH



#include "/utils/getAmbientLight.glsl"



vec3 getBasicLighting(float blockBrightness, float ambientBrightness  ARGS_OUT) {
	// cel shading experiments
	//blockBrightness = round(blockBrightness * 5) / 5;
	//skyBrightness = round(skyBrightness * 5) / 5;
	//ambientBrightness = round(ambientBrightness * 5) / 5;
	
	vec3 ambientLight = getAmbientLight(ARG_IN);
	ambientLight = mix(CAVE_AMBIENT_COLOR, ambientLight, ambientBrightness);
	
	#if BLOCKLIGHT_FLICKERING_ENABLED == 1
		#include "/import/blockFlickerAmount.glsl"
		blockBrightness *= blockFlickerAmount;
	#endif
	#if BLOCK_BRIGHTNESS_CURVE == 2
		blockBrightness = pow2(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 3
		blockBrightness = pow3(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 4
		blockBrightness = pow4(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 5
		blockBrightness = pow5(blockBrightness);
	#endif
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	
	vec3 total = smoothMax(blockLight, ambientLight, LIGHT_SMOOTHING);
	return total;
}



#endif
