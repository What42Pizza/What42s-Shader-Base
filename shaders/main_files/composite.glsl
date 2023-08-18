//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/ssao.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef BLOOM_ENABLED
		vec3 bloomColor = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
	#endif
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== SSAO ========
	
	#ifdef SSAO_ENABLED
		float aoFactor = getAoFactor();
		color *= 1.0 - aoFactor * AO_AMOUNT;
		#ifdef SSAO_SHOW_AMOUNT
			debugOutput = vec3(1.0 - aoFactor);
		#endif
	#endif
	
	
	
	// ======== BLOOM FILTERING ========
	
	#ifdef BLOOM_ENABLED
		float lum = getColorLum(bloomColor);
		float alpha = (lum - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		alpha = pow(clamp(alpha, 0.0, 1.0), BLOOM_CURVE);
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

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
