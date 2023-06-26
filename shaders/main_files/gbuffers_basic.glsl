varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 lmcoord;
varying vec3 glnormal;



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);
	
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
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	glnormal = gl_Normal;
}

#endif
