// transferres

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec4 glcolor;
	
	varying vec3 normal;
	
#endif

// includes

#include "/lib/lighting/pre_lighting.glsl"
#include "/lib/lighting/basic_lighting.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	
	
	// hurt flash, creeper flash, etc
	#include "/import/entityColor.glsl"
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	
	
	
	// main lighting
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	
	
	// outputs
	
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

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -5.0) return; // simple but effective optimization
	#endif
	
	
	#ifdef TAA_JITTER
		#if AA_STRATEGY == 4
			gl_Position.z -= 0.001;
		#else
			doTaaJitter(gl_Position.xy  ARGS_IN);
		#endif
	#endif
	
	
	glcolor = gl_Color;
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	doPreLighting(ARG_IN);
	
}

#endif
