#ifdef FSH

void main() {
	gl_FragData[0] = vec4(1.0);
}

#endif



#ifdef VSH

#include "/lib/waving.glsl"

void main() {
	
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
