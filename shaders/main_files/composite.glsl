//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/fog.glsl"

void main() {
	vec3 color = texelFetch(texture, ivec2(gl_FragCoord.xy), 0).rgb;
	vec3 bloomColor = texture2D(colortex2, texcoord).rgb;
	
	
	
	// ======== FOG ========
	
	if (!depthIsSky(getDepth(texcoord))) {
		applyFog(color, bloomColor);
	}
	
	
	
	// ======== BLOOM FILTERING ========
	
	float lum = getColorLum(bloomColor);
	float alpha = (lum - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
	alpha = pow(clamp(alpha, 0.0, 1.0), BLOOM_CURVE);
	bloomColor *= alpha;
	
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(bloomColor, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
