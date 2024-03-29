#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#ifdef REFLECTIONS_ENABLED
	#include "/utils/screen_to_view.glsl"
	#include "/lib/reflections.glsl"
#endif
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogDistance.glsl"
	#include "/lib/fog/getFogAmount.glsl"
#endif



#ifdef REFLECTIONS_ENABLED
	void doReflections(inout vec3 color  ARGS_OUT) {
		
		// skip sky and fog
		float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float linearDepth = toLinearDepth(depth  ARGS_IN);
		if (depthIsSky(linearDepth) || depthIsHand(linearDepth)) {return;}
		
		// get strengths
		vec2 reflectionStrengths = texelFetch(REFLECTION_STRENGTH_BUFFER, texelcoord, 0).rg;
		#if REFLECTIVE_EVERYTHING == 1
			reflectionStrengths = vec2(1.0, 0.0);
		#endif
		if (reflectionStrengths.r + reflectionStrengths.g < 0.01) {return;}
		
		// apply fog
		vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		#if FOG_ENABLED == 1
			#include "/import/gbufferModelViewInverse.glsl"
			vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
			float fogDistance = getFogDistance(playerPos  ARGS_IN);
			float fogAmount = getFogAmount(fogDistance, playerPos.y  ARGS_IN);
			reflectionStrengths *= 1.0 - fogAmount;
		#endif
		if (reflectionStrengths.r + reflectionStrengths.g < 0.01) {return;}
		
		vec3 normal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
		addReflection(color, viewPos, normal, MAIN_BUFFER, reflectionStrengths.r, reflectionStrengths.g  ARGS_IN);
		
	}
#endif



void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	#if BLOOM_ENABLED == 1
		vec3 bloomColor = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== REFLECTIONS ========
	
	#ifdef REFLECTIONS_ENABLED
		doReflections(color  ARGS_IN);
	#endif
	
	
	
	// ======== AUTO EXPOSURE ========
	
	#if AUTO_EXPOSURE_ENABLED == 1
		#include "/import/eyeBrightnessSmooth.glsl"
		vec2 normalizedBrightness = eyeBrightnessSmooth / 240.0;
		normalizedBrightness *= vec2(0.5, 1.0); // weights
		float autoExposureAmount = max(normalizedBrightness.x, normalizedBrightness.y);
		color *= mix(AUTO_EXPOSURE_DARK_MULT, AUTO_EXPOSURE_BRIGHT_MULT, autoExposureAmount);
	#endif
	
	
	
	// ======== BLOOM FILTERING ========
	
	#if BLOOM_ENABLED == 1
		float bloomMult = getColorLum(bloomColor * vec3(2.0, 1.0, 0.4));
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
