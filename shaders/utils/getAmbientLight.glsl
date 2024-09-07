#undef INCLUDE_GET_AMBIENT_LIGHT

#if defined FIRST_PASS && !defined GET_AMBIENT_LIGHT_FIRST_FINISHED
	#define INCLUDE_GET_AMBIENT_LIGHT
	#define GET_AMBIENT_LIGHT_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined GET_AMBIENT_LIGHT_SECOND_FINISHED
	#define INCLUDE_GET_AMBIENT_LIGHT
	#define GET_AMBIENT_LIGHT_SECOND_FINISHED
#endif



#ifdef INCLUDE_GET_AMBIENT_LIGHT



vec3 getAmbientLight(float ambientBrightness  ARGS_OUT) {
	
	#include "/import/ambientSunPercent.glsl"
	#include "/import/ambientMoonPercent.glsl"
	#include "/import/ambientSunrisePercent.glsl"
	#include "/import/ambientSunsetPercent.glsl"
	
	vec3 ambientSunLight     = AMBIENT_DAY_COLOR     * ambientSunPercent;
	vec3 ambientMoonLight    = AMBIENT_NIGHT_COLOR   * ambientMoonPercent;
	vec3 ambientSunriseLight = AMBIENT_SUNRISE_COLOR * ambientSunrisePercent;
	vec3 ambientSunsetLight  = AMBIENT_SUNSET_COLOR  * ambientSunsetPercent;
	
	#include "/import/rainStrength.glsl"
	float lightMult = 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT);
	
	vec3 ambientLight =
		ambientSunLight * lightMult
		+ ambientMoonLight
		+ ambientSunriseLight * lightMult
		+ ambientSunsetLight * lightMult;
	
	#include "/import/screenBrightness.glsl"
	ambientLight = mix(CAVE_AMBIENT_COLOR * (0.8 + 0.4 * screenBrightness), ambientLight, ambientBrightness);
	#ifdef NETHER
		ambientLight *= vec3(1.0, 0.5, 0.3);
	#endif
	
	#include "/import/nightVision.glsl"
	float betterNightVision = nightVision;
	if (betterNightVision > 0.0) {
		betterNightVision = 0.6 + 0.2 * betterNightVision;
		betterNightVision *= NIGHT_VISION_BRIGHTNESS;
	}
	vec3 lightVisionMin = vec3(betterNightVision);
	lightVisionMin.rb *= 1.0 - NIGHT_VISION_GREEN_AMOUNT;
	ambientLight = max(ambientLight, lightVisionMin);
	
	return ambientLight;
}



#endif
