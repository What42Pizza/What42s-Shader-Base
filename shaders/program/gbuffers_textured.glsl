#undef SHADOWS_ENABLED
#define SHADOWS_ENABLED 0

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec4 glcolor;
	varying vec3 normal;
	
	flat_inout vec3 skyLight;
	
#endif





#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"

void main() {
	
	vec4 albedo = texture2D(MAIN_TEXTURE, texcoord) * vec4(glcolor.rgb, 1.0);
	if (albedo.a < 0.1) discard;
	
	
	doFshLighting(albedo.rgb, lmcoord.x, lmcoord.y, vec3(0.0), normal  ARGS_IN);
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(encodeNormal(normal)),
		0.0,
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getSkyLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if defined TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;
	
	skyLight = getSkyLight(ARG_IN);
	
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.0) return; // simple but effective optimization
	#endif
	
	
	#if defined TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
