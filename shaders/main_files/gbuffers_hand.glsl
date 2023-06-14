varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;

#include "../lib/lighting.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	
	vec3 screenPos = vec3(gl_FragCoord.xy / viewSize, gl_FragCoord.z);
	vec3 viewPos = screenToView(screenPos);
	vec3 playerPos = viewToPlayer(viewPos);
	
	
	
	// main lighting
	
	vec3 brightnesses = getBasicLightingBrightnesses(lmcoord);
	
	#ifdef HANDHELD_LIGHT_ENABLED
		float handheldLight = max(1.0 - length(playerPos) / HANDHELD_LIGHT_DISTANCE, 0.0);
		handheldLight = pow(handheldLight, LIGHT_DROPOFF);
		handheldLight *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
		brightnesses.x = max(brightnesses.x, handheldLight);
	#endif
	
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	
	// bloom value
	
	vec4 colorForBloom = color;
	colorForBloom.rgb *= sqrt(BLOOM_HAND_BRIGHTNESS);
	
	
	
	/* DRAWBUFFERS:027 */
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
	gl_FragData[2] = vec4(1.0);
}

#endif





#ifdef VSH

#include "/lib/taa_jitter.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	doPreLighting();
	
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
}

#endif
