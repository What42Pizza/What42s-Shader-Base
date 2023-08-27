//---------------------------//
//        REFLECTIONS        //
//---------------------------//

// This code was originally taken from Complementary v4
// Link: https://modrinth.com/shader/complementary-shaders-v4



vec3 endMat(vec4 screenPos) {
	return screenPos.xyz/screenPos.w;
}

vec4 startMat(vec3 screenPos) {
	return vec4(screenPos.xyz, 1.0);
}

float cdist(vec2 coord) {
	return max(abs(coord.s-0.5) * 1.95, abs(coord.t-0.5) * 2.0);
}

vec2 Raytrace(vec3 viewPos, vec3 normal) {
	vec3 screenPos = vec3(0.0);
	
	vec3 stepVector = reflect(normalize(viewPos), normalize(normal)) * 0.1;
	viewPos += stepVector;
	
	int hitCount = 0;
	
	for(int i = 0; i < 30; i++) {
		screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
		if (screenPos.x < -0.02 || screenPos.x > 1.02 || screenPos.y < -0.02 || screenPos.y > 1.02) break;
		
		float screenPosDepth = toBlockDepth(screenPos.z);
		if (screenPosDepth < 0.0 || screenPosDepth > far * 0.9) break;
		float realDepth = toBlockDepth(texture2D(depthtex1, screenPos.xy).r) * 1.01;
		float realToScreen = screenPosDepth - realDepth;
		float stepVectorLen = length(stepVector);
		
		if (realToScreen > stepVectorLen * 2.0 + 0.5) return vec2(-2.0); // went behind surface
		if (realToScreen > 0.0) {
			hitCount ++;
			if (hitCount >= 6) return screenPos.xy; // converged on point
			viewPos -= stepVector;
			stepVector *= 0.1;
		}
		
		stepVector *= 2.0;
		viewPos += stepVector;
	}
	
	return vec2(-1.0);
}
