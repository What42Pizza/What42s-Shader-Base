// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	flat int blockType;
	
	varying vec3 normal;
	
	#if defined WATER_REFLECTIONS_ENABLED || defined WATER_RESNEL_ADDITION
		varying vec3 viewPos;
	#endif
	#if defined WAVING_WATER_NORMALS_ENABLED
		varying vec3 worldPos;
	#endif
	
#endif

// includes

#include "/lib/pre_lighting.glsl"
#include "/lib/basic_lighting.glsl"
#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif





#ifdef FSH

#ifdef WAVING_WATER_NORMALS_ENABLED
	#include "/lib/simplex_noise.glsl"
#endif
#ifdef WATER_REFLECTIONS_ENABLED
	#include "/lib/reflections.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	#ifdef WAVING_WATER_NORMALS_ENABLED
		vec3 normal = normal;
	#endif
	
	
	if (blockType == 1007) {
		
		color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
		
		
		// waving water normals
		#ifdef WAVING_WATER_NORMALS_ENABLED
			const float worldPosScale = 2.0;
			#include "/import/frameTimeCounter.glsl"
			vec3 randomPoint = abs(simplexNoise3From4(vec4(worldPos / worldPosScale, frameTimeCounter * 0.7)));
			randomPoint = normalize(randomPoint);
			vec3 normalWavingAddition = randomPoint * 0.15;
			normalWavingAddition *= abs(dot(normal, normalize(viewPos)));
			normal += normalWavingAddition;
			normal = normalize(normal);
		#endif
		
		
		// fresnel addition
		#ifdef WATER_RESNEL_ADDITION
			const vec3 fresnelColor = vec3(1.0, 0.6, 0.5);
			const float fresnelStrength = 0.3;
			vec3 fresnelNormal = normal;
			#ifdef WAVING_WATER_NORMALS_ENABLED
				fresnelNormal = normalize(fresnelNormal + normalWavingAddition * 30);
			#endif
			vec3 reflectedNormal = reflect(normalize(viewPos), fresnelNormal);
			#include "/import/shadowLightPosition.glsl"
			float fresnel = 1.0 - abs(dot(reflectedNormal, normalize(shadowLightPosition)));
			fresnel *= fresnel;
			color.rgb *= (1.0 - fresnelColor * fresnelStrength) + fresnel * fresnelColor * fresnelStrength * 2.0;
		#endif
		
		
	}
	
	
	// bloom value
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
	#endif
	
	
	// main lighting
	color.rgb *= glcolor;
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	#ifdef BLOOM_ENABLED
		#ifdef OVERWORLD
			#include "/import/ambientMoonPercent.glsl"
			float blockLight = lmcoord.x;
			float skyLight = lmcoord.y * (1.0 - ambientMoonPercent);
			colorForBloom.rgb *= max(blockLight * blockLight * 1.05, skyLight * 0.75);
		#endif
	#endif
	
	
	
	// fog
	#ifdef FOG_ENABLED
		#ifdef BLOOM_ENABLED
			applyFog(color.rgb, colorForBloom.rgb  ARGS_IN);
		#else
			applyFog(color.rgb  ARGS_IN);
		#endif
	#endif
	
	
	
	// outputs
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal, 1.0);
	
	#if defined BLOOM_ENABLED && defined WATER_REFLECTIONS_ENABLED
		/* DRAWBUFFERS:0423 */
		gl_FragData[2] = colorForBloom;
		gl_FragData[3] = vec4(WATER_REFLECTION_STRENGTHS, 0.0, 1.0);
	#endif
	
	#if defined BLOOM_ENABLED && !defined WATER_REFLECTIONS_ENABLED
		/* DRAWBUFFERS:042 */
		gl_FragData[2] = colorForBloom;
	#endif
	
	#if !defined BLOOM_ENABLED && defined WATER_REFLECTIONS_ENABLED
		/* DRAWBUFFERS:043 */
		gl_FragData[2] = vec4(WATER_REFLECTION_STRENGTHS, 0.0, 1.0);
	#endif
	
}

#endif





#ifdef VSH

#ifdef ISOMETRIC_RENDERING_ENABLED
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	#include "/import/mc_Entity.glsl"
	blockType = int(mc_Entity.x);
	
	#if !defined WAVING_WATER_NORMALS_ENABLED
		vec3 worldPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	#ifdef PHYSICALLY_WAVING_WATER_ENABLED
		if (blockType == 1007) {
			#include "/import/cameraPosition.glsl"
			#include "/import/frameTimeCounter.glsl"
			worldPos += cameraPosition;
			worldPos.y += sin(worldPos.x * 0.6 + worldPos.z * 1.4 + frameTimeCounter * 3.0) * 0.03;
			worldPos.y += sin(worldPos.x * 0.9 + worldPos.z * 0.6 + frameTimeCounter * 2.5) * 0.02;
			worldPos -= cameraPosition;
		}
	#endif
	
	#ifdef ISOMETRIC_RENDERING_ENABLED
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(worldPos);
	#endif
	
	#if !defined ISOMETRIC_RENDERING_ENABLED
		if (gl_Position.z < -1.5) return; // simple but effective optimization
	#endif
	
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#ifdef FOG_ENABLED
		processFogVsh(worldPos  ARGS_IN);
	#endif
	
	
	#if defined WATER_REFLECTIONS_ENABLED || defined WATER_RESNEL_ADDITION
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#endif
	
	#ifdef WAVING_WATER_NORMALS_ENABLED
		#include "/import/cameraPosition.glsl"
		worldPos += cameraPosition;
	#endif
	
	
	glcolor = gl_Color.rgb;
	#ifdef USE_SIMPLE_LIGHT
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doPreLighting(ARG_IN);
	
}

#endif
