//--------------------------------//
//        Value Processing        //
//--------------------------------//



varying vec2 texcoord;



#ifdef FSH



void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	
	vec3 normal;// = calculateNormal();
	//if (texcoord.x < 0.5) {
		normal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
	//}
	
	/* DRAWBUFFERS: 04 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(normal, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
