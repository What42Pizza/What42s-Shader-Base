#ifdef FIRST_PASS
	varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
#endif



#ifdef FSH

float fogify(float x, float w  ARGS_OUT) {
	return w / (x * x + w);
}

vec3 getSkyColor(ARG_OUT) {
	
	#include "/import/invViewSize.glsl"
	#include "/import/gbufferProjectionInverse.glsl"
	#include "/import/gbufferModelView.glsl"
	#include "/import/skyColor.glsl"
	#include "/import/fogColor.glsl"
	
	vec4 pos = vec4(gl_FragCoord.xy * invViewSize * 2.0 - 1.0, 1.0, 1.0);
	pos = gbufferProjectionInverse * pos;
	float upDot = dot(normalize(pos.xyz), gbufferModelView[1].xyz);
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25  ARGS_IN));
	
}

#ifdef DARKEN_SKY_UNDERGROUND
	float getHorizonMultiplier(ARG_OUT) {
		#ifdef OVERWORLD
			
			#include "/import/invViewSize.glsl"
			#include "/import/gbufferProjectionInverse.glsl"
			#include "/import/upPosition.glsl"
			#include "/import/horizonAltitudeAddend.glsl"
			#include "/import/eyeBrightnessSmooth.glsl"
			
			vec4 screenPos = vec4(gl_FragCoord.xy * invViewSize, gl_FragCoord.z, 1.0);
			vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
			float viewDot = dot(normalize(viewPos.xyz), normalize(upPosition));
			float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightnessSmooth.y / 240.0); // don't darken sky when there's sky light
			return clamp(viewDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
			
		#else
			return 1.0;
		#endif
	}
#endif



void main() {
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb;
	} else {
		color = getSkyColor();
	}
	
	#ifdef DARKEN_SKY_UNDERGROUND
		color *= getHorizonMultiplier();
	#endif
	
	#ifdef BLOOM_ENABLED
		vec3 colorForBloom = color;
		colorForBloom *= sqrt(BLOOM_SKY_BRIGHTNESS);
	#endif
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = vec4(colorForBloom, 1.0);
	#endif
}

#endif





#ifdef VSH

#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	
	gl_Position = ftransform();
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy);
	#endif
	
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
	
}

#endif
