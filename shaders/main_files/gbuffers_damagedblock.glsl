varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 glnormal;

// this file is to stop block breaking from having shadows



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	/* DRAWBUFFERS:029 */
	gl_FragData[0] = color;
	gl_FragData[1] = color;
	gl_FragData[2] = vec4(glnormal, 1.0);
}

#endif



#ifdef VSH

#include "/lib/taa_jitter.glsl"

void main() {
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	glnormal = gl_NormalMatrix * gl_Normal;
}

#endif
