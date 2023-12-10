//-----------------------------------//
//        BEFORE TRANSPARENTS        //
//-----------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif





#ifdef FSH

#include "/lib/lighting/basic_lighting.glsl"
#include "/lib/lighting/shadows.glsl"
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogDistance.glsl"
	#include "/lib/fog/getFogAmount.glsl"
	#include "/lib/fog/applyFog.glsl"
#endif
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"
#include "/utils/getSkyLight.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 colorForBloom = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
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
			float fogAmount = getFogAmount(fogDistance  ARGS_IN);
		#endif
		
		
		#if SHADOWS_ENABLED == 1
			float skyBrightness = getSkyBrightness(viewPos  ARGS_IN);
		#else
			float skyBrightness = getSkyBrightness(ARG_IN);
		#endif
		#include "/import/rainStrength.glsl"
		skyBrightness *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT) * 0.5;
		vec3 skyColor = getSkyLight(ARG_IN);
		color *= 1.0 + skyColor * skyBrightness * (1.0 - 0.6 * getColorLum(color));
		
		
		#if FOG_ENABLED == 1
			#if BLOOM_ENABLED == 1
				applyFog(color, colorForBloom, fogAmount  ARGS_IN);
			#else
				applyFog(color, fogAmount  ARGS_IN);
			#endif
		#endif
		
		
	}
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
	#if BLOOM_ENABLED == 1
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = vec4(colorForBloom, 1.0);
	#endif
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
