varying vec2 texcoord;
varying vec4 glcolor;



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	
	vec4 colorForBloom = color;
	colorForBloom.rgb *= sqrt(BLOOM_CLOUD_BRIGHTNESS);
	
	/* DRAWBUFFERS:023 */
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
	gl_FragData[2] = vec4(1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	#ifdef AA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
}

#endif
