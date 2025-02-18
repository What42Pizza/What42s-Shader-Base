#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec2 normal;
	
#endif





#ifdef FSH

void main() {
	
	vec4 albedo = texture2D(MAIN_BUFFER, texcoord) * vec4(normalize(glcolor), 1.0);
	if (albedo.a < 0.1) discard;
	
	
	#include "/import/heldBlockLightValue.glsl"
	albedo.rgb *= 1.0 + heldBlockLightValue / 15.0 * 0.5;
	
	
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
#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color.rgb;
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos);
	#else
		gl_Position = ftransform();
	#endif
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
}

#endif
