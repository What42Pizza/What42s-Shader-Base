// transferres

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec4 glcolor;
	
	varying vec3 normal;
	
#endif

// includes

#include "/lib/pre_lighting.glsl"
#include "/lib/basic_lighting.glsl"
#if FOG_ENABLED == 1
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
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	
	// bloom
	#if BLOOM_ENABLED == 1
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_ENTITY_BRIGHTNESS);
	#endif
	
	
	// fog
	#if ENTITY_FOG_ENABLED == 1
		#if BLOOM_ENABLED == 1
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
	
	#if BLOOM_ENABLED == 1 && RAIN_REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:0423 */
		gl_FragData[2] = colorForBloom;
		gl_FragData[3] = vec4(0.0, 0.0, 0.0, 1.0);
	#endif
	
	#if BLOOM_ENABLED == 1 && RAIN_REFLECTIONS_ENABLED == 0
		/* DRAWBUFFERS:042 */
		gl_FragData[2] = colorForBloom;
	#endif
	
	#if BLOOM_ENABLED == 0 && RAIN_REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:043 */
		gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
	#endif
	
}

#endif





#ifdef VSH

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
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -5.0) return; // simple but effective optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if ENTITY_FOG_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec4 position = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
		processFogVsh(position.xyz  ARGS_IN);
	#endif
	
	
	glcolor = gl_Color;
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	doPreLighting(ARG_IN);
	
}

#endif
