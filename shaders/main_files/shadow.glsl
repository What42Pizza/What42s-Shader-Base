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

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#if EXCLUDE_FOLIAGE == 1
		#include "/import/mc_Entity.glsl"
		if (mc_Entity.x >= 2000.0 && mc_Entity.x <= 2999.0) {
			gl_Position = vec4(10.0);
			return;
		}
	#endif
	
	#if WAVING_ENABLED == 1
		#include "/import/shadowModelViewInverse.glsl"
		#include "/import/shadowProjectionInverse.glsl"
		vec4 position = shadowModelViewInverse * shadowProjectionInverse * ftransform();
		applyWaving(position.xyz  ARGS_IN);
		#include "/import/shadowProjection.glsl"
		#include "/import/shadowModelView.glsl"
		gl_Position = shadowProjection * shadowModelView * position;
	#else
		gl_Position = ftransform();
	#endif
	
	gl_Position.xyz = distort(gl_Position.xyz);
	
	//#if TAA_ENABLED == 1
	//	doTaaJitter(gl_Position.xy  ARGS_IN);
	//#endif
	
}

#endif
