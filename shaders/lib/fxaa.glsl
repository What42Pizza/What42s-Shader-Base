#define FXAA_REDUCE_MIN (1.0 / 128.0)
#define FXAA_REDUCE_MUL (1.0 / 8.0)
#define FXAA_SPAN_MAX 8.0

void doFxaa(inout vec3 rgbM, sampler2D tex  ARGS_OUT) {
	
	vec3 rgbNW = texelFetch(tex, texelcoord + ivec2(0, 0), 0).xyz;
	vec3 rgbNE = texelFetch(tex, texelcoord + ivec2(1, 0), 0).xyz;
	vec3 rgbSW = texelFetch(tex, texelcoord + ivec2(0, 1), 0).xyz;
	vec3 rgbSE = texelFetch(tex, texelcoord + ivec2(1, 1), 0).xyz;
	
	vec3 luma = vec3(0.299, 0.587, 0.114);
	float lumaNW = dot(rgbNW, luma);
	float lumaNE = dot(rgbNE, luma);
	float lumaSW = dot(rgbSW, luma);
	float lumaSE = dot(rgbSE, luma);
	float lumaM  = dot(rgbM,  luma);
	
	float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
	float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
	
	vec2 dir;
	dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
	dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
	
	float dirReduce = max(
		(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
		FXAA_REDUCE_MIN
	);
	float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
	
	#include "/import/pixelSize.glsl"
	dir = min(
		vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
		max(
			vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
			dir * rcpDirMin
		)
	) * pixelSize;
	
	vec3 rgbA = (1.0/2.0) * (
		textureLod(tex, texcoord + dir * (1.0/3.0 - 0.5), 0.0).xyz +
		textureLod(tex, texcoord + dir * (2.0/3.0 - 0.5), 0.0).xyz);
	vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
		textureLod(tex, texcoord + dir * (0.0/3.0 - 0.5), 0.0).xyz +
		textureLod(tex, texcoord + dir * (3.0/3.0 - 0.5), 0.0).xyz);
	
	float lumaB = dot(rgbB, luma);
	
	if((lumaB < lumaMin) || (lumaB > lumaMax)) {
		rgbM = rgbA;
		return;
	}
	
	rgbM = rgbB;
}
