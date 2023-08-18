#include "/lib/aces.glsl"



void doColorCorrection(inout vec3 color) {
	
	// brightness
	color *= (BRIGHTNESS - 1.0) / 5.0 + 1.0;
	
	// tonemapper
	color = max(color, 0.0);
	#if TONEMAPPER == 0
		color = min(color, vec3(1.0));
	#elif TONEMAPPER == 1
		color = smoothMin(color, vec3(1.0), 0.01);
	#elif TONEMAPPER == 2
		color = simpleTonemap(color);
	#elif TONEMAPPER == 3
		color = acesFitted(color);
	#endif
	
	color = pow(color, vec3(1.0/2.2));
	
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
	
}
