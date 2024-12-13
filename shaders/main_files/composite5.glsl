#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"
#if SSS_DECONVERGE == 1
	#include "/lib/super_secret_settings/deconverge.glsl"
#endif
#if SHARPENING_ENABLED == 1
	#include "/lib/sharpening.glsl"
#endif
#include "/lib/color_correction.glsl"
#if COLORBLIND_MODE != 0
	#include "/lib/colorblindness.glsl"
#endif
#include "/lib/super_secret_settings/super_secret_settings.glsl"
#if HSV_POSTERIZE_ENABLED == 1
	#include "/lib/hsv_posterize.glsl"
#endif

void main() {
	
	#if SSS_DECONVERGE == 1
		vec3 color = sss_deconverge(ARG_IN);
	#else
		#if SSS_FLIP == 1
			#include "/import/viewSize.glsl"
			vec3 color = texelFetch(MAIN_BUFFER, ivec2(viewSize) - texelcoord, 0).rgb;
		#else
			vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
		#endif
	#endif
	
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== SHARPENING ========
	
	#if SHARPENING_ENABLED == 1
		doSharpening(color  ARGS_IN);
	#endif
	
	
	
	// ======== COLOR CORRECTION & TONE MAPPING ========
	
	doColorCorrection(color  ARGS_IN);
	#if COLORBLIND_MODE != 0
		applyColorblindnessCorrection(color  ARGS_IN);
	#endif
	
	
	
	// ======== SUPER SECRET SETTINGS ========
	
	doSuperSecretSettings(color  ARGS_IN);
	
	
	
	// ======== HSV POSTERIZE ========
	#if HSV_POSTERIZE_ENABLED == 1
		doHsvPosterize(color  ARGS_IN);
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
	
	
	
	// super secret settings
	#if SSS_INVERT == 1
		color = 1.0 - color;
	#endif
	
	
	//float dhDepth = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	//#include "/import/dhProjectionInverse.glsl"
	//#include "/import/gbufferModelViewInverse.glsl"
	//vec4 dhWorldpos = gbufferModelViewInverse * dhProjectionInverse * (vec4(texcoord, dhDepth, 1) * 2.0 - 1.0);
	//dhWorldpos.xyz /= dhWorldpos.w;
	//color = dhWorldpos.xyz / 200;
	
	
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
