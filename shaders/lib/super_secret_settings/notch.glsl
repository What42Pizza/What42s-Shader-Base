#ifdef FIRST_PASS
	const float[16] notch_dither = float[16] (
		0.9, 0.9, 0.4, 0.4,
		0.9, 0.9, 0.4, 0.4,
		0.1, 0.1, 0.6, 0.6,
		0.1, 0.1, 0.6, 0.6
	);
#endif



void sss_notch(inout vec3 color  ARGS_OUT) {
	#include "/import/viewSize.glsl"
	vec2 halfSize = viewSize * 0.5;
	
	vec2 steppedCoord = floor(texcoord * halfSize) / halfSize;
	
	const int QUALITY = SSS_NOTCH_QUALITY;
	const float RG_NOISE = 1.0 / (QUALITY * 3 / 2);
	const float B_NOISE = RG_NOISE * 2.0;
	const int B_QUALITY = QUALITY / 2;
	
	ivec2 noiseCoord = ivec2(steppedCoord * halfSize * 2);
	float noise = notch_dither[(noiseCoord.x % 4) + (noiseCoord.y % 4) * 4];
	vec3 col = texture2D(MAIN_TEXTURE_COPY, steppedCoord).rgb + noise * vec3(RG_NOISE, RG_NOISE, B_NOISE);
	float r = floor(col.r * QUALITY) / QUALITY;
	float g = floor(col.g * QUALITY) / QUALITY;
	float b = floor(col.b * B_QUALITY) / B_QUALITY;
	color = vec3(r, g, b);
}
