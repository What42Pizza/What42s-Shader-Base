// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec3 normal;
	flat_inout int blockData;
	
	#if REFLECTIONS_ENABLED == 1
		varying vec3 worldPos;
		varying float baseRainReflectionStrength;
	#endif
	#if SHOW_DANGEROUS_LIGHT == 1
		varying float isDangerousLight;
	#endif
	
#endif

// includes

#include "/lib/lighting/pre_lighting.glsl"
#include "/lib/lighting/basic_lighting.glsl"





#ifdef FSH

#if REFLECTIONS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * vec4(glcolor, 1.0);
	
	
	// main lighting
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	
	// show dangerous light
	#if SHOW_DANGEROUS_LIGHT == 1
		if (isDangerousLight > 0.0) {
			color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), 0.6);
		}
	#endif
	
	
	// block reflection strengths
	float blockReflectionAmount = (blockData % 1000 - blockData % 100) / 100 * 0.15 * mix(BLOCKS_REFLECTION_AMOUNT_MULT_UNDERGROUND, BLOCKS_REFLECTION_AMOUNT_MULT_SURFACE, lmcoord.y);
	vec2 reflectionStrengths = vec2(blockReflectionAmount * (1.0 - BLOCKS_REFLECTION_FRESNEL), blockReflectionAmount * BLOCKS_REFLECTION_FRESNEL);
	
	
	// rain reflection strength
	#if REFLECTIONS_ENABLED == 1
		#include "/import/cameraPosition.glsl"
		float rainReflectionStrength = baseRainReflectionStrength;
		float noise = simplexNoise((worldPos + cameraPosition) * 0.2);
		noise = clamp(RAIN_REFLECTION_SLOPE * (noise - (1.0 - RAIN_REFLECTION_COVERAGE)) + 1.0, RAIN_REFLECTION_MIN, 1.0);
		rainReflectionStrength *= noise;
		rainReflectionStrength *= lmcoord.y * lmcoord.y * lmcoord.y;
		vec2 rainReflectionStrengths = RAIN_REFLECTION_STRENGTHS * rainReflectionStrength;
		reflectionStrengths = mix(reflectionStrengths, vec2(1.0), rainReflectionStrengths);
	#endif
	
	
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

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	#include "/import/mc_Entity.glsl"
	blockData = int(mc_Entity.x);
	if (blockData < 1000) blockData = 0;
	
	
	#if REFLECTIONS_ENABLED == 0
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
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	glcolor = gl_Color.rgb;
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	#if REFLECTIONS_ENABLED == 1
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
