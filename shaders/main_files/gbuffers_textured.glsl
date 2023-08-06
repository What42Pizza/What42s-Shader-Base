varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 glnormal;

#include "../lib/lighting.glsl"

#ifdef SHADOWS_ENABLED
	#undef SHADOWS_ENABLED
#endif





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	
	
	// main lighting
	
	vec3 brightnesses = getLightingBrightnesses(lmcoord);
	
	#ifdef HANDHELD_LIGHT_ENABLED
		float depth = toLinearDepth(gl_FragCoord.z);
		float handheldLight = max(1.0 - (depth * far) / HANDHELD_LIGHT_DISTANCE, 0.0);
		handheldLight = pow(handheldLight, LIGHT_DROPOFF);
		handheldLight *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
		brightnesses.x = max(brightnesses.x, handheldLight);
	#endif
	
	color.rgb *= getLightColor(brightnesses.x, brightnesses.y, brightnesses.z);
	
	
	
	/* DRAWBUFFERS:026 */
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
	
	gl_Position = ftransform();
	if (gl_Position.z < -1.0) return; // simple but effective optimization
	
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	
	glcolor = gl_Color;
	glnormal = gl_NormalMatrix * gl_Normal;
	
	doPreLighting();
	
}

#endif
