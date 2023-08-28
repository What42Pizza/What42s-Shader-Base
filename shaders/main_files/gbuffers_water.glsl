// defines

#define NORMALS_NEEDED

#ifdef NORMALS_NEEDED
	#define OUTPUT_NORMALS
#endif
#ifdef WATER_REFLECTIONS_ENABLED
	#define NORMALS_NEEDED
#endif

#if defined BLOOM_ENABLED && defined OUTPUT_NORMALS
	#define BLOOM_AND_NORMALS
#endif

// transferred

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 glcolor;
flat int blockType;

#ifdef NORMALS_NEEDED
	varying vec3 normal;
#endif
#ifdef WATER_REFLECTIONS_ENABLED
	varying vec3 viewPos;
#endif
#ifdef WAVING_WATER_NORMALS_ENABLED
	varying vec3 worldPos;
#endif

// includes

#include "../lib/lighting.glsl"
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
		vec3 debugOutput = vec3(0.0);
	#endif
	
	color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
	
	
	// waving water normals
	#ifdef WAVING_WATER_NORMALS_ENABLED
		vec3 normal = normal;
		if (blockType == 1007) {
			vec3 worldPos = (worldPos + cameraPosition) * 0.6 + frameCounter * 0.01;
			normal += simplexNoise3From4(vec4(worldPos, frameCounter * 0.005)) * 0.015;
			normal = normalize(normal);
		}
	#endif
	
	
	// bloom value
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
	#endif
	
	
	// main lighting
	color.rgb *= glcolor;
	vec3 brightnesses = getLightingBrightnesses(lmcoord);
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	#ifdef SHOW_SUNLIGHT
		debugOutput = vec3(brightnesses.y);
	#endif
	#ifdef SHOW_BRIGHTNESSES
		debugOutput = brightnesses;
	#endif
	
	#ifdef BLOOM_ENABLED
		#ifdef OVERWORLD
			float blockLight = brightnesses.x;
			float skyLight = brightnesses.y * rawSunTotal;
			colorForBloom.rgb *= max(blockLight * blockLight * 1.05, skyLight * 0.75);
		#endif
	#endif
	
	
	// reflection
	#ifdef WATER_REFLECTIONS_ENABLED
		if (blockType == 1007) {
			vec2 reflectionPos = Raytrace(viewPos, normal);
			float fresnel = 1.0 + min(dot(normalize(viewPos), normal), 1.0);
			fresnel *= fresnel;
			fresnel *= fresnel;
			float lerpAmount = 0.3 + fresnel * 0.5;
			if (reflectionPos.x > -0.5) {
				vec3 reflectionColor = texture2D(MAIN_BUFFER_COPY, reflectionPos).rgb;
				reflectionColor *= 0.8 + color.rgb * 0.2;
				lerpAmount *= clamp(10.0 - 10.0 * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0);
				color.rgb = mix(color.rgb, reflectionColor, lerpAmount);
			} else if (reflectionPos.x < -1.5) {
				color.rgb *= 1.0 - lerpAmount * 0.8;
			}
		}
	#endif
	
	
	// fog
	#ifdef FOG_ENABLED
		#ifdef BLOOM_ENABLED
			applyFog(color.rgb, colorForBloom.rgb);
		#else
			applyFog(color.rgb);
		#endif
	#endif
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_AND_NORMALS
		/* DRAWBUFFERS:024 */
		gl_FragData[1] = colorForBloom;
		gl_FragData[2] = vec4(normal, 1.0);
	#elif defined BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#elif defined NORMALS_NEEDED
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(normal, 1.0);
	#endif
}

#endif





#ifdef VSH

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	
	blockType = int(mc_Entity.x);
	
	#if !defined WAVING_WATER_NORMALS_ENABLED
		vec3 worldPos;
	#endif
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	#ifdef PHYSICALLY_WAVING_WATER_ENABLED
		if (blockType == 1007) {
			vec3 actualWorldPos = worldPos + cameraPosition;
			worldPos.y += sin(actualWorldPos.x * 0.6 + actualWorldPos.z * 1.4 + frameCounter * 0.05) * 0.04;
			worldPos.y += sin(actualWorldPos.x * 0.9 + actualWorldPos.z * 0.6 + frameCounter * 0.04) * 0.03;
		}
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(worldPos);
	#else
		gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	#endif
	
	if (gl_Position.z < -1.5) return; // simple but effective optimization
	
	
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	
	#ifdef FOG_ENABLED
		getFogData(worldPos);
	#endif
	
	
	#ifdef WATER_REFLECTIONS_ENABLED
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
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
	
	
	doPreLighting();
	
}

#endif
