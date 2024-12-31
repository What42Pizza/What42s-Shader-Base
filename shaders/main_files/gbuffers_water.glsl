// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	flat_inout int blockData;
	
	varying vec3 normal;
	
	#if WATER_FRESNEL_ADDITION == 1
		varying vec3 viewPos;
	#endif
	#if WAVING_WATER_NORMALS_ENABLED == 1 || defined DISTANT_HORIZONS
		varying vec3 worldPos;
	#endif
	#if FOG_ENABLED == 1
		varying float fogDistance;
		varying float pixelY;
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
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if AA_STRATEGY == 2 || AA_STRATEGY == 3 || AA_STRATEGY == 4
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(worldPos.xz), abs(worldPos.y)) * 0.95;
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 10 - 8 * dither) discard;
	#endif
	
	
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	
	#if WAVING_WATER_NORMALS_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	if (blockData == 1007) {
		
		color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
		
		
		// waving water normals
		#if WAVING_WATER_NORMALS_ENABLED == 1
			const float worldPosScale = 2.0;
			#include "/import/frameTimeCounter.glsl"
			#include "/import/cameraPosition.glsl"
			vec3 randomPoint = abs(simplexNoise3From4(vec4((worldPos + cameraPosition) / worldPosScale, frameTimeCounter * 0.7)));
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
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	
	// fog
	#if FOG_ENABLED == 1
		float fogAmount = getFogAmount(fogDistance, pixelY  ARGS_IN);
		applyFog(color.rgb, fogAmount  ARGS_IN);
	#endif
	
	
	// block reflection strengths
	float blockReflectionAmount = (blockData % 1000 - blockData % 100) / 100 * 0.15 * mix(BLOCKS_REFLECTION_AMOUNT_MULT_UNDERGROUND, BLOCKS_REFLECTION_AMOUNT_MULT_SURFACE, lmcoord.y);
	vec2 blockReflectionStrengths = vec2(blockReflectionAmount * (1.0 - BLOCKS_REFLECTION_FRESNEL), blockReflectionAmount * BLOCKS_REFLECTION_FRESNEL);
	vec2 reflectionStrengths = blockData == 1007 ? WATER_REFLECTION_STRENGTHS : blockReflectionStrengths;
	
	
	// outputs
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal, 1.0);
	
	#if REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:046 */
		gl_FragData[2] = vec4(reflectionStrengths, 0.0, 1.0);
	#endif
	
}

#endif





#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogDistance.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	#include "/import/mc_Entity.glsl"
	blockData = int(mc_Entity.x);
	if (blockData < 1000) blockData = 0;
	
	#if !(WAVING_WATER_NORMALS_ENABLED == 1 || defined DISTANT_HORIZONS)
		vec3 worldPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	#if PHYSICALLY_WAVING_WATER_ENABLED == 1
		if (blockData == 1007) {
			float wavingAmount = mix(PHYSICALLY_WAVING_WATER_AMOUNT_UNDERGROUND, PHYSICALLY_WAVING_WATER_AMOUNT_SURFACE, lmcoord.y);
			#ifdef DISTANT_HORIZONS
				#include "/import/far.glsl"
				float lengthCylinder = max(length(worldPos.xz), abs(worldPos.y));
				wavingAmount *= smoothstep(far * 0.95 - 10, far * 0.9 - 10, lengthCylinder);
			#endif
			#include "/import/cameraPosition.glsl"
			#include "/import/frameTimeCounter.glsl"
			worldPos += cameraPosition;
			worldPos.y += sin(worldPos.x * 0.6 + worldPos.z * 1.4 + frameTimeCounter * 3.0) * 0.03 * wavingAmount;
			worldPos.y += sin(worldPos.x * 0.9 + worldPos.z * 0.6 + frameTimeCounter * 2.5) * 0.02 * wavingAmount;
			worldPos -= cameraPosition;
		}
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(worldPos);
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective optimization
	#endif
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if FOG_ENABLED == 1
		fogDistance = getFogDistance(worldPos  ARGS_IN);
		pixelY = worldPos.y;
	#endif
	
	
	#if WATER_FRESNEL_ADDITION == 1
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#endif
	
	
	glcolor = gl_Color.rgb;
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doPreLighting(ARG_IN);
	
}

#endif
