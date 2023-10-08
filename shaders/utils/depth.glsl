#ifndef util_depth
	#define util_depth 0
#endif

#undef include_self

#if defined FIRST_PASS && util_depth == 0
	#define include_self
	#define util_depth 1
#endif
#if defined SECOND_PASS && util_depth == 1
	#define include_self
	#define util_depth 2
#endif

#ifdef include_self



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
}



#endif
