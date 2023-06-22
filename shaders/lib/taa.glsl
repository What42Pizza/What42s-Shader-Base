//-------------------//
//        TAA        //
//-------------------//

// All of this code is taken from Complementary Reimagined
// Link: https://modrinth.com/shader/complementary-reimagined



const float regularEdge = 20.0;
const float extraEdgeMult = 3.0;

ivec2 neighbourhoodOffsets[8] = ivec2[8](
	ivec2(-1, -1),
	ivec2( 0, -1),
	ivec2( 1, -1),
	ivec2(-1,  0),
	ivec2( 1,  0),
	ivec2(-1,  1),
	ivec2( 0,  1),
	ivec2( 1,  1)
);



float ToLinearDepth(float depth) {
    return 2.0 * near / (far + near - depth * (far - near));
}

// Previous frame reprojection from Chocapic13
vec2 Reprojection(vec3 pos, vec3 cameraOffset) {
	pos = pos * 2.0 - 1.0;
	
	vec4 viewPosPrev = gbufferProjectionInverse * vec4(pos, 1.0);
	viewPosPrev /= viewPosPrev.w;
	viewPosPrev = gbufferModelViewInverse * viewPosPrev;
	
	vec4 previousPosition = viewPosPrev + vec4(cameraOffset, 0.0);
	previousPosition = gbufferPreviousModelView * previousPosition;
	previousPosition = gbufferPreviousProjection * previousPosition;
	return previousPosition.xy / previousPosition.w * 0.5 + 0.5;
}



void NeighbourhoodClamping(vec3 color, inout vec3 tempColor, float depth, inout float edge) {
	vec3 minclr = color, maxclr = color;
	
	for (int i = 0; i < 8; i++) {
		ivec2 texelCoordM = texelcoord + neighbourhoodOffsets[i];
		
		float depthCheck = texelFetch(depthtex1, texelCoordM, 0).r;
		if (abs(ToLinearDepth(depthCheck) - ToLinearDepth(depth)) > 0.09) {
			edge = regularEdge;
		}
		
		vec3 clr = texelFetch(texture, texelCoordM, 0).rgb;
		minclr = min(minclr, clr); maxclr = max(maxclr, clr);
	}
	
	tempColor = clamp(tempColor, minclr, maxclr);
}



void DoTAA(inout vec3 color, inout vec3 temp, float depth) {
	
	#ifndef TEMPORAL_FILTER
		depth = texelFetch(depthtex1, texelcoord, 0).r;
	#endif
	
	vec3 coord = vec3(texcoord, depth);
	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	vec2 prvCoord = Reprojection(coord, cameraOffset);
	
	vec2 view = vec2(viewWidth, viewHeight);
	vec3 tempColor = texture2D(colortex1, prvCoord).rgb;
	if (tempColor == vec3(0.0)) { // Fixes the first frame
		temp = color;
		return;
	}

	float edge = 0.0;
	NeighbourhoodClamping(color, tempColor, depth, edge);
	
	vec2 velocity = (texcoord - prvCoord.xy) * view;
	float blendFactor = float(
		prvCoord.x > 0.0 && prvCoord.x < 1.0 &&
		prvCoord.y > 0.0 && prvCoord.y < 1.0
	);
	float blendMinimum = 0.3;
	float blendVariable = 0.25;
	float blendConstant = 0.65;
	float velocityFactor = dot(velocity, velocity) * 10.0;
	blendFactor *= max(exp(-velocityFactor) * blendVariable + blendConstant - length(cameraOffset) * edge, blendMinimum);
	
	color = mix(color, tempColor, blendFactor);
	temp = color;
	
}