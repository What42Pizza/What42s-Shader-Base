void doTaaJitter(inout vec2 pos  ARGS_OUT) {
	#include "/import/taaOffset.glsl"
	vec2 offset = taaOffset;
	#if ISOMETRIC_RENDERING_ENABLED == 1
		pos += offset * 0.7;
	#else
		pos += offset * gl_Position.w;
	#endif
}
