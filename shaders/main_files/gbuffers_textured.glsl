// defines

#if defined BLOOM_ENABLED && defined NORMALS_NEEDED
	#define BLOOM_AND_NORMALS
#endif

// transfers

varying vec2 texcoord;
varying float lightMult;

#ifdef NORMALS_NEEDED
	varying vec3 normal;
#endif





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	color.rgb *= lightMult;
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	#ifdef BLOOM_AND_NORMALS
		/* DRAWBUFFERS:024 */
		gl_FragData[1] = color;
		gl_FragData[2] = vec4(normal, 1.0);
	#elif defined BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = color;
	#elif defined NORMALS_NEEDED
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(normal, 1.0);
	#endif
}

#endif





#ifdef VSH

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	vec2 lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lightMult = max(max(lmcoord.x, lmcoord.y), 0.1);
	
	
	gl_Position = ftransform();
	if (gl_Position.z < -1.0) return; // simple but effective optimization
	
	
	#ifdef TAA_ENABLED
		gl_Position.xy += taaOffset * gl_Position.w;
	#endif
	
	
	#ifdef NORMALS_NEEDED
		normal = gl_NormalMatrix * gl_Normal;
	#endif
	
	
}

#endif
