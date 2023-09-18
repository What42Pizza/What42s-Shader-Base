// defines

#ifdef NORMALS_NEEDED
	#define OUTPUT_NORMALS
#endif
#ifdef WATER_REFLECTIONS_ENABLED
	#define NORMALS_NEEDED
#endif

#if defined BLOOM_ENABLED && defined OUTPUT_NORMALS
	#define BLOOM_AND_NORMALS
#endif

// transfers

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 glcolor;
flat int blockType;

#ifdef NORMALS_NEEDED
	varying vec3 normal;
#endif
#if defined WATER_REFLECTIONS_ENABLED || defined WATER_RESNEL_ADDITION
	varying vec3 viewPos;
#endif
#if defined WAVING_WATER_NORMALS_ENABLED
	varying vec3 worldPos;
#endif

// includes

#include "/lib/lighting.glsl"
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
	vec3 normal = normal;
	
	
	if (blockType == 1007) {
		
		
		// waving water normals
		#ifdef WAVING_WATER_NORMALS_ENABLED
			const float worldPosScale = 1.5;
			vec3 randomPoint = abs(simplexNoise3From4(vec4(worldPos / worldPosScale, frameCounter * 0.01)));
			vec3 normalWavingAddition = randomPoint * 0.1;
			normal += normalWavingAddition;
			normal = normalize(normal);
		#endif
		
		
		// fresnel addition
		#ifdef WATER_RESNEL_ADDITION
			vec3 fresnelNormal = normal;
			#ifdef WAVING_WATER_NORMALS_ENABLED
				fresnelNormal = normalize(fresnelNormal + normalWavingAddition * 30);
			#endif
			float fresnel = 1.0 - dot(normalize(-viewPos), fresnelNormal);
			color.rgb *= 0.8 + fresnel * 0.4;
		#endif
		
		
	}
	
	
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
			addReflection(color.rgb, viewPos, normal, MAIN_BUFFER_COPY, 0.3, 0.5);
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

#ifdef ISOMETRIC_RENDERING_ENABLED
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

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
			worldPos += cameraPosition;
			worldPos.y += sin(worldPos.x * 0.6 + worldPos.z * 1.4 + frameCounter * 0.05) * 0.04;
			worldPos.y += sin(worldPos.x * 0.9 + worldPos.z * 0.6 + frameCounter * 0.04) * 0.03;
			worldPos -= cameraPosition;
		}
	#endif
	
	#ifdef ISOMETRIC_RENDERING_ENABLED
		gl_Position = projectIsometric(worldPos);
	#else
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(worldPos);
	#endif
	
	#if !defined ISOMETRIC_RENDERING_ENABLED
		if (gl_Position.z < -1.5) return; // simple but effective optimization
	#endif
	
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	#ifdef FOG_ENABLED
		getFogData(worldPos);
	#endif
	
	
	#if defined WATER_REFLECTIONS_ENABLED || defined WATER_RESNEL_ADDITION
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#endif
	
	#ifdef WAVING_WATER_NORMALS_ENABLED
		worldPos += cameraPosition;
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
