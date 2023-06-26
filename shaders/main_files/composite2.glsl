//--------------------------------------------------------//
//        Post-Processing 3 (adding noisy results)        //
//--------------------------------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/ssao.glsl"

void main() {
	vec3 color = texelFetch(texture, texelcoord, 0).rgb;
	
	vec3 playerPos = texelFetch(colortex10, texelcoord, 0).rgb;
	
	
	
	// ======== SSAO ========
	
	#ifdef SSAO
		float aoFactor = getAoFactor();
		color *= 1.0 - aoFactor * AO_AMOUNT;
	#endif
	
	
	
	// ======== NOISY ADDITIONS ========
	
	vec3 noisyAdditions = textureLod(colortex8, texcoord, BLOOM_MIP_MAP).rgb;
	//color += noisyAdditions;
	
	
	
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
