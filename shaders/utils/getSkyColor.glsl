#undef INCLUDE_GET_SKY_COLOR

#if defined FIRST_PASS && !defined GET_SKY_COLOR_FIRST_FINISHED
	#define INCLUDE_GET_SKY_COLOR
	#define GET_SKY_COLOR_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined GET_SKY_COLOR_SECOND_FINISHED
	#define INCLUDE_GET_SKY_COLOR
	#define GET_SKY_COLOR_SECOND_FINISHED
#endif



#ifdef INCLUDE_GET_SKY_COLOR



float fogify(float x, float w  ARGS_OUT) {
	return w / (x * x + w);
}

#if DARKEN_SKY_UNDERGROUND == 1
	float getHorizonMultiplier(ARG_OUT) {
		#ifdef OVERWORLD
			
			#include "/import/invViewSize.glsl"
			#include "/import/gbufferProjectionInverse.glsl"
			#include "/import/upPosition.glsl"
			#include "/import/horizonAltitudeAddend.glsl"
			#include "/import/eyeBrightnessSmooth.glsl"
			
			vec4 screenPos = vec4(gl_FragCoord.xy * invViewSize, gl_FragCoord.z, 1.0);
			vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
			float viewDot = dot(normalize(viewPos.xyz), normalize(upPosition));
			float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightnessSmooth.y / 240.0); // don't darken sky when there's sky light
			return clamp(viewDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
			
		#else
			return 1.0;
		#endif
	}
#endif

vec3 getSkyColor(ARG_OUT) {
	
	#include "/import/invViewSize.glsl"
	#include "/import/gbufferProjectionInverse.glsl"
	#include "/import/gbufferModelView.glsl"
	#include "/import/skyColor.glsl"
	#include "/import/fogColor.glsl"
	
	vec3 alteredSkyColor = mix(vec3(getColorLum(skyColor)), skyColor, 0.8);
	
	vec4 pos = vec4(gl_FragCoord.xy * invViewSize * 2.0 - 1.0, 1.0, 1.0);
	pos = gbufferProjectionInverse * pos;
	float upDot = dot(normalize(pos.xyz), gbufferModelView[1].xyz);
	vec3 finalSkyColor = mix(alteredSkyColor, fogColor, fogify(max(upDot, 0.0), 0.25  ARGS_IN));
	
	#if DARKEN_SKY_UNDERGROUND == 1
		finalSkyColor *= getHorizonMultiplier(ARG_IN);
	#endif
	
	return finalSkyColor * SKY_BRIGHTNESS;
}



#endif
