varying float skyBrightnessMult;

#ifdef SHADOWS_ENABLED
	varying vec3 shadowPos;
	varying float offsetMult;
	
	#if SHADOW_FILTERING == 1
		const int SHADOW_OFFSET_COUNT = 9;
		const float SHADOW_OFFSET_WEIGHTS_TOTAL = 1.0 + 0.94 * 8;
		const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
			vec3( 0.0,  0.0, 1.0 ),
			vec3( 0.7,  0.0, 0.94),
			vec3( 0.0,  0.7, 0.94),
			vec3(-0.7,  0.0, 0.94),
			vec3( 0.0, -0.7, 0.94),
			vec3( 0.5,  0.5, 0.94),
			vec3(-0.5,  0.5, 0.94),
			vec3( 0.5, -0.5, 0.94),
			vec3(-0.5, -0.5, 0.94)
		);
	#elif SHADOW_FILTERING == 2
		const int SHADOW_OFFSET_COUNT = 17;
		const float SHADOW_OFFSET_WEIGHTS_TOTAL = 1.0 + 0.94 * 8 + 0.78 * 8;
		const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
			vec3( 0.0 ,  0.0 , 1.0 ),
			vec3( 0.5 ,  0.0 , 0.94),
			vec3( 0.0 ,  0.5 , 0.94),
			vec3(-0.5 ,  0.0 , 0.94),
			vec3( 0.0 , -0.5 , 0.94),
			vec3( 0.35,  0.35, 0.94),
			vec3(-0.35,  0.35, 0.94),
			vec3( 0.35, -0.35, 0.94),
			vec3(-0.35, -0.35, 0.94),
			vec3( 0.38,  0.92, 0.78),
			vec3( 0.92,  0.38, 0.78),
			vec3( 0.92, -0.38, 0.78),
			vec3( 0.38, -0.92, 0.78),
			vec3(-0.38, -0.92, 0.78),
			vec3(-0.92, -0.38, 0.78),
			vec3(-0.92,  0.38, 0.78),
			vec3(-0.38,  0.92, 0.78)
		);
	#elif SHADOW_FILTERING == 3
		const int SHADOW_OFFSET_COUNT = 33;
		const float SHADOW_OFFSET_WEIGHTS_TOTAL = 1.0 + 0.94 * 8 + 0.78 * 8 + 0.57 * 8 + 0.37 * 8;
		const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
			vec3( 0.0 ,  0.0 , 1.0 ),
			vec3( 0.5 ,  0.0 , 0.94),
			vec3( 0.0 ,  0.5 , 0.94),
			vec3(-0.5 ,  0.0 , 0.94),
			vec3( 0.0 , -0.5 , 0.94),
			vec3( 0.35,  0.35, 0.94),
			vec3(-0.35,  0.35, 0.94),
			vec3( 0.35, -0.35, 0.94),
			vec3(-0.35, -0.35, 0.94),
			vec3( 0.38,  0.92, 0.78),
			vec3( 0.92,  0.38, 0.78),
			vec3( 0.92, -0.38, 0.78),
			vec3( 0.38, -0.92, 0.78),
			vec3(-0.38, -0.92, 0.78),
			vec3(-0.92, -0.38, 0.78),
			vec3(-0.92,  0.38, 0.78),
			vec3(-0.38,  0.92, 0.78),
			vec3( 1.5 ,  0.0 , 0.57),
			vec3( 0.0 ,  1.5 , 0.57),
			vec3(-1.5 ,  0.0 , 0.57),
			vec3( 0.0 , -1.5 , 0.57),
			vec3( 1.06,  1.06, 0.57),
			vec3(-1.06,  1.06, 0.57),
			vec3( 1.06, -1.06, 0.57),
			vec3(-1.06, -1.06, 0.57),
			vec3( 0.76,  1.84, 0.37),
			vec3( 1.84,  0.76, 0.37),
			vec3( 1.84, -0.76, 0.37),
			vec3( 0.76, -1.84, 0.37),
			vec3(-0.76, -1.84, 0.37),
			vec3(-1.84, -0.76, 0.37),
			vec3(-1.84,  0.76, 0.37),
			vec3(-0.76,  1.84, 0.37)
		);
	#endif
	
#endif

#ifdef HANDHELD_LIGHT_ENABLED
	varying float handLightBrightness;
#endif





float getSkyBrightnessMult(float lightDot) {
	
	//return sin((lightDot + 1.0) * PI / 4.0);
	
	//float temp = lightDot * 0.5 - 0.5;
	//return temp * temp * temp + 1.0;
	
	//return pow(max(lightDot, 0.0), 0.12);
	
	const float curve = 3.0;
	const float finalFactor = 1.0 / (1.0 - 1.0 / (curve * 10.0 + 1.0));
	return (1.0 - 1.0 / (max(lightDot, 0.0) * curve * 10.0 + 1.0)) * finalFactor;
	
}



#ifdef FSH

