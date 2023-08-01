float getOffsetAoInfluence (vec3 centerNormal, vec3 centerPos, vec2 offset) {
	
	vec3 offsetPos = getViewPos(texcoord + offset);
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
	
	
	vec3 viewPos = getViewPos(texcoord);
	float viewPosLen = length(viewPos);
	if (viewPosLen == 0.0) {return 0.0;}
	
	float noise = randomFloat(rngStart) * 10.0;
	float scale = inversesqrt(viewPosLen) * AO_SIZE * 0.04;
	vec3 centerNormal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
	
	float total = 0.0;
	const int AO_SAMPLE_COUNT = AO_QUALITY * AO_QUALITY;
	for (int i = 0; i <= AO_SAMPLE_COUNT; i ++) {
		
		float len = (float(i) / AO_SAMPLE_COUNT + 0.1) * scale;
		vec2 offset = vec2(cos(i * noise) * len / aspectRatio, sin(i * noise) * len);
		
		total += getOffsetAoInfluence(centerNormal, viewPos, offset);
		
	}
	total *= 1.0 / AO_SAMPLE_COUNT;
	//total *= smoothstep();
	
	return total * 0.6;
}
