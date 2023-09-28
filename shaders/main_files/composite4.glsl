//---------------------------------//
//        Post-Processing 5        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#ifdef TAA_ENABLED
	#include "/lib/taa.glsl"
#endif
#ifdef MOTION_BLUR_ENABLED
	#include "/lib/motion_blur.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 prev = vec3(0.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	float handFactor = 0.0;
	#if !defined ISOMETRIC_RENDERING_ENABLED
		if (depthIsHand(linearDepth)) {
			depth = fromLinearDepth(HAND_DEPTH  ARGS_IN);
			handFactor = -0.25;
		}
	#endif
	
	vec3 pos = vec3(texcoord, depth);
	#include "/import/cameraPosition.glsl"
	#include "/import/previousCameraPosition.glsl"
	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	vec2 prevCoord = reprojection(pos, cameraOffset  ARGS_IN);
	
	
	
	// ======== TAA ========
	
	#ifdef TAA_ENABLED
		doTAA(color, prev, linearDepth, prevCoord, handFactor  ARGS_IN);
	#endif
	
	
	
	// ======== MOTION BLUR ========
	
	#ifdef MOTION_BLUR_ENABLED
		if (length(texcoord - prevCoord) > 0.00001) {
			doMotionBlur(color, prevCoord  ARGS_IN);
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
