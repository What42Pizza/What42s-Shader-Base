#undef INCLUDE_GET_SKY_LIGHT

#if defined FIRST_PASS && !defined GET_SKY_LIGHT_FIRST_FINISHED
	#define INCLUDE_GET_SKY_LIGHT
	#define GET_SKY_LIGHT_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined GET_SKY_LIGHT_SECOND_FINISHED
	#define INCLUDE_GET_SKY_LIGHT
	#define GET_SKY_LIGHT_SECOND_FINISHED
#endif



#ifdef INCLUDE_GET_SKY_LIGHT



vec3 getSkyLight(ARG_OUT) {
	
	#include "/import/sunDayColorPercent.glsl"
	#include "/import/sunriseColorPercent.glsl"
	#include "/import/sunsetColorPercent.glsl"
	#include "/import/sunLightBrightness.glsl"
	#include "/import/moonLightBrightness.glsl"
	
	vec3 sundayLight = SKYLIGHT_DAY_COLOR * sunDayColorPercent;
	vec3 sunriseLight = SKYLIGHT_SUNRISE_COLOR * sunriseColorPercent;
	vec3 sunsetLight = SKYLIGHT_SUNSET_COLOR * sunsetColorPercent;
	vec3 sunLight = (sundayLight + sunriseLight + sunsetLight) * sunLightBrightness;
	vec3 moonLight = SKYLIGHT_NIGHT_COLOR * moonLightBrightness;
	
	#include "/import/rainStrength.glsl"
	sunLight *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT);
	
	return (sunLight + moonLight) * 0.7;
	
}



#endif
