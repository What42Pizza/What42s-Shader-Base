//---------------------------------//
//        Post-Processing 5        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#include "/utils/reprojection.glsl"

#if TAA_ENABLED == 1
	#include "/lib/taa.glsl"
#endif
#if MOTION_BLUR_ENABLED == 1
	#include "/lib/motion_blur.glsl"
#endif
#if SHARPENING_ENABLED == 1
	#include "/lib/sharpening.glsl"
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
	#if ISOMETRIC_RENDERING_ENABLED == 0
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
	
	#if TAA_ENABLED == 1
		doTAA(color, prev, linearDepth, prevCoord, handFactor  ARGS_IN);
	#endif
	
	
	
	// ======== MOTION BLUR ========
	
	#if MOTION_BLUR_ENABLED == 1
		if (length(texcoord - prevCoord) > 0.00001) {
			doMotionBlur(color, prevCoord  ARGS_IN);
		}
	#endif
	
	
	
	// ======== SHARPENING ========
	
	#if SHARPENING_ENABLED == 1
		doSharpening(color  ARGS_IN);
	#endif
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:01 */
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
