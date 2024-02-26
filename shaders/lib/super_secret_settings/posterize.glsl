void sss_posterize(inout vec3 color  ARGS_OUT) {
	color = sqrt(color);
	color = floor(color * SSS_POSTERIZE_QUALITY + 0.5) / SSS_POSTERIZE_QUALITY;
	color *= color;
}
