// defines

#if defined BLOOM_ENABLED && defined NORMALS_NEEDED
	#define BLOOM_AND_NORMALS
#endif

// transferres

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec4 glcolor;
	
	#ifdef NORMALS_NEEDED
		varying vec3 normal;
	#endif
	
#endif

// includes

#include "/lib/lighting.glsl"
#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	// hurt flash, creeper flash, etc
	#include "/import/entityColor.glsl"
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	
	
	// main lighting
	vec3 brightnesses = getLightingBrightnesses(lmcoord  ARGS_IN);
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z  ARGS_IN);
	
	
	// bloom
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_ENTITY_BRIGHTNESS);
	#endif
	
	
	// fog
	#ifdef ENTITY_FOG_ENABLED
		applyFog(color.rgb, colorForBloom.rgb  ARGS_IN);
	#endif
	
	
	/* DRAWBUFFERS:0*/
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_AND_NORMALS
		/* DRAWBUFFERS:0243 */
		gl_FragData[1] = colorForBloom;
		gl_FragData[2] = vec4(normal, 1.0);
		#ifdef RAIN_REFLECTIONS_ENABLED
			gl_FragData[3] = vec4(0.0, 0.0, 0.0, 1.0);
		#endif
	#elif defined BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#elif defined NORMALS_NEEDED
		/* DRAWBUFFERS:043 */
		gl_FragData[1] = vec4(normal, 1.0);
		#ifdef RAIN_REFLECTIONS_ENABLED
			gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
		#endif
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
	
	
	#ifdef ISOMETRIC_RENDERING_ENABLED
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if !defined ISOMETRIC_RENDERING_ENABLED
		if (gl_Position.z < -5.0) return; // simple but effective optimization
	#endif
	
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#ifdef ENTITY_FOG_ENABLED
		vec4 position = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
		getFogData(position.xyz  ARGS_IN);
	#endif
	
	
	glcolor = gl_Color;
	
	#ifdef NORMALS_NEEDED
		normal = gl_NormalMatrix * gl_Normal;
	#endif
	
	
	doPreLighting(ARG_IN);
	
}

#endif
