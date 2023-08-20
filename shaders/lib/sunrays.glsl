#ifdef SUNRAYS_ENABLED
	flat vec2 lightCoord;
	flat float sunraysAmountMult;
#endif



#ifdef FSH

float getSunraysAmount(inout uint rng) {
	
	
	#if SUNRAYS_STYLE == 1
		vec2 pos = texcoord;
		float noise = (randomFloat(rng) - 1.0) * 0.2 + 1.0;
		vec2 coordStep = (lightCoord - pos) / SUNRAY_SAMPLE_COUNT * noise;
		
	#elif SUNRAYS_STYLE == 2
		vec2 pos = texcoord;
		vec2 coordStep = (lightCoord - pos) / SUNRAY_SAMPLE_COUNT;
		float noise = randomFloat(rng) * 0.7;
		pos += coordStep * noise;
		
	#endif
	
	float total = 0.0;
	for (int i = 1; i < SUNRAY_SAMPLE_COUNT; i ++) {
		#ifdef SUNRAYS_FLICKERING_FIX
			if (pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0) {
				total *= float(SUNRAY_SAMPLE_COUNT) / i;
				break;
			}
		#endif
		float depth = texelFetch(DEPTH_BUFFER_ALL, ivec2(pos * viewSize), 0).r;
		if (depthIsSky(toLinearDepth(depth))) {
			total += 1.0 + float(i) / SUNRAY_SAMPLE_COUNT;
		}
		pos += coordStep;
	}
	total /= SUNRAY_SAMPLE_COUNT;
	
	if (total > 0.0) total = max(total, 0.2);
	
	float output = sqrt(total) * sunraysAmountMult;
	output *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
	
	return output;
}

#endif



#ifdef VSH

void calculateLightCoord() {
	
	vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
	lightPos /= lightPos.z;
	lightCoord = lightPos.xy * 0.5 + 0.5;
	
}

// this entire function SHOULD be computed on the cpu, but it has to be glsl code because it uses settings that are ONLY defined in glsl
void calculateSunraysAmount() {
	
	vec4 skylightPercents = getSkylightPercents();
	
	sunraysAmountMult =
		skylightPercents.x * SUNRAYS_AMOUNT_DAY +
		skylightPercents.y * SUNRAYS_AMOUNT_NIGHT +
		skylightPercents.z * SUNRAYS_AMOUNT_SUNRISE +
		skylightPercents.w * SUNRAYS_AMOUNT_SUNSET;
	
	if (isOtherLightSource) {
		if (isSun) {
			sunraysAmountMult *= skylightPercents.x + skylightPercents.z + skylightPercents.w;
		} else {
			sunraysAmountMult *= skylightPercents.y;
		}
	}
	
	sunraysAmountMult *= 0.3;
	
}

#endif
