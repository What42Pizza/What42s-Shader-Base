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
	vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb;
	vec3 noisyAdditions = vec3(0.0);
	
	#include "/utils/var_rng.glsl"
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	
	
	
	// ======== BLOOM CALCULATIONS ========
	
	#if BLOOM_ENABLED == 1
		vec3 bloomAddition = getBloomAddition(rng, depth  ARGS_IN);
		noisyAdditions += bloomAddition;
	#endif
	
	
	
	// ======== SUNRAYS ========
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		
		#if DEPTH_SUNRAYS_ENABLED == 1
			#include "/import/isSun.glsl"
			vec3 depthSunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
			vec3 depthSunraysAddition = getDepthSunraysAmount(rng  ARGS_IN) * depthSunraysAmountMult * depthSunraysColor;
			noisyAdditions += depthSunraysAddition;
		#endif
		#if VOL_SUNRAYS_ENABLED == 1
			#include "/import/sunLightBrightness.glsl"
			#include "/import/sunAngle.glsl"
			vec3 volSunraysColor = sunAngle < 0.5 ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
			float rawVolSunraysAmount = getVolSunraysAmount(depth, rng  ARGS_IN) * volSunraysAmountMult;
			float volSunraysAmount = 1.0 / (rawVolSunraysAmount + 1.0);
			color *= 1.0 + (1.0 - volSunraysAmount) * SUNRAYS_BRIGHTNESS_INCREASE * 2.0;
			float volSunraysAmountMax = 1.0 - 0.4 * (sunAngle < 0.5 ? SUNRAYS_AMOUNT_MAX_DAY : SUNRAYS_AMOUNT_MAX_NIGHT);
			color = mix(volSunraysColor * 1.25, color, max(volSunraysAmount, volSunraysAmountMax));
		#endif
		
	#endif
	
	
	
	/* DRAWBUFFERS:06 */
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
		
		#include "/import/isSun.glsl"
		if (isSun) {
			depthSunraysAmountMult = (ambientSunPercent + ambientSunrisePercent + ambientSunsetPercent) * SUNRAYS_AMOUNT_DAY;
			depthSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_MULT_SUNRISE + ambientSunsetPercent * SUNRAYS_MULT_SUNSET;
		} else {
			depthSunraysAmountMult = (ambientMoonPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.5) * SUNRAYS_AMOUNT_NIGHT;
		}
		#include "/import/rainStrength.glsl"
		depthSunraysAmountMult *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		//depthSunraysAmountMult *= 0.5;
		
	#endif
	
	#if VOL_SUNRAYS_ENABLED == 1
		#include "/import/sunLightBrightness.glsl"
		#include "/import/moonLightBrightness.glsl"
		#include "/import/sunAngle.glsl"
		volSunraysAmountMult = sunAngle < 0.5 ? SUNRAYS_AMOUNT_DAY : SUNRAYS_AMOUNT_NIGHT;
		volSunraysAmountMult *= sqrt(sunLightBrightness + moonLightBrightness);
		volSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_MULT_SUNRISE + ambientSunsetPercent * SUNRAYS_MULT_SUNSET;
		#include "/import/rainStrength.glsl"
		volSunraysAmountMult *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
	#endif
	
}

#endif
