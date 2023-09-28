//---------------------------//
//        REFLECTIONS        //
//---------------------------//

// This code was originally taken from Complementary v4, but it's basically been completely rewritten



void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
	#include "/import/gbufferProjection.glsl"
	vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
	vec3 viewStepVector = reflect(normalize(viewPos), normalize(normal));
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + viewStepVector)) * 0.5 + 0.5;
	vec3 stepVector = nextScreenPos - screenPos;
	screenPos = nextScreenPos;
	
	int hitCount = 0;
	
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
		
		float realDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
		float realToScreen = screenPos.z - realDepth;
		float stepVectorLen = length(stepVector);
		
		//if (realToScreen > stepVectorLen * 2) { // went behind object
		//	reflectionPos = screenPos.xy;
		//	error = 1;
		//	return;
		//}
		if (realToScreen > 0.0 && realToScreen < stepVectorLen * 5) {
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
		if (screenPos.x < -0.02 || screenPos.x > 1.02 || screenPos.y < -0.02 || screenPos.y > 1.02) {
			error = 2;
			return;
		}
		//float newLinearDepth = toLinearDepth(screenPos.z);
		//if (newLinearDepth < 0) { // went behind camera (maybe?)
		//	error = 2;
		//	return;
		//}
		//if (newLinearDepth > 1) { // went into sky (maybe?)
		//	reflectionPos = screenPos.xy;
		//	error = 0;
		//	return;
		//}
	}
	
	error = 2;
}



void addReflection(inout vec3 color, vec3 viewPos, vec3 normal, sampler2D texture, const float baseStrength, const float fresnelStrength  ARGS_OUT) {
	vec2 reflectionPos;
	int error;
	raytrace(reflectionPos, error, viewPos, normal  ARGS_IN);
	
	float fresnel = 1.0 + dot(normalize(viewPos), normal);
	fresnel *= fresnel;
	fresnel *= fresnel;
	float lerpAmount = baseStrength + fresnelStrength * fresnel;
	#include "/import/fogColor.glsl"
	#include "/import/eyeBrightness.glsl"
	vec3 alteredFogColor = fogColor * (0.25 + 0.75 * eyeBrightness.y / 240.0);
	
	if (error == 0) {
		vec3 reflectionColor = texture2DLod(texture, reflectionPos, 0).rgb;
		reflectionColor = mix(alteredFogColor, reflectionColor, clamp(5.0 - 5.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0));
		reflectionColor *= 0.8 + color * 0.2;
		color = mix(color, reflectionColor, lerpAmount);
		
	//} else if (error == 1) {
	//	reflectionPos = (reflectionPos + texcoord) / 2;//mix(texcoord, reflectionPos, randomFloat(rngStart));
	//	vec3 reflectionColor = texture2DLod(texture, reflectionPos, 0).rgb;
	//	reflectionColor = mix(fogColor, reflectionColor, clamp(5.0 - 5.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0));
	//	reflectionColor *= 0.8 + color * 0.2;
	//	color = mix(color, reflectionColor, lerpAmount);
		
	} else {
		vec3 reflectionColor = alteredFogColor;
		reflectionColor *= 0.8 + color * 0.2;
		color = mix(color, reflectionColor, lerpAmount);
		
	}
	
}
