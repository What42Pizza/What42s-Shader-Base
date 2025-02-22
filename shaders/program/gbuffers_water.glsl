#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec3 normal;
	flat_inout int materialId;
	
	flat_inout vec3 skyLight;
	
	#if WATER_FRESNEL_ADDITION == 1
		varying vec3 viewPos;
	#endif
	#if WAVING_WATER_NORMALS_ENABLED == 1 || defined DISTANT_HORIZONS
		varying vec3 playerPos;
	#endif
	#if BORDER_FOG_ENABLED == 1
		varying float fogAmount;
	#endif
	
#endif





#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"

#if WAVING_WATER_NORMALS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/fog/applyFog.glsl"
#endif

void main() {
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#ifdef TAA_ENABLED
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y)) * 0.95;
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 10 - 8 * dither) discard;
	#endif
	
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	
	#if WAVING_WATER_NORMALS_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	if (materialId == 7) {
		
		color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
		
		
		// waving water normals
		#if WAVING_WATER_NORMALS_ENABLED == 1
			const float worldPosScale = 2.0;
			#include "/import/frameTimeCounter.glsl"
			#include "/import/cameraPosition.glsl"
			vec3 randomPoint = abs(simplexNoise3From4(vec4((playerPos + cameraPosition) / worldPosScale, frameTimeCounter * 0.7)));
			vec3 normalWavingAddition = normalize(randomPoint) * 0.15;
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
	color.rgb *= glcolor;
	doFshLighting(color.rgb, lmcoord.x, lmcoord.y, viewPos, normal  ARGS_IN);
	
	
	// fog
	#if BORDER_FOG_ENABLED == 1
		applyFog(color.rgb, fogAmount  ARGS_IN);
	#endif
	
	
	float reflectiveness = ((materialId - materialId % 100) / 100) * 0.15;
	if (materialId == 7) reflectiveness = WATER_REFLECTION_AMOUNT;
	
	
	/* DRAWBUFFERS:03 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(encodeNormal(normal)),
		reflectiveness,
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
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/fog/getFogAmount.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color.rgb;
	normal = gl_NormalMatrix * gl_Normal;
	
	#include "/import/mc_Entity.glsl"
	materialId = int(mc_Entity.x);
	if (materialId < 1000) materialId = 0;
	materialId %= 1000;
	
	skyLight = getSkyLight(ARG_IN);
	
	
	#if !(WAVING_WATER_NORMALS_ENABLED == 1 || defined DISTANT_HORIZONS)
		vec3 playerPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	#if PHYSICALLY_WAVING_WATER_ENABLED == 1
		if (materialId == 7) {
			float wavingAmount = mix(PHYSICALLY_WAVING_WATER_AMOUNT_UNDERGROUND, PHYSICALLY_WAVING_WATER_AMOUNT_SURFACE, lmcoord.y);
			#ifdef DISTANT_HORIZONS
				#include "/import/far.glsl"
				float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
				wavingAmount *= smoothstep(far * 0.95 - 10, far * 0.9 - 10, lengthCylinder);
			#endif
			#include "/import/cameraPosition.glsl"
			#include "/import/frameTimeCounter.glsl"
			playerPos += cameraPosition;
			playerPos.y += sin(playerPos.x * 0.6 + playerPos.z * 1.4 + frameTimeCounter * 3.0) * 0.03 * wavingAmount;
			playerPos.y += sin(playerPos.x * 0.9 + playerPos.z * 0.6 + frameTimeCounter * 2.5) * 0.02 * wavingAmount;
			playerPos -= cameraPosition;
		}
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective optimization
	#endif
	
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if BORDER_FOG_ENABLED == 1
		fogAmount = getFogAmount(playerPos  ARGS_IN);
	#endif
	
	
	#if WATER_FRESNEL_ADDITION == 1
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#endif
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
