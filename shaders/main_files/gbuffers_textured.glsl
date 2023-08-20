varying vec2 texcoord;
varying vec2 lmcoord;
//varying vec4 glcolor;

#undef SHADOWS_ENABLED

#include "../lib/lighting.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);// * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	
	// main lighting
	
	//vec3 brightnesses = getLightingBrightnesses(lmcoord);
	//color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	color.rgb *= max(max(lmcoord.x, lmcoord.y), 0.1);
	
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = color;
	#endif
}

#endif





#ifdef VSH

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	
	gl_Position = ftransform();
	if (gl_Position.z < -1.0) return; // simple but effective optimization
	
	
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	
	//glcolor = gl_Color;
	
	
	doPreLighting();
	
}

#endif
