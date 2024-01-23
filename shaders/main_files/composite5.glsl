//---------------------------------//
//        Post-Processing 6        //
//---------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/lib/simplex_noise.glsl"
#include "/lib/color_correction.glsl"
#if COLORBLIND_MODE != 0
	#include "/lib/colorblindness.glsl"
#endif
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"

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
	
	
	
	// ======== COLOR CORRECTION & TONE MAPPING ========
	
	doColorCorrection(color  ARGS_IN);
	#if COLORBLIND_MODE != 0
		applyColorblindnessCorrection(color  ARGS_IN);
	#endif
	
	
	
	// ======== VIGNETTE ========
	
	#if VIGNETTE_ENABLED == 1 && !defined END
		#include "/import/eyeBrightnessSmooth.glsl"
		float vignetteSkyAmount = 1.0 - eyeBrightnessSmooth.y / 240.0;
		vignetteSkyAmount = vignetteSkyAmount * (VIGNETTE_AMOUNT_UNDERGROUND - VIGNETTE_AMOUNT_SURFACE) + VIGNETTE_AMOUNT_SURFACE;
		float vignetteAlpha = length(texcoord - 0.5) * VIGNETTE_SCALE * 0.7;
		#if VIGNETTE_NOISE_ENABLED == 1
			#include "/utils/var_rng.glsl"
			vignetteAlpha += randomFloat(rng) * 0.02;
		#endif
		vignetteAlpha *= vignetteSkyAmount;
		color *= 1.0 - vignetteAlpha;
	#endif
	
	//color = vec3(toLinearDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r  ARGS_IN));
	//color = vec3(toBlockDepth(depth  ARGS_IN));
	
	
	
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
