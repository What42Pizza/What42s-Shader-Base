varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
varying vec3 upVec;





#ifdef FSH

float getHorizonMultiplier() {
	#ifdef OVERWORLD
		vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
		vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
		float viewDot = dot(normalize(viewPos.xyz), upVec);
		float altitudeAddend = atan(75.0 / (eyeAltitude - 58.0));
		altitudeAddend += (altitudeAddend > 0.0) ? -HALF_PI : HALF_PI; // fix output of atan
		altitudeAddend -= (atan(eyeAltitude - 64.0) + HALF_PI) / 20.0; // shrink horizon faster when you're high off the ground
		altitudeAddend = min(altitudeAddend, 1.0 - 2.0 * eyeBrightnessSmooth.y / 240.0); // don't darken sky when there's sky light
		return clamp(viewDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
	#else
		return 1.0;
	#endif
}



void main() {
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb;
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = calcSkyColor(normalize(pos.xyz));
	}
	
	#ifdef DARKEN_SKY_UNDERGROUND
		color *= getHorizonMultiplier();
	#endif
	
	vec3 colorForBloom = color;
	colorForBloom *= sqrt(BLOOM_SKY_BRIGHTNESS);
	
	/* DRAWBUFFERS:0245 */
	// write to the buffers: main texture, bloom, sky color, and bloom sky color
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(colorForBloom, 1.0);
	gl_FragData[2] = vec4(color, 1.0);
	gl_FragData[3] = vec4(colorForBloom, 1.0);
}

#endif





#ifdef VSH

void main() {
	gl_Position = ftransform();
	#ifdef AA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
	upVec = normalize(gbufferModelView[1].xyz);
}

#endif
