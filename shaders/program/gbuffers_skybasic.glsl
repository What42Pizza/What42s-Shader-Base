#ifdef FIRST_PASS
	varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
#endif



#ifdef FSH

#include "/utils/getSkyColor.glsl"

void main() {
	
	vec3 albedo = getSkyColor(ARG_IN);
	if (starData.a > 0.5) {
		albedo = starData.rgb;
		#if DARKEN_STARS_NEAR_BLOCKLIGHT == 1
			#include "/import/eyeBrightnessSmooth.glsl"
			float blockBrightness = eyeBrightnessSmooth.x / 240.0;
			blockBrightness = min(blockBrightness * 8.0, 1.0);
			albedo *= blockBrightness * (DARKENED_STARS_BRIGHTNESS - 1.0) + 1.0;
		#endif
	}
	
	
	/*
		0.0: albedo.r
		0.1: albedo.g
		0.2: albedo.b
		1.0: lmcoord.x & lmcoord.y
		1.1: normal x & normal y
		1.2: gl_Color brightness (squared 'length' of gl_Color) * 0.25
		1.3: block id
	*/
	/* DRAWBUFFERS:01 */
	gl_FragData[0] = vec4(albedo, 1.0);
	gl_FragData[1] = vec4(
		packVec2(0.0, 0.0),
		packVec2(0.0, 0.0),
		0.75,
		0.0
	);
	
}

#endif





#ifdef VSH

#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	gl_Position = ftransform();
	bool isStar = gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0;
	starData = vec4(gl_Color.rgb * STARS_BRIGHTNESS, float(isStar));
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
}

#endif
