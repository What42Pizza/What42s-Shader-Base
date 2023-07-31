varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 glnormal;

#ifdef FOG_ENABLED
	varying float fogAmount;
	varying vec3 fogSkyColor;
	varying vec3 fogBloomSkyColor;
#endif




#ifdef FSH

#include "/lib/fog.glsl"

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	
	// bloom
	
	vec4 colorForBloom = color;
	colorForBloom.rgb *= sqrt(BLOOM_CLOUD_BRIGHTNESS);
	
	
	// fog
	
	#ifdef FOG_ENABLED
		applyFog(color.rgb, colorForBloom.rgb, fogAmount, fogSkyColor, fogBloomSkyColor);
	#endif
	
	
	/* DRAWBUFFERS:029 */
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
	gl_FragData[2] = vec4(glnormal, 1.0);
}

#endif



#ifdef VSH

#include "/lib/taa_jitter.glsl"
#include "/lib/fog.glsl"

void main() {
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	glnormal = gl_NormalMatrix * gl_Normal;
	#ifdef FOG_ENABLED
		vec3 playerPos = gl_Vertex.xyz;
		getFogData(playerPos, fogAmount, fogSkyColor, fogBloomSkyColor);
	#endif
}

#endif
