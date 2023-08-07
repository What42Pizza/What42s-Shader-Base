vec3 getBlurredColor(vec2 coord, float size) {
	vec3 colorTotal = vec3(0.0);
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1, -2) * pixelSize * size, 0).rgb * 0.287;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0, -2) * pixelSize * size, 0).rgb * 0.368;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1, -2) * pixelSize * size, 0).rgb * 0.287;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2, -1) * pixelSize * size, 0).rgb * 0.287;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1, -1) * pixelSize * size, 0).rgb * 0.607;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0, -1) * pixelSize * size, 0).rgb * 0.779;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1, -1) * pixelSize * size, 0).rgb * 0.607;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2, -1) * pixelSize * size, 0).rgb * 0.287;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2,  0) * pixelSize * size, 0).rgb * 0.368;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  0) * pixelSize * size, 0).rgb * 0.779;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  0) * pixelSize * size, 0).rgb * 1.0;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  0) * pixelSize * size, 0).rgb * 0.779;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2,  0) * pixelSize * size, 0).rgb * 0.368;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2,  1) * pixelSize * size, 0).rgb * 0.287;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  1) * pixelSize * size, 0).rgb * 0.607;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  1) * pixelSize * size, 0).rgb * 0.779;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  1) * pixelSize * size, 0).rgb * 0.607;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2,  1) * pixelSize * size, 0).rgb * 0.287;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  2) * pixelSize * size, 0).rgb * 0.287;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  2) * pixelSize * size, 0).rgb * 0.368;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  2) * pixelSize * size, 0).rgb * 0.287;
	return colorTotal / 9.986016; // value is pre-calculated total of weights (weights are gaussian of (offset length over 2))
}



#ifdef DEBUG_OUTPUT_ENABLED
	#define DEBUG_ARG_OUT , inout vec3 debugOutput
#else
	#define DEBUG_ARG_OUT
#endif

void doDOF(inout vec3 color DEBUG_ARG_OUT) {
	
	#ifdef DOF_LOCKED_FOCAL_PLANE
		float focusDepth = DOF_FOCAL_PLANE_DISTANCE / far;
	#else
		float focusDepth = centerLinearDepthSmooth;
	#endif
	
	float linearDepth = toLinearDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
	float depthChange = linearDepth - focusDepth;
	
	float nearBlurAmount = depthChange * (-1.0 / DOF_NEAR_BLUR_SLOPE) - (DOF_NEAR_BLUR_START / DOF_NEAR_BLUR_SLOPE);
	nearBlurAmount = clamp(nearBlurAmount, 0.0, 1.0) * DOF_NEAR_BLUR_STRENGTH;
	vec3 nearBlur = getBlurredColor(texcoord, nearBlurAmount * DOF_NEAR_BLUR_SIZE);
	
	float farBlurAmount = depthChange * (1.0 / DOF_FAR_BLUR_SLOPE) - (DOF_FAR_BLUR_START / DOF_FAR_BLUR_SLOPE);
	farBlurAmount = clamp(farBlurAmount, 0.0, 1.0) * DOF_FAR_BLUR_STRENGTH;
	vec3 farBlur = getBlurredColor(texcoord, farBlurAmount * DOF_FAR_BLUR_SIZE);
	
	#ifdef DOF_SHOW_AMOUNTS
		debugOutput = vec3(nearBlurAmount, farBlurAmount, 0.0);
	#endif
	
	color = mix(color, farBlur, farBlurAmount);
	color = mix(color, nearBlur, nearBlurAmount);
	
}
