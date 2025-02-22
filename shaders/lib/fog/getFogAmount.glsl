float getFogAmount(vec3 playerPos  ARGS_OUT) {
	
	float fogDistance = max(length(playerPos.xz), abs(playerPos.y));
	#include "/import/invFar.glsl"
	float fogAmount = fogDistance * invFar;
	fogAmount = (fogAmount - BORDER_FOG_START) / (BORDER_FOG_END - BORDER_FOG_START);
	fogAmount = clamp(fogAmount, 0.0, 1.0);
	
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 0) {
		#if BORDER_FOG_CURVE == 2
			fogAmount = pow2(fogAmount);
		#elif BORDER_FOG_CURVE == 3
			fogAmount = pow3(fogAmount);
		#elif BORDER_FOG_CURVE == 4
			fogAmount = pow4(fogAmount);
		#elif BORDER_FOG_CURVE == 5
			fogAmount = pow5(fogAmount);
		#endif
	}
	
	return fogAmount;
}
