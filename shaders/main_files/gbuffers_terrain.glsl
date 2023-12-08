// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec3 normal;
	
	#if RAIN_REFLECTIONS_ENABLED == 1
		varying vec3 worldPos;
		varying float baseRainReflectionStrength;
	#endif
	#if SHOW_DANGEROUS_LIGHT == 1
		varying float isDangerousLight;
	#endif
	
#endif

// includes

#include "/lib/pre_lighting.glsl"
#include "/lib/basic_lighting.glsl"
#if FOG_ENABLED == 1
	#include "/lib/fog.glsl"
#endif





#ifdef FSH

#if RAIN_REFLECTIONS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * vec4(glcolor, 1.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	// bloom value
	#if BLOOM_ENABLED == 1
		vec4 colorForBloom = color;
	#endif
	
	
	// main lighting
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	#if BLOOM_ENABLED == 1
		#ifdef OVERWORLD
			#include "/import/ambientMoonPercent.glsl"
			float blockLight = lmcoord.x;
			float skyLight = lmcoord.y * (1.0 - ambientMoonPercent);
			colorForBloom.rgb *= max(blockLight * blockLight * 1.05, skyLight * 0.75);
		#elif defined NETHER
			colorForBloom.rgb *= lmcoord.x;
			colorForBloom.rgb *= dot(colorForBloom.rgb, vec3(0.92, 0.35, 0.07)) * 1.3;
		#endif
	#endif
	
	
	// fog
	#if FOG_ENABLED == 1
		#if BLOOM_ENABLED == 1
			applyFog(color.rgb, colorForBloom.rgb  ARGS_IN);
		#else
			applyFog(color.rgb  ARGS_IN);
		#endif
	#endif
	
	
	// show dangerous light
	#if SHOW_DANGEROUS_LIGHT == 1
		if (isDangerousLight > 0.0) {
			color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), 0.6);
		}
	#endif
	
	
	// rain reflection strength
	#if RAIN_REFLECTIONS_ENABLED == 1
		#include "/import/cameraPosition.glsl"
		float rainReflectionStrength = baseRainReflectionStrength;
		float noise = simplexNoise((worldPos + cameraPosition) * 0.2);
		noise = clamp(RAIN_REFLECTION_SLOPE * (noise - (1.0 - RAIN_REFLECTION_COVERAGE)) + 1.0, RAIN_REFLECTION_MIN, 1.0);
		rainReflectionStrength *= noise;
		rainReflectionStrength *= lmcoord.y * lmcoord.y * lmcoord.y;
	#endif
	
	
	// outputs
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal, 1.0);
	
	#if BLOOM_ENABLED == 1 && RAIN_REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:0423 */
		gl_FragData[2] = colorForBloom;
		gl_FragData[3] = vec4(RAIN_REFLECTION_STRENGTHS * rainReflectionStrength, 0.0, 1.0);
	#endif
	
	#if BLOOM_ENABLED == 1 && RAIN_REFLECTIONS_ENABLED == 0
		/* DRAWBUFFERS:042 */
		gl_FragData[2] = colorForBloom;
	#endif
	
	#if BLOOM_ENABLED == 0 && RAIN_REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:043 */
		gl_FragData[2] = vec4(RAIN_REFLECTION_STRENGTHS * rainReflectionStrength, 0.0, 1.0);
	#endif
	
}

#endif





#ifdef VSH

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	#if RAIN_REFLECTIONS_ENABLED == 0
		vec3 worldPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
	#if WAVING_ENABLED == 1
		applyWaving(worldPos  ARGS_IN);
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
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if FOG_ENABLED == 1
		processFogVsh(worldPos  ARGS_IN);
	#endif
	
	
	glcolor = gl_Color.rgb;
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	#if RAIN_REFLECTIONS_ENABLED == 1
		#include "/import/upPosition.glsl"
		#include "/import/rainReflectionStrength.glsl"
		baseRainReflectionStrength = dot(normalize(upPosition), normal) * 0.5 + 0.5;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= rainReflectionStrength;
	#endif
	
	
	#if SHOW_DANGEROUS_LIGHT == 1
		isDangerousLight = float(
			lmcoord.x < 0.51
			&& dot(normal, normalize(upPosition)) > 0.9
		);
	#endif
	
	
	doPreLighting(ARG_IN);
	
}

#endif
