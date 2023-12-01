#ifdef FSH



#include "/utils/getAmbientLight.glsl"



vec3 getBasicLighting(float blockBrightness, float ambientBrightness  ARGS_OUT) {
	// cel shading experiments
	//blockBrightness = round(blockBrightness * 5) / 5;
	//skyBrightness = round(skyBrightness * 5) / 5;
	//ambientBrightness = round(ambientBrightness * 5) / 5;
	
	vec3 ambientLight = getAmbientLight(ARG_IN);
	
	#ifdef BLOCKLIGHT_FLICKERING_ENABLED
		#include "/import/blockFlickerAmount.glsl"
		blockBrightness *= blockFlickerAmount;
	#endif
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	
	vec3 total = smoothMax(blockLight, ambientLight, LIGHT_SMOOTHING);
	return total;
}



#endif
