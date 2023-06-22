varying vec2 texcoord;
varying vec4 glcolor;

// this file is to stop the colormap from being used and calculated



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = color;
	gl_FragData[1] = color;
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
}

#endif
