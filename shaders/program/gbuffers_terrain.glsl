#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec2 normal;
	flat_inout int materialId;
	
	#ifdef DISTANT_HORIZONS
		varying vec3 playerPos;
	#endif
	
#endif





#ifdef FSH

void main() {
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if AA_STRATEGY == 2 || AA_STRATEGY == 3
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 4 - 12 * dither) discard;
	#endif
	
	
	// decrease vanilla ao in caves
	float glcolorBrightness = length(glcolor);
	glcolorBrightness = 1.0 - (1.0 - glcolorBrightness) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	vec3 newGlcolor = normalize(glcolor) * glcolorBrightness;
	
	
	vec4 albedo = texture2D(MAIN_TEXTURE, texcoord);
	if (albedo.a < 0.1) discard;
	albedo.rgb = smoothMin(albedo.rgb, vec3(1.0), 0.15);
	albedo.rgb *= newGlcolor;
	
	
	float reflectiveness = ((materialId - materialId % 100) / 100) * 0.15;
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(normal.x, normal.y),
		reflectiveness,
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"

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
	materialId %= 1000;
	
	
	#ifndef DISTANT_HORIZONS
		vec3 playerPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
	#if WAVING_ENABLED == 1
		applyWaving(playerPos  ARGS_IN);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
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
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
