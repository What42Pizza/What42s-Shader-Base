//---------------------------------//
//        Post-Processing 2        //
//---------------------------------//



varying vec2 texcoord;
varying vec2 lightCoord;



#ifdef FSH

#include "/lib/bloom.glsl"
#include "/lib/sunrays.glsl"

void main() {
	vec3 color = texelFetch(texture, ivec2(gl_FragCoord.xy), 0).rgb;
	
	vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
	vec3 viewPos = screenToView(screenPos);
	vec3 playerPos = viewToPlayer(viewPos);
	
	
	
	// ======== BLOOM ========
	
	#ifdef BLOOM_ENABLED
		float sizeMult = 1.0 / sqrt(length(playerPos));
		
		vec3 bloomAddition = vec3(0.0);
		for (int i = 0; i < BLOOM_COMPUTE_COUNT; i++) {
			bloomAddition += getBloomAddition(sizeMult, i);
		}
		bloomAddition = bloomAddition / BLOOM_COMPUTE_COUNT * BLOOM_AMOUNT * 0.3;
		#ifdef NETHER
			bloomAddition *= BLOOM_NETHER_MULT;
		#endif
		color += bloomAddition;
		
		#ifdef SHOW_BLOOM_ADDITION
			color = bloomAddition;
		#endif
		
		#ifdef SHOW_BLOOM_FILTERED_TEXTURE
			color = texture2D(colortex2, texcoord).rgb;
		#endif
	#endif
	
	
	
	// ======== SUNRAYS ========
	
	#ifdef SUNRAYS_ENABLED
		
		vec4 sunraysData = getCachedSunraysData();
		vec3 sunraysColor = sunraysData.xyz;
		float sunraysAmount = sunraysData.w;
		
		float sunraysAddition = 0.0;
		for (int i = 0; i < SUNRAYS_COMPUTE_COUNT; i ++) {
			sunraysAddition += getSunraysAddition(i);
		};
		sunraysAddition /= SUNRAYS_COMPUTE_COUNT;
		sunraysAddition *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
		
		if (shadowLightPosition.b > 0.0) {
			vec4 sunlightPercents = getCachedSkylightPercents();
			sunraysAddition *= max(sunlightPercents.z, sunlightPercents.w) * 0.8;
		}
		color += sunraysAddition * sunraysAmount * 0.3 * sunraysColor;
		
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
	lightPos /= lightPos.z;
	lightCoord = lightPos.xy * 0.5 + 0.5;
	
}

#endif
