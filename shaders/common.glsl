const float PI = 3.1415926538;
const float HALF_PI = PI / 2.0;

#ifdef FSH
	ivec2 texelcoord = ivec2(gl_FragCoord.xy);
#endif

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D shadowtex0;
#ifdef DISTANT_HORIZONS
	uniform sampler2D dhDepthTex0;
	uniform sampler2D dhDepthTex1;
#endif
//uniform sampler2D noisetex;

//uniform float centerDepth;
//uniform float centerDepthSmooth;



// misc defines

#ifdef FSH
	#define flat_inout flat in
	//#define varying in
#else
	#define flat_inout flat out
	//#define varying out
#endif

//#define HAND_DEPTH 0.19 // idk what should actually be here



// buffer values:

#define MAIN_TEXTURE               colortex0
#define MAIN_TEXTURE_COPY          colortex1
#define OPAQUE_DATA_TEXTURE        colortex2
#define TRANSPARENT_DATA_TEXTURE   colortex3
#define PREV_TEXTURE               colortex4
#define BLOOM_TEXTURE              colortex5
#define NOISY_TEXTURE              colortex6

#define DEPTH_BUFFER_ALL                   depthtex0
#define DEPTH_BUFFER_WO_TRANS              depthtex1
#define DEPTH_BUFFER_WO_TRANS_OR_HANDHELD  depthtex2
#ifdef DISTANT_HORIZONS
	#define DH_DEPTH_BUFFER_ALL       dhDepthTex0
	#define DH_DEPTH_BUFFER_WO_TRANS  dhDepthTex1
#endif





float pow2(float v) {
	return v * v;
}
float pow3(float v) {
	return v * v * v;
}
float pow4(float v) {
	float v2 = v * v;
	return v2 * v2;
}
float pow5(float v) {
	float v2 = v * v;
	return v2 * v2 * v;
}
float pow10(float v) {
	float v2 = v * v;
	float v4 = v2 * v2;
	return v4 * v4 * v2;
}

vec2 pow2(vec2 v) {
	return v * v;
}
vec2 pow3(vec2 v) {
	return v * v * v;
}

vec3 pow2(vec3 v) {
	return v * v;
}
vec3 pow3(vec3 v) {
	return v * v * v;
}

float maxAbs(vec2 v) {
	float r = abs(v.r);
	float g = abs(v.g);
	return max(r, g);
}

float maxAbs(vec3 v) {
	float r = abs(v.r);
	float g = abs(v.g);
	float b = abs(v.b);
	return max(max(r, g), b);
}

float percentThroughClamped(float value, float low, float high) {
	float percentThrough = (value - low) / (high - low);
	return clamp(percentThrough, 0.0, 1.0);
}

float getColorLum(vec3 color) {
	return dot(color, vec3(0.2125, 0.7154, 0.0721));
}

// all these smooth functions seem the same for speed

//// from: https://iquilezles.org/articles/smin/
//vec3 smoothMin(vec3 a, vec3 b, float k) {
//	vec3 h = max(k-abs(a-b), 0.0)/k;
//	return min(a, b) - h*h*k*0.25;
//}

//// same as smoothMin but w/ in&out inverted
//vec3 smoothMax(vec3 a, vec3 b, float k) {
//	vec3 h = max(k-abs(a-b), 0.0)/k;
//	return max(a, b) + h*h*k*0.25;
//}

//// from: https://www.shadertoy.com/view/Ml3Gz8
//vec3 smoothMin(vec3 a, vec3 b, float k) {
//	vec3 h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
//	return mix(a, b, h) - k*h*(1.0-h);
//}

//// same as smoothMin but w/ in&out inverted
//vec3 smoothMax(vec3 a, vec3 b, float k) {
//	vec3 h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
//	return mix(a, b, h) + k*h*(1.0-h);
//}

vec3 smoothMin(vec3 v1, vec3 v2, float a) {
	float v1Lum = getColorLum(v1);
	float v2Lum = getColorLum(v2);
	return (v1 + v2 - sqrt((v1 - v2) * (v1 - v2) + a * (v1Lum + v2Lum) / 2.0)) / 2.0;
}

