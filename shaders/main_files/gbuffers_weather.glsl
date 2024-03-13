#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec4 glcolor;
	
	varying vec3 normal;
	
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	
	color.a *= 1.0 - WEATHER_TRANSPARENCY;
	
	// auto exposure
	#if AUTO_EXPOSURE_ENABLED == 1
		#include "/import/eyeBrightnessSmooth.glsl"
		float autoExposureAmount = dot(eyeBrightnessSmooth / 240.0, vec2(0.5, 1.0));
		color *= mix(AUTO_EXPOSURE_DARK_MULT, AUTO_EXPOSURE_BRIGHT_MULT, autoExposureAmount);
	#endif
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal, 1.0);
	
	#if REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:043 */
		gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
	#endif
	
}

#endif



#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_JITTER
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
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
	
	normal = gl_NormalMatrix * gl_Normal;
	
}

#endif
