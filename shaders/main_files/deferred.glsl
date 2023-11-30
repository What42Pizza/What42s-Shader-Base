//-----------------------------------//
//        BEFORE TRANSPARENTS        //
//-----------------------------------//



#ifdef FIRST_PASS
	varying vec2 texcoord;
#endif





#ifdef FSH

#include "/lib/basic_lighting.glsl"
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"
#include "/lib/shadows.glsl"

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	if (linearDepth < 0.99) {
		vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		float skyBrightness = getSkyBrightness(viewPos  ARGS_IN);
		#include "/import/rainStrength.glsl"
		skyBrightness *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT) * 0.5;
		vec3 skyColor = getSkyLight(getSkylightPercents(ARG_IN));
		#include "/import/invFar.glsl"
		#if MC_VERSION >= 11300
			const float FOG_END = 0.9;
		#else
			const float FOG_END = 0.85;
		#endif
		color *= 1.0 + skyColor * skyBrightness * (1.0 - 0.6 * getColorLum(color.rgb)) * smoothstep(FOG_END, FOG_END - 0.1, length(viewPos) * invFar);
	}
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
