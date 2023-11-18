//---------------------------//
//        REFLECTIONS        //
//---------------------------//

// This code was originally taken from Complementary v4, but it has been completely rewritten



/*
#ifdef FIRST_PASS
	vec3 nvec3(vec4 pos) {
		return pos.xyz/pos.w;
	}
	vec4 nvec4(vec3 pos) {
		return vec4(pos.xyz, 1.0);
	}
	float cdist(vec2 coord) {
		return max(abs(coord.s-0.5) * 1.95, abs(coord.t-0.5) * 2.0);
	}
#endif

vec4 Raytrace(sampler2D depthtex, vec3 viewPos, vec3 normal, float dither  ARGS_OUT) {
	vec3 pos = vec3(0.0);
	float dist = 0.0;

	#if AA > 1
		dither = fract(dither + frameTimeCounter);
	#endif

	vec3 start = viewPos;
    vec3 vector = reflect(normalize(viewPos), normalize(normal));
    viewPos += vector;
	vec3 tvector = vector;

    int sr = 0;

    for(int i = 0; i < 30; i++) {
		#include "/import/gbufferProjection.glsl"
        pos = nvec3(gbufferProjection * nvec4(viewPos)) * 0.5 + 0.5;
		if (pos.x < -0.05 || pos.x > 1.05 || pos.y < -0.05 || pos.y > 1.05) break;

		vec3 rfragpos = vec3(pos.xy, texture2D(depthtex,pos.xy).r);
		#include "/import/gbufferProjectionInverse.glsl"
        rfragpos = nvec3(gbufferProjectionInverse * nvec4(rfragpos * 2.0 - 1.0));
		dist = length(start - rfragpos);

        float err = length(viewPos - rfragpos);
		float lVector = length(vector);
		if (lVector > 1.0) lVector = pow(lVector, 1.14);
		if (err < lVector) {
                sr++;
                if(sr >= 6) break;
				tvector -= vector;
                vector *= 0.1;
		}
        vector *= 2.0;
        tvector += vector * (dither * 0.05 + 1.0);
		viewPos = start + tvector;
    }

	return vec4(pos, dist);
}



void addReflection(inout vec3 color, vec3 viewPos, vec3 normal, sampler2D texture, const float baseStrength, const float fresnelStrength  ARGS_OUT) {
//vec4 SimpleReflection(vec3 viewPos, vec3 normal, float dither, float skyLightFactor) {
	vec4 reflection = vec4(0.0);
	
	vec4 pos = Raytrace(depthtex1, viewPos, normal, 0.0  ARGS_IN);
	
	float border = clamp(1.0 - pow(cdist(pos.st), 50.0), 0.0, 1.0);
		
	if (pos.z < 1.0 - 1e-5) {
		float refDepth = texture2D(depthtex1, pos.st).r;
		reflection.a = float(0.999999 > refDepth);
		if (reflection.a > 0.001) {
			reflection.rgb = texture2D(MAIN_BUFFER, pos.st).rgb;
			//if (refDepth > 0.9995) reflection.rgb *= sqrt3(skyLightFactor);
		}
		reflection.a *= border;
	}
	
	color = reflection.rgb;
	
	//reflection.rgb = pow(reflection.rgb * 2.0, vec3(8.0));
	
	//return reflection;
}
*/



//#include "/utils/depth.glsl"

// newest:
///*
void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
	#include "/import/gbufferProjection.glsl"
	vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
	vec3 viewStepVector = reflect(normalize(viewPos), normalize(normal));
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + viewStepVector)) * 0.5 + 0.5;
	vec3 stepVector = nextScreenPos - screenPos;
	//stepVector *= 0.5;
	screenPos = nextScreenPos;
	//screenPos += stepVector;
	
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
//*/



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



///*
void addReflection(inout vec3 color, vec3 viewPos, vec3 normal, sampler2D texture, const float baseStrength, const float fresnelStrength  ARGS_OUT) {
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
	
	const float inputColorWeight = 0.4;
	
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
//*/
