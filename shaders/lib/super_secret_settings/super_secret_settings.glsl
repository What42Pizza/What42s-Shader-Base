#if SSS_POSTERIZE == 1
	#include "/lib/super_secret_settings/posterize.glsl"
#endif
#if SSS_NOTCH == 1
	#include "/lib/super_secret_settings/notch.glsl"
#endif
#if SSS_BUMPY == 1
	#include "/lib/super_secret_settings/bumpy.glsl"
#endif
#if SSS_SCANLINES == 1
	#include "/lib/super_secret_settings/scanlines.glsl"
#endif



void doSuperSecretSettings(inout vec3 color  ARGS_OUT) {
	
	#if SSS_POSTERIZE == 1
		sss_posterize(color  ARGS_IN);
	#endif
	#if SSS_NOTCH == 1
		sss_notch(color  ARGS_IN);
	#endif
	#if SSS_BUMPY == 1
		sss_bumpy(color  ARGS_IN);
	#endif
	#if SSS_SCANLINES == 1
		sss_scanlines(color  ARGS_IN);
	#endif
	
}
