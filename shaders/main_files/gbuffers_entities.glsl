varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;

#include "../lib/lighting.glsl"
#include "/lib/fog.glsl"




#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	// hurt flash, creeper flash, etc
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	
	
	// main lighting
	vec3 brightnesses = getLightingBrightnesses(lmcoord);
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	// bloom
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_ENTITY_BRIGHTNESS);
	#endif
	
	
	// fog
	#ifdef ENTITY_FOG_ENABLED
		applyFog(color.rgb, colorForBloom.rgb);
	#endif
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#endif
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
	
	
	doPreLighting();
	
}

#endif
