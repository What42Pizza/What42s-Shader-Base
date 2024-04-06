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

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#include "/import/mc_Entity.glsl"
	int blockData = int(mc_Entity.x);
	if (blockData >= 1000) {
		int shadowData = (blockData % 100 - blockData % 10) / 10;
		#if EXCLUDE_FOLIAGE == 1
			#define SHADOW_DATA_THRESHOLD 0
		#else
			#define SHADOW_DATA_THRESHOLD 1
		#endif
		if (shadowData > SHADOW_DATA_THRESHOLD) {
			gl_Position = vec4(10.0);
			return;
		}
	}
	
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
	
}

#endif
