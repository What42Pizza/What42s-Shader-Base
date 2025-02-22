#define FOG_WATER_COLOR vec3(0.0, 0.2, 1.0)
#define FOG_LAVA_COLOR vec3(0.8, 0.25, 0.1)
#define FOG_POWDERED_SNOW_COLOR vec3(0.7, 0.85, 1.0)



#include "/utils/getSkyColor.glsl"

void applyFog(inout vec3 color, float fogAmount  ARGS_OUT) {
	vec3 skyColor = getSkyColor(ARG_IN);
	color.rgb = mix(color.rgb, skyColor, fogAmount);
}
