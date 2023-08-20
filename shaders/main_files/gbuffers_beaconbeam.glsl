varying vec2 texcoord;
flat float glcolor_alpha;

// this file is included to remove the vertex depth optimization





#ifdef FSH

void main() {
	vec4 color = vec4(texture2D(MAIN_BUFFER, texcoord).rgb, glcolor_alpha);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	color.rgb *= 1.3;
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = color;
	#endif
}

#endif





#ifdef VSH

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	glcolor_alpha = gl_Color.a;
	
}

#endif
