#ifdef FIRST_PASS
	varying vec2 texcoord;
	flat_inout vec3 skyLight;
#endif





#ifdef FSH



#include "/lib/lighting/shadows.glsl"

#if SHADOWS_ENABLED == 1
float getSkyBrightness(vec3 viewPos  ARGS_OUT) {
#else
float getSkyBrightness(ARG_OUT) {
#endif
	
	// get normal dot sun/moon pos
	#ifdef OVERWORLD
		vec3 normal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
		#include "/import/shadowLightPosition.glsl"
		float lightDot = dot(normalize(shadowLightPosition), normal);
	#else
		float lightDot = 1.0;
	#endif
	
	// sample shadow
	#if SHADOWS_ENABLED == 1
		float skyBrightness = sampleShadow(viewPos, lightDot  ARGS_IN);
	#else
		float skyBrightness = 0.95;
	#endif
	
	// misc processing
	skyBrightness *= max(lightDot, 0.0);
	#include "/import/rainStrength.glsl"
	skyBrightness *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT) * 0.5;
	
	return skyBrightness;
}



#if SSAO_ENABLED == 1
	#include "/lib/ssao.glsl"
#endif
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogDistance.glsl"
	#include "/lib/fog/getFogAmount.glsl"
	#include "/lib/fog/applyFog.glsl"
#endif
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"



void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	
	
	if (linearDepth < 0.99) {
		
		
		#if FOG_ENABLED == 1 || SHADOWS_ENABLED == 1
			vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		#endif
		
		
		#if FOG_ENABLED == 1
			#include "/import/gbufferModelViewInverse.glsl"
			vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
			float fogDistance = getFogDistance(playerPos  ARGS_IN);
			float fogAmount = getFogAmount(fogDistance, playerPos.y  ARGS_IN);
		#endif
		
		
		#if SHADOWS_ENABLED == 1
			float skyBrightness = getSkyBrightness(viewPos  ARGS_IN);
		#else
			float skyBrightness = getSkyBrightness(ARG_IN);
		#endif
		color *= 1.0 + skyLight * skyBrightness * (1.0 - 0.6 * getColorLum(color));
		
		
		#if SSAO_ENABLED == 1
			float aoFactor = getAoFactor(ARG_IN);
			//#if SSAO_APPLICATION_TYPE == 1
				color *= 1.0 - aoFactor * AO_AMOUNT;
			//#elif SSAO_APPLICATION_TYPE == 2
			//	color = pow(color, vec3(1.0 + aoFactor * 1.5));
			//#endif
			#if SSAO_SHOW_AMOUNT == 1
				debugOutput = vec3(1.0 - aoFactor);
			#endif
		#endif
		
		
		#if FOG_ENABLED == 1
			applyFog(color, fogAmount  ARGS_IN);
		#endif
		
		
	}
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

#include "/utils/getSkyLight.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	skyLight = getSkyLight(ARG_IN);
}

#endif
