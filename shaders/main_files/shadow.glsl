varying vec2 texcoord;



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord);
	
	gl_FragData[0] = color;
}

#endif



#ifdef VSH

#include "/lib/waving.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#ifdef WAVING_ENABLED
		vec4 position = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
		applyWaving(position.xyz);
		gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	#else
		gl_Position = ftransform();
	#endif
	
	#ifdef EXCLUDE_FOLIAGE
		if (mc_Entity.x >= 2000.0 && mc_Entity.x <= 2999.0) {
			gl_Position = vec4(10.0);
		} else {
			gl_Position.xyz = distort(gl_Position.xyz);
		}
	#else
		gl_Position.xyz = distort(gl_Position.xyz);
	#endif
	
}

#endif
