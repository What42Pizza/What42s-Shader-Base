#ifdef FIRST_PASS
	flat_inout vec4 glcolor;
#endif



#ifdef FSH

void main() {
	
	vec4 albedo = glcolor;
	
	
	/*
		0.0: albedo.r
		0.1: albedo.g
		0.2: albedo.b
		1.0: lmcoord.x & lmcoord.y
		1.1: normal x & normal y
		1.2: gl_Color brightness (squared 'length' of gl_Color) * 0.25
		1.3: block id
	*/
	/* DRAWBUFFERS:01 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(0.0, 0.0),
		packVec2(0.0, 0.0),
		0.75,
		0.0
	);
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
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	glcolor = gl_Color;
	
}

#endif
