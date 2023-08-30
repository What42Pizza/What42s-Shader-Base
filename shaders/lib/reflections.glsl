//---------------------------//
//        REFLECTIONS        //
//---------------------------//

// This code was originally taken from Complementary v4
// Link: https://modrinth.com/shader/complementary-shaders-v4



void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 normal) {
	vec3 screenPos = vec3(0.0);
	
	vec3 stepVector = reflect(normalize(viewPos), normalize(normal)) * 0.1;
	viewPos += stepVector;
	
	int hitCount = 0;
	
	for(int i = 0; i < 30; i++) {
		screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
		if (screenPos.x < -0.02 || screenPos.x > 1.02 || screenPos.y < -0.02 || screenPos.y > 1.02) break;
		
		float screenPosDepth = toBlockDepth(screenPos.z);
		if (screenPosDepth < 0.0 || screenPosDepth > far * 0.99) break;
		float realDepth = toBlockDepth(texture2D(depthtex1, screenPos.xy).r) * 1.01;
		float realToScreen = screenPosDepth - realDepth;
		float stepVectorLen = length(stepVector);
		
		if (realToScreen > stepVectorLen * 2.0 + 0.5) { // went behind object
			reflectionPos = screenPos.xy;
			error = 1;
			return;
		}
		if (realToScreen > 0.0) {
			hitCount ++;
			if (hitCount >= 6) { // converged on point
				reflectionPos = screenPos.xy;
				error = 0;
				return;
			}
			viewPos -= stepVector;
			stepVector *= 0.1;
		}
		
		stepVector *= 2.0;
		viewPos += stepVector;
	}
	
	error = 2;
}



void addReflection(inout vec3 color, vec3 viewPos, vec3 normal, sampler2D texture, float baseStrength, float fresnelStrength) {
	vec2 reflectionPos;
	int error;
	raytrace(reflectionPos, error, viewPos, normal);
	
	float fresnel = 1.0 + dot(normalize(viewPos), normal);
	fresnel *= fresnel;
	fresnel *= fresnel;
	float lerpAmount = baseStrength + fresnel * fresnelStrength;
	
	if (error == 0) {
		vec3 reflectionColor = texture2D(texture, reflectionPos).rgb;
		reflectionColor *= 0.8 + color.rgb * 0.2;
		lerpAmount *= clamp(8.0 - 8.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0);
		color.rgb = mix(color.rgb, reflectionColor, lerpAmount);
		
	} else if (error == 1) {
		color.rgb *= 1.0 - lerpAmount * 0.8;
		
	}
	
}
