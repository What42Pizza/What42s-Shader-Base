varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 glcolor;

#ifdef REFLECTIONS_ENABLED
	varying vec3 normal;
	varying vec3 viewPos;
	varying vec4 worldPos;
	flat int blockType;
#endif

#include "../lib/lighting.glsl"
#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif

#if defined BLOOM_ENABLED && defined REFLECTIONS_ENABLED
	#define BLOOM_AND_REFLECTIONS
#endif





#ifdef FSH

#ifdef REFLECTIONS_ENABLED
	#include "/lib/reflections.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
	
	
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
	#ifdef REFLECTIONS_ENABLED
		if (blockType == 1007) {
			vec2 reflectionPos = Raytrace(viewPos, normal);
			float fresnel = 1.0 + min(dot(normalize(viewPos), normal), 1.0);
			fresnel *= fresnel;
			fresnel *= fresnel;
			float lerpAmount = 0.1 + fresnel * 0.4;
			if (reflectionPos.x > -0.5) {
				vec3 reflectionColor = texture2D(MAIN_BUFFER_COPY, reflectionPos).rgb;
				color.rgb = mix(color.rgb, reflectionColor, lerpAmount);
			} else if (reflectionPos.x < -1.5) {
				float fresnel = 1.0 + min(dot(normalize(viewPos), normal), 1.0);
				fresnel *= fresnel;
				fresnel *= fresnel;
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
	
	
	// show dangerous light
	#ifdef SHOW_DANGEROUS_LIGHT
		if (lmcoord.x < 0.5) {
			color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), 0.6);
		}
	#endif
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_AND_REFLECTIONS
		/* DRAWBUFFERS:024 */
		gl_FragData[1] = colorForBloom;
		gl_FragData[2] = vec4(normal, 1.0);
	#elif defined BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#elif defined REFLECTIONS_ENABLED
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(normal, 1.0);
	#endif
}

#endif





#ifdef VSH

#include "/lib/waving.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	#if !defined REFLECTIONS_ENABLED
		vec4 worldPos;
	#endif
	worldPos = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
	
	
	#ifdef WAVING_ENABLED
		blockType = int(mc_Entity.x);
		if (blockType == 1007) {
			vec3 actualWorldPos = worldPos.xyz + cameraPosition;
			worldPos.y += sin(actualWorldPos.x * 0.6 + actualWorldPos.z * 1.4 + frameCounter * 0.05) * 0.08;
			worldPos.y += sin(actualWorldPos.x * 0.9 + actualWorldPos.z * 0.6 + frameCounter * 0.04) * 0.05;
		}
		gl_Position = gl_ProjectionMatrix * gbufferModelView * worldPos;
	#else
		gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	#endif
	
	
	if (gl_Position.z < -1.0) return; // simple but effective optimization
	
	
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	
	#ifdef FOG_ENABLED
		getFogData(worldPos.xyz);
	#endif
	
	
	#ifdef REFLECTIONS_ENABLED
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#endif
	
	
	glcolor = gl_Color.rgb;
	#ifdef USE_SIMPLE_LIGHT
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	normal = (gl_NormalMatrix * gl_Normal);
	
	
	doPreLighting();
	
}

#endif
