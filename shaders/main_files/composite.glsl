//--------------------------------//
//        Value Processing        //
//--------------------------------//



varying vec2 texcoord;



#ifdef FSH



void main() {
	
	float depth;
	if (texelFetch(HAND_MASK_BUFFER, texelcoord, 0).r > 0.5) {
		depth = fromLinearDepth(1);
	} else {
		depth = texelFetch(depthtex0, texelcoord, 0).r;
	}
	vec3 screenPos = vec3(texcoord, depth);
	vec3 viewPos = screenToView(screenPos);
	
	/* RENDERTARGETS: 10 */
	gl_FragData[0] = vec4(viewPos, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
