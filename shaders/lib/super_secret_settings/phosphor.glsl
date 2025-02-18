void sss_phosphor(inout vec3 color  ARGS_OUT) {
	vec3 prev = texelFetch(PREV_TEXTURE, texelcoord, 0).rgb;
	
	vec3 curvedColor = pow(color, vec3(SSS_PHOSPHOR_CURVE));
	vec3 curvedPrev = pow(prev, vec3(SSS_PHOSPHOR_CURVE));
	vec3 blurred = max(curvedColor, curvedPrev * SSS_PHOSPHOR_AMOUNT);
	color = pow(blurred, vec3(1.0 / SSS_PHOSPHOR_CURVE));
}
