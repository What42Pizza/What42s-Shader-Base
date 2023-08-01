varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 glnormal;

#include "../lib/lighting.glsl"
#include "/lib/fog.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	#ifdef HANDHELD_LIGHT_ENABLED
		vec3 screenPos = vec3(gl_FragCoord.xy / viewSize, gl_FragCoord.z);
		vec3 viewPos = screenToView(screenPos);
		vec3 playerPos = viewToPlayer(viewPos);
	#endif
	
	
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
	
	
	// fog
	#ifdef FOG_ENABLED
		applyFog(color.rgb, colorForBloom.rgb);
	#endif
	
	
	// show dangerous light
	#ifdef SHOW_DANGEROUS_LIGHT
		if (lmcoord.x < 0.5) {
			color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), 0.6);
		}
	#endif
	
	
	/* DRAWBUFFERS:026 */
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
	gl_FragData[2] = vec4(glnormal, 1.0);
}

#endif





#ifdef VSH

#include "/lib/waving.glsl"
#include "/lib/taa_jitter.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	vec4 position = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
	
	#ifdef WAVING_ENABLED
		applyWaving(position.xyz);
		gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	#else
		gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	#endif
	
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	
	#ifdef FOG_ENABLED
		getFogData(position.xyz);
	#endif
	
	glcolor = gl_Color;
	glnormal = gl_NormalMatrix * gl_Normal;
	
	doPreLighting();
	
}

#endif
