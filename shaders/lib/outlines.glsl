//float getOutlineAmount(ARG_OUT) {
	
//	// implements difference of gaussians
//	float depth1 = 0.0;
//	float depth2 = 0.0;
//	float sample;
//	sample  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2(-1, -1), 0).r  ARGS_IN);
//	sample += toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 1, -1), 0).r  ARGS_IN);
//	sample += toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2(-1,  1), 0).r  ARGS_IN);
//	sample += toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 1,  1), 0).r  ARGS_IN);
//	depth1 += sample * 0.801;
//	depth2 += sample * 0.726;
//	sample  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 0, -1), 0).r  ARGS_IN);
//	sample += toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2(-1,  0), 0).r  ARGS_IN);
//	sample += toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 1,  0), 0).r  ARGS_IN);
//	sample += toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 0,  1), 0).r  ARGS_IN);
//	depth1 += sample * 0.895;
//	depth2 += sample * 0.852;
//	sample  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r  ARGS_IN);
//	depth1 += sample;
//	depth2 += sample;
//	depth1 /= 7.784;
//	depth2 /= 7.312;
	
//	#include "/import/far.glsl"
//	float diff = abs(depth1 - depth2) * far;
//	return smoothstep(0.01, 0.025, diff);
//}



float getOutlineAmount(ARG_OUT) {
	
	#include "/import/far.glsl"
	float m  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 0,  0), 0).r  ARGS_IN);
	if (depthIsSky(m)) {return 0.0;}
	m *= far;
	float tl = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2(-1, -1), 0).r  ARGS_IN) * far;
	float t  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 0, -1), 0).r  ARGS_IN) * far;
	float tr = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 1, -1), 0).r  ARGS_IN) * far;
	float l  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2(-1,  0), 0).r  ARGS_IN) * far;
	float r  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 1,  0), 0).r  ARGS_IN) * far;
	float bl = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2(-1,  1), 0).r  ARGS_IN) * far;
	float b  = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 0,  1), 0).r  ARGS_IN) * far;
	float br = toLinearDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord + ivec2( 1,  1), 0).r  ARGS_IN) * far;
	
	float lineA = (tl - m) + (br - m);
	float lineB = (tr - m) + (bl - m);
	float lineC = (t - m) + (b - m);
	float lineD = (l - m) + (r - m);
	float total = lineA + lineB + lineC + lineD;
	
	return clamp(abs(total * inversesqrt(m)), 0.0, 1.0);
}
