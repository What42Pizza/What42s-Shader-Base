//-------------------//
//        TAA        //
//-------------------//

// This code was originally taken from Complementary Reimagined
// Link: https://modrinth.com/shader/complementary-reimagined



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



#if !defined ISOMETRIC_RENDERING_ENABLED
	// Previous frame reprojection from Chocapic13
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset) {
		screenPos = screenPos * 2.0 - 1.0;
		
		vec4 viewPos = gbufferProjectionInverse * vec4(screenPos, 1.0);
		viewPos /= viewPos.w;
		vec4 worldPos = gbufferModelViewInverse * viewPos;
		
		vec4 prevWorldPos = worldPos + vec4(cameraOffset, 0.0);
		vec4 prevCoord = gbufferPreviousProjection * gbufferPreviousModelView * prevWorldPos;
		return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
	}
#else
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset) {
		const float scale = ISOMETRIC_WORLD_SCALE * 0.5;
		const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		const float forwardMinusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 - ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		vec4 scaleVec = vec4(scale * aspectRatio, scale, -forwardPlusBackward, 1);
		const vec4 offsetVec = vec4(0, 0, forwardMinusBackward / forwardPlusBackward, 0);
		screenPos = screenPos * 2.0 - 1.0;
		
		vec4 worldPos = gbufferModelViewInverse * ((vec4(screenPos, 1.0) + offsetVec) * scaleVec);
		worldPos /= worldPos.w;
		
		vec4 prevWorldPos = worldPos + vec4(cameraOffset, 0.0);
		vec4 prevCoord = (gbufferPreviousModelView * prevWorldPos) / scaleVec - offsetVec;
		return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
	}
#endif



void neighbourhoodClamping(vec3 color, inout vec3 prevColor) {
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



void doTAA(inout vec3 color, inout vec3 newPrev, float linearDepth, vec2 prevCoord, float handFactor) {
	
	if (
		prevCoord.x < 0.0 || prevCoord.x > 1.0 ||
		prevCoord.y < 0.0 || prevCoord.y > 1.0
	) {
		newPrev = color;
		return;
	}
	
	vec3 prevColor = texture2D(TAA_PREV_BUFFER, prevCoord).rgb;
	
	neighbourhoodClamping(color, prevColor);
	
	const float blendMin = 0.3;
	const float blendMax = 0.98;
	const float blendVariable = 0.15;
	const float blendConstant = 0.65;
	const float depthFactor = 0.017;
	
	vec2 velocity = (texcoord - prevCoord.xy) * viewSize;
	float velocityAmount = dot(velocity, velocity) * 10.0;
	
	#if !defined ISOMETRIC_RENDERING_ENABLED
		float blockDepth = linearDepth * far;
	#else
		float blockDepth = 0;
	#endif
	
	float blendAmount = blendConstant
		+ exp(-velocityAmount) * (blendVariable + sqrt(blockDepth) * depthFactor)
		+ handFactor;
	blendAmount = clamp(blendAmount, blendMin, blendMax);
	
	color = mix(color, prevColor, blendAmount);
	newPrev = color;
	
}
