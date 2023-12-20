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
	return twoTimesNearTimesFar / (farPlusNear - depth * farMinusNear);
	//#include "/import/near.glsl"
	//#include "/import/far.glsl"
	//float linearDepth = toLinearDepth(depth  ARGS_IN);
	//return mix(near, far * 0.5, linearDepth);
}



#endif
