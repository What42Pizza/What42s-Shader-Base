vec3 getBlurredColor(vec2 coord, float size) {
	vec3 colorTotal = vec3(0.0);
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1, -2) * pixelSize * size, 0).rgb / length(vec2(-1, -2));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0, -2) * pixelSize * size, 0).rgb / length(vec2( 0, -2));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1, -2) * pixelSize * size, 0).rgb / length(vec2( 1, -2));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2, -1) * pixelSize * size, 0).rgb / length(vec2(-2, -1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1, -1) * pixelSize * size, 0).rgb / length(vec2(-1, -1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0, -1) * pixelSize * size, 0).rgb / length(vec2( 0, -1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1, -1) * pixelSize * size, 0).rgb / length(vec2( 1, -1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2, -1) * pixelSize * size, 0).rgb / length(vec2( 2, -1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2,  0) * pixelSize * size, 0).rgb / length(vec2(-2,  0));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  0) * pixelSize * size, 0).rgb / length(vec2(-1,  0));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  0) * pixelSize * size, 0).rgb;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  0) * pixelSize * size, 0).rgb / length(vec2( 1,  0));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2,  0) * pixelSize * size, 0).rgb / length(vec2( 2,  0));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2,  1) * pixelSize * size, 0).rgb / length(vec2(-2,  1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  1) * pixelSize * size, 0).rgb / length(vec2(-1,  1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  1) * pixelSize * size, 0).rgb / length(vec2( 0,  1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  1) * pixelSize * size, 0).rgb / length(vec2( 1,  1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2,  1) * pixelSize * size, 0).rgb / length(vec2( 2,  1));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  2) * pixelSize * size, 0).rgb / length(vec2(-1,  2));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  2) * pixelSize * size, 0).rgb / length(vec2( 0,  2));
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  2) * pixelSize * size, 0).rgb / length(vec2( 1,  2));
	return colorTotal / 13.406135888745856; // value is pre-calculated total of weights
}



void doDOF(inout vec3 color) {
	
	float focusDepth = centerLinearDepthSmooth;
	float linearDepth = toLinearDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
	float depthChange = linearDepth - focusDepth;
	
	float nearBlurAmount = depthChange * (-1.0 / DOF_NEAR_BLUR_SLOPE) - (DOF_NEAR_BLUR_START / DOF_NEAR_BLUR_SLOPE);
	nearBlurAmount = clamp(nearBlurAmount, 0.0, 1.0) * DOF_NEAR_BLUR_STRENGTH;
	vec3 nearBlur = getBlurredColor(texcoord, nearBlurAmount * DOF_NEAR_BLUR_SIZE);
	
	float farBlurAmount = depthChange * (1.0 / DOF_FAR_BLUR_SLOPE) - (DOF_FAR_BLUR_START / DOF_FAR_BLUR_SLOPE);
	farBlurAmount = clamp(farBlurAmount, 0.0, 1.0) * DOF_FAR_BLUR_STRENGTH;
	vec3 farBlur = getBlurredColor(texcoord, farBlurAmount * DOF_FAR_BLUR_SIZE);
	
	color = mix(color, farBlur, farBlurAmount);
	color = mix(color, nearBlur, nearBlurAmount);
	
}
