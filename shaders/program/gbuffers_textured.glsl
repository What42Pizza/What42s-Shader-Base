#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec4 glcolor;
	varying vec2 normal;
	
#endif





#ifdef FSH

void main() {
	
	vec4 albedo = texture2D(MAIN_BUFFER, texcoord) * vec4(normalize(glcolor.rgb), 1.0);
	if (albedo.a < 0.1) discard;
	
	
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
		packVec2(lmcoord.x, lmcoord.y),
		packVec2(normal.x, normal.y),
		dot(glcolor, glcolor) * 0.25,
		0.0
	);
	
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
	glcolor = gl_Color;
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	
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
	
	
}

#endif
