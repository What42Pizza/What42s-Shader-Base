void sss_bumpy(inout vec3 color  ARGS_OUT) {
	#include "/import/pixelSize.glsl"
	
	vec4 u = texture2D(MAIN_TEXTURE_COPY, texcoord + vec2(         0.0, -pixelSize.y) * 1.25);
	vec4 d = texture2D(MAIN_TEXTURE_COPY, texcoord + vec2(         0.0,  pixelSize.y) * 1.25);
	vec4 l = texture2D(MAIN_TEXTURE_COPY, texcoord + vec2(-pixelSize.x,          0.0) * 1.25);
	vec4 r = texture2D(MAIN_TEXTURE_COPY, texcoord + vec2( pixelSize.x,          0.0) * 1.25);
	
	vec4 nc = normalize(vec4(color, 1.0));
	vec4 nu = normalize(u);
	vec4 nd = normalize(d);
	vec4 nl = normalize(l);
	vec4 nr = normalize(r);
	
	float du = dot(nc, nu);
	float dd = dot(nc, nd);
	float dl = dot(nc, nl);
	float dr = dot(nc, nr);
	
	float i = 64.0;
	
	float f = 1.0;
	f += (du * i) - (dd * i);
	f += (dr * i) - (dl * i);
	
	color *= clamp(f, 0.5, 2.0);
}
