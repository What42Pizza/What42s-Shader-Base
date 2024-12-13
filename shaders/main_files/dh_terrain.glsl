// transfers

#ifdef FIRST_PASS
	
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec3 normal;
	varying vec3 worldPos;
	flat_inout int dhBlock;
	
	#if REFLECTIONS_ENABLED == 1
		varying float baseRainReflectionStrength;
	#endif
	
#endif

// includes

#include "/lib/lighting/pre_lighting.glsl"
#include "/lib/lighting/basic_lighting.glsl"





#ifdef FSH

#include "/utils/getSkyLight.glsl"

#if REFLECTIONS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	
	float lengthCylinder = max(length(worldPos.xz), abs(worldPos.y));
	#include "/import/far.glsl"
	if (lengthCylinder < far - 16) discard;
	
	vec3 color = glcolor;
	
	
	// main lighting
	color *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	
	// add noise for fake texture
	#include "/import/cameraPosition.glsl"
	uvec3 noisePos = uvec3(ivec3((worldPos + cameraPosition) * 6 + 0.5));
	uint noise = randomizeUint(noisePos.x) ^ randomizeUint(noisePos.y) ^ randomizeUint(noisePos.z);
	color *= 1.0 + 0.1 * randomFloat(noise);
	color = clamp(color, vec3(0), vec3(1));
	
	
	// rain reflection strength
	#if REFLECTIONS_ENABLED == 1
		#include "/import/cameraPosition.glsl"
		float rainReflectionStrength = baseRainReflectionStrength;
		float rainNoise = simplexNoise((worldPos + cameraPosition) * 0.2);
		rainNoise = clamp(RAIN_REFLECTION_SLOPE * (rainNoise - (1.0 - RAIN_REFLECTION_COVERAGE)) + 1.0, RAIN_REFLECTION_MIN, 1.0);
		rainReflectionStrength *= rainNoise;
		rainReflectionStrength *= lmcoord.y * lmcoord.y * lmcoord.y;
		vec2 reflectionStrengths = RAIN_REFLECTION_STRENGTHS * rainReflectionStrength;
	#endif
	
	
	// outputs
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = vec4(color, 1.0);
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

void main() {
	
	normal = gl_NormalMatrix * gl_Normal;
	lmcoord = gl_MultiTexCoord2.xy;
	adjustLmcoord(lmcoord);
	dhBlock = dhMaterialId;
	
	if (dhMaterialId == DH_BLOCK_LEAVES) glcolor.rgb *= 1.3;
	
	
	#include "/import/gbufferModelViewInverse.glsl"
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
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
	
	
	#if REFLECTIONS_ENABLED == 1
		#include "/import/upPosition.glsl"
		#include "/import/rainReflectionStrength.glsl"
		baseRainReflectionStrength = dot(normalize(upPosition), normal) * 0.5 + 0.5;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= baseRainReflectionStrength;
		baseRainReflectionStrength *= rainReflectionStrength;
	#endif
	
	
	doPreLighting(ARG_IN);
	
}

#endif
