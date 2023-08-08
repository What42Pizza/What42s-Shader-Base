#if defined SHADER_TEXTURED || defined SHADER_HAND
	#undef SHADOWS_ENABLED
#endif



varying float sideShading;
varying float lightDotMult;

#ifdef SHADOWS_ENABLED
	varying vec3 shadowPos;
	varying float offsetMult;
	
	#ifdef SHADOW_FILTERING
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





float alterLightDot(float lightDot) {
	return sin((lightDot + 1.0) * PI / 4.0);
}



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


	
// return value channels: (blockBrightness, skyBrightness, ambientBrightness)
vec3 getLightingBrightnesses(vec2 lmcoord) {
	
	float blockBrightness = pow(lmcoord.x, LIGHT_DROPOFF) * sideShading;
	float skyBrightness = 0;
	float ambientBrightness = pow(lmcoord.y, LIGHT_DROPOFF) * sideShading;
	
	#ifdef SHADOWS_ENABLED
		if (lightDotMult > alterLightDot(0.0)) {
			// surface is facing towards shadowLightPosition
			
			#ifndef SHADOW_FILTERING
				
				// no filtering
				vec3 offsetShadowPos = shadowPos;
				offsetShadowPos.xy += randomVec2(rngStart) * offsetMult * 0.2;
				if (texture2D(shadowtex0, offsetShadowPos.xy).r >= offsetShadowPos.z) {
					skyBrightness += 1;
				}
				
			#else
				
				// filtered
				//if (texture2D(shadowtex0, shadowPos.xy).r >= shadowPos.z - 0.05) {
					vec3 offsetShadowPos = shadowPos;
					offsetShadowPos.xy += randomVec2(rngStart) * offsetMult * 0.3;
					for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
						if (texture2D(shadowtex0, offsetShadowPos.xy + SHADOW_OFFSETS[i].xy * offsetMult).r >= offsetShadowPos.z) {
							float currentShadowWeight = SHADOW_OFFSETS[i].z;
							skyBrightness += currentShadowWeight;
						}
					}
					skyBrightness /= SHADOW_OFFSET_WEIGHTS_TOTAL;
					skyBrightness = min(skyBrightness * 2.3, 1.0);
				//} else {
				//	skyBrightness = 0.5;
				//}
				
			#endif
			
		}
	#else
		skyBrightness = 1.0;
	#endif
	
	skyBrightness *= lightDotMult;
	skyBrightness = max(skyBrightness, ambientBrightness * 0.8);
	skyBrightness *= ambientBrightness;
	
	return vec3(blockBrightness, skyBrightness, ambientBrightness);
}



#endif





#ifdef VSH



void doPreLighting() {
	
	float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
	lightDotMult = alterLightDot(lightDot);
	
	#ifdef SHADOWS_ENABLED
		
		#if defined SHADER_TERRAIN && defined EXCLUDE_FOLIAGE
			if (mc_Entity.x >= 2000.0 && mc_Entity.x <= 2999.0) lightDot = 1.0;
		#endif
		
		if (lightDot > 0.0) { // vertex is facing towards the sky
			vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
			vec4 worldPos = gbufferModelViewInverse * viewPos;
			#ifndef SHADOW_FILTERING
				shadowPos = getShadowPos(viewPos, lightDot);
			#else
				shadowPos = getLessBiasedShadowPos(viewPos, lightDot);
			#endif
			offsetMult = length(shadowPos.xy * 2.0 - 1.0);
			offsetMult *= offsetMult;
			offsetMult = offsetMult * SHADOW_OFFSET_INCREASE + SHADOW_OFFSET_MIN;
		}
		
	#endif
	
	vec3 shadingNormals = vec3(abs(gl_Normal.x), gl_Normal.y, abs(gl_Normal.z));
	sideShading = shadingNormals.x * -0.3 + shadingNormals.y * 0.5 + shadingNormals.z * 0.3;
	sideShading = (sideShading * SIDE_SHADING / 2.0) + 1.0;
	
}



#endif
