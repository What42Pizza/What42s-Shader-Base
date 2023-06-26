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
uniform vec3 cameraPoition;
uniform vec3 previousCameraPoition;
uniform float rainStrength;
uniform float wetness;
uniform float screenBrightness;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferPreviousModelView;
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
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
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



// DON'T DELETE:
/*
const bool colortex1Clear = false;
const int colortex6Format = R16F;
const int colortex7Format = R8;
const int colortex9Format = RGB16F;
const int colortex10Format = RGB16F;
const bool colortex0MipmapEnabled = true;
const bool colortex8MipmapEnabled = true;
const float wetnessHalflife = 50.0f;
const float drynessHalflife = 50.0f;
const int noiseTextureResolution = 256;
*/



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
//    vec3 shadowPos = playerToShadow(playerPos);
//	return shadowPos;
//    float distb = sqrt(shadowPos.x * shadowPos.x + shadowPos.y * shadowPos.y);
//    float distortFactor = distb * shadowMapBias + (1.0 - shadowMapBias);
//    shadowPos.xy /= distortFactor;
//    shadowPos.z *= 0.2;
//    return shadowPos * 0.5 + 0.5;
//}



//float SampleShadow(vec3 screenPos) {
//	vec3 viewPos = screenToView(screenPos);
//	vec3 playerPos = viewToPlayer(viewPos);
//	vec3 shadowPos = calculateShadowPos(playerPos);
//    float shadow0 = texture2D(shadowtex0, shadowPos.st).x;
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

bool depthIsSky(float depth) {
	return depth > 0.99;
}



///*
// taken from: https://briansharpe.wordpress.com/2011/11/15/a-fast-and-simple-32bit-floating-point-hash-function/
vec4 FAST_32_hash(vec2 gridcell) {
	// gridcell is assumed to be an integer coordinate
	const vec2 OFFSET = vec2(26.0, 161.0);
	const float DOMAIN = 71.0;
	const float SOMELARGEFLOAT = 951.135664;
	vec4 P = vec4(gridcell.xy, gridcell.xy + 1.0);
	P = P - floor(P * (1.0 / DOMAIN)) * DOMAIN;  // truncate the domain
	P += OFFSET.xyxy;                              // offset to interesting part of the noise
	P *= P;                                        // calculate and return the hash
	return fract(P.xzxz * P.yyww * (1.0 / SOMELARGEFLOAT));
}



float noise(int offset) {
	vec4 hash = FAST_32_hash(vec2(offset));
	float average = (hash.x + hash.y + hash.z + hash.w) / 4.0;
	return average * 2.0 - 1.0;
}

vec2 noiseVec2D(vec2 texcoord, int offset) {
	vec4 hash = FAST_32_hash(texcoord * offset * 10000);
	return hash.xy * 2.0 - 1.0;
}

vec3 noiseVec3D(int offset) {
	vec4 hash = FAST_32_hash(vec2(offset));
	return hash.xyz * 2.0 - 1.0;
}
//*/



/*
float noise(int pos) {
	int x = pos % noiseTextureResolution;
	int y = (pos / noiseTextureResolution) % noiseTextureResolution;
	return texelFetch(noisetex, ivec2(x, y), 0).x * 2.0 - 1.0;
}

float noise(vec2 texcoord, int offset) {
	ivec2 coords = ivec2(texcoord * offset * noiseTextureResolution) % noiseTextureResolution;
	return texelFetch(noisetex, coords, 0).x * 2.0 - 1.0;
}

vec2 noiseVec2D(vec2 texcoord, int offset) {
	float x = noise(texcoord, offset);
	float y = noise(texcoord, offset + 1);
	return vec2(x, y);
}

vec3 noiseVec3D(int offset) {
	float x = noise(offset);
	float y = noise(offset + 1000);
	float z = noise(offset + 2000);
	return vec3(x, y, z);
}
*/



float getCachedValue(int index) {
	return texelFetch(colortex6, ivec2(index, 0), 0).r;
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
