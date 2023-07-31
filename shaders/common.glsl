const float PI = 3.1415926538;
const float HALF_PI = PI / 2.0;

uniform int frameCounter;
uniform float frameTimeCounter;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec4 entityColor;
uniform float viewHeight;
uniform float viewWidth;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform int worldTime;
uniform ivec2 eyeBrightnessSmooth;
uniform float eyeAltitude;
uniform int isEyeInWater;
uniform int heldBlockLightValue;
uniform float rainStrength;
uniform float wetness;
uniform float screenBrightness;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferPreviousModelView;
uniform mat3 normalMatrix;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 shadowLightPosition;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D shadowtex0;
uniform sampler2D noisetex;



uniform vec2 viewSize;
uniform vec2 pixelSize;
uniform int frameMod8;
uniform float velocity;
uniform float betterRainStrength;

#ifdef FSH
	ivec2 texelcoord = ivec2(gl_FragCoord.xy);
#endif

#ifdef VSH
	attribute vec4 mc_Entity;
	attribute vec2 mc_midTexCoord;
#endif

#define HAND_DEPTH 0.175 // idk what should actually be here



// buffer values:

#define MAIN_BUFFER              texture
#define TAA_PREV_BUFFER          colortex1
#define BLOOM_BUFFER             colortex2
#define SKY_COLOR_BUFFER         colortex4
#define SKY_BLOOM_COLOR_BUFFER   colortex5
#define PER_FRAME_VALUES_BUFFER  colortex6
#define NOISY_ADDITIONS_BUFFER   colortex8
#define NORMALS_BUFFER           colortex9
#define VIEW_POS_BUFFER          colortex10
#define DEBUG_BUFFER             colortex11

#define DEPTH_BUFFER_ALL                   depthtex0
#define DEPTH_BUFFER_WO_TRANS              depthtex1
#define DEPTH_BUFFER_WO_TRANS_OR_HANDHELD  depthtex2



// cached value indicies:

const int CACHED_SUNLIGHT_PERCENT = 0;
const int CACHED_MOONLIGHT_PERCENT = 1;
const int CACHED_SUNRISE_PERCENT = 2;
const int CACHED_SUNSET_PERCENT = 3;

const int CACHED_SKY_RED = 4;
const int CACHED_SKY_GREEN = 5;
const int CACHED_SKY_BLUE = 6;
const int CACHED_AMBIENT_RED = 7;
const int CACHED_AMBIENT_GREEN = 8;
const int CACHED_AMBIENT_BLUE = 9;

const int CACHED_SUNRAYS_RED = 10;
const int CACHED_SUNRAYS_GREEN = 11;
const int CACHED_SUNRAYS_BLUE = 12;
const int CACHED_SUNRAYS_AMOUNT = 13;





// CODE FROM COMPLEMENTARY REIMAGINED:

//#define diagonal3(m) vec3((m)[0].x, (m)[1].y, (m)[2].z)
//#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

vec3 screenToView(vec3 pos) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x,
						  gbufferProjectionInverse[1].y,
						  gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2.0 - 1.0;
    vec4 viewPos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return viewPos.xyz / viewPos.w;
}

vec3 viewToPlayer(vec3 pos) {
	return mat3(gbufferModelViewInverse) * pos + gbufferModelViewInverse[3].xyz;
}

//vec3 playerToShadow(vec3 pos) {
//	vec3 shadowpos = mat3(shadowModelView) * pos + shadowModelView[3].xyz;
//	return vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z) * shadowpos + shadowProjection[3].xyz;
//	//return projMAD(shadowProjection, shadowpos);
//}



//vec3 calculateShadowPos(vec3 playerPos) {
//	vec3 shadowPos = playerToShadow(playerPos);
//	return shadowPos;
//	float distb = sqrt(shadowPos.x * shadowPos.x + shadowPos.y * shadowPos.y);
//	float distortFactor = distb * shadowMapBias + (1.0 - shadowMapBias);
//	shadowPos.xy /= distortFactor;
//	shadowPos.z *= 0.2;
//	return shadowPos * 0.5 + 0.5;
//}



//float SampleShadow(vec3 screenPos) {
//	vec3 viewPos = screenToView(screenPos);
//	vec3 playerPos = viewToPlayer(viewPos);
//	vec3 shadowPos = calculateShadowPos(playerPos);
//	float shadow0 = texture2D(shadowtex0, shadowPos.st).x;
//	return shadow0;
//}

// END OF COMPLEMENTARY REIMAGINED'S CODE





//euclidian distance is defined as sqrt(a^2 + b^2 + ...)
//this length function instead does cbrt(a^3 + b^3 + ...)
//this results in smaller distances along the diagonal axes.
float cubeLength(vec2 v) {
	return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}

float getDistortFactor(vec2 v) {
	#if SHADOW_DISTORT_EXP == 2
		return length(v) + SHADOW_DISTORT_ADDITION;
	#elif SHADOW_DISTORT_EXP == 3
		return cubeLength(v) + SHADOW_DISTORT_ADDITION;
	#else
		return pow(pow(abs(v.x), SHADOW_DISTORT_EXP) + pow(abs(v.y), SHADOW_DISTORT_EXP), 1.0 / SHADOW_DISTORT_EXP) + SHADOW_DISTORT_ADDITION;
	#endif
}

vec3 distort(vec3 v, float factor) {
	return vec3(v.xy / factor, v.z * 0.5);
}

vec3 distort(vec3 v) {
	return distort(v, getDistortFactor(v.xy));
}



float getColorLum(vec3 color) {
	return dot(color, vec3(0.2125, 0.7154, 0.0721));
}

