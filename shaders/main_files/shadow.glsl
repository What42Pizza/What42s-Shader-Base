#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord);
	
	gl_FragData[0] = color;
}

#endif



#ifdef VSH

#ifdef WAVING_ENABLED
	#include "/lib/waving.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#ifdef EXCLUDE_FOLIAGE
		#include "/import/mc_Entity.glsl"
		if (mc_Entity.x >= 2000.0 && mc_Entity.x <= 2999.0) {
			gl_Position = vec4(10.0);
			return;
		}
	#endif
	
	#ifdef WAVING_ENABLED
		#include "/import/shadowModelViewInverse.glsl"
		#include "/import/shadowProjectionInverse.glsl"
		vec4 position = shadowModelViewInverse * shadowProjectionInverse * ftransform();
		applyWaving(position.xyz);
		#include "/import/shadowProjection.glsl"
		#include "/import/shadowModelView.glsl"
		gl_Position = shadowProjection * shadowModelView * position;
	#else
		gl_Position = ftransform();
	#endif
	
	gl_Position.xyz = distort(gl_Position.xyz  ARGS_IN);
	
}

#endif
