vec3 getBloomAddition(float sizeMult, int noiseOffset) {
	vec3 bloomAddition = vec3(0.0);
	for (int layer = 0; layer < BLOOM_LEVELS; layer++) {
		float size = float(layer + 1) / BLOOM_LEVELS;
		float layerLen = size * sizeMult * BLOOM_SIZE * 0.2;
		
		vec2 noiseVec = noiseVec2D(texcoord, noiseOffset * BLOOM_LEVELS * 2 + layer);
		vec2 coord = texcoord + noiseVec * size * sizeMult * 0.1;
		
		vec3 brightest = vec3(0.0);
		float brightestLum = 0.0;
		const int BLOOM_SAMPLE_COUNT = BLOOM_QUALITY * BLOOM_QUALITY;
		for (int i = 0; i <= BLOOM_SAMPLE_COUNT; i ++) {
			
			float len = sqrt(float(i) / BLOOM_SAMPLE_COUNT + 0.1) * layerLen;
			float angle = float(i) + noiseVec.x * 10.0;
			vec2 offset = vec2(cos(angle) * len / aspectRatio, sin(angle) * len);
			vec2 sampleCoord = coord + offset;
			
			vec3 sample = texelFetch(colortex2, ivec2(sampleCoord / pixelSize), 0).rgb;
			float sampleLum = getColorLum(sample); // for some reason, having this value pre-calculated and stored in its own buffer is slower (but pre-calculating the bloom sky color and putting it in its own buffer is slightly faster??? maybe I need to re-try doing this?)
			if (sampleLum > brightestLum) {
				brightest = sample;
				brightestLum = sampleLum;
			}
			
		}
		
		bloomAddition += brightest;
		
	}
	return bloomAddition / BLOOM_LEVELS;
}
