//-------------------//
//        TAA        //
//-------------------//

// This code was originally taken from Complementary Reimagined
// Link: https://modrinth.com/shader/complementary-reimagined



#ifdef FIRST_PASS
	const int clampingOffsetCount = 8;
	ivec2 clampingOffsets[clampingOffsetCount] = ivec2[clampingOffsetCount](
		ivec2(-1, -1),
		ivec2( 0, -1),
		ivec2( 1, -1),
		ivec2(-1,  0),
		ivec2( 1,  0),
		ivec2(-1,  1),
		ivec2( 0,  1),
		ivec2( 1,  1)
	);
#endif



void neighbourhoodClamping(vec3 color, inout vec3 prevColor  ARGS_OUT) {
	vec3 minColor = color;
	vec3 maxColor = color;
	
	for (int i = 0; i < clampingOffsetCount; i++) {
		ivec2 offsetCoord = texelcoord + clampingOffsets[i];
		vec3 offsetColor = texelFetch(MAIN_BUFFER, offsetCoord, 0).rgb;
		minColor = min(minColor, offsetColor);
		maxColor = max(maxColor, offsetColor);
	}
	
	prevColor = clamp(prevColor, minColor, maxColor);
}



void doTAA(inout vec3 color, inout vec3 newPrev, float linearDepth, vec2 prevCoord  ARGS_OUT) {
	
	if (
		prevCoord.x < 0.0 || prevCoord.x > 1.0 ||
		prevCoord.y < 0.0 || prevCoord.y > 1.0
	) {
		newPrev = color;
		return;
	}
	
	vec3 prevColor = texture2D(TAA_PREV_BUFFER, prevCoord).rgb;
	
	neighbourhoodClamping(color, prevColor  ARGS_IN);
	
	const float blendMin = 0.3;
	const float blendMax = 0.98;
	const float blendVariable = 0.15;
	const float blendConstant = 0.65;
	const float depthFactor = 0.017;
	
	#include "/import/viewSize.glsl"
	vec2 velocity = (texcoord - prevCoord.xy) * viewSize;
	float velocityAmount = dot(velocity, velocity) * 10.0;
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		#include "/import/far.glsl"
		float blockDepth = linearDepth * far;
	#else
		float blockDepth = 0;
	#endif
	
	float blendAmount = blendConstant + exp(-velocityAmount) * (blendVariable + sqrt(blockDepth) * depthFactor);
	blendAmount = clamp(blendAmount, blendMin, blendMax);
	
	color = mix(color, prevColor, blendAmount);
	newPrev = color;
	
}
