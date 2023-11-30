//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#ifdef RAIN_REFLECTIONS_ENABLED
	#include "/utils/screen_to_view.glsl"
	#include "/lib/reflections.glsl"
#endif
#ifdef SSAO_ENABLED
	#include "/lib/ssao.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	#ifdef BLOOM_ENABLED
		vec3 bloomColor = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== REFLECTIONS ========
	
	#ifdef RAIN_REFLECTIONS_ENABLED
		vec2 reflectionStengths = texelFetch(REFLECTION_STRENGTH_BUFFER, texelcoord, 0).rg;
		if (reflectionStengths.r + reflectionStengths.g > 0.01) {
			float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
			float linearDepth = toLinearDepth(depth  ARGS_IN);
			if (!(depthIsSky(linearDepth) || depthIsHand(linearDepth))) {
				vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
				vec3 normal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
				addReflection(color, viewPos, normal, MAIN_BUFFER, reflectionStengths.r, reflectionStengths.g  ARGS_IN);
			}
		}
	#endif
	
	
	
	// ======== SSAO ========
	
	#ifdef SSAO_ENABLED
		float aoFactor = getAoFactor(ARG_IN);
		//#if SSAO_APPLICATION_TYPE == 1
			color *= 1.0 - aoFactor * AO_AMOUNT;
		//#elif SSAO_APPLICATION_TYPE == 2
		//	color = pow(color, vec3(1.0 + aoFactor * 1.5));
		//#endif
		#ifdef SSAO_SHOW_AMOUNT
			debugOutput = vec3(1.0 - aoFactor);
		#endif
	#endif
	
	
	
	// ======== BLOOM FILTERING ========
	
	#ifdef BLOOM_ENABLED
		float alpha = getColorLum(bloomColor);
		alpha = (alpha - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		alpha = clamp(alpha, 0.0, 1.0);
		bloomColor *= alpha;
	#endif
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = vec4(bloomColor, 1.0);
	#endif
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
