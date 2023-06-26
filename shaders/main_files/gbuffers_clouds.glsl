varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 glnormal;



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	
	vec4 colorForBloom = color;
	colorForBloom.rgb *= sqrt(BLOOM_CLOUD_BRIGHTNESS);
	
	/* DRAWBUFFERS:0239 */
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
	gl_FragData[2] = vec4(1.0);
	gl_FragData[3] = vec4(glnormal, 1.0);
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
	glnormal = gl_Normal;
}

#endif
