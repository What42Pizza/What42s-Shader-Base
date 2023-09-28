#define import_viewWidth
#define import_viewHeight
#define import_frameCounter

#ifdef FIRST_PASS
	int rng = 0;
#else
	int rng =
		int(gl_FragCoord.x) +
		int(gl_FragCoord.y) * int(viewWidth) +
		int(frameCounter  ) * int(viewWidth) * int(viewHeight);
#endif
