varying vec2 texcoord;
flat vec4 glcolor;
flat vec3 glnormal;

#include "/lib/fog.glsl"



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	// bloom
	vec4 colorForBloom = color;
	colorForBloom.rgb *= sqrt(BLOOM_CLOUD_BRIGHTNESS);
	
	
	// fog
	#ifdef FOG_ENABLED
		applyFog(color.rgb, colorForBloom.rgb);
	#endif
	
	
	/* DRAWBUFFERS:024 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color.rgb = debugOutput;
	#endif
	gl_FragData[0] = color;
	gl_FragData[1] = colorForBloom;
	gl_FragData[2] = vec4(glnormal, 1.0);
}

#endif



#ifdef VSH

#include "/lib/taa_jitter.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	gl_Position = ftransform();
	
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	
	#ifdef FOG_ENABLED
		vec4 position = gl_Vertex;//gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
		getFogData(position.xyz);
	#endif
	
	glcolor = gl_Color;
	glnormal = normalize(gl_NormalMatrix * gl_Normal);
	
}

#endif
