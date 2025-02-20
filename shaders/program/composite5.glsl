#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#include "/utils/reprojection.glsl"

#if SSS_PHOSPHOR == 1
	#include "/lib/super_secret_settings/phosphor.glsl"
#endif
#ifdef REFLECTIONS_ENABLED
	#include "/utils/screen_to_view.glsl"
	#include "/lib/reflections.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/fog/getFogAmount.glsl"
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



#ifdef REFLECTIONS_ENABLED
	void doReflections(inout vec3 color, float depth, vec3 normal, float reflectionStrength  ARGS_OUT) {
		
		// skip sky and fog
		float linearDepth = toLinearDepth(depth  ARGS_IN);
		if (depthIsHand(linearDepth)) return;
		#ifdef DISTANT_HORIZONS
			float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
			float linearDhDepth = toLinearDepthDh(dhDepth  ARGS_IN);
			if (depthIsSky(linearDepth) && depthIsSky(linearDhDepth)) return;
		#else
			if (depthIsSky(linearDepth)) return;
		#endif
		
		// apply fog
		vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		#ifdef DISTANT_HORIZONS
			if (depthIsSky(linearDepth)) viewPos = screenToViewDh(vec3(texcoord, dhDepth)  ARGS_IN);
		#endif
		#if BORDER_FOG_ENABLED == 1
			#include "/import/gbufferModelViewInverse.glsl"
			vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
			float fogAmount = getFogAmount(playerPos  ARGS_IN);
			if (fogAmount > 0.99) return;
			reflectionStrength *= 1.0 - fogAmount;
		#endif
		
		addReflection(color, viewPos, normal, MAIN_TEXTURE, reflectionStrength  ARGS_IN);
		
	}
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
	
	vec4 data;
	float depth0 = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float depth1 = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	if (depth0 < depth1) { // if transparents depth is less than non-transparents depth then use transparents data tex
		data = texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0);
	} else {
		data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
	}
	vec3 normal = decodeNormal(unpackVec2(data.y));
	
	
	
	// ======== REFLECTIONS ========
	
	#ifdef REFLECTIONS_ENABLED
		#if REFLECTIVE_EVERYTHING == 1
			float reflectionStrength = 1.0;
		#else
			float reflectionStrength = data.z;
		#endif
		if (reflectionStrength > 0.01) {
			doReflections(color, depth0, normal, reflectionStrength  ARGS_IN);
		}
	#endif
	
	
	
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
	
	// ======== FXAA OR TAA ========
	#if AA_STRATEGY == 4
		float preventTaa = texture2D(PREVENT_TAA_BUFFER, texcoord, -2).r;
		float opaqueDepth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		bool isTransparent = opaqueDepth - depth > 0.001;
		if (preventTaa > 0.1) {
			doFxaa(color, MAIN_TEXTURE  ARGS_IN);
		}
		if (preventTaa < 0.5 || isTransparent) {
			doTAA(color, blockDepth, prevCoord  ARGS_IN);
		}
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
	#if (AA_STRATEGY == 2 || AA_STRATEGY == 3 || AA_STRATEGY == 4) || SSS_PHOSPHOR == 1
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