vec3 smoothMax(vec3 v1, vec3 v2, float a) {
	float v1Lum = getColorLum(v1);
	float v2Lum = getColorLum(v2);
	return (v1 + v2 + sqrt((v1 - v2) * (v1 - v2) + a * (v1Lum + v2Lum) / 2.0)) / 2.0;
}

vec3 smoothClamp(vec3 v, vec3 minV, vec3 maxV, float a) {
	return smoothMax(smoothMin(v, maxV, a), minV, a);
}

float cosineInterpolate(float edge1, float edge2, float value) {
	float value2 = (1.0 - cos(value * PI)) / 2.0;
	return edge1 * (1.0 - value2) + edge2 * value2;
}

float cubicInterpolate(float edge0, float edge1, float edge2, float edge3, float value) {
	float value2 = value * value;
	float a0 = edge3 - edge2 - edge0 + edge1;
	float a1 = edge0 - edge1 - a0;
	float a2 = edge2 - edge0;
	float a3 = edge1;
	return(a0 * value * value2 + a1 * value2 + a2 * value + a3);
}

vec3 cubicInterpolate(vec3 edge0, vec3 edge1, vec3 edge2, vec3 edge3, float value) {
	float x = cubicInterpolate(edge0.x, edge1.x, edge2.x, edge3.x, value);
	float y = cubicInterpolate(edge0.y, edge1.y, edge2.y, edge3.y, value);
	float z = cubicInterpolate(edge0.z, edge1.z, edge2.z, edge3.z, value);
	return vec3(x, y, z);
}

float bayer2(vec2 a) {
	a = floor(a);
	return fract(dot(a, vec2(0.5, a.y * 0.75)));
}
float bayer4  (const vec2 a) {return bayer2 (0.5   * a) * 0.25     + bayer2(a); }
float bayer8  (const vec2 a) {return bayer4 (0.5   * a) * 0.25     + bayer2(a); }
float bayer16 (const vec2 a) {return bayer4 (0.25  * a) * 0.0625   + bayer4(a); }
float bayer32 (const vec2 a) {return bayer8 (0.25  * a) * 0.0625   + bayer4(a); }
float bayer64 (const vec2 a) {return bayer8 (0.125 * a) * 0.015625 + bayer8(a); }
float bayer128(const vec2 a) {return bayer16(0.125 * a) * 0.015625 + bayer8(a); }

float packVec2(vec2 v) {
	v = floor(v * 2047.0 + 0.5);
	return dot(v, vec2(1.0, 2048.0)) / 0x3FFFFF;
}

float packVec2(float x, float y) {return packVec2(vec2(x, y));}

vec2 unpackVec2(float v) {
	v *= 0x3FFFFF; // map to 0 - 2^22-1
	float x = mod(v, 2048.0); // take lowest 11 bits
	v = floor(v / 2048.0); // shift 11 bits
	float y = v; // take last 11 bits
	return vec2(x, y) / 2047.0; // map to 0-1
}

// octahedral encoding/decoding
vec2 encodeNormal(vec3 v) {
	v /= abs(v.x) + abs(v.y) + abs(v.z);
	v.xy = (v.z >= 0.0) ? v.xy : (1.0 - abs(v.yx)) * (vec2(v.x >= 0.0, v.y >= 0.0) * 2.0 - 1.0);
	return v.xy * 0.5 + 0.5;
}

vec3 decodeNormal(vec2 v) {
	vec2 f = v * 2.0 - 1.0;
	vec3 n = vec3(f, 1.0 - abs(f.x) - abs(f.y));
	float t = max(-n.z, 0.0);
	n.xy += vec2(n.x >= 0.0 ? -t : t, n.y >= 0.0 ? -t : t);
	return normalize(n);
}



vec4 startMat(vec3 pos) {
	return vec4(pos.xyz, 1.0);
}
vec3 endMat(vec4 pos) {
	return pos.xyz / pos.w;
}

bool depthIsSky(float depth) {
	return depth > 0.99;
}
bool depthIsHand(float depth) {
	return depth < 0.003;
}

// never underestimate trial and error
#ifdef FSH
	float estimateDepthFSH(vec2 texcoord, float linearDepth) {
		float len = length(texcoord * 2.0 - 1.0);
		return linearDepth + len * len / 8.0;
	}
#else
	float estimateDepthVSH() {
		float len = length(gl_Position.xy) / max(gl_Position.w, 1.0);
		return gl_Position.z * (1.0 + len * len * 0.7);
	}
