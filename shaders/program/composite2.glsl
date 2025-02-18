#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	
	#if BLOOM_ENABLED == 0
		const bool colortex3MipmapEnabled = true;
	#endif
	
#endif



#ifdef FSH

#include "/lib/simplex_noise.glsl"

void main() {
	
	
	
	// ======== UNDERWATER WAVING ========
	
	#ifdef UNDERWATER_WAVINESS_ENABLED
		vec2 texcoord = texcoord;
		#include "/import/isEyeInWater.glsl"
		if (isEyeInWater == 1) {
			texcoord = (texcoord - 0.5) * 0.95 + 0.5;
			#include "/import/frameTimeCounter.glsl"
			vec3 simplexInput = vec3(
				texcoord * 6.0 * UNDERWATER_WAVINESS_SCALE,
				frameTimeCounter * 0.65 * UNDERWATER_WAVINESS_SPEED
			);
			texcoord += simplexNoise2From3(simplexInput) * 0.0015 * UNDERWATER_WAVINESS_AMOUNT;
		}
	#endif
	
	vec3 color = texture2D(MAIN_BUFFER, texcoord).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texture2D(DEBUG_BUFFER, texcoord).rgb;
	#endif
	
	
	
	// ======== NOISY ADDITIONS ========
	
	const int noiseMipMap = 1;
	vec3 noisyAdditions = texture2DLod(NOISY_ADDITIONS_BUFFER, texcoord, noiseMipMap).rgb;
	color += noisyAdditions;
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
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
