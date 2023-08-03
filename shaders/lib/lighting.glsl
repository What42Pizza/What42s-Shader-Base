varying vec4 viewPos;
varying float lightDot;
varying float offsetMult;
varying float sideShading;

#if SHADOW_FILTERING == 1
	#define SHADOW_OFFSET_COUNT 8
	const float SHADOW_OFFSET_WEIGHTS_TOTAL = 0.45 * 8;
	const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
		vec3(1, 0, 0.45),
		vec3(-1, 0, 0.45),
		vec3(0, 1, 0.45),
		vec3(0, -1, 0.45),
		vec3(0.71, 0.71, 0.45),
		vec3(-0.71, 0.71, 0.45),
		vec3(0.71, -0.71, 0.45),
		vec3(-0.71, -0.71, 0.45)
	);
#elif SHADOW_FILTERING == 2
	#define SHADOW_OFFSET_COUNT 16
	const float SHADOW_OFFSET_WEIGHTS_TOTAL = 0.4 * 8 + 0.55 * 8;
	const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
		vec3(1.5, 0, 0.4),
		vec3(-1.5, 0, 0.4),
		vec3(0, 1.5, 0.4),
		vec3(0, -1.5, 0.4),
		vec3(1.1, 1.1, 0.4),
		vec3(-1.1, 1.1, 0.4),
		vec3(1.1, -1.1, 0.4),
		vec3(-1.1, -1.1, 0.4),
		vec3(0.29, 0.69, 0.55),
		vec3(0.69, 0.29, 0.55),
		vec3(0.69, -0.29, 0.55),
		vec3(0.29, -0.69, 0.55),
		vec3(-0.29, -0.69, 0.55),
		vec3(-0.69, -0.29, 0.55),
		vec3(-0.69, 0.29, 0.55),
		vec3(-0.29, 0.69, 0.55)
	);
#endif





#ifdef FSH

vec3 getLightColor(float blockBrightness, float skyBrightness, float ambientBrightness) {
	vec4 skylightPercents = getSkylightPercents();
	vec3 skyColor = getSkyColor(skylightPercents);
	vec3 ambientColor = getAmbientColor(skylightPercents);
	
	#ifdef OVERWORLD
		float ambientMin = 0.1;
	#else
		float ambientMin = 0.3;
	#endif
	#ifdef USE_VANILLA_BRIGHTNESS
		ambientMin *= screenBrightness * 0.66 + 0.33;
	#endif
	
	ambientBrightness = ambientBrightness * (1.0 - ambientMin) + ambientMin;
	vec3 blockLight   = blockBrightness   * BLOCK_COLOR;
	vec3 skyLight     = skyBrightness     * skyColor;
	vec3 ambientLight = ambientBrightness * ambientColor;
	vec3 blockMaxSky = smoothMax(blockLight, skyLight, LIGHT_SMOOTHING);
	vec3 total = smoothMax(blockMaxSky, ambientLight, LIGHT_SMOOTHING);
	return total;
}



#ifdef SHADOWS_ENABLED
	
	// return value channels: (blockBrightness, skyBrightness, ambientBrightness)
	vec3 getLightingBrightnesses(vec2 lmcoord) {
		
		float blockBrightness = pow(lmcoord.x, LIGHT_DROPOFF) * sideShading;
		float skyBrightness = 0;
		float ambientBrightness = pow(lmcoord.y, LIGHT_DROPOFF) * sideShading;
		
		if (lightDot > 0.0) {
			// surface is facing towards shadowLightPosition
			
			vec4 currPos = viewPos;
			currPos.xy += randomVec2(rngStart) * offsetMult * 15;
			vec3 shadowPos = getShadowPos(currPos, lightDot);
			if (texture2D(shadowtex0, shadowPos.xy).r >= shadowPos.z) {
				skyBrightness += 1;
			}
			#if SHADOW_FILTERING > 0
				
				for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
					if (texture2D(shadowtex0, shadowPos.xy + SHADOW_OFFSETS[i].xy * offsetMult).r >= shadowPos.z) {
						float currentShadowWeight = SHADOW_OFFSETS[i].z;
						skyBrightness += currentShadowWeight;
					}
				}
				skyBrightness /= SHADOW_OFFSET_WEIGHTS_TOTAL + 1;
			#endif
			
		}
		
		skyBrightness *= sin((lightDot + 1.0) * PI / 4.0);
		skyBrightness = max(skyBrightness, ambientBrightness * 0.8);
		skyBrightness *= ambientBrightness;
		
		return vec3(blockBrightness, skyBrightness, ambientBrightness);
	}
	
#endif



// return value channels: (blockBrightness, skyBrightness, ambientBrightness)
vec3 getBasicLightingBrightnesses(vec2 lmcoord) {
	
	float blockBrightness = pow(lmcoord.x, LIGHT_DROPOFF) * sideShading;
	float skyBrightness = 1.0;
	float ambientBrightness = pow(lmcoord.y, LIGHT_DROPOFF) * sideShading;
	
	skyBrightness *= sin((lightDot + 1.0) * PI / 4.0);
	skyBrightness = max(skyBrightness, ambientBrightness * 0.8);
	skyBrightness *= ambientBrightness;
	
	return vec3(blockBrightness, skyBrightness, ambientBrightness);
}



#endif





#ifdef VSH



void doPreLighting() {
	
	lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
	#if defined SHADER_TERRAIN && defined EXCLUDE_FOLIAGE
		// when EXCLUDE_FOLIAGE is enabled, act as if foliage is always facing towards the sky.
		// in other words, don't darken the back side of it unless something else is casting a shadow on it.
		if (mc_Entity.x >= 2000.0 && mc_Entity.x <= 2999.0) lightDot = 1.0;
	#endif
	
	viewPos = gl_ModelViewMatrix * gl_Vertex;
	#ifdef SHADOWS_ENABLED
		if (lightDot > 0.0) {
			// vertex is facing towards the sky
			offsetMult = pow(maxAbs(gl_Vertex.xyz), 0.75) * SHADOW_OFFSET_INCREASE + SHADOW_OFFSET_MIN;
			offsetMult *= 0.01;
		}
	#endif
	
	vec3 shadingNormals = vec3(abs(gl_Normal.x), gl_Normal.y, abs(gl_Normal.z));
	sideShading = shadingNormals.x * -0.3 + shadingNormals.y * 0.5 + shadingNormals.z * 0.3;
	sideShading = (sideShading * SIDE_SHADING / 2.0) + 1.0;
	
}



#endif
