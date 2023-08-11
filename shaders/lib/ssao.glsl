float estimateDistance(float linearDepth) {
	float len = length(texcoord * 2.0 - 1.0);
	return linearDepth + len * len / 8.0; // never underestimate trial and error
}



float getAoInfluence(float centerDepth, vec2 offset) {
	
	float depth1 = toLinearDepth(texture2D(DEPTH_BUFFER_ALL, texcoord + offset).r);
	float depth2 = toLinearDepth(texture2D(DEPTH_BUFFER_ALL, texcoord - offset).r);
	float diff1 = centerDepth - depth1;
	float diff2 = centerDepth - depth2;
	
	float output = float(diff1 + diff2 > 0.0001);
	output *= smoothstep(0.01, 0.0, diff1);
	output *= smoothstep(0.01, 0.0, diff2);
	
	return output;
}



float getAoFactor() {
	
	float depth = toLinearDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
	float noise = randomFloat(rngStart) * 10.0;
	float scale = inversesqrt(depth * far) * AO_SIZE * 0.1;
	
	float total = 0.0;
	for (int i = 1; i <= AO_SAMPLE_COUNT; i ++) {
		
		float len = (float(i) / AO_SAMPLE_COUNT + 0.1) * scale;
		vec2 offset = vec2(cos(i * noise) * len * invAspectRatio, sin(i * noise) * len);
		
		total += getAoInfluence(depth, offset);
		
	}
	total /= AO_SAMPLE_COUNT;
	total *= smoothstep(0.8, 0.7, estimateDistance(depth));
	
	return total * 0.4;
}
