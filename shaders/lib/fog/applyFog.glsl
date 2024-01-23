#define FOG_WATER_COLOR vec3(0.0, 0.2, 1.0)
#define FOG_LAVA_COLOR vec3(0.8, 0.25, 0.1)
#define FOG_POWDERED_SNOW_COLOR vec3(0.7, 0.85, 1.0)



vec3 getFogColor(vec3 airFogColor  ARGS_OUT) {
	#include "/import/isEyeInWater.glsl"
	vec3[4] allFogColors = vec3[4] (airFogColor, FOG_WATER_COLOR, FOG_LAVA_COLOR, FOG_POWDERED_SNOW_COLOR);
	return allFogColors[isEyeInWater];
}



#include "/utils/getSkyColor.glsl"

void applyFog(inout vec3 color, float fogAmount  ARGS_OUT) {
	vec3 airFogColor = getSkyColor(ARG_IN);
	vec3 fogColor = getFogColor(airFogColor  ARGS_IN);
	color.rgb = mix(color.rgb, fogColor, fogAmount);
}
