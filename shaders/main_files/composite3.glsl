//---------------------------------//
//        Post-Processing 3        //
//---------------------------------//



const bool colortex0MipmapEnabled = true;



varying vec2 texcoord;



#ifdef FSH

#include "/lib/aces.glsl"

void main() {
	vec3 color = texelFetch(texture, ivec2(gl_FragCoord.xy), 0).rgb;
	
	
	
	// ======== SHARPENING ========
	
	#ifdef SHARPENING_ENABLED
		
		#if SHARPENING_DETECT_SIZE == 3
			
			vec3 colorTotal = color;
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1, -1), 0).rgb  /* weight: */  / length(vec2(-1, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0, -1), 0).rgb  /* weight: */  / length(vec2( 0, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1, -1), 0).rgb  /* weight: */  / length(vec2( 1, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  0), 0).rgb  /* weight: */  / length(vec2(-1,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  0), 0).rgb  /* weight: */  / length(vec2( 1,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  1), 0).rgb  /* weight: */  / length(vec2(-1,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0,  1), 0).rgb  /* weight: */  / length(vec2( 0,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  1), 0).rgb  /* weight: */  / length(vec2( 1,  1));
			vec3 blur = colorTotal / 7.82842712474619; // value is pre-calculated total of weights + 1
			
		#elif SHARPENING_DETECT_SIZE == 5
			
			vec3 colorTotal = color;
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1, -2), 0).rgb  /* weight: */  / length(vec2(-1, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0, -2), 0).rgb  /* weight: */  / length(vec2( 0, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1, -2), 0).rgb  /* weight: */  / length(vec2( 1, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2, -1), 0).rgb  /* weight: */  / length(vec2(-2, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1, -1), 0).rgb  /* weight: */  / length(vec2(-1, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0, -1), 0).rgb  /* weight: */  / length(vec2( 0, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1, -1), 0).rgb  /* weight: */  / length(vec2( 1, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2, -1), 0).rgb  /* weight: */  / length(vec2( 2, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2,  0), 0).rgb  /* weight: */  / length(vec2(-2,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  0), 0).rgb  /* weight: */  / length(vec2(-1,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  0), 0).rgb  /* weight: */  / length(vec2( 1,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2,  0), 0).rgb  /* weight: */  / length(vec2( 2,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2,  1), 0).rgb  /* weight: */  / length(vec2(-2,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  1), 0).rgb  /* weight: */  / length(vec2(-1,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0,  1), 0).rgb  /* weight: */  / length(vec2( 0,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  1), 0).rgb  /* weight: */  / length(vec2( 1,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2,  1), 0).rgb  /* weight: */  / length(vec2( 2,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  2), 0).rgb  /* weight: */  / length(vec2(-1,  2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0,  2), 0).rgb  /* weight: */  / length(vec2( 0,  2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  2), 0).rgb  /* weight: */  / length(vec2( 1,  2));
			vec3 blur = colorTotal / 13.406135888745856; // value is pre-calculated total of weights + 1
			
		#elif SHARPENING_DETECT_SIZE == 7
			
			vec3 colorTotal = color;
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1, -3), 0).rgb  /* weight: */  / length(vec2(-1, -3));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0, -3), 0).rgb  /* weight: */  / length(vec2( 0, -3));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1, -3), 0).rgb  /* weight: */  / length(vec2( 1, -3));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2, -2), 0).rgb  /* weight: */  / length(vec2(-2, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1, -2), 0).rgb  /* weight: */  / length(vec2(-1, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0, -2), 0).rgb  /* weight: */  / length(vec2( 0, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1, -2), 0).rgb  /* weight: */  / length(vec2( 1, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2, -2), 0).rgb  /* weight: */  / length(vec2( 2, -2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-3, -1), 0).rgb  /* weight: */  / length(vec2(-3, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2, -1), 0).rgb  /* weight: */  / length(vec2(-2, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1, -1), 0).rgb  /* weight: */  / length(vec2(-1, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0, -1), 0).rgb  /* weight: */  / length(vec2( 0, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1, -1), 0).rgb  /* weight: */  / length(vec2( 1, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2, -1), 0).rgb  /* weight: */  / length(vec2( 2, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 3, -1), 0).rgb  /* weight: */  / length(vec2( 3, -1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-3,  0), 0).rgb  /* weight: */  / length(vec2(-3,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2,  0), 0).rgb  /* weight: */  / length(vec2(-2,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  0), 0).rgb  /* weight: */  / length(vec2(-1,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  0), 0).rgb  /* weight: */  / length(vec2( 1,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2,  0), 0).rgb  /* weight: */  / length(vec2( 2,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 3,  0), 0).rgb  /* weight: */  / length(vec2( 3,  0));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-3,  1), 0).rgb  /* weight: */  / length(vec2(-3,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2,  1), 0).rgb  /* weight: */  / length(vec2(-2,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  1), 0).rgb  /* weight: */  / length(vec2(-1,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0,  1), 0).rgb  /* weight: */  / length(vec2( 0,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  1), 0).rgb  /* weight: */  / length(vec2( 1,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2,  1), 0).rgb  /* weight: */  / length(vec2( 2,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 3,  1), 0).rgb  /* weight: */  / length(vec2( 3,  1));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-2,  2), 0).rgb  /* weight: */  / length(vec2(-2,  2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  2), 0).rgb  /* weight: */  / length(vec2(-1,  2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0,  2), 0).rgb  /* weight: */  / length(vec2( 0,  2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  2), 0).rgb  /* weight: */  / length(vec2( 1,  2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 2,  2), 0).rgb  /* weight: */  / length(vec2( 2,  2));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2(-1,  3), 0).rgb  /* weight: */  / length(vec2(-1,  3));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 0,  3), 0).rgb  /* weight: */  / length(vec2( 0,  3));
			colorTotal += texelFetch(texture, ivec2(gl_FragCoord.xy) + ivec2( 1,  3), 0).rgb  /* weight: */  / length(vec2( 1,  3));
			vec3 blur = colorTotal / 18.683504912586983; // value is pre-calculated total of weights + 1
			
		#endif
		
		float cameraVel = length(cameraPosition - previousCameraPosition);
		cameraVel = min(cameraVel, 0.1);
		color = mix(color, blur, (SHARPEN_AMOUNT / 5.0 + cameraVel * SHARPEN_VEL_ADDITION * 2.0) * -1.0);
		//color = blur;
		
	#endif
	
	
	
	// ======== COLOR CORRECTION & TONE MAPPING ========
	
	#ifdef ACES_ENABLED
		color = acesFitted(color);
	#else
		color = smoothClamp(color, vec3(0.0), vec3(1.0), 0.001);
	#endif
	
	color = pow(color, vec3(1.0/2.2));
	
	// brightness
	color *= (BRIGHTNESS - 1.0) / 5.0 + 1.0;
	
	// contrast
	color = mix(CONTRAST_DETECT_COLOR, color, CONTRAST / 5.0 + 1.0);
	
	// saturation & vibrance
	float colorLum = getColorLum(color);
	vec3 lumDiff = color - colorLum;
	float saturationAmount = (SATURATION + SATURATION_LIGHT * pow(colorLum, 3.0) + SATURATION_DARK * pow(1 - colorLum, 3.0) * 2.0) / 2.0;
	float vibranceAmount = maxAbs(lumDiff);
	vibranceAmount = pow(vibranceAmount, 0.5);
	vibranceAmount *= pow(1 - vibranceAmount * vibranceAmount, 10.0) * VIBRANCE * 3.0;
	color += lumDiff * (saturationAmount + vibranceAmount);
	
	color = pow(color, vec3(2.2) * (1.0 - GAMMA / 2.0));
	
	
	
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
	gl_FragData[0] = vec4(color, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
