varying vec2 texcoord;
varying vec4 glcolor;

#ifdef NORMALS_NEEDED
	varying vec3 normal;
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef NORMALS_NEEDED
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(normal, 1.0);
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
	
	glcolor = gl_Color;
	
	#ifdef NORMALS_NEEDED
		normal = gl_NormalMatrix * gl_Normal;
	#endif
	
}

#endif
