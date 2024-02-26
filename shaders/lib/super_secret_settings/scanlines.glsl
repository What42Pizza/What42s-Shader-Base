#ifdef FIRST_PASS
	const float ScanlineBrightScale = 1.0;
	const float ScanlineOffset = 0.0;
#endif



void sss_scanlines(inout vec3 color  ARGS_OUT) {
	#include "/import/viewSize.glsl"
	float InnerSine = texcoord.y * viewSize.y * 0.25 / SSS_SCANLINES_SCALE;
	float ScanBrightMod = sin(InnerSine * PI + ScanlineOffset * viewSize.y * 0.25);
	float ScanBrightness = ScanBrightMod * ScanBrightMod * ScanlineBrightScale;
	ScanBrightness = mix(1.0, ScanBrightness, SSS_SCANLINES_AMOUNT);
	color *= ScanBrightness;
}
