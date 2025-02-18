#ifdef FIRST_PASS
	const int SAMPLE_COUNT = MOTION_BLUR_QUALITY * MOTION_BLUR_QUALITY;
#endif

void doMotionBlur(inout vec3 color, vec2 prevCoord, float centerDepth  ARGS_OUT) {
	color *= color;
	
	#include "/utils/var_rng.glsl"
	
	#include "/import/invFrameTime.glsl"
	vec2 coordStep = (prevCoord - texcoord) * invFrameTime;
	coordStep *= MOTION_BLUR_AMOUNT * 0.01;
	coordStep /= SAMPLE_COUNT;
	vec2 pos = texcoord;
	pos += coordStep * randomFloat(rng) * 0.25;
	
	for (int i = 0; i < SAMPLE_COUNT; i ++) {
		pos += coordStep;
		float sampleDepth = texture2DLod(DEPTH_BUFFER_WO_TRANS, pos, 0).x;
		vec3 sample = texture2D(PREV_TEXTURE, pos).rgb;
		color += sample * sample;
	}
	color /= SAMPLE_COUNT + 1;
	
	color = sqrt(color);
}
