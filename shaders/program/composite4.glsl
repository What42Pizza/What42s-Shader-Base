#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/utils/depth.glsl"

#if DOF_ENABLED == 1
	#include "/lib/depth_of_field.glsl"
#endif
#if REFLECTIONS_ENABLED == 1
	#include "/utils/screen_to_view.glsl"
	#include "/lib/reflections.glsl"
	#if BORDER_FOG_ENABLED == 1
		#include "/lib/fog/getFogAmount.glsl"
	#endif
#endif



#if REFLECTIONS_ENABLED == 1
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
	vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb;
	
	
	
	// ======== DEPTH OF FIELD ========
	
	#if DOF_ENABLED == 1
		doDOF(color  ARGS_IN);
	#endif
	
	
	
	// ======== REFLECTIONS ========
	
	vec4 data;
	float depth0 = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float depth1 = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	bool shouldUseTransparent = depth0 < depth1; // if transparents depth is less than non-transparents depth then use transparents data tex
	#ifdef DISTANT_HORIZONS
		float dhDepth0 = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float dhDepth1 = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		shouldUseTransparent = shouldUseTransparent || dhDepth0 < dhDepth1;
	#endif
	if (shouldUseTransparent) {
		data = texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0);
	} else {
		data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
	}
	vec3 normal = decodeNormal(unpackVec2(data.y));
	
	#if REFLECTIONS_ENABLED == 1
		#if REFLECTIVE_EVERYTHING == 1
			float reflectionStrength = 1.0;
		#else
			float reflectionStrength = data.z;
		#endif
		if (reflectionStrength > 0.01) {
			doReflections(color, depth0, normal, reflectionStrength  ARGS_IN);
		}
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
