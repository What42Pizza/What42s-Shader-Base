//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/ssao.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 bloomColor = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
	
	
	
	// ======== SSAO ========
	
	#ifdef SSAO_ENABLED
		float aoFactor = getAoFactor();
		color *= 1.0 - aoFactor * AO_AMOUNT;
	#endif
	
	
	
	// ======== BLOOM FILTERING ========
	
	#ifdef BLOOM_ENABLED
		float lum = getColorLum(bloomColor);
		float alpha = (lum - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		alpha = pow(clamp(alpha, 0.0, 1.0), BLOOM_CURVE);
		bloomColor *= alpha;
	#endif
	
	
	
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS: 02 */
		gl_FragData[0] = vec4(color, 1.0);
		gl_FragData[1] = vec4(bloomColor, 1.0);
	#else
		/* DRAWBUFFERS: 0 */
		gl_FragData[0] = vec4(color, 1.0);
	#endif
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
