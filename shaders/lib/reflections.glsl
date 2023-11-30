//---------------------------//
//        REFLECTIONS        //
//---------------------------//

// This code was originally taken from Complementary v4, but it has been completely rewritten



void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
	#include "/import/gbufferProjection.glsl"
	vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
	vec3 viewStepVector = reflect(normalize(viewPos), normalize(normal));
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + viewStepVector)) * 0.5 + 0.5;
	vec3 stepVector = nextScreenPos - screenPos;
	//stepVector *= 0.5;
	//screenPos = nextScreenPos;
	//screenPos += stepVector;
	
	#include "/utils/var_rng.glsl"
	screenPos = mix(screenPos, nextScreenPos, (randomFloat(rng) + 1.0) * 0.6);
	
	int hitCount = 0;
	
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
		
		float realDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
		float realToScreen = screenPos.z - realDepth;
		
		if (realDepth < 0.8) {
			error = 2;
			return;
		}
		if (realToScreen > pow(stepVector.z, 0.3) * 0.15) { // went behind object
		//if (realToScreen > pow(stepVector.z, 0.2) * 0.03) { // went behind object
			//error = 1;
			//return;
			#include "/utils/var_rng.glsl"
			reflectionPos = mix(nextScreenPos.xy, screenPos.xy, randomFloat(rng) * 0.5 + 0.5);
			//screenPos -= stepVector * (randomFloat(rng) * 0.5 + 0.5);
			//reflectionPos = screenPos.xy;
			error = 0;
			return;
		}
		//if (realToScreen > stepVector.z * 2) { // went behind object
		//	error = 1;
		//	return;
		//	if (realDepth < 0.98) {
		//		error = 2;
		//		return;
		//	}
		//	#include "/utils/var_rng.glsl"
		//	screenPos -= stepVector * randomFloat(rng);
		//	reflectionPos = screenPos.xy;
		//	error = 0;
		//	return;
		//}
		if (realToScreen > 0.0) {
			hitCount ++;
			if (hitCount >= 6) { // converged on point
				reflectionPos = screenPos.xy;
				error = 0;
				return;
			}
			screenPos -= stepVector;
			stepVector *= 0.5;
		}
		
		stepVector *= REFLECTION_STEP_INCREASE;
		screenPos += stepVector;
		if (screenPos.x < -0.1 || screenPos.x > 1.1 || screenPos.y < -0.1 || screenPos.y > 1.1) {
			error = 2;
			return;
		}
	}
	
	error = 2;
}



// old:
/*
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
		//float stepVectorLen = length(stepVector);
		
		if (realToScreen > stepVector.z) { // went behind object
			if (realDepth < 0.98) {
				error = 2;
				return;
			}
			#include "/utils/var_rng.glsl"
			screenPos -= stepVector * randomFloat(rng);
			reflectionPos = screenPos.xy;
			error = 0;
			return;
		}
		if (realToScreen > 0.0) {//} && realToScreen < stepVectorLen * 5) {
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
		//float newLinearDepth = toLinearDepth(screenPos.z * 0.5 + 0.5  ARGS_IN);
		//if (newLinearDepth < 0.0) { // went behind camera (maybe?)
		//	error = 1;
		//	return;
		//}
		//if (newLinearDepth > 1.0) { // went into sky (maybe?)
		//	//reflectionPos = screenPos.xy;
		//	error = 1;
		//	return;
		//}
	}
	
	error = 2;
}
*/



// even older:
/*
void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
	#include "/import/gbufferProjection.glsl"
	vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
	vec3 viewStepVector = reflect(normalize(viewPos), normalize(normal));
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + viewStepVector)) * 0.5 + 0.5;
	vec3 stepVector = nextScreenPos - screenPos;
	screenPos = nextScreenPos;
	
	int hitCount = 0;
	
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
		
		float realDepth = texture2D(depthtex1, screenPos.xy).r;
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
*/



void addReflection(inout vec3 color, vec3 viewPos, vec3 normal, sampler2D texture, float baseStrength, float fresnelStrength  ARGS_OUT) {
	vec2 reflectionPos;
	int error;
	raytrace(reflectionPos, error, viewPos, normal  ARGS_IN);
	
	float fresnel = 1.0 - abs(dot(normalize(viewPos), normal));
	fresnel *= fresnel;
	fresnel *= fresnel;
	float lerpAmount = baseStrength + fresnelStrength * fresnel;
	#include "/import/fogColor.glsl"
	#include "/import/eyeBrightness.glsl"
	vec3 alteredFogColor = fogColor * (0.25 + 0.75 * eyeBrightness.y / 240.0);
	
	const float inputColorWeight = 0.2;
	
	if (error == 0) {
		vec3 reflectionColor = texture2DLod(texture, reflectionPos, 0).rgb;
		reflectionColor = mix(alteredFogColor, reflectionColor, clamp(5.0 - 5.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0));
		reflectionColor *= (1.0 - inputColorWeight) + color * inputColorWeight;
		color = mix(color, reflectionColor, lerpAmount);
		
	//} else if (error == 1) {
	//	color *= vec3(1.0, 0.1, 0.1);
		
	//} else if (error == 1) {
	//	reflectionPos = (reflectionPos + texcoord) / 2;//mix(texcoord, reflectionPos, randomFloat(rngStart));
	//	vec3 reflectionColor = texture2DLod(texture, reflectionPos, 0).rgb;
	//	reflectionColor = mix(fogColor, reflectionColor, clamp(5.0 - 5.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0));
	//	reflectionColor *= 0.8 + color * 0.2;
	//	color = mix(color, reflectionColor, lerpAmount);
		
	} else {
		vec3 reflectionColor = alteredFogColor;
		reflectionColor *= (1.0 - inputColorWeight) + color * inputColorWeight;
		color = mix(color, reflectionColor, lerpAmount);
		
	}
	
}
