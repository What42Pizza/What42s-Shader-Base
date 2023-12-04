//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#if RAIN_REFLECTIONS_ENABLED == 1
	#include "/utils/screen_to_view.glsl"
	#include "/lib/reflections.glsl"
#endif
#if SSAO_ENABLED == 1
	#include "/lib/ssao.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	#if BLOOM_ENABLED == 1
		vec3 bloomColor = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== REFLECTIONS ========
	
	#if RAIN_REFLECTIONS_ENABLED == 1
		vec2 reflectionStengths = texelFetch(REFLECTION_STRENGTH_BUFFER, texelcoord, 0).rg;
		#if REFLECTIVE_EVERYTHING == 1
			reflectionStengths = vec2(1.0, 0.0);
		#endif
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
	
	#if SSAO_ENABLED == 1
		float aoFactor = getAoFactor(ARG_IN);
		//#if SSAO_APPLICATION_TYPE == 1
			color *= 1.0 - aoFactor * AO_AMOUNT;
		//#elif SSAO_APPLICATION_TYPE == 2
		//	color = pow(color, vec3(1.0 + aoFactor * 1.5));
		//#endif
		#if SSAO_SHOW_AMOUNT == 1
			debugOutput = vec3(1.0 - aoFactor);
		#endif
	#endif
	
	
	
	// ======== BLOOM FILTERING ========
	
	#if BLOOM_ENABLED == 1
		float bloomMult = getColorLum(bloomColor);
		bloomMult = (bloomMult - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		bloomMult = clamp(bloomMult, 0.0, 1.0);
		bloomColor *= bloomMult;
	#endif
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
	#if BLOOM_ENABLED == 1
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
