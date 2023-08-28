float getAoInfluence(float centerDepth, vec2 offset) {
	
	float depth1 = toLinearDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord + offset).r);
	float depth2 = toLinearDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord - offset).r);
	float diff1 = centerDepth - depth1;
	float diff2 = centerDepth - depth2;
	
	float output = float(diff1 + diff2 > 0.0001);
	output *= smoothstep(0.01, 0.0, diff1);
	output *= smoothstep(0.01, 0.0, diff2);
	
	return output;
}



float getAoFactor() {
	
	float depth = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r);
	float noise = normalizeNoiseAround1(randomFloat(rngStart), 0.3);
	float scale = AO_SIZE * 0.13 / (depth * far);
	
	float total = 0.0;
	float maxTotal = 0.0; // this doesn't seem to have any performance impact vs total/=SAMPLE_COUNT at the end, so it's probably being pre-computed at comp-time
	const int SAMPLE_COUNT = AO_QUALITY * AO_QUALITY;
	for (int i = 1; i <= SAMPLE_COUNT; i ++) {
		
		float len = (float(i) / SAMPLE_COUNT + 0.3) * scale;
		vec2 offset = vec2(cos(i * noise) * len * invAspectRatio, sin(i * noise) * len);
		
		float weight = 2.0 - float(i) / SAMPLE_COUNT;
		total += getAoInfluence(depth, offset) * weight;
		maxTotal += weight;
		
	}
	total /= maxTotal;
	total *= smoothstep(0.8, 0.7, estimateDepthFSH(texcoord, depth));
	
	return total * 0.35;
}
