//------------------------------------//
//        ISOMETRIC PROJECTION        //
//------------------------------------//

// This code was originally taken from XorDev's Ortho Shaderpack
// Link: https://github.com/XorDev/Ortho-Shaderpack/tree/master



vec4 projectIsometric(vec3 worldPos) {
	const float scale = ISOMETRIC_WORLD_SCALE * 0.5;
	const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	const float forwardMinusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 - ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	vec4 scaleVec = vec4(scale * aspectRatio, scale, -forwardPlusBackward, 1);
	const vec4 offsetVec = vec4(0, 0, forwardMinusBackward / forwardPlusBackward, 0);
	return (gbufferModelView * vec4(worldPos, 1.0)) / scaleVec - offsetVec;
}
