//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

void main(ARG_OUT) {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	#ifdef BLOOM_ENABLED
		vec3 bloomColor = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	// ======== BLOOM FILTERING ========
	
	#ifdef BLOOM_ENABLED
		float alpha = getColorLum(bloomColor  ARGS_IN);
		alpha = (alpha - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		alpha = clamp(alpha, 0.0, 1.0);
		bloomColor *= alpha;
	#endif
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = vec4(bloomColor, 1.0);
	#endif
}

#endif



#ifdef VSH

void main(ARG_OUT) {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
