float getSunraysAmount(inout uint rng) {
	
	
	#if SUNRAYS_STYLE == 1
		vec2 pos = texcoord;
		float noise = (randomFloat(rng) - 1.0) * 0.2 + 1.0;
		vec2 coordStep = (lightCoord - pos) / SUNRAY_SAMPLE_COUNT * noise;
		
	#elif SUNRAYS_STYLE == 2
		vec2 pos = texcoord;
		vec2 coordStep = (lightCoord - pos) / SUNRAY_SAMPLE_COUNT;
		float noise = randomFloat(rng) * 0.7;
		pos += coordStep * noise;
		
	#endif
	
	float total = 0.0;
	for (int i = 1; i < SUNRAY_SAMPLE_COUNT; i ++) {
		#ifdef SUNRAYS_FLICKERING_FIX
			if (pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0) {
				total *= float(SUNRAY_SAMPLE_COUNT) / i;
				break;
			}
		#endif
		float depth = texelFetch(DEPTH_BUFFER_ALL, ivec2(pos * viewSize), 0).r;
		if (depthIsSky(toLinearDepth(depth))) {
			total += 1.0 + float(i) / SUNRAY_SAMPLE_COUNT;
		}
		pos += coordStep;
	}
	total /= SUNRAY_SAMPLE_COUNT;
	
	if (total > 0.0) total = max(total, 0.2);
	
	return sqrt(total) * 0.3;
}
