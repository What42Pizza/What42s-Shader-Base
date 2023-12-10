#define FOG_WATER_COLOR vec3(0.0, 0.2, 1.0)
#define FOG_LAVA_COLOR vec3(0.8, 0.25, 0.1)
#define FOG_POWDERED_SNOW_COLOR vec3(0.7, 0.85, 1.0)



vec3 getFogColor(vec3 airFogColor  ARGS_OUT) {
	#include "/import/isEyeInWater.glsl"
	vec3[4] allFogColors = vec3[4] (airFogColor, FOG_WATER_COLOR, FOG_LAVA_COLOR, FOG_POWDERED_SNOW_COLOR);
	return allFogColors[isEyeInWater];
}

vec3 getBloomFogColor(vec3 airBloomFogColor  ARGS_OUT) {
	#include "/import/isEyeInWater.glsl"
	vec3[4] allBloomFogColors = vec3[4] (airBloomFogColor, FOG_WATER_COLOR, FOG_LAVA_COLOR, FOG_POWDERED_SNOW_COLOR);
	return allBloomFogColors[isEyeInWater];
}



#include "/utils/getSkyColor.glsl"

#if BLOOM_ENABLED == 1
void applyFog(inout vec3 color, inout vec3 colorForBloom, float fogAmount  ARGS_OUT) {
#else
void applyFog(inout vec3 color, float fogAmount  ARGS_OUT) {
#endif
	
	vec3 airFogColor = getSkyColor(ARG_IN);
	#if BLOOM_ENABLED == 1
		vec3 airBloomFogColor = airFogColor * sqrt(BLOOM_SKY_BRIGHTNESS);
	#endif
	
	vec3 fogColor = getFogColor(airFogColor  ARGS_IN);
	#if BLOOM_ENABLED == 1
		vec3 bloomFogColor = getBloomFogColor(airBloomFogColor  ARGS_IN);
	#endif
	
	color.rgb = mix(color.rgb, fogColor, fogAmount);
	#if BLOOM_ENABLED == 1
		colorForBloom.rgb = mix(colorForBloom.rgb, bloomFogColor, fogAmount);
	#endif
	
}
