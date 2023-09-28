void doTaaJitter(inout vec2 pos  ARGS_OUT) {
	#include "/import/taaOffset.glsl"
	#ifdef ISOMETRIC_RENDERING_ENABLED
		pos += taaOffset * 0.5;
	#else
		pos += taaOffset * gl_Position.w;
	#endif
}
