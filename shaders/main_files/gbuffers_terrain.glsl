// defines

#if defined BLOOM_ENABLED && defined NORMALS_NEEDED
	#define BLOOM_AND_NORMALS
#endif

// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	
	#ifdef RAIN_REFLECTIONS_ENABLED
		varying vec3 worldPos;
		varying float baseRainReflectionStrength;
	#endif
	#ifdef NORMALS_NEEDED
		varying vec3 normal;
	#endif
	#ifdef SHOW_DANGEROUS_LIGHT
		varying float isDangerousLight;
	#endif
	
#endif

// includes

#include "/lib/lighting.glsl"
#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif





#ifdef FSH

#ifdef RAIN_REFLECTIONS_ENABLED
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	// bloom value
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
	#endif
	
	
	// main lighting
	color.rgb *= glcolor;
	vec3 brightnesses = getLightingBrightnesses(lmcoord  ARGS_IN);
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z  ARGS_IN);
	#ifdef SHOW_SUNLIGHT
		debugOutput = vec3(brightnesses.y);
	#endif
	#ifdef SHOW_BRIGHTNESSES
		debugOutput = brightnesses;
	#endif
	
	#ifdef BLOOM_ENABLED
		#ifdef OVERWORLD
			float blockLight = brightnesses.x;
			#include "/import/rawSunTotal.glsl"
			float skyLight = brightnesses.y * rawSunTotal;
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
	
	
	// show dangerous light
	#ifdef SHOW_DANGEROUS_LIGHT
		if (isDangerousLight > 0.0) {
			color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), 0.6);
		}
	#endif
	
	
	// rain reflection strength
	#ifdef RAIN_REFLECTIONS_ENABLED
		float rainReflectionStrength = baseRainReflectionStrength;
		#include "/import/cameraPosition.glsl"
		rainReflectionStrength *= simplexNoise((worldPos + cameraPosition) * 0.2  ARGS_IN);
		rainReflectionStrength *= lmcoord.y;
	#endif
	
	
	/* DRAWBUFFERS:06 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(lmcoord, 0.0, color.a);
	#ifdef BLOOM_AND_NORMALS
		/* DRAWBUFFERS:06243 */
		gl_FragData[2] = colorForBloom;
		gl_FragData[3] = vec4(normal, 1.0);
		#ifdef RAIN_REFLECTIONS_ENABLED
			gl_FragData[4] = vec4(rainReflectionStrength, 0.0, 0.0, 1.0);
		#endif
	#elif defined BLOOM_ENABLED
		/* DRAWBUFFERS:062 */
		gl_FragData[2] = colorForBloom;
	#elif defined NORMALS_NEEDED
		/* DRAWBUFFERS:0643 */
		gl_FragData[2] = vec4(normal, 1.0);
		#ifdef RAIN_REFLECTIONS_ENABLED
			gl_FragData[3] = vec4(rainReflectionStrength, 0.0, 0.0, 1.0);
		#endif
	#endif
}

#endif





#ifdef VSH

#ifdef WAVING_ENABLED
	#include "/lib/waving.glsl"
#endif
#ifdef ISOMETRIC_RENDERING_ENABLED
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	#if !defined RAIN_REFLECTIONS_ENABLED
		vec3 worldPos;
	#endif
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
	#ifdef WAVING_ENABLED
		applyWaving(worldPos  ARGS_IN);
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
		getFogData(worldPos  ARGS_IN);
	#endif
	
	
	glcolor = gl_Color.rgb;
	#ifdef USE_SIMPLE_LIGHT
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	#ifdef NORMALS_NEEDED
		normal = gl_NormalMatrix * gl_Normal;
	#endif
	
	
	#ifdef RAIN_REFLECTIONS_ENABLED
		#include "/import/upPosition.glsl"
		baseRainReflectionStrength = dot(normalize(upPosition), normal) * 0.5 + 0.5;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= betterRainStrength;
	#endif
	
	
	#ifdef SHOW_DANGEROUS_LIGHT
		isDangerousLight = float(
			lmcoord.x < 0.51
			&& dot(normal, normalize(upPosition)) > 0.9
		);
	#endif
	
	
	doPreLighting(ARG_IN);
	
}

#endif
