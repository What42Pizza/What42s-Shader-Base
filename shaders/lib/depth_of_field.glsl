#include "/utils/depth.glsl"



vec3 getBlurredColor(vec2 coord, float size  ARGS_OUT) {
	#include "/import/pixelSize.glsl"
	vec3 colorTotal = vec3(0.0);
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1, -2) * pixelSize * size, 0).rgb * 0.574;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0, -2) * pixelSize * size, 0).rgb * 0.641;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1, -2) * pixelSize * size, 0).rgb * 0.574;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2, -1) * pixelSize * size, 0).rgb * 0.574;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1, -1) * pixelSize * size, 0).rgb * 0.801;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0, -1) * pixelSize * size, 0).rgb * 0.895;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1, -1) * pixelSize * size, 0).rgb * 0.801;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2, -1) * pixelSize * size, 0).rgb * 0.574;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2,  0) * pixelSize * size, 0).rgb * 0.641;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  0) * pixelSize * size, 0).rgb * 0.895;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  0) * pixelSize * size, 0).rgb * 1.0;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  0) * pixelSize * size, 0).rgb * 0.895;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2,  0) * pixelSize * size, 0).rgb * 0.641;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-2,  1) * pixelSize * size, 0).rgb * 0.574;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  1) * pixelSize * size, 0).rgb * 0.801;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  1) * pixelSize * size, 0).rgb * 0.895;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  1) * pixelSize * size, 0).rgb * 0.801;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 2,  1) * pixelSize * size, 0).rgb * 0.574;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2(-1,  2) * pixelSize * size, 0).rgb * 0.574;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 0,  2) * pixelSize * size, 0).rgb * 0.641;
	colorTotal += texture2D(MAIN_BUFFER, coord + vec2( 1,  2) * pixelSize * size, 0).rgb * 0.574;
	return colorTotal / 14.94; // value is pre-calculated total of weights (weights are gaussian of (offset length over 3))
}



void doDOF(inout vec3 color  DEBUG_ARGS_OUT  ARGS_OUT) {
	
	#if DOF_LOCKED_FOCAL_PLANE == 1
		#include "/import/invFar.glsl"
		float focusDepth = DOF_FOCAL_PLANE_DISTANCE * invFar;
	#else
		#ifdef IS_IRIS
			#include "/import/viewSize.glsl"
			float depth = texelFetch(DEPTH_BUFFER_ALL, ivec2(viewSize) / 2, 0).r;
			float focusDepth = toLinearDepth(depth  ARGS_IN);
		#else
			#include "/import/centerLinearDepthSmooth.glsl"
			float focusDepth = centerLinearDepthSmooth;
		#endif
	#endif
	
	float linearDepth = toLinearDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r  ARGS_IN);
	float depthChange = linearDepth - focusDepth;
	#if DOF_SLOPE_TYPE == 1
		depthChange /= 15.0 * focusDepth;
	#endif
	
	float nearBlurAmount = depthChange * (-1.0 / DOF_NEAR_BLUR_SLOPE) - (DOF_NEAR_BLUR_START / DOF_NEAR_BLUR_SLOPE);
	nearBlurAmount = clamp(nearBlurAmount, 0.0, 1.0) * DOF_NEAR_BLUR_STRENGTH;
	float farBlurAmount = depthChange * (1.0 / DOF_FAR_BLUR_SLOPE) - (DOF_FAR_BLUR_START / DOF_FAR_BLUR_SLOPE);
	farBlurAmount = clamp(farBlurAmount, 0.0, 1.0) * DOF_FAR_BLUR_STRENGTH;
	
	#if DOF_SHOW_AMOUNTS == 1
		debugOutput = vec3(nearBlurAmount, farBlurAmount, 0.0);
	#endif
	
	#include "/import/far.glsl"
	float blurSizeMult = 1.0 / (linearDepth * far * 0.01 + 1.0);
	vec3 nearBlur = getBlurredColor(texcoord, nearBlurAmount * blurSizeMult * DOF_NEAR_BLUR_SIZE  ARGS_IN);
	vec3 farBlur = getBlurredColor(texcoord, farBlurAmount * blurSizeMult * DOF_FAR_BLUR_SIZE  ARGS_IN);
	color = mix(color, farBlur, min(farBlurAmount, 1.0));
	color = mix(color, nearBlur, min(nearBlurAmount, 1.0));
	
}
