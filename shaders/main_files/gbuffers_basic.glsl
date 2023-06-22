varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 lmcoord;



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = color;
	gl_FragData[1] = color;
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	#ifdef AA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}

#endif
