#ifdef FIRST_PASS
	const int SAMPLE_COUNT = MOTION_BLUR_QUALITY * MOTION_BLUR_QUALITY;
#endif

void doMotionBlur(inout vec3 color, vec2 prevCoord  ARGS_OUT) {
	
	#include "/import/invFrameTime.glsl"
	vec2 coordStep = (prevCoord - texcoord) * invFrameTime;
	coordStep *= MOTION_BLUR_AMOUNT * 0.01;
	coordStep /= SAMPLE_COUNT;
	vec2 pos = texcoord;
	
	for (int i = 0; i < SAMPLE_COUNT; i ++) {
		pos += coordStep;
		color += texture2D(TAA_PREV_BUFFER, pos).rgb;
	}
	
	color /= SAMPLE_COUNT + 1;
	
}
