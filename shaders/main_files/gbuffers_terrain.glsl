varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 glcolor;

#include "../lib/lighting.glsl"
#include "/lib/fog.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	// bloom value
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
	#endif
	
	
	// main lighting
	color.rgb *= glcolor;
	vec3 brightnesses = getLightingBrightnesses(lmcoord);
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	#ifdef SHOW_SUNLIGHT
		debugOutput = vec3(brightnesses.y);
	#endif
	#ifdef SHOW_BRIGHTNESSES
		debugOutput = brightnesses;
	#endif
	
	#ifdef BLOOM_ENABLED
		#ifdef OVERWORLD
			float blockLight = brightnesses.x;
			const float nightBloomIncrease = 0.1;
			float skyLight = brightnesses.y * (1.0 + nightBloomIncrease - rawSunTotal * nightBloomIncrease);
			colorForBloom.rgb *= max(blockLight * blockLight * 1.05, skyLight * 0.75);
		#endif
	#endif
	
	
	// fog
	#ifdef FOG_ENABLED
		#ifdef BLOOM_ENABLED
			applyFog(color.rgb, colorForBloom.rgb);
		#else
			applyFog(color.rgb);
		#endif
	#endif
	
	
	// show dangerous light
	#ifdef SHOW_DANGEROUS_LIGHT
		if (lmcoord.x < 0.5) {
			color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), 0.6);
		}
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

#include "/lib/waving.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	vec4 worldPos = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
	
	
	#ifdef WAVING_ENABLED
		applyWaving(worldPos.xyz);
		gl_Position = gl_ProjectionMatrix * gbufferModelView * worldPos;
	#else
		gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	#endif
	
	
	if (gl_Position.z < -1.0) return; // simple but effective optimization
	
	
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	
	#ifdef FOG_ENABLED
		getFogData(worldPos.xyz);
	#endif
	
	
	glcolor = gl_Color.rgb;
	#ifdef USE_SIMPLE_LIGHT
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doPreLighting();
	
}

#endif
