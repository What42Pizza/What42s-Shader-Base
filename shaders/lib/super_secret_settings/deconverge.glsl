#ifdef FIRST_PASS
	const vec3 ConvergeX = vec3(-4, 0, 2);
	const vec3 ConvergeY = vec3(0, -4, 2);
#endif



vec3 sss_deconverge(ARG_OUT) {
	
	#include "/import/pixelSize.glsl"
	vec3 convergeX = ConvergeX * pixelSize.x / SSS_DECONVERGE_QUALITY * SSS_DECONVERGE_AMOUNT;
	vec3 convergeY = ConvergeY * pixelSize.y / SSS_DECONVERGE_QUALITY * SSS_DECONVERGE_AMOUNT;
	
	vec3 CoordX = vec3(texcoord.x);
	vec3 CoordY = vec3(texcoord.y);
	#if SSS_FLIP == 1
		CoordX = 1.0 - CoordX;
		CoordY = 1.0 - CoordY;
	#endif
	vec3 color = vec3(0.0);
	
	for (int i = 0; i < SSS_DECONVERGE_QUALITY; i++) {
		CoordX += convergeX;
		CoordY += convergeY;
		color.r += texture2D(MAIN_TEXTURE_COPY, vec2(CoordX.x, CoordY.x)).r;
		color.g += texture2D(MAIN_TEXTURE_COPY, vec2(CoordX.y, CoordY.y)).g;
		color.b += texture2D(MAIN_TEXTURE_COPY, vec2(CoordX.z, CoordY.z)).b;
	}
	
	return color / SSS_DECONVERGE_QUALITY;
}
