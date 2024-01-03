void doTaaJitter(inout vec2 pos  ARGS_OUT) {
	#include "/import/taaOffset.glsl"
	#if ISOMETRIC_RENDERING_ENABLED == 1
		pos += taaOffset * 0.7;
	#else
		pos += taaOffset * gl_Position.w;
	#endif
}
