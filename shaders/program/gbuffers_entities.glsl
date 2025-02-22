#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec2 normal;
	
#endif





#ifdef FSH

void main() {
	
	vec4 albedo = texture2D(MAIN_TEXTURE, texcoord);
	if (albedo.a < 0.1) discard;
	albedo.rgb = smoothMin(albedo.rgb, vec3(1.0), 0.2);
	albedo.rgb *= glcolor.rgb;
	
	
	// hurt flash, creeper flash, etc
	#include "/import/entityColor.glsl"
	albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
	albedo.rgb *= 1.0 + (1.0 - max(lmcoord.x, lmcoord.y)) * entityColor.a;
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(normal.x, normal.y),
		0.0,
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color.rgb;
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -5.0) return; // simple but effective optimization
	#endif
	
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
