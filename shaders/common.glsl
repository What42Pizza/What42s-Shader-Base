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
uniform sampler2D colortex0;
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

varying vec3 testValue;

#define HAND_DEPTH 0.19 // idk what should actually be here



// buffer values:

#define MAIN_BUFFER              colortex0
#define TAA_PREV_BUFFER          colortex1
#define BLOOM_BUFFER             colortex2
#define NOISY_ADDITIONS_BUFFER   colortex5
#define NORMALS_BUFFER           colortex6
#define DEBUG_BUFFER             colortex11

#define DEPTH_BUFFER_ALL                   depthtex0
#define DEPTH_BUFFER_WO_TRANS              depthtex1
#define DEPTH_BUFFER_WO_TRANS_OR_HANDHELD  depthtex2

// DON'T DELETE:
/*
const bool colortex1Clear = false;
const int colortex6Format = RGB16F;
const bool colortex0MipmapEnabled = true;
const bool colortex2MipmapEnabled = true;
const bool colortex5MipmapEnabled = true;
const float wetnessHalflife = 50.0f;
const float drynessHalflife = 50.0f;
const int noiseTextureResolution = 256;
*/





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

// END OF COMPLEMENTARY REIMAGINED'S CODE





// euclidian distance is defined as sqrt(a^2 + b^2 + ...)
// this length function instead does cbrt(a^3 + b^3 + ...)
// this results in smaller distances along the diagonal axes.
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
bool depthIsHand(float depth) {
	return depth < 0.003;
}

vec3 getViewPos(vec2 coords) {
	float depth = texture2D(DEPTH_BUFFER_ALL, coords).r;
	float linearDepth = toLinearDepth(depth);
	if (depthIsSky(linearDepth) || depthIsHand(linearDepth)) {
		return vec3(0.0);
	}
	vec3 screenPos = vec3(coords, depth);
	return screenToView(screenPos);
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

#ifdef USE_BETTER_RAND
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
#else
	float randomFloat(inout uint rng) {
		rng = rng * 747796405u + 2891336453u;
		rng ^= rotateRight(rng, 11u);
		rng ^= rotateRight(rng, 17u);
		rng ^= rotateRight(rng, 23u);
		float f = float(rng % 1000000u);
		return f / 500000.0 - 1.0;
	}
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





#ifdef FSH

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 getSkyColor() {
	vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
	pos = gbufferProjectionInverse * pos;
	float upDot = dot(normalize(pos.xyz), gbufferModelView[1].xyz);
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}

#endif



vec3 getShadowPos(vec4 viewPos, float lightDot) {
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos.xy);
	shadowPos = distort(shadowPos, distortFactor); //apply shadow distortion
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= SHADOW_BIAS * (distortFactor * distortFactor) / abs(lightDot); //apply shadow bias
	return shadowPos;
}





float getSunlightPercent_Sunrise() {
	int time = (worldTime > 12000) ? (worldTime - 24000) : worldTime;
	return clamp(percentThrough(time, SUNRISE_START - 24000, SUNRISE_END), 0.0, 1.0);
}

float getSunlightPercent_Sunset() {
	int time = worldTime;
	return clamp(1 - percentThrough(time, SUNSET_START, SUNSET_END), 0.0, 1.0);
}

// return value channels: (sun, moon, sunrise, sunset)
vec4 getRawSkylightPercents() {
	int sunriseTime = (worldTime > 18000) ? (worldTime - 24000) : worldTime;
	if (sunriseTime >= SUNRISE_START && sunriseTime < SUNRISE_SWITCH) {
		float sunrisePercent = percentThrough(sunriseTime, SUNRISE_START, SUNRISE_SWITCH);
		return vec4(0.0, 1.0 - sunrisePercent, sunrisePercent, 0.0);
	}
	if (sunriseTime >= SUNRISE_SWITCH && sunriseTime < SUNRISE_END) {
		float sunPercent = percentThrough(sunriseTime, SUNRISE_SWITCH, SUNRISE_END);
		return vec4(sunPercent, 0.0, 1.0 - sunPercent, 0.0);
	}
	if (sunriseTime >= SUNRISE_END && worldTime < SUNSET_START) {
		return vec4(1.0, 0.0, 0.0, 0.0);
	}
	if (worldTime >= SUNSET_START && worldTime < SUNSET_SWITCH) {
		float sunsetPercent = percentThrough(worldTime, SUNSET_START, SUNSET_SWITCH);
		return vec4(1.0 - sunsetPercent, 0.0, 0.0, sunsetPercent);
	}
	if (worldTime >= SUNSET_SWITCH && worldTime < SUNSET_END) {
		float moonPercent = percentThrough(worldTime, SUNSET_SWITCH, SUNSET_END);
		return vec4(0.0, moonPercent, 0.0, 1.0 - moonPercent);
	}
	return vec4(0.0, 1.0, 0.0, 0.0);
}

vec4 getSkylightPercents() {
	vec4 skylightPercents = getRawSkylightPercents();
	skylightPercents.xzw *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT);
	return skylightPercents;
}



vec3 getSkyColor(vec4 skylightPercents) {
	return
		skylightPercents.x * SKYLIGHT_DAY_COLOR +
		skylightPercents.y * SKYLIGHT_NIGHT_COLOR +
		skylightPercents.z * SKYLIGHT_SUNRISE_COLOR +
		skylightPercents.w * SKYLIGHT_SUNSET_COLOR;
}

vec3 getAmbientColor(vec4 skylightPercents) {
	return
		skylightPercents.x * AMBIENT_DAY_COLOR +
		skylightPercents.y * AMBIENT_NIGHT_COLOR +
		skylightPercents.z * AMBIENT_SUNRISE_COLOR +
		skylightPercents.w * AMBIENT_SUNSET_COLOR;
}





vec4 getSunraysData() {
	vec4 skylightPercents = getSkylightPercents();
	
	int sunriseTime = (worldTime > 18000) ? (worldTime - 24000) : worldTime;
	bool isDay = sunriseTime >= SUNRISE_START && sunriseTime <= SUNSET_END;
	bool isOtherSource = shadowLightPosition.b > 0.0;
	bool isSun = isDay ^^ isOtherSource;
	
	vec3 sunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
	
	float sunraysAmount =
		skylightPercents.x * SUNRAYS_AMOUNT_DAY +
		skylightPercents.y * SUNRAYS_AMOUNT_NIGHT +
		skylightPercents.z * SUNRAYS_AMOUNT_SUNRISE +
		skylightPercents.w * SUNRAYS_AMOUNT_SUNSET;
	
	if (isOtherSource) {
		if (isSun) {
			sunraysAmount *= sqrt(skylightPercents.x + skylightPercents.z + skylightPercents.w);
		} else {
			sunraysAmount *= sqrt(skylightPercents.y);
		}
	}
	
	return vec4(sunraysColor, sunraysAmount);
}

