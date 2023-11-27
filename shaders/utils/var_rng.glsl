#define import_viewWidth
#define import_viewHeight
#define import_frameCounter

#ifdef FIRST_PASS
	uint rng = 0u;
#else
	uint rng =
		uint(gl_FragCoord.x) +
		uint(gl_FragCoord.y) * uint(viewWidth) +
		uint(frameCounter  ) * uint(viewWidth) * uint(viewHeight);
#endif
