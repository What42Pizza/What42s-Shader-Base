// defines

#undef SHADOWS_ENABLED

// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec4 glcolor;
	
	varying vec3 normal;
	
	#if FOG_ENABLED == 1
		varying float fogDistance;
		varying float pixelY;
	#endif
	
#endif

// includes

#include "/lib/lighting/pre_lighting.glsl"
#include "/lib/lighting/basic_lighting.glsl"





#ifdef FSH

#if FOG_ENABLED == 1
	#include "/lib/fog/getFogAmount.glsl"
	#include "/lib/fog/applyFog.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	// fog
	#if FOG_ENABLED == 1
		float fogAmount = getFogAmount(fogDistance, pixelY  ARGS_IN);
		color.a *= 1.0 - fogAmount;
	#endif
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal, 1.0);
	
	#if REFLECTIONS_ENABLED == 1 && AA_STRATEGY == 4
		/* DRAWBUFFERS:0465 */
		gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
		gl_FragData[3] = vec4(1.0, 1.0, 1.0, 1.0);
	#elif REFLECTIONS_ENABLED == 1 && AA_STRATEGY != 4
		/* DRAWBUFFERS:046 */
		gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
	#elif REFLECTIONS_ENABLED == 0 && AA_STRATEGY == 4
		/* DRAWBUFFERS:045 */
		gl_FragData[2] = vec4(1.0, 1.0, 1.0, 1.0);
	#endif
	
}

#endif





#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if defined TAA_JITTER && AA_STRATEGY != 4
	#include "/lib/taa_jitter.glsl"
#endif
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogDistance.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	#if FOG_ENABLED == 1 || ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.0) return; // simple but effective optimization
	#endif
	
	
	#if defined TAA_JITTER && AA_STRATEGY != 4
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if FOG_ENABLED == 1
		fogDistance = getFogDistance(worldPos  ARGS_IN);
		pixelY = worldPos.y;
	#endif
	
	
	glcolor = gl_Color;
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	doPreLighting(ARG_IN);
	
}

#endif
