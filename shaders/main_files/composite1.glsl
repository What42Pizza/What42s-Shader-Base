#ifdef FIRST_PASS
	varying vec2 texcoord;
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		flat_inout vec2 lightCoord;
		flat_inout float depthSunraysAmountMult;
	#endif
	#if VOL_SUNRAYS_ENABLED == 1
		flat_inout float volSunraysAmountMult;
	#endif
#endif



#ifdef FSH

#if BLOOM_ENABLED == 1
	#include "/lib/bloom.glsl"
#endif
#if DEPTH_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_depth.glsl"
#endif
#if VOL_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_vol.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	vec3 noisyAdditions = vec3(0.0);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	#include "/utils/var_rng.glsl"
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	
	
	
	// ======== BLOOM CALCULATIONS ========
	
	#if BLOOM_ENABLED == 1
		
		vec3 bloomAddition = getBloomAddition(rng, depth  ARGS_IN);
		noisyAdditions += bloomAddition;
		
		#if BLOOM_SHOW_ADDITION == 1
			debugOutput = bloomAddition;
		#endif
		#if BLOOM_SHOW_FILTERED_TEXTURE == 1
			debugOutput += texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
		#endif
		
	#endif
	
	
	
	// ======== SUNRAYS ========
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		
		#if DEPTH_SUNRAYS_ENABLED == 1
			#include "/import/isSun.glsl"
			vec3 depthSunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
			vec3 depthSunraysAddition = getDepthSunraysAmount(rng  ARGS_IN) * depthSunraysAmountMult * depthSunraysColor;
			noisyAdditions += depthSunraysAddition;
			#if SUNRAYS_SHOW_ADDITION == 1
				debugOutput.r += depthSunraysAddition;
			#endif
		#endif
		#if VOL_SUNRAYS_ENABLED == 1
			#include "/import/sunAngle.glsl"
			vec3 volSunraysColor = sunAngle < 0.5 ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
			float rawVolSunraysAmount = getVolSunraysAmount(depth, rng  ARGS_IN) * volSunraysAmountMult;
			float volSunraysAmount = 1.0 / (rawVolSunraysAmount + 1.0);
			color *= 1.0 + (1.0 - volSunraysAmount) * SUNRAYS_BRIGHTNESS_INCREASE * 2.0;
			color = mix(volSunraysColor * 1.25, color, volSunraysAmount);
			#if SUNRAYS_SHOW_ADDITION == 1
				debugOutput.g += 1.0 / (volSunraysAmount + 1.0);
			#endif
		#endif
		
	#endif
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:03 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(noisyAdditions, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		#include "/import/ambientSunPercent.glsl"
		#include "/import/ambientMoonPercent.glsl"
		#include "/import/ambientSunrisePercent.glsl"
		#include "/import/ambientSunsetPercent.glsl"
	#endif
	
	#if DEPTH_SUNRAYS_ENABLED == 1
	
		#include "/import/shadowLightPosition.glsl"
		#include "/import/gbufferProjection.glsl"
		vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
		lightPos /= lightPos.z;
		lightCoord = lightPos.xy * 0.5 + 0.5;
		
		#include "/import/isOtherLightSource.glsl"
		#include "/import/isSun.glsl"
		if (isSun) {
			depthSunraysAmountMult = 
				ambientSunPercent * SUNRAYS_AMOUNT_DAY +
				ambientSunrisePercent * SUNRAYS_AMOUNT_SUNRISE +
				ambientSunsetPercent * SUNRAYS_AMOUNT_SUNSET;
		} else {
			depthSunraysAmountMult = (ambientMoonPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.5) * SUNRAYS_AMOUNT_NIGHT;
		}
		#include "/import/rainStrength.glsl"
		depthSunraysAmountMult *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		depthSunraysAmountMult *= 0.3;
		
	#endif
	
	#if VOL_SUNRAYS_ENABLED == 1
		#include "/import/sunLightBrightness.glsl"
		#include "/import/moonLightBrightness.glsl"
		volSunraysAmountMult =
			ambientSunPercent * SUNRAYS_AMOUNT_DAY +
			sqrt(ambientSunrisePercent) * SUNRAYS_AMOUNT_SUNRISE +
			sqrt(ambientSunsetPercent) * SUNRAYS_AMOUNT_SUNSET +
			ambientMoonPercent * SUNRAYS_AMOUNT_NIGHT;
		volSunraysAmountMult *= sunLightBrightness + moonLightBrightness;
		#include "/import/rainStrength.glsl"
		volSunraysAmountMult *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
	#endif
	
}

#endif