#endif

void adjustLmcoord(inout vec2 lmcoord) {
	const float low = 0.0333;
	const float high = 0.95;
	lmcoord -= low;
	lmcoord /= high - low;
	lmcoord = clamp(lmcoord, 0.0, 1.0);
}

vec3 getSkyLight(vec4 skylightPercents) {
	vec3 skyLight = 
		skylightPercents.x * SKYLIGHT_DAY_COLOR +
		skylightPercents.y * SKYLIGHT_NIGHT_COLOR +
		skylightPercents.z * SKYLIGHT_SUNRISE_COLOR +
		skylightPercents.w * SKYLIGHT_SUNSET_COLOR;
	return skyLight / 2.0;
}

vec3 getAmbientLight(vec4 skylightPercents, float ambientBrightness) {
	vec3 ambient = 
		skylightPercents.x * AMBIENT_DAY_COLOR +
		skylightPercents.y * AMBIENT_NIGHT_COLOR +
		skylightPercents.z * AMBIENT_SUNRISE_COLOR +
		skylightPercents.w * AMBIENT_SUNSET_COLOR;
	return mix(CAVE_AMBIENT_COLOR, ambient, ambientBrightness);
}



#ifdef USE_BETTER_RAND
	// taken from: https://www.reedbeta.com/blog/hash-functions-for-gpu-rendering/
	uint randomizeUint(inout uint rng) {
		rng = rng * 747796405u + 2891336453u;
		uint v = ((rng >> ((rng >> 28u) + 4u)) ^ rng) * 277803737u;
		return (v >> 22u) ^ v;
	}
	/*
	// maybe switch to this:
	// taken from: https://www.pcg-random.org/download.html
	uint32_t pcg32_random_r(pcg32_random_t* rng)
	{
		uint64_t oldstate = rng->state;
		rng->state = oldstate * 6364136223846793005ULL + rng->inc;
		uint32_t xorshifted = ((oldstate >> 18u) ^ oldstate) >> 27u;
		uint32_t rot = oldstate >> 59u;
		return (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
	}
	*/
#else
	uint rotateRight(uint value, uint shift) {
		return (value >> shift) | (value << (32u - shift));
	}
	uint randomizeUint(inout uint rng) {
		rng = rng * 747796405u + 2891336453u;
		rng ^= rotateRight(rng, 11u);
		rng ^= rotateRight(rng, 17u);
		rng ^= rotateRight(rng, 23u);
		return rng;
	}
#endif

float randomFloat(inout uint rng) {
	uint v = randomizeUint(rng);
	const uint BIT_MASK = (2u << 16u) - 1u;
	float normalizedValue = float(v & BIT_MASK) / float(BIT_MASK);
	return normalizedValue * 2.0 - 1.0;
}

vec2 randomVec2(inout uint rng) {
	float x = randomFloat(rng);
	float y = randomFloat(rng);
	return vec2(x, y);
}

vec3 randomVec3(inout uint rng) {
	float x = randomFloat(rng);
	float y = randomFloat(rng);
	float z = randomFloat(rng);
	return vec3(x, y, z);
}

vec3 randomVec3FromRValue(uint rng) {
	return randomVec3(rng);
}

float normalizeNoiseAround1(float noise, float range) {
	return noise * range + 1.0;
}

vec2 normalizeNoiseAround1(vec2 noise, float range) {
	float x = normalizeNoiseAround1(noise.x, range);
	float y = normalizeNoiseAround1(noise.y, range);
	return vec2(x, y);
}

vec3 normalizeNoiseAround1(vec3 noise, float range) {
	float x = normalizeNoiseAround1(noise.x, range);
	float y = normalizeNoiseAround1(noise.y, range);
	float z = normalizeNoiseAround1(noise.z, range);
	return vec3(x, y, z);
}



float cubeLength(vec2 v) {
	return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}

float getDistortFactor(vec3 v) {
	return cubeLength(v.xy) + SHADOW_DISTORT_ADDITION;
}

vec3 distort(vec3 v, float distortFactor) {
	return vec3(v.xy / distortFactor, v.z * 0.5);
}

vec3 distort(vec3 v) {
	return distort(v, getDistortFactor(v));
}
