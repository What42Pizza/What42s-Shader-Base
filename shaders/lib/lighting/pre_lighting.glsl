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
	
	vec3 shadingNormals = vec3(abs(gl_Normal.x), gl_Normal.y, abs(gl_Normal.z));
	float sideShading = dot(shadingNormals, vec3(-0.3, 0.5, 0.3));
	sideShading = sideShading * SIDE_SHADING * 0.5 + 1.0;
	lmcoord *= sideShading;
	
}

#endif
