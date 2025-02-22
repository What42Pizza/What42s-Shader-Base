#ifdef FIRST_PASS
	
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec2 normal;
	varying vec3 playerPos;
	flat_inout int dhBlock;
	
#endif





#ifdef FSH

#include "/utils/getSkyLight.glsl"

void main() {
	
	float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
	#include "/import/far.glsl"
	if (lengthCylinder < far - 20) discard;
	
	vec3 albedo = glcolor * 0.85;
	
	
	// add noise for fake texture
	#include "/import/cameraPosition.glsl"
	uvec3 noisePos = uvec3(ivec3((playerPos + cameraPosition) * 6.0 + 0.5));
	uint noise = randomizeUint(noisePos.x) ^ randomizeUint(noisePos.y) ^ randomizeUint(noisePos.z);
	albedo *= 1.0 + 0.1 * randomFloat(noise);
	albedo = clamp(albedo, vec3(0.0), vec3(1.0));
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo, 1.0);
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
	lmcoord = gl_MultiTexCoord2.xy;
	glcolor = gl_Color.rgb;
	adjustLmcoord(lmcoord);
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	dhBlock = dhMaterialId;
	
	
	glcolor = mix(vec3(getColorLum(glcolor)), glcolor, 1.1);
	if (dhMaterialId == DH_BLOCK_LEAVES) glcolor.rgb *= 1.15;
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#ifdef TAA_ENABLED
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
