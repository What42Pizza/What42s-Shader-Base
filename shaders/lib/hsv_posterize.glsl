#ifdef FIRST_PASS


// taken from: https://stackoverflow.com/a/17897228
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


float compress(float v, int quality) {
	const float slope = HSV_POSTERIZE_STEP_SLOPE;
	float sloped = (fract(v * quality) - 0.5) * slope + 0.5;
	sloped = clamp(sloped, 0.0, 1.0);
	return (sloped + floor(v * quality)) / quality;
}

//float compress(float v, int quality) { // creates optical illusion??
//	return v + 0.16 / quality * sin((2 * v + 1.0 / quality) * PI * quality);
//}


#endif



void doHsvPosterize(inout vec3 color  ARGS_OUT) {
	float depth = toLinearDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r  ARGS_IN);
	if (depthIsSky(depth)) {return;}
	color = rgb2hsv(color);
	#if HSV_POSTERIZE_HUE_QUALITY > 0
		color.x = compress(color.x, HSV_POSTERIZE_HUE_QUALITY);
	#endif
	#if HSV_POSTERIZE_SATURATION_QUALITY > 0
		color.y = compress(color.y, HSV_POSTERIZE_SATURATION_QUALITY);
	#endif
	#if HSV_POSTERIZE_BRIGHTNESS_QUALITY > 0
		color.z = compress(color.z, HSV_POSTERIZE_BRIGHTNESS_QUALITY);
	#endif
	color = hsv2rgb(color);
}
