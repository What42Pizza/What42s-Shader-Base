#ifdef FIRST_PASS
	flat vec2 lightCoord;
	flat float sunraysAmountMult;
#endif

#include "/utils/depth.glsl"



#ifdef FSH

float getSunraysAmount(inout uint rng  ARGS_OUT) {
	const int SAMPLE_COUNT = int(SUNRAYS_QUALITY * SUNRAYS_QUALITY / 2);
	
	
	#if SUNRAYS_STYLE == 1
		vec2 pos = texcoord;
		float noise = (randomFloat(rng) - 1.0) * 0.2 + 1.0;
		vec2 coordStep = (lightCoord - pos) / SAMPLE_COUNT * noise;
		
	#elif SUNRAYS_STYLE == 2
		vec2 pos = texcoord;
		vec2 coordStep = (lightCoord - pos) / SAMPLE_COUNT;
		float noise = randomFloat(rng) * 0.7;
		pos += coordStep * noise;
		
	#endif
	
	float total = 0.0;
	for (int i = 1; i < SAMPLE_COUNT; i ++) {
		#ifdef SUNRAYS_FLICKERING_FIX
			if (pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0) {
				total *= float(SAMPLE_COUNT) / i;
				break;
			}
		#endif
		#include "/import/viewSize.glsl"
		float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, ivec2(pos * viewSize), 0).r;
		if (depthIsSky(toLinearDepth(depth  ARGS_IN))) {
			total += 1.0 + float(i) / SAMPLE_COUNT;
		}
		pos += coordStep;
	}
	total /= SAMPLE_COUNT;
	
	if (total > 0.0) total = max(total, 0.2);
	
	float output = sqrt(total) * sunraysAmountMult;
	output *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
	
	return output;
}

#endif



#ifdef VSH

void calculateLightCoord(ARG_OUT) {
	
	#include "/import/shadowLightPosition.glsl"
	#include "/import/gbufferProjection.glsl"
	vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
	lightPos /= lightPos.z;
	lightCoord = lightPos.xy * 0.5 + 0.5;
	
}

// this entire function SHOULD be computed on the cpu, but it has to be glsl code because it uses settings that are ONLY defined in glsl
void calculateSunraysAmount(ARG_OUT) {
	#include "/import/ambientSunPercent.glsl"
	#include "/import/ambientMoonPercent.glsl"
	#include "/import/ambientSunrisePercent.glsl"
	#include "/import/ambientSunsetPercent.glsl"
	#include "/import/isOtherLightSource.glsl"
	#include "/import/isSun.glsl"
	
	if (isSun) {
		sunraysAmountMult = 
			ambientSunPercent * SUNRAYS_AMOUNT_DAY +
			ambientSunrisePercent * SUNRAYS_AMOUNT_SUNRISE +
			ambientSunsetPercent * SUNRAYS_AMOUNT_SUNSET;
	} else {
		sunraysAmountMult = (ambientMoonPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.5) * SUNRAYS_AMOUNT_NIGHT;
	}
	
	sunraysAmountMult *= 0.3;
	
}

#endif
