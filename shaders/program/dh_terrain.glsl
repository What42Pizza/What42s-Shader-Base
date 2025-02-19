#ifdef FIRST_PASS
	
	varying vec2 lmcoord;
	varying vec3 glcolor;
	varying vec2 normal;
	varying vec3 worldPos;
	flat_inout int dhBlock;
	
#endif





#ifdef FSH

#include "/utils/getSkyLight.glsl"

void main() {
	
	float lengthCylinder = max(length(worldPos.xz), abs(worldPos.y));
	#include "/import/far.glsl"
	if (lengthCylinder < far - 20) discard;
	
	vec3 albedo = glcolor;
	
	
	// add noise for fake texture
	#include "/import/cameraPosition.glsl"
	uvec3 noisePos = uvec3(ivec3((worldPos + cameraPosition) * 6.0 + 0.5));
	uint noise = randomizeUint(noisePos.x) ^ randomizeUint(noisePos.y) ^ randomizeUint(noisePos.z);
	albedo *= 1.0 + 0.1 * randomFloat(noise);
	albedo = clamp(albedo, vec3(0.0), vec3(1.0));
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo, 1.0);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x, lmcoord.y),
		packVec2(normal.x, normal.y),
		0.0,
		1.0
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
	lmcoord = gl_MultiTexCoord2.xy;
	glcolor = gl_Color.rgb;
	adjustLmcoord(lmcoord);
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	#include "/import/gbufferModelViewInverse.glsl"
	worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	dhBlock = dhMaterialId;
	
	
	if (dhMaterialId == DH_BLOCK_LEAVES) glcolor.rgb *= 1.3;
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(worldPos);
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
