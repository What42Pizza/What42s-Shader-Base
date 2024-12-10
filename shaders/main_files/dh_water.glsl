// transfers

#ifdef FIRST_PASS
	
	varying vec2 lmcoord;
	varying vec4 glcolor;
	flat_inout int dhBlock;
	
	varying vec3 normal;
	
	#if WATER_FRESNEL_ADDITION == 1
		varying vec3 viewPos;
	#endif
	#if WAVING_WATER_NORMALS_ENABLED == 1
		varying vec3 worldPos;
	#endif
	
#endif

// includes

#include "/lib/lighting/pre_lighting.glsl"
#include "/lib/lighting/basic_lighting.glsl"





#ifdef FSH

#if WAVING_WATER_NORMALS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogAmount.glsl"
	#include "/lib/fog/applyFog.glsl"
#endif

void main() {
	vec4 color = glcolor;
	
	#if WAVING_WATER_NORMALS_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	#include "/import/viewWidth.glsl"
	#include "/import/viewHeight.glsl"
    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    if (texture2D(depthtex1, screenPos.xy).r < 1.0) discard;
	
	
	if (dhBlock == DH_BLOCK_WATER) {
		
		color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
		
		
		// waving water normals
		#if WAVING_WATER_NORMALS_ENABLED == 1
			const float worldPosScale = 2.0;
			#include "/import/frameTimeCounter.glsl"
			vec3 randomPoint = abs(simplexNoise3From4(vec4(worldPos / worldPosScale, frameTimeCounter * 0.7)));
			randomPoint = normalize(randomPoint);
			vec3 normalWavingAddition = randomPoint * 0.15;
			normalWavingAddition *= abs(dot(normal, normalize(viewPos)));
			normalWavingAddition *= mix(WAVING_WATER_NORMALS_AMOUNT_UNDERGROUND, WAVING_WATER_NORMALS_AMOUNT_SURFACE, lmcoord.y);
			normal += normalWavingAddition;
			normal = normalize(normal);
		#endif
		
		
		// fresnel addition
		#if WATER_FRESNEL_ADDITION == 1
			const vec3 fresnelColor = vec3(1.0, 0.6, 0.5);
			const float fresnelStrength = 0.3;
			vec3 fresnelNormal = normal;
			#if WAVING_WATER_NORMALS_ENABLED == 1
				fresnelNormal = normalize(fresnelNormal + normalWavingAddition * 30);
			#endif
			vec3 reflectedNormal = reflect(normalize(viewPos), fresnelNormal);
			#include "/import/shadowLightPosition.glsl"
			float fresnel = 1.0 - abs(dot(reflectedNormal, normalize(shadowLightPosition)));
			fresnel *= fresnel;
			color.rgb *= (1.0 - fresnelColor * fresnelStrength) + fresnel * fresnelColor * fresnelStrength * 2.0;
		#endif
		
		
		color.a = (1.0 - WATER_TRANSPARENCY);
		
	}
	
	
	// main lighting
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	
	// outputs
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = color;
	
}

#endif





#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	dhBlock = dhMaterialId;
	
	#if WAVING_WATER_NORMALS_ENABLED == 0
		vec3 worldPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(worldPos);
	#endif
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if WATER_FRESNEL_ADDITION == 1
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#endif
	
	#if WAVING_WATER_NORMALS_ENABLED == 1
		#include "/import/cameraPosition.glsl"
		worldPos += cameraPosition;
	#endif
	
	
	glcolor = gl_Color;
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doPreLighting(ARG_IN);
	
}

#endif
