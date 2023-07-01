float getSunraysAddition(int noiseOffset) {
	
	vec2 noiseVec = noiseVec2D(texcoord, noiseOffset) * 0.6;
	vec2 startPos = texcoord;
	vec2 coordStep = (lightCoord - startPos) / SUNRAY_STEP_COUNT;
	startPos += coordStep * noiseVec;
	
	float total = 0.0;
	for (int i = 1; i < SUNRAY_STEP_COUNT; i ++) {
		vec2 coords = startPos + coordStep * i;
		#ifdef SUNRAYS_FLICKERING_FIX
			if (coords.x < 0.0 || coords.x > 1.0 || coords.y < 0.0 || coords.y > 1.0) {
				total *= float(SUNRAY_STEP_COUNT) / i;
				break;
			}
		#endif
		float depth = getDepth(coords);
		if (depthIsSky(depth)) {
			total += 1 + float(i) / SUNRAY_STEP_COUNT;
		}
	}
	
	return sqrt(total / SUNRAY_STEP_COUNT) * 0.3;
}
