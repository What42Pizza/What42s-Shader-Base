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
	
	#ifdef SHADOWS_ENABLED
		vec3 brightnesses = getLightingBrightnesses(lmcoord);
	#else
		vec3 brightnesses = getBasicLightingBrightnesses(lmcoord);
	#endif
	
	#ifdef HANDHELD_LIGHT_ENABLED
		float handheldLight = max(1.0 - length(playerPos) / HANDHELD_LIGHT_DISTANCE, 0.0);
		handheldLight = pow(handheldLight, LIGHT_DROPOFF);
		handheldLight *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
		brightnesses.x = max(brightnesses.x, handheldLight);
	#endif
	
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	
	// bloom value
	
	vec4 colorForBloom = color;
	#ifdef OVERWORLD
		float blockLight = brightnesses.x;
		float skyLight = brightnesses.y;
		colorForBloom.rgb *= max(blockLight * blockLight * 1.05, skyLight * 0.75);
	#endif
	
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
}

#endif





#ifdef VSH

#include "/lib/waving.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	doPreLighting();
	
	#ifdef WAVING_ENABLED
		vec4 position = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
		applyWaving(position.xyz);
		gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	#else
		gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	#endif
	
	#ifdef AA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
}

#endif
