#undef INCLUDE_DEPTH

#if defined FIRST_PASS && !defined DEPTH_FIRST_FINISHED
	#define INCLUDE_DEPTH
	#define DEPTH_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined DEPTH_SECOND_FINISHED
	#define INCLUDE_DEPTH
	#define DEPTH_SECOND_FINISHED
#endif



#ifdef INCLUDE_DEPTH



float toLinearDepth(float depth  ARGS_OUT) {
	#include "/import/twoTimesNear.glsl"
	#include "/import/farPlusNear.glsl"
	#include "/import/farMinusNear.glsl"
	return twoTimesNear / (farPlusNear - depth * farMinusNear);
}

float fromLinearDepth(float depth  ARGS_OUT) {
	#include "/import/farPlusNear.glsl"
	#include "/import/twoTimesNear.glsl"
	#include "/import/invFarMinusNear.glsl"
	return (farPlusNear - twoTimesNear / depth) * invFarMinusNear;
}

float toBlockDepth(float depth  ARGS_OUT) {
	#include "/import/twoTimesNearTimesFar.glsl"
	#include "/import/farPlusNear.glsl"
	#include "/import/farMinusNear.glsl"
	#include "/import/far.glsl"
	return twoTimesNearTimesFar / (farPlusNear - depth * farMinusNear);
}



#ifdef DISTANT_HORIZONS
	
	float toLinearDepthDh(float depth  ARGS_OUT) {
		#include "/import/dhNearPlane.glsl"
		#include "/import/dhFarPlane.glsl"
		return 2.0 * dhNearPlane / (dhFarPlane + dhNearPlane - depth * (dhFarPlane - dhNearPlane));
	}
	
	float toBlockDepthDh(float depth  ARGS_OUT) {
		#include "/import/dhNearPlane.glsl"
		#include "/import/dhFarPlane.glsl"
		return 2.0 * dhNearPlane * dhFarPlane / (dhFarPlane + dhNearPlane - depth * (dhFarPlane - dhNearPlane));
	}
	
#endif



#endif
