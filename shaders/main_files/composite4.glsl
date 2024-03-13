#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	
	#if AA_STRATEGY == 4
		const bool colortex5MipmapEnabled = true;
	#endif
	
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#include "/utils/reprojection.glsl"

#if SSS_PHOSPHOR == 1
	#include "/lib/super_secret_settings/phosphor.glsl"
#endif
#if AA_STRATEGY == 1 || AA_STRATEGY == 3 || AA_STRATEGY == 4
	#include "/lib/fxaa.glsl"
#endif
#if AA_STRATEGY == 2 || AA_STRATEGY == 3 || AA_STRATEGY == 4
	#include "/lib/taa.glsl"
#endif
#if MOTION_BLUR_ENABLED == 1
	#include "/lib/motion_blur.glsl"
#endif
#if SHARPENING_ENABLED == 1
	#include "/lib/sharpening.glsl"
#endif

void main() {
	
	// super secret settings
	ivec2 sampleCoord = texelcoord;
	#if SSS_PIXELS != 0
		#include "/import/viewSize.glsl"
		int texelSize = int(viewSize.y) / SSS_PIXELS;
		sampleCoord /= texelSize;
		sampleCoord *= texelSize;
	#endif
	
	vec3 color = texelFetch(MAIN_BUFFER, sampleCoord, 0).rgb;
	vec3 prev = vec3(0.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// super secret settings
	
	#if SSS_PHOSPHOR == 1
		sss_phosphor(color  ARGS_IN);
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
	
	
	
	// ======== FXAA ========
	#if AA_STRATEGY == 1 || AA_STRATEGY == 3
		doFxaa(color, MAIN_BUFFER  ARGS_IN);
	#endif
	
	// ======== TAA ========
	#if AA_STRATEGY == 2 || AA_STRATEGY == 3
		doTAA(color, prev, linearDepth, prevCoord, handFactor  ARGS_IN);
	#endif
	
	// ======== FXAA OR TAA ========
	#if AA_STRATEGY == 4
		float preventTaa = texture2D(PREVENT_TAA_BUFFER, texcoord, -2).r;
		float opaqueDepth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		bool isTransparent = opaqueDepth - depth > 0.001;
		if (preventTaa > 0.1) {
			doFxaa(color, MAIN_BUFFER  ARGS_IN);
		}
		if (preventTaa < 0.5 || isTransparent) {
			doTAA(color, prev, linearDepth, prevCoord, handFactor  ARGS_IN);
		}
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
