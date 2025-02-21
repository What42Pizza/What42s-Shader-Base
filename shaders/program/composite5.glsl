#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#include "/utils/reprojection.glsl"

#if SSS_PHOSPHOR == 1
	#include "/lib/super_secret_settings/phosphor.glsl"
#endif
#if AA_STRATEGY == 1 || AA_STRATEGY == 3
	#include "/lib/fxaa.glsl"
#endif
#if AA_STRATEGY == 2 || AA_STRATEGY == 3
	#include "/lib/taa.glsl"
#endif
#if MOTION_BLUR_ENABLED == 1
	#include "/lib/motion_blur.glsl"
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
	
	vec3 color = texelFetch(MAIN_TEXTURE, sampleCoord, 0).rgb;
	
	
	
	// super secret settings
	
	#if SSS_PHOSPHOR == 1
		sss_phosphor(color  ARGS_IN);
	#endif
	
	
	
	float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	float blockDepth = toBlockDepth(depth  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		float blockDhDepth = toBlockDepthDh(dhDepth  ARGS_IN);
		blockDepth = min(blockDepth, blockDhDepth);
	#endif
	
	vec3 pos = vec3(texcoord, depth);
	#include "/import/cameraPosition.glsl"
	#include "/import/previousCameraPosition.glsl"
	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	vec2 prevCoord = reprojection(pos, cameraOffset  ARGS_IN);
	
	
	
	// ======== FXAA ========
	#if AA_STRATEGY == 1 || AA_STRATEGY == 3
		doFxaa(color, MAIN_TEXTURE  ARGS_IN);
	#endif
	
	// ======== TAA ========
	#if AA_STRATEGY == 2 || AA_STRATEGY == 3
		doTAA(color, blockDepth, prevCoord  ARGS_IN);
	#endif
	
	
	
	// ======== MOTION BLUR ========
	
	#if MOTION_BLUR_ENABLED == 1
		vec3 prevColor = color;
		if (length(texcoord - prevCoord) > 0.00001) {
			doMotionBlur(color, prevCoord, depth  ARGS_IN);
		}
	#endif
	
	
	
	/* DRAWBUFFERS:1 */
	gl_FragData[0] = vec4(color, 1.0);
	#if (AA_STRATEGY == 2 || AA_STRATEGY == 3) || SSS_PHOSPHOR == 1
		/* DRAWBUFFERS:14 */
		#if MOTION_BLUR_ENABLED == 1
			gl_FragData[1] = vec4(prevColor, 1.0);
		#else
			gl_FragData[1] = vec4(color, 1.0);
		#endif
	#endif
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
