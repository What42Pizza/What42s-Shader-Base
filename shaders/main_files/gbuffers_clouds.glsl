// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	flat_inout float glcolor;
	flat_inout vec3 colorMult;
	#if HIDE_NEARBY_CLOUDS == 1
		varying float opacity;
	#endif
	#if FOG_ENABLED == 1
		varying float fogDistance;
	#endif
	
#endif



#ifdef FSH

#if FOG_ENABLED == 1
	#include "/lib/fog/getFogAmount.glsl"
	#include "/lib/fog/applyFog.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	#if HIDE_NEARBY_CLOUDS == 0
		#define opacity (1.0 - CLOUD_TRANSPARENCY)
	#endif
	color.a = opacity;
	
	
	color.rgb *= colorMult;
	
	
	// fog
	#if FOG_ENABLED == 1
		float fogAmount = getFogAmount(fogDistance  ARGS_IN);
		applyFog(color.rgb, fogAmount  ARGS_IN);
	#endif
	
	
	
	// outputs
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
	
}

#endif



#ifdef VSH

#include "/utils/getSkyLight.glsl"
#include "/utils/getAmbientLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif
#if FOG_ENABLED == 1
	#include "/lib/fog/getFogDistance.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	vec3 skyLight = getSkyLight(ARG_IN);
	vec3 ambientLight = getAmbientLight(ARG_IN);
	colorMult = skyLight + ambientLight;
	//colorMult = mix(vec3(getColorLum(colorMult)), colorMult, vec3(1.0));
	colorMult = normalize(colorMult) * 2.0 * CLOUDS_BRIGHTNESS;
	
	#if ISOMETRIC_RENDERING_ENABLED == 1 || HIDE_NEARBY_CLOUDS == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	#if FOG_ENABLED == 1
		vec4 position = gl_Vertex;
		fogDistance = getFogDistance(position.xyz  ARGS_IN);
	#endif
	
	#if HIDE_NEARBY_CLOUDS == 1
		opacity = (1.0 - CLOUD_TRANSPARENCY) * atan(length(worldPos) - 30.0) / PI + 0.5;
	#endif
	
	glcolor = gl_Color.r;
	
}

#endif