float percentThrough(float v, float minv, float maxv) {
	return (v - minv) / (maxv - minv);
}

float maxAbs(vec3 v) {
	float r = abs(v.r);
	float g = abs(v.g);
	float b = abs(v.b);
	return max(max(r, g), b);
}

float inverseLength(vec3 v) {
	return inversesqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

float powDot(vec3 a, vec3 b, float e) {
	return pow(a.x * b.x, e) + pow(a.y * b.y, e) + pow(a.z * b.z, e);
}

float powDot(vec2 a, vec2 b, float e) {
	return pow(a.x * b.x, e) + pow(a.y * b.y, e);
}

vec3 smoothMin(vec3 v1, vec3 v2, float a) {
	float v1Lum = getColorLum(v1);
	float v2Lum = getColorLum(v2);
	return (v1 + v2 - sqrt((v1 - v2) * (v1 - v2) + a * (v1Lum + v2Lum) / 2)) / 2;
}

vec3 smoothMax(vec3 v1, vec3 v2, float a) {
	float v1Lum = getColorLum(v1);
	float v2Lum = getColorLum(v2);
	return (v1 + v2 + sqrt((v1 - v2) * (v1 - v2) + a * (v1Lum + v2Lum) / 2)) / 2;
}

vec3 smoothClamp(vec3 v, vec3 minV, vec3 maxV, float a) {
	return smoothMax(smoothMin(v, maxV, a), minV, a);
}

float cosineInterpolate(float edge1, float edge2, float value) {
   float value2 = (1.0 - cos(value * PI)) / 2.0;
   return(edge1 * (1.0 - value2) + edge2 * value2);
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

vec2 setVecMaxLen(vec2 vec, float maxLen) {
	float len = length(vec);
	return vec / len * min(len, maxLen);
}

float getDepth(vec2 coords) {
	return 2.0 * near / (far + near - (2.0 * texture2D(depthtex0, coords).x - 1.0) * (far - near));
}

float toLinearDepth(float depth) {
    return 2.0 * near / (far + near - depth * (far - near));
}

float fromLinearDepth(float depth) {
	return (2.0 * near / depth - far - near) / (near - far);
}

float toBlockDepth(float depth) {
	depth = toLinearDepth(depth);
	depth = depth * (far - near) + near;
	return depth;
}

bool depthIsSky(float depth) {
	return depth > 0.99;
}



#ifdef FSH
	uint rngStart =
		uint(gl_FragCoord.x) +
		uint(gl_FragCoord.y) * uint(viewWidth) +
		uint(frameCounter  ) * uint(viewWidth) * uint(viewHeight);
#endif

uint rotateRight(uint value, uint shift) {
    return (value >> shift) | (value << (32u - shift));
}

#ifdef USE_FAST_RAND
	float randomFloat(inout uint rng) {
		rng = rng * 747796405u + 2891336453u;
		rng ^= rotateRight(rng, 11u);
		rng ^= rotateRight(rng, 17u);
		rng ^= rotateRight(rng, 23u);
		float f = float(rng % 1000000u);
		return f / 500000.0 - 1.0;
	}
#else
	// taken from: https://www.reedbeta.com/blog/hash-functions-for-gpu-rendering/
	float randomFloat(inout uint rng) {
		rng = rng * 747796405u + 2891336453u;
		uint v = ((rng >> ((rng >> 28u) + 4u)) ^ rng) * 277803737u;
		v = (v >> 22u) ^ v;
		float f = float(v % 1000000u);
		return f / 500000.0 - 1.0;
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
#endif

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



float getCachedValue(int index) {
	return texelFetch(PER_FRAME_VALUES_BUFFER, ivec2(index, 0), 0).r;
}

vec4 getCachedSkylightPercents() {
	float sunlightPercent = getCachedValue(CACHED_SUNLIGHT_PERCENT);
	float moonlightPercent = getCachedValue(CACHED_MOONLIGHT_PERCENT);
	float sunrisePercent = getCachedValue(CACHED_SUNRISE_PERCENT);
	float sunsetPercent = getCachedValue(CACHED_SUNSET_PERCENT);
	return vec4(sunlightPercent, moonlightPercent, sunrisePercent, sunsetPercent);
}

vec3 getCachedSkyColor() {
	float skyRed = getCachedValue(CACHED_SKY_RED);
	float skyGreen = getCachedValue(CACHED_SKY_GREEN);
	float skyBlue = getCachedValue(CACHED_SKY_BLUE);
	return vec3(skyRed, skyGreen, skyBlue);
}

vec3 getCachedAmbientColor() {
	float ambientRed = getCachedValue(CACHED_AMBIENT_RED);
	float ambientGreen = getCachedValue(CACHED_AMBIENT_GREEN);
	float ambientBlue = getCachedValue(CACHED_AMBIENT_BLUE);
	return vec3(ambientRed, ambientGreen, ambientBlue);
}

vec4 getCachedSunraysData() {
	float sunraysRed = getCachedValue(CACHED_SUNRAYS_RED);
	float sunraysGreen = getCachedValue(CACHED_SUNRAYS_GREEN);
	float sunraysBlue = getCachedValue(CACHED_SUNRAYS_BLUE);
	float sunraysAmount = getCachedValue(CACHED_SUNRAYS_AMOUNT);
	return vec4(sunraysRed, sunraysGreen, sunraysBlue, sunraysAmount);
}





float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}



vec3 getShadowPos(vec4 viewPos, float lightDot) {
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos.xy);
	shadowPos = distort(shadowPos, distortFactor); //apply shadow distortion
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= SHADOW_BIAS * (distortFactor * distortFactor) / abs(lightDot); //apply shadow bias
	return shadowPos;
}
