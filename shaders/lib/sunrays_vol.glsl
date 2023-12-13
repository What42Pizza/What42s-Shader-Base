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



float getVolSunraysAmount(inout vec3 color, float depth, inout uint rng  ARGS_OUT) {
	const int SAMPLE_COUNT = int(SUNRAYS_QUALITY * SUNRAYS_QUALITY * 2);
	
	vec3 viewPosDir = screenToView(vec3(texcoord, depth)  ARGS_IN);
	#include "/import/far.glsl"
	viewPosDir = normalize(viewPosDir) * far / SAMPLE_COUNT;
	vec3 viewPos = vec3(0.0);
	
	const float noiseAmount = 0.6;
	float random = randomFloat(rng);
	viewPos += viewPosDir * (1.0 + random * noiseAmount / 2.0);
	
	float total = 0.0;
	for (int i = 0; i < SAMPLE_COUNT; i ++) {
		
		#include "/import/gbufferProjection.glsl"
		vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
		if (screenPos.z > depth) {
			break;
		}
		
		vec3 shadowPos = getShadowPos(viewPos  ARGS_IN);
		if (texture2D(shadowtex0, shadowPos.xy).r >= shadowPos.z) {
			total += 1.0;
		}
		
		viewPos += viewPosDir;
		
	}
	float output = total / SAMPLE_COUNT;
	#include "/import/eyeBrightnessSmooth.glsl"
	output = pow(output, mix(0.1, 0.7, eyeBrightnessSmooth.y / 240.0));
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
	float fogDistance = getFogDistance(playerPos  ARGS_IN);
	float fogAmount = getFogAmount(fogDistance  ARGS_IN);
	output *= 1.0 - 0.9 * fogAmount;
	
	return output * 0.7;
}
