//---------------------------------//
//        Post-Processing 6        //
//---------------------------------//



varying vec2 texcoord;



#ifdef FSH

#ifdef SHARPENING_ENABLED
	#include "/lib/sharpening.glsl"
#endif
#include "/lib/color_correction.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== SHARPENING ========
	
	#ifdef SHARPENING_ENABLED
		doSharpening(color);
	#endif
	
	
	
	// ======== COLOR CORRECTION & TONE MAPPING ========
	
	doColorCorrection(color);
	
	
	
	// ======== VIGNETTE ========
	
	#ifdef VIGNETTE_ENABLED
		float vignetteSkyAmount = 1.0 - eyeBrightnessSmooth.y / 240.0;
		vignetteSkyAmount = vignetteSkyAmount * (VIGNETTE_AMOUNT_UNDERGROUND - VIGNETTE_AMOUNT_SURFACE) + VIGNETTE_AMOUNT_SURFACE;
		float vignetteAlpha = length(texcoord - 0.5) * VIGNETTE_SCALE * 0.7;
		#ifdef VIGNETTE_NOISE_ENABLED
			vignetteAlpha += noise(texcoord, 0) * 0.01;
		#endif
		vignetteAlpha *= vignetteSkyAmount;
		color *= 1.0 - vignetteAlpha;
	#endif
	
	//color = texture2D(MAIN_BUFFER_COPY, texcoord).rgb;
	
	
	
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
