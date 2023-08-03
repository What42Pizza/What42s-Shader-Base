void doSharpening(inout vec3 color) {
	
	#if SHARPENING_DETECT_SIZE == 3
		
		vec3 colorTotal = color;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -1), 0).rgb / length(vec2(-1, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -1), 0).rgb / length(vec2( 0, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -1), 0).rgb / length(vec2( 1, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  0), 0).rgb / length(vec2(-1,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  0), 0).rgb / length(vec2( 1,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  1), 0).rgb / length(vec2(-1,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  1), 0).rgb / length(vec2( 0,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  1), 0).rgb / length(vec2( 1,  1));
		vec3 blur = colorTotal / 7.82842712474619; // value is pre-calculated total of weights + 1
		
	#elif SHARPENING_DETECT_SIZE == 5
		
		vec3 colorTotal = color;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -2), 0).rgb / length(vec2(-1, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -2), 0).rgb / length(vec2( 0, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -2), 0).rgb / length(vec2( 1, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2, -1), 0).rgb / length(vec2(-2, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -1), 0).rgb / length(vec2(-1, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -1), 0).rgb / length(vec2( 0, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -1), 0).rgb / length(vec2( 1, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2, -1), 0).rgb / length(vec2( 2, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  0), 0).rgb / length(vec2(-2,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  0), 0).rgb / length(vec2(-1,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  0), 0).rgb / length(vec2( 1,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  0), 0).rgb / length(vec2( 2,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  1), 0).rgb / length(vec2(-2,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  1), 0).rgb / length(vec2(-1,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  1), 0).rgb / length(vec2( 0,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  1), 0).rgb / length(vec2( 1,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  1), 0).rgb / length(vec2( 2,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  2), 0).rgb / length(vec2(-1,  2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  2), 0).rgb / length(vec2( 0,  2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  2), 0).rgb / length(vec2( 1,  2));
		vec3 blur = colorTotal / 13.406135888745856; // value is pre-calculated total of weights + 1
		
	#elif SHARPENING_DETECT_SIZE == 7
		
		vec3 colorTotal = color;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -3), 0).rgb / length(vec2(-1, -3));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -3), 0).rgb / length(vec2( 0, -3));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -3), 0).rgb / length(vec2( 1, -3));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2, -2), 0).rgb / length(vec2(-2, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -2), 0).rgb / length(vec2(-1, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -2), 0).rgb / length(vec2( 0, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -2), 0).rgb / length(vec2( 1, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2, -2), 0).rgb / length(vec2( 2, -2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-3, -1), 0).rgb / length(vec2(-3, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2, -1), 0).rgb / length(vec2(-2, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -1), 0).rgb / length(vec2(-1, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -1), 0).rgb / length(vec2( 0, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -1), 0).rgb / length(vec2( 1, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2, -1), 0).rgb / length(vec2( 2, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 3, -1), 0).rgb / length(vec2( 3, -1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-3,  0), 0).rgb / length(vec2(-3,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  0), 0).rgb / length(vec2(-2,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  0), 0).rgb / length(vec2(-1,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  0), 0).rgb / length(vec2( 1,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  0), 0).rgb / length(vec2( 2,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 3,  0), 0).rgb / length(vec2( 3,  0));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-3,  1), 0).rgb / length(vec2(-3,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  1), 0).rgb / length(vec2(-2,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  1), 0).rgb / length(vec2(-1,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  1), 0).rgb / length(vec2( 0,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  1), 0).rgb / length(vec2( 1,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  1), 0).rgb / length(vec2( 2,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 3,  1), 0).rgb / length(vec2( 3,  1));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  2), 0).rgb / length(vec2(-2,  2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  2), 0).rgb / length(vec2(-1,  2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  2), 0).rgb / length(vec2( 0,  2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  2), 0).rgb / length(vec2( 1,  2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  2), 0).rgb / length(vec2( 2,  2));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  3), 0).rgb / length(vec2(-1,  3));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  3), 0).rgb / length(vec2( 0,  3));
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  3), 0).rgb / length(vec2( 1,  3));
		vec3 blur = colorTotal / 18.683504912586983; // value is pre-calculated total of weights + 1
		
	#endif
	
	float cameraVel = length(cameraPosition - previousCameraPosition);
	cameraVel = min(cameraVel, 0.1);
	color = mix(color, blur, (SHARPEN_AMOUNT / 5.0 + cameraVel * SHARPEN_VEL_ADDITION * 2.0) * -1.0);
	//color = blur;
	
}
