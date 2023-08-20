varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
flat vec3 upVec;





#ifdef FSH

float getHorizonMultiplier() {
	#ifdef OVERWORLD
		vec4 screenPos = vec4(gl_FragCoord.xy * invViewSize, gl_FragCoord.z, 1.0);
		vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
		float viewDot = dot(normalize(viewPos.xyz), upVec);
		float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightnessSmooth.y / 240.0); // don't darken sky when there's sky light
		return clamp(viewDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
	#else
		return 1.0;
	#endif
}



void main() {
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb;
	} else {
		color = getSkyColor();
	}
	
	#ifdef DARKEN_SKY_UNDERGROUND
		color *= getHorizonMultiplier();
	#endif
	
	#ifdef BLOOM_ENABLED
		vec3 colorForBloom = color;
		colorForBloom *= sqrt(BLOOM_SKY_BRIGHTNESS);
	#endif
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = vec4(colorForBloom, 1.0);
	#endif
}

#endif





#ifdef VSH

void main() {
	
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
	upVec = normalize(gbufferModelView[1].xyz);
	
}

#endif
