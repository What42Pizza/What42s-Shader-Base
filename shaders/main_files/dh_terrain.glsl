// transfers

#ifdef FIRST_PASS
	
	varying vec2 lmcoord;
	varying vec4 glcolor;
	flat_inout int dhBlock;
	
#endif

// includes

#include "/lib/lighting/pre_lighting.glsl"
#include "/lib/lighting/basic_lighting.glsl"





#ifdef FSH

#include "/utils/getSkyLight.glsl"

void main() {
	vec4 color = glcolor;
	
	
	// main lighting
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	vec3 skyLight = getSkyLight(ARG_IN);
	color.rgb *= 1.0 + skyLight * 0.8 * (1.0 - 0.6 * getColorLum(color.rgb));
	
	
	// show dangerous light
	#if SHOW_DANGEROUS_LIGHT == 1
		if (isDangerousLight > 0.0) {
			color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), 0.6);
		}
	#endif
	
	
	// outputs
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
	
}

#endif





#ifdef VSH

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	dhBlock = dhMaterialId;
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
	    gl_Position = ftransform();
	#endif
	
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	glcolor = gl_Color;
	
	
	doPreLighting(ARG_IN);
	
}

#endif
