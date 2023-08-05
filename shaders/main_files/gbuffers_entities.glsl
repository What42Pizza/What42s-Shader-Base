varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 glnormal;

#include "../lib/lighting.glsl"
#include "/lib/fog.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	
	// hurt flash, creeper flash, etc
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	
	
	// main lighting
	#ifdef SHADOWS_ENABLED
		vec3 brightnesses = getLightingBrightnesses(lmcoord);
	#else
		vec3 brightnesses = getBasicLightingBrightnesses(lmcoord);
	#endif
	
	#ifdef HANDHELD_LIGHT_ENABLED
		float depth = toLinearDepth(gl_FragCoord.z);
		float handheldLight = max(1.0 - (depth * far) / HANDHELD_LIGHT_DISTANCE, 0.0);
		handheldLight = pow(handheldLight, LIGHT_DROPOFF);
		handheldLight *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
		brightnesses.x = max(brightnesses.x, handheldLight);
	#endif
	
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	// bloom
	vec4 colorForBloom = color;
	colorForBloom.rgb *= sqrt(BLOOM_ENTITY_BRIGHTNESS);
	
	
	// fog
	#ifdef ENTITY_FOG_ENABLED
		applyFog(color.rgb, colorForBloom.rgb);
	#endif
	
	
	/* DRAWBUFFERS:024 */
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
	
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	if (gl_Position.z < -5.0) return; // simple but effective optimization
	
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	
	#ifdef ENTITY_FOG_ENABLED
		vec4 position = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
		getFogData(position.xyz);
	#endif
	
	glcolor = gl_Color;
	glnormal = gl_NormalMatrix * gl_Normal;
	
	doPreLighting();
	
}

#endif
