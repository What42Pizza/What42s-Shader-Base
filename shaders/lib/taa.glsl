//-------------------//
//        TAA        //
//-------------------//

// All of this code is taken from Complementary Reimagined
// Link: https://modrinth.com/shader/complementary-reimagined



const float regularEdge = 20.0;

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



// Previous frame reprojection from Chocapic13
vec2 reprojection(vec3 pos, vec3 cameraOffset) {
	pos = pos * 2.0 - 1.0;
	
	vec4 viewPosPrev = gbufferProjectionInverse * vec4(pos, 1.0);
	viewPosPrev /= viewPosPrev.w;
	viewPosPrev = gbufferModelViewInverse * viewPosPrev;
	
	vec4 previousPosition = viewPosPrev + vec4(cameraOffset, 0.0);
	previousPosition = gbufferPreviousModelView * previousPosition;
	previousPosition = gbufferPreviousProjection * previousPosition;
	return previousPosition.xy / previousPosition.w * 0.5 + 0.5;
}



void neighbourhoodClamping(vec3 color, inout vec3 prevColor, float rawDepth, inout float edge) {
	float depth = toLinearDepth(rawDepth);
	vec3 minColor = color;
	vec3 maxColor = color;
	
	for (int i = 0; i < clampingOffsetCount; i++) {
		ivec2 offsetCoord = texelcoord + clampingOffsets[i];
		
		float offsetDepth = toLinearDepth(texelFetch(depthtex1, offsetCoord, 0).r);
		if (!depthIsSky(depth) && abs(offsetDepth - depth) > 0.09) {
			edge = regularEdge;
		}
		
		vec3 offsetColor = texelFetch(texture, offsetCoord, 0).rgb;
		minColor = min(minColor, offsetColor);
		maxColor = max(maxColor, offsetColor);
	}
	
	prevColor = clamp(prevColor, minColor, maxColor);
}



void doTAA(inout vec3 color, inout vec3 newPrev) {
	
	float depth;
	if (texelFetch(colortex7, ivec2(gl_FragCoord.xy), 0).r > 0.5) {
		depth = fromLinearDepth(0.175); // idk what should actually be here
	} else {
		depth = texelFetch(depthtex1, texelcoord, 0).r;
	}
	
	vec3 coord = vec3(texcoord, depth);
	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	vec2 prevCoord = reprojection(coord, cameraOffset);
	
	vec3 prevColor = texture2D(colortex1, prevCoord).rgb;
	if (prevColor == vec3(0.0)) { // Fixes the first frame
		newPrev = color;
		return;
	}
	
	float edge = 0.0;
	neighbourhoodClamping(color, prevColor, depth, edge);
	edge = 0.0;
	
	vec2 velocity = (texcoord - prevCoord.xy) * viewSize;
	float blendFactor = float(
		prevCoord.x > 0.0 && prevCoord.x < 1.0 &&
		prevCoord.y > 0.0 && prevCoord.y < 1.0
	);
	float blendMinimum = 0.3;
	float blendVariable = 0.25;
	float blendConstant = 0.65;
	float velocityFactor = dot(velocity, velocity) * 10.0;
	blendFactor *= max(exp(-velocityFactor) * blendVariable + blendConstant - length(cameraOffset) * edge, blendMinimum);
	
	color = mix(color, prevColor, blendFactor);
	//color = texelFetch(texture, ivec2(prevCoord * viewSize), 0).rgb;
	newPrev = color;
	
}