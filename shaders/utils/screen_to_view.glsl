#if ISOMETRIC_RENDERING_ENABLED == 0
	
	// CODE FROM COMPLEMENTARY REIMAGINED:
	vec3 screenToView(vec3 pos  ARGS_OUT) {
		#include "/import/gbufferProjectionInverse.glsl"
		vec4 iProjDiag = vec4(
			gbufferProjectionInverse[0].x,
			gbufferProjectionInverse[1].y,
			gbufferProjectionInverse[2].zw
		);
		vec3 p3 = pos * 2.0 - 1.0;
		vec4 viewPos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
		return viewPos.xyz / viewPos.w;
	}
	// END OF COMPLEMENTARY REIMAGINED'S CODE
	
#else
	
	#include "/lib/isometric.glsl"
	
	vec3 screenToView(vec3 pos  ARGS_OUT) {
		pos = pos * 2.0 - 1.0;
		pos.z += getIsometricOffset(ARG_IN);
		pos /= getIsometricScale(ARG_IN);
		return pos;
	}
	
#endif
