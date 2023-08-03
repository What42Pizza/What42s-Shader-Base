void doMotionBlur(inout vec3 color, vec2 prevCoord) {
	
	vec2 coordStep = (prevCoord - texcoord) / MOTION_BLUR_SAMPLE_COUNT * MOTION_BLUR_AMOUNT * 0.7;
	vec2 pos = texcoord;
	
	for (int i = 0; i < MOTION_BLUR_SAMPLE_COUNT; i ++) {
		pos += coordStep;
		color += texture2D(TAA_PREV_BUFFER, pos).rgb;
	}
	
	color /= MOTION_BLUR_SAMPLE_COUNT + 1;
	
}
