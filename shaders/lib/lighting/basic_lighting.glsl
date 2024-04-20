#ifdef FSH



#include "/utils/getAmbientLight.glsl"



vec3 getBasicLighting(float blockBrightness, float ambientBrightness  ARGS_OUT) {
	
	#if CEL_SHADING_ENABLED == 1
		blockBrightness =
			sqrt(blockBrightness) * 0.8
			+ step(0.2, blockBrightness) * 0.2;
		ambientBrightness = smoothstep(0.0, 1.0, ambientBrightness);
	#endif
	
	vec3 ambientLight = getAmbientLight(ARG_IN);
	ambientLight = mix(CAVE_AMBIENT_COLOR, ambientLight, ambientBrightness);
	
	#if BLOCKLIGHT_FLICKERING_ENABLED == 1
		#include "/import/blockFlickerAmount.glsl"
		blockBrightness *= 1.0 + (blockFlickerAmount - 1.0) * BLOCKLIGHT_FLICKERING_AMOUNT;
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
	#include "/import/eyeBrightness.glsl"
	#include "/import/moonLightBrightness.glsl"
	blockBrightness *= 1.0 + (eyeBrightness.y / 240.0) * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	
	vec3 total = smoothMax(blockLight, ambientLight, LIGHT_SMOOTHING);
	return total;
}



#endif
