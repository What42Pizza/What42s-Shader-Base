//-----------------------------//
//        Anti-Aliasing        //
//-----------------------------//



varying vec2 texcoord;



#ifdef FSH

#include "/lib/taa.glsl"

void main() {
	vec3 color = texelFetch(texture, texelcoord, 0).rgb;
	vec3 prev = vec3(0.0);
	
	doTAA(color, prev);
	
	/* DRAWBUFFERS:01 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(prev, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
