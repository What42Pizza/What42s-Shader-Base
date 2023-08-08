varying vec2 texcoord;
varying vec2 lmcoord;
flat vec3 glnormal;

#include "../lib/lighting.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	
	// main lighting
	
	vec3 brightnesses = getLightingBrightnesses(lmcoord);
	
	#ifdef HANDHELD_LIGHT_ENABLED
		float depth = toLinearDepth(gl_FragCoord.z);
		float handheldLight = max(1.0 - (depth * far) / HANDHELD_LIGHT_DISTANCE, 0.0);
		if (handheldLight > 0.0) {
			handheldLight = pow(handheldLight, LIGHT_DROPOFF);
			handheldLight *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			brightnesses.x = max(brightnesses.x, handheldLight);
		}
	#endif
	
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	
	// bloom value
	
	vec4 colorForBloom = color;
	colorForBloom.rgb *= sqrt(BLOOM_HAND_BRIGHTNESS);
	
	
	
	/* DRAWBUFFERS:024 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
	gl_FragData[2] = vec4(glnormal, 1.0);
}

#endif





#ifdef VSH

#include "/lib/taa_jitter.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	
	glnormal = gl_NormalMatrix * gl_Normal;
	
	doPreLighting();
	
}

#endif
