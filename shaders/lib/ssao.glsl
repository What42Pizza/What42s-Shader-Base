vec3 projectPointToPlane(vec3 v, vec3 planePoint, vec3 planeNormal) {
	vec3 VP = v - planePoint;
	float VPdotN = dot(VP, planeNormal);
	return v - VPdotN * planeNormal;
}



float getOffsetAoInfluence (vec3 centerNormal, vec3 centerPos, vec2 offset) {
	
	vec3 offsetNormal = texture2D(NORMALS_BUFFER, texcoord + offset).rgb;
	vec3 offsetPos = texture2D(PLAYER_POS_BUFFER, texcoord + offset).rgb;
	
	// exclude if occluder is too far
	float posDiff = length(centerPos - offsetPos);
	if (posDiff > 0.5) {return 0.0;}
	
	// exclude if occluder is behind normal plane
	float diffDotNormal = dot(offsetPos - centerPos, centerNormal);
	if (diffDotNormal < -0.01) {return 0.0;}
	
	// TODO: replace with thing that projects the offset point onto the center line (difined be the point and the normal) then does the same with offsetPos + offsetNormal * 0.01 and compares it it's closer
	float dist1 = length(centerPos - projectPointToPlane(offsetPos, centerPos, centerNormal));
	float dist2 = length(centerPos - projectPointToPlane(offsetPos + offsetNormal * 0.01, centerPos, centerNormal));
	if (dist2 >= dist1) {return 0.0;}
	
	return 1.0;
}



float getAoFactor() {
	
	vec2 noiseVec = noiseVec2D(texcoord, frameCounter) * 0.1;
	//vec2 coord = texcoord + noiseVec;
	
	vec3 centerNormal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
	vec3 centerPos = texelFetch(PLAYER_POS_BUFFER, texelcoord, 0).rgb;
	float centerPosLen = length(centerPos);
	if (centerPosLen > 1000.0) {return 0.0;}
	float scale = inversesqrt(centerPosLen);
	
	float total = 0.0;
	const int AO_SAMPLE_COUNT = 10;
	for (int i = 0; i <= AO_SAMPLE_COUNT; i ++) {
		
		float len = sqrt(float(i) / AO_SAMPLE_COUNT + 0.1) * scale * 0.02;
		vec2 offset = vec2(cos(i + noiseVec.x) * len / aspectRatio, sin(i + noiseVec.x) * len);
		
		total += getOffsetAoInfluence(centerNormal, centerPos, offset);
		
	}
	total *= 1.0 / AO_SAMPLE_COUNT;
	
	//float total = 0.0;
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2( 1.0,  0.0) * AO_SIZE * scale * 0.01);
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2( 0.0,  1.0) * AO_SIZE * scale * 0.01);
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2(-1.0,  0.0) * AO_SIZE * scale * 0.01);
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2( 0.0, -1.0) * AO_SIZE * scale * 0.01);
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2( 1.0,  1.0) * AO_SIZE * scale * 0.007);
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2(-1.0,  1.0) * AO_SIZE * scale * 0.007);
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2( 1.0, -1.0) * AO_SIZE * scale * 0.007);
	//total += getOffsetAoInfluence(centerNormal, centerPos, vec2(-1.0, -1.0) * AO_SIZE * scale * 0.007);
	//total *= 1.0 / 8.0;
	
	return total;
}
