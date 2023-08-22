//---------------------------------//
//        Post-Processing 5        //
//---------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/taa.glsl"
#include "/lib/motion_blur.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 prev = vec3(0.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	float depth = texelFetch(depthtex1, texelcoord, 0).r;
	float linearDepth = toLinearDepth(depth);
	float handFactor = 0.0;
	if (depthIsHand(linearDepth)) {
		depth = fromLinearDepth(HAND_DEPTH);
		handFactor = -0.25;
	}
	
	vec3 coord = vec3(texcoord, depth);
	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	vec2 prevCoord = reprojection(coord, cameraOffset);
	
	
	
	// ======== TAA ========
	
	#ifdef TAA_ENABLED
		doTAA(color, prev, linearDepth, prevCoord, handFactor);
	#endif
	
	
	
	// ======== MOTION BLUR ========
	
	#ifdef MOTION_BLUR_ENABLED
		if (length(texcoord - prevCoord) > 0.00001) {
			doMotionBlur(color, prevCoord);
		}
	#endif
	
	
	
	/* DRAWBUFFERS:01 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(prev, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
