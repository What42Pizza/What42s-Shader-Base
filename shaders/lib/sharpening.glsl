void doSharpening(inout vec3 color) {
	
	#if SHARPENING_DETECT_SIZE == 3
		
		vec3 colorTotal = color;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  1), 0).rgb * 0.801;
		vec3 blur = colorTotal / 7.784; // value is pre-calculated total of weights + 1 (weights are gaussian of (offset length over 3))
		
	#elif SHARPENING_DETECT_SIZE == 5
		
		vec3 colorTotal = color;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  2), 0).rgb * 0.574;
		vec3 blur = colorTotal / 13.94; // value is pre-calculated total of weights + 1 (weights are gaussian of (offset length over 3))
		
	#elif SHARPENING_DETECT_SIZE == 7
		
		vec3 colorTotal = color;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -3), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -3), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -3), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2, -2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2, -2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-3, -1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0, -1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 3, -1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-3,  0), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 3,  0), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-3,  1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 3,  1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-2,  2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 2,  2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2(-1,  3), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 0,  3), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_BUFFER, texelcoord + ivec2( 1,  3), 0).rgb * 0.329;
		vec3 blur = colorTotal / 20.688; // value is pre-calculated total of weights + 1 (weights are gaussian of (offset length over 3))
		
	#endif
	
	float sharpenAmount = SHARPEN_AMOUNT * 0.12 + sharpenVelocityFactor * SHARPEN_VEL_ADDITION;
	color = mix(color, blur, sharpenAmount * -1.0); // exaggerate the difference between the image and the blurred image
	//color = blur;
	
}
