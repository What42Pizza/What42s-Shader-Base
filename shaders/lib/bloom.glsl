vec3 sampleBloom(float sizeMult, inout uint rng) {
	vec3 bloomAddition = vec3(0.0);
	for (int layer = 0; layer < BLOOM_LEVELS; layer++) {
		float size = float(layer + 1) / BLOOM_LEVELS;
		size = pow(size, 1.25);
		size *= sizeMult;
		
		vec2 noiseVec = randomVec2(rng) * 0.02;
		vec2 coord = texcoord + noiseVec * size;
		float noise = noiseVec.x * 100000.0;
		
		size *= BLOOM_SIZE * 0.1;
		
		vec3 brightest = vec3(0.0);
		float brightestLum = 0.0;
		for (int i = 0; i <= BLOOM_SAMPLE_COUNT; i ++) {
			
			float len = sqrt(float(i) / BLOOM_SAMPLE_COUNT + 0.1) * size;
			vec2 offset = vec2(cos(i + noise) * len * invAspectRatio, sin(i + noise) * len);
			vec2 sampleCoord = coord + offset;
			
			vec3 sample = texture2D(BLOOM_BUFFER, sampleCoord).rgb;
			float sampleLum = getColorLum(sample);
			
			//float interpValue = float(sampleLum > getColorLum(brightest)); // doesn't seem any faster?
			//brightest = brightest * (1.0 - interpValue) + sample * interpValue;
			
			if (sampleLum > brightestLum) {
				brightest = sample;
				brightestLum = sampleLum;
			}
			
		}
		
		bloomAddition += brightest;
		
	}
	bloomAddition /= BLOOM_LEVELS;
	
	return bloomAddition * 0.08;
}



vec3 getBloomAddition(inout uint rng) {
	
	float depth = toBlockDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
	float sizeMult = inversesqrt(depth);
	
	vec3 bloomAddition = vec3(0.0);
	for (int i = 0; i < BLOOM_COMPUTE_COUNT; i++) {
		bloomAddition += sampleBloom(sizeMult, rng);
	}
	bloomAddition *= (1.0 / BLOOM_COMPUTE_COUNT) * BLOOM_AMOUNT * 2.0;
	
	#ifdef NETHER
		bloomAddition *= BLOOM_NETHER_MULT;
	#endif
	
	return bloomAddition;
}
