void doTaaJitter(inout vec2 pos) {
	#ifdef ISOMETRIC_RENDERING_ENABLED
		pos += taaOffset * 0.5;
	#else
		pos += taaOffset * gl_Position.w;
	#endif
}
