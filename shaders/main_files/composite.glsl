//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/fog.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 bloomColor = texture2D(BLOOM_BUFFER, texcoord).rgb;
	
	vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
	vec3 viewPos = screenToView(screenPos);
	vec3 playerPos = viewToPlayer(viewPos);
	
	
	
	// ======== FOG ========
	
	#ifdef FOG_ENABLED
		if (!depthIsSky(getDepth(texcoord))) {
			applyFog(color, bloomColor);
		}
	#endif
	
	
	
	// ======== BLOOM FILTERING ========
	
	#ifdef BLOOM_ENABLED
		float lum = getColorLum(bloomColor);
		float alpha = (lum - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		alpha = pow(clamp(alpha, 0.0, 1.0), BLOOM_CURVE);
		bloomColor *= alpha;
	#endif
	
	
	
	#ifdef BLOOM_ENABLED
		/* RENDERTARGETS: 0,2,10 */
		gl_FragData[0] = vec4(color, 1.0);
		gl_FragData[1] = vec4(bloomColor, 1.0);
		gl_FragData[2] = vec4(playerPos, 1.0);
	#else
		/* RENDERTARGETS: 0,10 */
		gl_FragData[0] = vec4(color, 1.0);
		gl_FragData[1] = vec4(playerPos, 1.0);
	#endif
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
