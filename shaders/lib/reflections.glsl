//---------------------------//
//        REFLECTIONS        //
//---------------------------//

// This code was originally taken from Complementary v4, but it's basically been completely rewritten



void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 normal) {
	
	vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
	vec3 viewStepVector = reflect(normalize(viewPos), normalize(normal));
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + viewStepVector)) * 0.5 + 0.5;
	vec3 stepVector = nextScreenPos - screenPos;
	screenPos = nextScreenPos;
	
	int hitCount = 0;
	
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
		
		float realDepth = texture2D(depthtex1, screenPos.xy).r * 1.0;
		float realToScreen = screenPos.z - realDepth;
		float stepVectorLen = length(stepVector);
		
		if (realToScreen > stepVectorLen){ // went behind object
			reflectionPos = screenPos.xy;
			error = 1;
			return;
		}
		if (realToScreen > 0.0 || (screenPos.x < -0.02 || screenPos.x > 1.02 || screenPos.y < -0.02 || screenPos.y > 1.02)) {
			hitCount ++;
			if (hitCount >= 6) { // converged on point
				reflectionPos = screenPos.xy;
				error = 0;
				return;
			}
			screenPos -= stepVector;
			stepVector *= 0.1;
		}
		
		stepVector *= REFLECTION_STEP_INCREASE;
		screenPos += stepVector;
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
		lerpAmount *= clamp(5.0 - 5.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0);
		color.rgb = mix(color.rgb, reflectionColor, lerpAmount);
		
	} else if (error == 1) {
		lerpAmount *= clamp(5.0 - 5.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0);
		color.rgb *= 1.0 - lerpAmount * 0.8;
		
	}
	
}
