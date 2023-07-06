float getOffsetAoInfluence (vec3 centerNormal, vec3 centerPos, vec2 offset) {
	
	vec3 offsetNormal = texture2D(NORMALS_BUFFER, texcoord + offset).rgb;
	vec3 offsetPos = texture2D(VIEW_POS_BUFFER, texcoord + offset).rgb;
	
	vec3 centerToOffset = offsetPos - centerPos;
	
	// exclude if occluder is behind normal plane
	float diffDotNormal = dot(normalize(centerToOffset), centerNormal);
	if (diffDotNormal < 0.1) {return 0.0;}
	
	// exclude if occluder is too far
	float posDiff = length(centerToOffset);
	float output = smoothstep(0.5, 0, posDiff);
	
	return output;
}



float getAoFactor() {
	
	vec2 noiseVec = randomVec2(rngStart) * 10.0;
	
	vec3 centerNormal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
	vec3 centerPos = texelFetch(VIEW_POS_BUFFER, texelcoord, 0).rgb;
	float centerPosLen = length(centerPos);
	if (centerPosLen > 1000.0) {return 0.0;}
	float scale = inversesqrt(centerPosLen) * AO_SIZE * 0.04;
	
	float total = 0.0;
	const int AO_SAMPLE_COUNT = AO_QUALITY * AO_QUALITY;
	for (int i = 0; i <= AO_SAMPLE_COUNT; i ++) {
		
		float len = (float(i) / AO_SAMPLE_COUNT + 0.1) * scale;
		vec2 offset = vec2(cos(i * noiseVec.x) * len / aspectRatio, sin(i * noiseVec.x) * len);
		
		total += getOffsetAoInfluence(centerNormal, centerPos, offset);
		
	}
	total *= 1.0 / AO_SAMPLE_COUNT;
	
	return total * 0.6;
}
