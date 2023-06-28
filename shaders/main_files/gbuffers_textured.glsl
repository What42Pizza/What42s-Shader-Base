varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 glnormal;

#include "../lib/lighting.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	#ifdef HANDHELD_LIGHT_ENABLED
		vec3 screenPos = vec3(gl_FragCoord.xy / viewSize, gl_FragCoord.z);
		vec3 viewPos = screenToView(screenPos);
		vec3 playerPos = viewToPlayer(viewPos);
	#endif
	
	
	
	// main lighting
	
	vec3 brightnesses = getBasicLightingBrightnesses(lmcoord);
	
	#ifdef HANDHELD_LIGHT_ENABLED
		float handheldLight = max(1.0 - length(playerPos) / HANDHELD_LIGHT_DISTANCE, 0.0);
		handheldLight = pow(handheldLight, LIGHT_DROPOFF);
		handheldLight *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
		brightnesses.x = max(brightnesses.x, handheldLight);
	#endif
	
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	
	/* DRAWBUFFERS:029 */
	gl_FragData[0] = color;
	gl_FragData[1] = color;
	gl_FragData[3] = vec4(glnormal, 1.0);
}

#endif





#ifdef VSH

#include "/lib/taa_jitter.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	glnormal = gl_Normal;
	
	doPreLighting();
	
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
}

#endif
