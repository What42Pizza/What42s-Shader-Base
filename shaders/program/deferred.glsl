#ifdef FIRST_PASS
	varying vec2 texcoord;
	flat_inout vec3 skyLight;
#endif





#ifdef FSH



#include "/lib/lighting/fsh_lighting.glsl"

#if SSAO_ENABLED == 1
	#include "/lib/ssao.glsl"
#endif
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogDistance.glsl"
	#include "/lib/fog/getFogAmount.glsl"
	#include "/lib/fog/applyFog.glsl"
#endif
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"

#if OUTLINES_ENABLED == 1
	#include "/lib/outlines.glsl"
#endif



void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb;
	vec4 data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
	vec2 lmcoord = unpackVec2(data.x);
	vec3 normal = decodeNormal(unpackVec2(data.y));
	
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float linearDhDepth = toLinearDepthDh(dhDepth  ARGS_IN);
	#endif
	
	
	
	// ======== OUTLINES ========
	
	#if OUTLINES_ENABLED == 1
		color *= 1.0 - getOutlineAmount(ARG_IN);
	#endif
	
	
	#ifdef DISTANT_HORIZONS
		bool isNonSky = !depthIsSky(linearDepth) || !depthIsSky(linearDhDepth);
	#else
		bool isNonSky = !depthIsSky(linearDepth);
	#endif
	if (isNonSky) {
		
		
		vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		doFshLighting(color, lmcoord.x, lmcoord.y, viewPos, normal  ARGS_IN);
		color *= sqrt(unpackVec2(data.z).x * 4.0);
		
		
		#if FOG_ENABLED == 1
			#include "/import/gbufferModelViewInverse.glsl"
			vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
			float fogDistance = getFogDistance(playerPos  ARGS_IN);
			float fogAmount = getFogAmount(fogDistance, playerPos.y  ARGS_IN);
		#endif
		
		
		#if SSAO_ENABLED == 1
			float aoFactor = getAoFactor(ARG_IN);
			color *= 1.0 - aoFactor * AO_AMOUNT;
		#endif
		
		
		#if FOG_ENABLED == 1
			applyFog(color, fogAmount  ARGS_IN);
		#endif
		
		
	}
	
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

#include "/utils/getSkyLight.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	skyLight = getSkyLight(ARG_IN);
}

#endif