vec3 getLightColor(float blockBrightness, float skyBrightness, float ambientBrightness) {
	vec4 skylightPercents = getSkylightPercents();
	vec3 skyColor = getSkyColor(skylightPercents);
	vec3 ambientColor = getAmbientColor(skylightPercents);
	
	#ifdef OVERWORLD
		float ambientMin = 0.15;
	#else
		float ambientMin = 0.3;
	#endif
	#ifdef USE_VANILLA_BRIGHTNESS
		ambientMin *= 0.33 + screenBrightness * 0.66;
	#endif
	
	ambientBrightness = ambientBrightness * (1.0 - ambientMin) + ambientMin;
	vec3 blockLight   = blockBrightness   * BLOCK_COLOR;
	vec3 skyLight     = skyBrightness     * skyColor;
	vec3 ambientLight = ambientBrightness * ambientColor;
	//return max(max(blockLight, skyLight), ambientLight);
	vec3 blockMaxSky = smoothMax(blockLight, skyLight, LIGHT_SMOOTHING);
	vec3 total = smoothMax(blockMaxSky, ambientLight, LIGHT_SMOOTHING);
	return total;
}



// return value channels: (blockBrightness, skyBrightness, ambientBrightness)
vec3 getLightingBrightnesses(vec2 lmcoord) {
	
	
	float skyBrightness = 0;
	
	#ifdef SHADOWS_ENABLED
		if (skyBrightnessMult > 0.0) {
			// surface is facing towards shadowLightPosition
			
			vec3 offsetShadowPos = shadowPos;
			vec2 noise = normalizeNoiseAround1(randomVec2(rngStart), 0.4);
			offsetShadowPos.xy += noise * offsetMult * 0.4;
			
			#if SHADOW_FILTERING == 0
				
				// no filtering
				if (texture2D(shadowtex0, offsetShadowPos.xy).r >= offsetShadowPos.z) {
					skyBrightness += 1.0;
				}
				
			#else
				
				// filtered
				// tactic: just absorb the shadow acne and average it out, then multiply and clamp to get back to 1.0
				for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
					if (texture2D(shadowtex0, offsetShadowPos.xy + SHADOW_OFFSETS[i].xy * offsetMult).r >= offsetShadowPos.z) {
						float currentShadowWeight = SHADOW_OFFSETS[i].z;
						skyBrightness += currentShadowWeight;
					}
				}
				skyBrightness /= SHADOW_OFFSET_WEIGHTS_TOTAL;
				skyBrightness = min(skyBrightness * (2.4 - skyBrightnessMult), 1.0);
				//skyBrightness = min(skyBrightness * 2.3, 1.0);
				
			#endif
			
		}
	#else
		skyBrightness = 1.0;
	#endif
	
	#if !defined SHOW_SUNLIGHT
		skyBrightness *= skyBrightnessMult;
	#endif
	
	
	float blockBrightness = lmcoord.x;
	#ifdef HANDHELD_LIGHT_ENABLED
		blockBrightness = max(blockBrightness, handLightBrightness);
	#endif
	
	float ambientBrightness = lmcoord.y;
	
	
	return vec3(blockBrightness, skyBrightness, ambientBrightness);
}



#endif





#ifdef VSH



void doPreLighting() {
	
	
	float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
	
	#ifdef SHADOWS_ENABLED
		
		#if defined SHADER_TERRAIN && defined EXCLUDE_FOLIAGE
			if (mc_Entity.x >= 2000.0 && mc_Entity.x <= 2999.0) {
				lightDot = max(lightDot, 0.025);
			}
		#endif
		
		if (lightDot > 0.0) { // vertex is facing towards the sky
			vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
			vec4 worldPos = gbufferModelViewInverse * viewPos;
			#if SHADOW_FILTERING == 0
				shadowPos = getShadowPos(viewPos, lightDot);
			#else
				shadowPos = getLessBiasedShadowPos(viewPos);
			#endif
			offsetMult = length(shadowPos.xy * 2.0 - 1.0);
			offsetMult *= offsetMult;
			offsetMult = offsetMult * SHADOW_OFFSET_INCREASE + SHADOW_OFFSET_MIN;
		}
		
	#endif
	
	skyBrightnessMult = getSkyBrightnessMult(lightDot);
	skyBrightnessMult *= sqrt(lmcoord.y);
	
	
	#ifdef HANDHELD_LIGHT_ENABLED
		handLightBrightness = 0.0;
		float depth = estimateDepthVSH();
		if (depth <= HANDHELD_LIGHT_DISTANCE) {
			handLightBrightness = max(1.0 - depth / HANDHELD_LIGHT_DISTANCE, 0.0);
			handLightBrightness = handLightBrightness;
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
		}
	#endif
	
	
	vec3 shadingNormals = vec3(abs(gl_Normal.x), gl_Normal.y, abs(gl_Normal.z));
	float sideShading = dot(shadingNormals, vec3(-0.3, 0.5, 0.3));
	sideShading = sideShading * SIDE_SHADING * 0.5 + 1.0;
	lmcoord *= sideShading;
	
	
}



#endif
