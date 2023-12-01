// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec3 normal;
	
	#ifdef RAIN_REFLECTIONS_ENABLED
		varying vec3 worldPos;
		varying float baseRainReflectionStrength;
	#endif
	#ifdef SHOW_DANGEROUS_LIGHT
		varying float isDangerousLight;
	#endif
	
#endif

// includes

#include "/lib/pre_lighting.glsl"
#include "/lib/basic_lighting.glsl"
#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif





#ifdef FSH

#ifdef RAIN_REFLECTIONS_ENABLED
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * vec4(glcolor, 1.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	// bloom value
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
	#endif
	
	
	// main lighting
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	#ifdef BLOOM_ENABLED
		#ifdef OVERWORLD
			#include "/import/sunriseColorPercent.glsl"
			#include "/import/sunsetColorPercent.glsl"
			#include "/import/sunDayPercent.glsl"
			float blockLight = lmcoord.x;
			float skyLight = lmcoord.y * (sunriseColorPercent + sunsetColorPercent + sunDayPercent);
			colorForBloom.rgb *= max(blockLight * blockLight * 1.05, skyLight * 0.75);
		#elif defined NETHER
			colorForBloom.rgb *= lmcoord.x;
			colorForBloom.rgb *= dot(colorForBloom.rgb, vec3(0.92, 0.35, 0.07)) * 1.3;
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
	
	#if defined BLOOM_ENABLED && defined RAIN_REFLECTIONS_ENABLED
		/* DRAWBUFFERS:0423 */
		gl_FragData[2] = colorForBloom;
		gl_FragData[3] = vec4(RAIN_REFLECTION_STRENGTHS * rainReflectionStrength, 0.0, 1.0);
	#endif
	
	#if defined BLOOM_ENABLED && !defined RAIN_REFLECTIONS_ENABLED
		/* DRAWBUFFERS:042 */
		gl_FragData[2] = colorForBloom;
	#endif
	
	#if !defined BLOOM_ENABLED && defined RAIN_REFLECTIONS_ENABLED
		/* DRAWBUFFERS:043 */
		gl_FragData[2] = vec4(RAIN_REFLECTION_STRENGTHS * rainReflectionStrength, 0.0, 1.0);
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
	adjustLmcoord(lmcoord);
	
	#if !defined RAIN_REFLECTIONS_ENABLED
		vec3 worldPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
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
	
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	#ifdef RAIN_REFLECTIONS_ENABLED
		#include "/import/upPosition.glsl"
		#include "/import/rainReflectionStrength.glsl"
		baseRainReflectionStrength = dot(normalize(upPosition), normal) * 0.5 + 0.5;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= rainReflectionStrength;
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
