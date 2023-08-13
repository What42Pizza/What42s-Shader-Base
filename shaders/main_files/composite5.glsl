//---------------------------------//
//        Post-Processing 6        //
//---------------------------------//



varying vec2 texcoord;



// custom tonemapper, probably trash according to color theory
vec3 simpleTonemap(vec3 color) {
	vec3 lowCurve = color * color;
	vec3 highCurve = 1.0 - 1.0 / (color * 10.0 + 1.0);
	return mix(lowCurve, highCurve, color);
}



#ifdef FSH

#include "/lib/sharpening.glsl"
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
		float vignetteAlpha = length(texcoord - 0.5) * VIGNETTE_SCALE;
		#ifdef VIGNETTE_NOISE_ENABLED
			vignetteAlpha += noise(texcoord, 0) * 0.01;
		#endif
		vignetteAlpha = pow(vignetteAlpha, VIGNETTE_CURVE) * vignetteSkyAmount;
		color *= 1.0 - vignetteAlpha;
	#endif
	
	
	
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
