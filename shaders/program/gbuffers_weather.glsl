#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec4 glcolor;
	
	varying vec3 normal;
	
#endif



#ifdef FSH

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	color.a *= 1.0 - WEATHER_TRANSPARENCY;
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
	
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
	
	vec4 pos = gl_Vertex;
	float horizontalAmount = pos.y * WEATHER_HORIZONTAL_AMOUNT * 0.5;
	pos.x += horizontalAmount;
	horizontalAmount *= 0.5;
	pos.z += horizontalAmount;
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * pos));
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * pos;
	#endif
	
	#ifdef TAA_JITTER
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	glcolor = gl_Color;
	
	normal = gl_NormalMatrix * gl_Normal;
	
}

#endif
