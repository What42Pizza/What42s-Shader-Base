// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	flat float glcolor;
	flat vec3 colorMult;
	
#endif

// includes

#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	color.a = CLOUD_TRANSPARENCY;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	color.rgb *= colorMult * 2.3;
	
	
	// bloom
	#ifdef BLOOM_ENABLED
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_CLOUD_BRIGHTNESS);
	#endif
	
	
	// fog
	#ifdef FOG_ENABLED
		#ifdef BLOOM_ENABLED
			applyFog(color.rgb, colorForBloom.rgb  ARGS_IN);
		#else
			applyFog(color.rgb  ARGS_IN);
		#endif
	#endif
	
	
	
	// outputs
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
	
	#if defined BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#endif
	
}

#endif



#ifdef VSH

#include "/utils/getSkyLight.glsl"
#include "/utils/getAmbientLight.glsl"

#ifdef ISOMETRIC_RENDERING_ENABLED
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	vec3 skyLight = getSkyLight(ARG_IN);
	vec3 ambientLight = getAmbientLight(ARG_IN);
	colorMult = skyLight + ambientLight;
	//colorMult = mix(vec3(getColorLum(colorMult)), colorMult, vec3(1.0));
	colorMult = normalize(colorMult);
	
	#ifdef ISOMETRIC_RENDERING_ENABLED
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	#ifdef FOG_ENABLED
		vec4 position = gl_Vertex;
		getFogData(position.xyz  ARGS_IN);
	#endif
	
	glcolor = gl_Color.r;
	
}

#endif
