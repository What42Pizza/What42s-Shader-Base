//--------------------------------------------------------//
//        Post-Processing 3 (adding noisy results)        //
//--------------------------------------------------------//



#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	
	#if BLOOM_ENABLED == 0
		const bool colortex3MipmapEnabled = true;
	#endif
	
#endif



#ifdef FSH

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== NOISY ADDITIONS ========
	
	const int noiseMipMap = 1;
	vec3 noisyAdditions = texture2DLod(NOISY_ADDITIONS_BUFFER, texcoord, noiseMipMap).rgb;
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
