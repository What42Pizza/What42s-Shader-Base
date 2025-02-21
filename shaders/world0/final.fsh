#version 330 compatibility

uniform sampler2D colortex7;
uniform sampler2D shadowtex0;

void main() {
	vec3 color = texelFetch(colortex7, ivec2(gl_FragCoord), 0).rgb;
	gl_FragData[0] = vec4(color, 1.0);
}
