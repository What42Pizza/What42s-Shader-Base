#undef SHADOWS_ENABLED
#define SHADOWS_ENABLED 0

#ifdef FIRST_PASS
	
	varying vec4 glcolor;
	varying vec2 lmcoord;
	varying vec3 normal;
	flat_inout int dhBlock;
	
	varying vec3 playerPos;
	varying vec3 viewPos;
	flat_inout vec3 skyLight;
	
#endif





#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"

#include "/utils/screen_to_view.glsl"
#if WAVING_WATER_NORMALS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	
	float dither = bayer64(gl_FragCoord.xy);
	#if AA_STRATEGY == 2 || AA_STRATEGY == 3
		#include "/import/frameCounter.glsl"
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif
	float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
	#include "/import/far.glsl"
	if (lengthCylinder < far - 10 - 8 * dither) discard;
	
	float realDepth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	#include "/import/invViewSize.glsl"
	vec3 realPos = screenToView(vec3(gl_FragCoord.xy * invViewSize, realDepth)  ARGS_IN);
	if (realDepth < 1.0 && length(realPos) < length(playerPos)) discard;
	
	
	vec4 color = glcolor;
	vec2 reflectionStrengths = vec2(0.0);
	
	#if WAVING_WATER_NORMALS_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	if (dhBlock == DH_BLOCK_WATER) {
		
		color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
		
		
		// waving water normals
		#if WAVING_WATER_NORMALS_ENABLED == 1
			const float worldPosScale = 2.0;
			#include "/import/frameTimeCounter.glsl"
			#include "/import/cameraPosition.glsl"
			vec3 randomPoint = abs(simplexNoise3From4(vec4((playerPos + cameraPosition) / worldPosScale, frameTimeCounter * 0.7)));
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
	doFshLighting(color.rgb, lmcoord.x, lmcoord.y, viewPos, normal  ARGS_IN);
	
	
	/* DRAWBUFFERS:03 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(encodeNormal(normal)),
		dhBlock == DH_BLOCK_WATER ? WATER_REFLECTION_AMOUNT : 0.0,
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getSkyLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	glcolor = gl_Color;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	normal = gl_NormalMatrix * gl_Normal;
	dhBlock = dhMaterialId;
	
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	if (dhBlock == DH_BLOCK_WATER) {
		playerPos.y -= 0.11213;
	}
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	skyLight = getSkyLight(ARG_IN);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
