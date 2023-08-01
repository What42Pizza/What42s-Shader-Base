//--------------------------------//
//        Value Processing        //
//--------------------------------//



varying vec2 texcoord;



#ifdef FSH

/*
vec3 calculateNormal() {
	// Sample the center depth value
	float depthCenter = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	
	// Calculate screen-space derivatives (dPdx and dPdy)
	float ddx = dFdx(depthCenter);
	float ddy = dFdy(depthCenter);
	
	// Calculate the eye-space position
	float linearDepth = 1.0 / mix(far, near, depthCenter);
	vec4 position = vec4(texcoord * 2.0 - 1.0, depthCenter * 2.0 - 1.0, 1.0);
	position.z = linearDepth;
	position = gbufferProjectionInverse * position;
	position /= position.w;
	
	// Calculate eye-space positions of neighboring pixels
	vec4 positionX = position + vec4(ddx, 0.0, 0.0, 0.0);
	vec4 positionY = position + vec4(0.0, ddy, 0.0, 0.0);
	
	// Calculate the surface normal in eye-space
	vec3 dpdx = positionX.xyz - position.xyz;
	vec3 dpdy = positionY.xyz - position.xyz;
	vec3 normal = normalize(cross(dpdx, dpdy));
	
	// Convert the normal from eye-space to world-space (if needed)
	normal = normalize(gl_NormalMatrix * normal);
	
	return normal;
}
*/

vec3 calculateNormal() {
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	
	// Calculate the screen-space position of the current fragment
	vec2 dx = vec2(pixelSize.x, 0.0);
	vec2 dy = vec2(0.0, pixelSize.y);
	vec3 position = vec3(texcoord, depth);
	vec3 positionDX = vec3(texcoord + dx, texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2(1, 0), 0).r);
	vec3 positionDY = vec3(texcoord + dy, texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2(0, 1), 0).r);
	
	// Estimate the partial derivatives of position with respect to screen space
	vec3 dpdx = positionDX - position;
	vec3 dpdy = positionDY - position;
	
	// Calculate the normal vector
	vec3 normal = cross(dpdx, dpdy);
	normal.xy *= -1.0; // Invert the Y-axis to match the OpenGL convention
	
	// Normalize the normal vector
	normal = normalize(normal);
	
	return normal;
}



vec3 calculateNormal2() {
	
	float centerDepth = toBlockDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
	float xDepth = toBlockDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2(1, 0), 0).r);
	float yDepth = toBlockDepth(texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2(0, 1), 0).r);
	float depthXChange = (centerDepth - xDepth) / centerDepth;
	float depthYChange = (centerDepth - yDepth) / centerDepth;
	float totalDepthChange = depthXChange + depthYChange;
	
	vec3 normal = vec3(pixelSize, depthXChange + depthYChange);
	normal = normalize(normal);
	//normal = vec3(depthXChange, depthYChange, 0) * 10;
	
	return normal;
}



void main() {
	vec3 color = texelFetch(MAIN_BUFFER, texelcoord, 0).rgb;
	
	vec3 normal = calculateNormal2();
	if (texcoord.x < 0.5 || true) {
		normal = texelFetch(NORMALS_BUFFER, texelcoord, 0).rgb;
	}
	
	/* DRAWBUFFERS: 06 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(normal, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
