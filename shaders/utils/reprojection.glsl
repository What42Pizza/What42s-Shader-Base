// this code is used in both TAA and Motion Blur



#undef INCLUDE_REPROJECTION

#if defined FIRST_PASS && !defined REPROJECTION_FIRST_FINISHED
	#define INCLUDE_REPROJECTION
	#define REPROJECTION_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined REPROJECTION_SECOND_FINISHED
	#define INCLUDE_REPROJECTION
	#define REPROJECTION_SECOND_FINISHED
#endif



#ifdef INCLUDE_REPROJECTION



#if ISOMETRIC_RENDERING_ENABLED == 0
	
	
	// Previous frame reprojection from Chocapic13
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset  ARGS_OUT) {
		#include "/import/gbufferProjectionInverse.glsl"
		#include "/import/gbufferModelViewInverse.glsl"
		#include "/import/gbufferPreviousProjection.glsl"
		#include "/import/gbufferPreviousModelView.glsl"
		screenPos = screenPos * 2.0 - 1.0;
		
		vec4 viewPos = gbufferProjectionInverse * vec4(screenPos, 1.0);
		viewPos /= viewPos.w;
		vec4 worldPos = gbufferModelViewInverse * viewPos;
		
		vec4 prevWorldPos = worldPos + vec4(cameraOffset, 0.0);
		vec4 prevCoord = gbufferPreviousProjection * gbufferPreviousModelView * prevWorldPos;
		return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
	}
	
	
#else
	
	
	#include "/lib/isometric.glsl"
	
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset  ARGS_OUT) {
		
		vec3 worldPos = screenPos * 2.0 - 1.0;
		worldPos.z += getIsometricOffset(ARG_IN);
		worldPos /= getIsometricScale(ARG_IN);
		#include "/import/gbufferModelViewInverse.glsl"
		worldPos = mat3(gbufferModelViewInverse) * worldPos;
		
		vec3 prevWorldPos = worldPos + cameraOffset;
		
		#include "/import/gbufferPreviousModelView.glsl"
		vec2 prevCoord = (mat3(gbufferPreviousModelView) * prevWorldPos).xy;
		prevCoord.xy *= getIsometricScale(ARG_IN).xy;
		return prevCoord.xy * 0.5 + 0.5;
	}
	
	
#endif



#endif
