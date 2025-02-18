//---------------------------//
//        REFLECTIONS        //
//---------------------------//



void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
	#include "/import/gbufferProjection.glsl"
	vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
	vec3 viewStepVector = reflect(normalize(viewPos), normalize(normal));
	//viewStepVector /= dot(viewStepVector.xy, viewStepVector.xy);
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + viewStepVector)) * 0.5 + 0.5;
	vec3 stepVector = nextScreenPos - screenPos;
	//stepVector *= 0.5;
	//screenPos = nextScreenPos;
	//screenPos += stepVector;
	
	#include "/utils/var_rng.glsl"
	screenPos = mix(screenPos, nextScreenPos, (randomFloat(rng) + 1.5) * 0.6);
	
	int hitCount = 0;
	
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
		
		float realDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
		#ifdef DISTANT_HORIZONS
			vec3 realBlockViewPos = screenToView(vec3(texcoord, realDepth)  ARGS_IN);
			float realDepthDh = texture2D(DH_DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
			vec3 realBlockViewPosDh = screenToViewDh(vec3(texcoord, realDepthDh)  ARGS_IN);
			if (length(realBlockViewPosDh) < length(realBlockViewPos)) realBlockViewPos = realBlockViewPosDh;
			#include "/import/gbufferProjection.glsl"
			vec4 sampleScreenPos = gbufferProjection * vec4(realBlockViewPos, 1.0);
			realDepth = sampleScreenPos.z / sampleScreenPos.w * 0.5 + 0.5;
		#endif
		float realToScreen = screenPos.z - realDepth;
		
		if (realToScreen > pow(stepVector.z, 0.3) * 0.15) { // went behind object
			#include "/utils/var_rng.glsl"
			reflectionPos = mix(nextScreenPos.xy, screenPos.xy, randomFloat(rng) * 0.4 + 0.5);
			error = 0;
			return;
		}
		if (realToScreen > 0.0) {
			hitCount ++;
			if (hitCount >= 10) { // converged on point
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
	//viewStepVector /= dot(viewStepVector.xy, viewStepVector.xy);
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + viewStepVector)) * 0.5 + 0.5;
	vec3 stepVector = nextScreenPos - screenPos;
	//stepVector *= 0.5;
	//screenPos = nextScreenPos;
	//screenPos += stepVector;
	
	#include "/utils/var_rng.glsl"
	screenPos = mix(screenPos, nextScreenPos, (randomFloat(rng) + 1.5) * 0.6);
	
	int hitCount = 0;
	
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
		
		float realDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
		float realToScreen = screenPos.z - realDepth;
		
		if (realToScreen > pow(stepVector.z, 0.3) * 0.15) { // went behind object
		//if (realToScreen > pow(stepVector.z, 0.2) * 0.03) { // went behind object
			//error = 1;
			//return;
			#include "/utils/var_rng.glsl"
			reflectionPos = mix(nextScreenPos.xy, screenPos.xy, randomFloat(rng) * 0.4 + 0.5);
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
			if (hitCount >= 10) { // converged on point
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
*/



void addReflection(inout vec3 color, vec3 viewPos, vec3 normal, sampler2D texture, float reflectionStrength  ARGS_OUT) {
	vec2 reflectionPos;
	int error;
	raytrace(reflectionPos, error, viewPos, normal  ARGS_IN);
	
	float fresnel = 1.0 - abs(dot(normalize(viewPos), normal));
	fresnel *= fresnel;
	fresnel *= fresnel;
	reflectionStrength *= 1.0 - REFLECTION_FRESNEL * (1.0 - fresnel);
	#include "/import/fogColor.glsl"
	#include "/import/eyeBrightness.glsl"
	vec3 alteredFogColor = fogColor * (0.25 + 0.75 * eyeBrightness.y / 240.0);
	
	const float inputColorWeight = 0.2;
	
	if (error == 0) {
		vec3 reflectionColor = texture2DLod(texture, reflectionPos, 0).rgb;
		float fadeOutSlope = 1.0 / (max(normal.z, 0.0) + 0.0001);
		reflectionColor = mix(alteredFogColor, reflectionColor, clamp(fadeOutSlope - fadeOutSlope * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0));
		reflectionColor *= (1.0 - inputColorWeight) + color * inputColorWeight;
		color = mix(color, reflectionColor, reflectionStrength);
		
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
		color = mix(color, reflectionColor, reflectionStrength);
		
	}
	//color = vec3(reflectionPos, 0);
	
}
