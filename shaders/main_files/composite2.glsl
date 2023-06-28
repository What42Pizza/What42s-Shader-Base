//--------------------------------------------------------//
//        Post-Processing 3 (adding noisy results)        //
//--------------------------------------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/ssao.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	
	vec3 playerPos = texelFetch(PLAYER_POS_BUFFER, texelcoord, 0).rgb;
	
	
	
	// ======== SSAO ========
	
	#ifdef SSAO
		float aoFactor = getAoFactor();
		color *= 1.0 - aoFactor * AO_AMOUNT;
	#endif
	
	
	
	// ======== NOISY ADDITIONS ========
	
	const int noiseMipMap = 2;
	vec3 noisyAdditions = textureLod(NOISY_ADDITIONS_BUFFER, texcoord, noiseMipMap).rgb;
	color += noisyAdditions;
	
	
	
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
