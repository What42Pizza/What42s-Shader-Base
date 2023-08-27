varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;

#ifdef REFLECTIONS_ENABLED
	varying vec3 normal;
#endif

#undef SHADOWS_ENABLED

#include "../lib/lighting.glsl"

#if defined BLOOM_ENABLED && defined REFLECTIONS_ENABLED
	#define BLOOM_AND_REFLECTIONS
#endif





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	
	// main lighting
	
	vec3 brightnesses = getLightingBrightnesses(lmcoord);
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	
	// bloom value
	
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_HAND_BRIGHTNESS);
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_AND_REFLECTIONS
		/* DRAWBUFFERS:024 */
		gl_FragData[1] = colorForBloom;
		gl_FragData[2] = vec4(normal, 1.0);
	#elif defined BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#elif defined REFLECTIONS_ENABLED
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(normal, 1.0);
	#endif
}

#endif





#ifdef VSH

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	
	glcolor = gl_Color;
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	doPreLighting();
	
}

#endif
