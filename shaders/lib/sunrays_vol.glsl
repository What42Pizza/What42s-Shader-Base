#include "/utils/screen_to_view.glsl"
#include "/utils/depth.glsl"
#include "/lib/fog/getFogDistance.glsl"
#include "/lib/fog/getFogAmount.glsl"



vec3 getShadowPos(vec3 viewPos  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec4 playerPos = gbufferModelViewInverse * startMat(viewPos);
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; // convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor); // apply shadow distortion
	shadowPos = shadowPos * 0.5 + 0.5;
	return shadowPos;
}



float getVolSunraysAmount(float depth, inout uint rng  ARGS_OUT) {
	const int SAMPLE_COUNT = int(SUNRAYS_QUALITY * SUNRAYS_QUALITY);
	
	vec3 viewPosStep = screenToView(vec3(texcoord, depth)  ARGS_IN);
	#include "/import/far.glsl"
	float blockDepth = min(length(viewPosStep), far);
	viewPosStep = normalize(viewPosStep) * (blockDepth / SAMPLE_COUNT);
	vec3 viewPos = vec3(0.0);
	
	float random = randomFloat(rng);
	viewPos += viewPosStep * (1.0 + random * 0.5);
	
	float total = 0.0;
	bool prevInShadowcaster = false;
	for (int i = 0; i < SAMPLE_COUNT; i ++) {
		
		vec3 shadowPos = getShadowPos(viewPos  ARGS_IN);
		if (texture2D(shadowtex0, shadowPos.xy).r >= shadowPos.z) {
			total += SUNRAYS_INC_AMOUNT;
			if (!prevInShadowcaster) total += SUNRAYS_ENTER_AMOUNT;
			prevInShadowcaster = true;
		} else {
			prevInShadowcaster = false;
		}
		
		viewPos += viewPosStep;
		
	}
	float sunraysAmount = total / SAMPLE_COUNT * blockDepth;
	
	#include "/import/eyeBrightnessSmooth.glsl"
	float skyBrightness = eyeBrightnessSmooth.y / 240.0;
	sunraysAmount += (sunraysAmount > 0.0 ? 1.0 : 0.0) * mix(SUNRAYS_MIN_UNDERGROUND, SUNRAYS_MIN_SURFACE, skyBrightness);
	sunraysAmount *= 0.01;
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
	if (blockDepth == far) {
		playerPos *= 10.0;
	}
	float fogDistance = getFogDistance(playerPos  ARGS_IN);
	float fogAmount = getFogAmount(fogDistance, playerPos.y  ARGS_IN);
	sunraysAmount *= 1.0 - 0.7 * fogAmount;
	
	return sunraysAmount;
}
