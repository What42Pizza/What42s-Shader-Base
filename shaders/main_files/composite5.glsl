//---------------------------------//
//        Post-Processing 6        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/lib/simplex_noise.glsl"
#include "/lib/color_correction.glsl"

void main() {
	
	vec2 texcoord = texcoord;
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 1) {
		texcoord = (texcoord - 0.5) * 0.95 + 0.5;
		#include "/import/frameTimeCounter.glsl"
		texcoord += simplexNoise2From3(vec3(texcoord * 5.0, frameTimeCounter * 0.6)) * 0.003;
	}
	
	vec3 color = texture2D(MAIN_BUFFER, texcoord).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texture2D(DEBUG_BUFFER, texcoord).rgb;
	#endif
	
	
	
	// ======== COLOR CORRECTION & TONE MAPPING ========
	
	doColorCorrection(color  ARGS_IN);
	
	
	
	// ======== VIGNETTE ========
	
	#ifdef VIGNETTE_ENABLED
		#include "/import/eyeBrightnessSmooth.glsl"
		float vignetteSkyAmount = 1.0 - eyeBrightnessSmooth.y / 240.0;
		vignetteSkyAmount = vignetteSkyAmount * (VIGNETTE_AMOUNT_UNDERGROUND - VIGNETTE_AMOUNT_SURFACE) + VIGNETTE_AMOUNT_SURFACE;
		float vignetteAlpha = length(texcoord - 0.5) * VIGNETTE_SCALE * 0.7;
		#ifdef VIGNETTE_NOISE_ENABLED
			#include "/utils/var_rng.glsl"
			vignetteAlpha += randomFloat(rng) * 0.02;
		#endif
		vignetteAlpha *= vignetteSkyAmount;
		color *= 1.0 - vignetteAlpha;
	#endif
	
	//color = texture2D(shadowtex0, texcoord).rgb;
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
