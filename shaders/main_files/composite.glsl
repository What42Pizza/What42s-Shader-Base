//---------------------------------//
//        Post-Processing 1        //
//---------------------------------//



varying vec2 texcoord;

//#ifdef REFLECTIONS_ENABLED
//	flat vec3 upVec;
//#endif



#ifdef FSH

//#ifdef REFLECTIONS_ENABLED
//	#include "/lib/reflections.glsl"
//#endif

void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	#ifdef BLOOM_ENABLED
		vec3 bloomColor = texelFetch(BLOOM_BUFFER, texelcoord, 0).rgb;
	#endif
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = texelFetch(DEBUG_BUFFER, texelcoord, 0).rgb;
	#endif
	
	
	
	// ======== REFLECTIONS ========
	
	//#ifdef REFLECTIONS_ENABLED
	//	vec3 normal = normalize(texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb);
	//	float reflectionMult = dot(normal, upVec);
	//	vec3 viewPos = getViewPos(texcoord, texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
	//	vec2 reflectionPos = Raytrace(viewPos, normal);
	//	if (reflectionPos.x > -0.5) {
	//		vec3 reflectionColor = texture2DLod(MAIN_BUFFER, reflectionPos, 0).rgb; // WHY DO I HAVE TO USE LOD HERE??????
	//		color = mix(color, reflectionColor, 0.7);
	//	} else {
	//		vec3 reflectionColor = getSkyColor();
	//		color = mix(color, reflectionColor, 0.7);
	//	}
	//#endif
	
	
	
	// ======== BLOOM FILTERING ========
	
	#ifdef BLOOM_ENABLED
		float alpha = getColorLum(bloomColor);
		alpha = (alpha - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		alpha = clamp(alpha, 0.0, 1.0);
		bloomColor *= alpha;
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	gl_FragData[0] = vec4(color, 1.0);
	#ifdef BLOOM_ENABLED
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = vec4(bloomColor, 1.0);
	#endif
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	//#ifdef REFLECTIONS_ENABLED
	//	upVec = normalize(gbufferModelView[1].xyz);
	//#endif
	
}

#endif
