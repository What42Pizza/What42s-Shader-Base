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



#if !defined ISOMETRIC_RENDERING_ENABLED
	
	
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
	
	
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset  ARGS_OUT) {
		#include "/import/aspectRatio.glsl"
		#include "/import/gbufferModelViewInverse.glsl"
		#include "/import/gbufferPreviousModelView.glsl"
		const float scale = ISOMETRIC_WORLD_SCALE * 0.5;
		const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		const float forwardMinusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 - ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		vec4 scaleVec = vec4(scale * aspectRatio, scale, -forwardPlusBackward, 1);
		const vec4 offsetVec = vec4(0, 0, forwardMinusBackward / forwardPlusBackward, 0);
		screenPos = screenPos * 2.0 - 1.0;
		
		vec4 worldPos = gbufferModelViewInverse * ((vec4(screenPos, 1.0) + offsetVec) * scaleVec);
		worldPos /= worldPos.w;
		
		vec4 prevWorldPos = worldPos + vec4(cameraOffset, 0.0);
		vec4 prevCoord = (gbufferPreviousModelView * prevWorldPos) / scaleVec - offsetVec;
		return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
	}
	
	
#endif



#endif
