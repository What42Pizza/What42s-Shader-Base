#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec2 normal;
	flat_inout int materialId;
	
	#ifdef DISTANT_HORIZONS
		varying vec3 worldPos;
	#endif
	
#endif





#ifdef FSH

void main() {
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if AA_STRATEGY == 2 || AA_STRATEGY == 3 || AA_STRATEGY == 4
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(worldPos.xz), abs(worldPos.y));
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 4 - 12 * dither) discard;
	#endif
	
	
	vec4 albedo = texture2D(MAIN_TEXTURE, texcoord) * vec4(normalize(glcolor), 1.0);
	if (albedo.a < 0.1) discard;
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x, lmcoord.y),
		packVec2(normal.x, normal.y),
		dot(glcolor, glcolor) * 0.25,
		materialId / 65535.0
	);
	
}

#endif





#ifdef VSH

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
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
	
	#include "/import/mc_Entity.glsl"
	materialId = int(mc_Entity.x);
	if (materialId < 1000) materialId = 0;
	
	
	#ifndef DISTANT_HORIZONS
		vec3 worldPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
	#if WAVING_ENABLED == 1
		applyWaving(worldPos  ARGS_IN);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(worldPos);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective(?) optimization
	#endif
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
}

#endif
