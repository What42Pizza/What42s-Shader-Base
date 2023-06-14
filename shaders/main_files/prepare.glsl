//--------------------------------------//
//        Per-Frame Calculations        //
//--------------------------------------//



#ifdef FSH

#include "/lib/perFrame.glsl"

/* DRAWBUFFERS:6 */
void main() {
	ivec2 fragCoord = ivec2(gl_FragCoord.xy);
	if (fragCoord.y > 0) {return;}
	switch (fragCoord.x) {
		
		
		
		// sunlightPercents
		
		case CACHED_SUNLIGHT_PERCENT: {
			vec4 skylightPercents = getSkylightPercents();
			gl_FragData[0] = vec4(skylightPercents.x, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_MOONLIGHT_PERCENT: {
			vec4 skylightPercents = getSkylightPercents();
			gl_FragData[0] = vec4(skylightPercents.y, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_SUNRISE_PERCENT: {
			vec4 skylightPercents = getSkylightPercents();
			gl_FragData[0] = vec4(skylightPercents.z, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_SUNSET_PERCENT: {
			vec4 skylightPercents = getSkylightPercents();
			gl_FragData[0] = vec4(skylightPercents.w, 0.0, 0.0, 1.0);
		break;}
		
		
		
		// skyLight and ambientLight
		
		case CACHED_SKY_RED: {
			vec4 skylightPercents = getSkylightPercents();
			vec3 skyColor = getSkyColor(skylightPercents);
			gl_FragData[0] = vec4(skyColor.r, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_SKY_GREEN: {
			vec4 skylightPercents = getSkylightPercents();
			vec3 skyColor = getSkyColor(skylightPercents);
			gl_FragData[0] = vec4(skyColor.g, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_SKY_BLUE: {
			vec4 skylightPercents = getSkylightPercents();
			vec3 skyColor = getSkyColor(skylightPercents);
			gl_FragData[0] = vec4(skyColor.b, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_AMBIENT_RED: {
			vec4 ambientlightPercents = getSkylightPercents();
			vec3 ambientColor = getAmbientColor(ambientlightPercents);
			gl_FragData[0] = vec4(ambientColor.r, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_AMBIENT_GREEN: {
			vec4 ambientlightPercents = getSkylightPercents();
			vec3 ambientColor = getAmbientColor(ambientlightPercents);
			gl_FragData[0] = vec4(ambientColor.g, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_AMBIENT_BLUE: {
			vec4 ambientlightPercents = getSkylightPercents();
			vec3 ambientColor = getAmbientColor(ambientlightPercents);
			gl_FragData[0] = vec4(ambientColor.b, 0.0, 0.0, 1.0);
		break;}
		
		
		
		// sunraysData
		
		case CACHED_SUNRAYS_RED: {
			vec4 sunraysData = getSunraysData();
			gl_FragData[0] = vec4(sunraysData.x, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_SUNRAYS_GREEN: {
			vec4 sunraysData = getSunraysData();
			gl_FragData[0] = vec4(sunraysData.y, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_SUNRAYS_BLUE: {
			vec4 sunraysData = getSunraysData();
			gl_FragData[0] = vec4(sunraysData.z, 0.0, 0.0, 1.0);
		break;}
		
		case CACHED_SUNRAYS_AMOUNT: {
			vec4 sunraysData = getSunraysData();
			gl_FragData[0] = vec4(sunraysData.w, 0.0, 0.0, 1.0);
		break;}
		
		
		
	}
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
}

#endif
