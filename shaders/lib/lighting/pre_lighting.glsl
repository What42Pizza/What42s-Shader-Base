#ifdef VSH

void doPreLighting(ARG_OUT) {
	
	#if HANDHELD_LIGHT_ENABLED == 1
		float depth = estimateDepthVSH();
		if (depth <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - depth / HANDHELD_LIGHT_DISTANCE, 0.0);
			#include "/import/heldBlockLightValue.glsl"
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			lmcoord.x = max(lmcoord.x, handLightBrightness);
		}
	#endif
	
	#ifdef NETHER
		lmcoord.y = NETHER_AMBIENT_BRIGHTNESS * 1.3;
	#elif defined END
		lmcoord.y = END_AMBIENT_BRIGHTNESS;
	#endif
	
	vec3 shadingNormals = vec3(abs(gl_Normal.x), gl_Normal.y, abs(gl_Normal.z));
	#ifdef SHADER_DH_TERRAIN
		float sideShading = dot(shadingNormals, vec3(-1.2, -0.1, -1));
	#else
		float sideShading = dot(shadingNormals, vec3(-0.8, 0.3, -0.6));
	#endif
	sideShading *= SIDE_SHADING;
	lmcoord *= 1.0 + sideShading;
	
}

#endif
