#ifdef import_cameraPosition
	uniform vec3 cameraPosition;
#endif
#ifdef import_previousCameraPosition
	uniform vec3 previousCameraPosition;
#endif
#ifdef import_shadowModelView
	uniform mat4 shadowModelView;
#endif
#ifdef import_shadowProjection
	uniform mat4 shadowProjection;
#endif
#ifdef import_sunPosition
	uniform vec3 sunPosition;
#endif
#ifdef import_moonPosition
	uniform vec3 moonPosition;
#endif
#ifdef import_shadowLightPosition
	uniform vec3 shadowLightPosition;
#endif
#ifdef import_fogColor
	uniform vec3 fogColor;
#endif
#ifdef import_skyColor
	uniform vec3 skyColor;
#endif
#ifdef import_entityColor
	uniform vec4 entityColor;
#endif
#ifdef import_viewHeight
	uniform float viewHeight;
#endif
#ifdef import_viewWidth
	uniform float viewWidth;
#endif
#ifdef import_frameCounter
	uniform int frameCounter;
#endif
#ifdef import_frameTimeCounter
	uniform float frameTimeCounter;
#endif
#ifdef import_aspectRatio
	uniform float aspectRatio;
#endif
#ifdef import_frameTime
	uniform float frameTime;
#endif
#ifdef import_near
	uniform float near;
#endif
#ifdef import_far
	uniform float far;
#endif
#ifdef import_worldTime
	uniform int worldTime;
#endif
#ifdef import_eyeBrightness
	uniform ivec2 eyeBrightness;
#endif
#ifdef import_eyeBrightnessSmooth
	uniform ivec2 eyeBrightnessSmooth;
#endif
#ifdef import_eyeAltitude
	uniform float eyeAltitude;
#endif
#ifdef import_isEyeInWater
	uniform int isEyeInWater;
#endif
#ifdef import_upPosition
	uniform vec3 upPosition;
#endif
#ifdef import_heldBlockLightValue
	uniform int heldBlockLightValue;
#endif
#ifdef import_rainStrength
	uniform float rainStrength;
#endif
#ifdef import_wetness
	uniform float wetness;
#endif
#ifdef import_screenBrightness
	uniform float screenBrightness;
#endif
#ifdef import_gbufferModelView
	uniform mat4 gbufferModelView;
#endif
#ifdef import_gbufferModelViewInverse
	uniform mat4 gbufferModelViewInverse;
#endif
#ifdef import_gbufferProjection
	uniform mat4 gbufferProjection;
#endif
#ifdef import_gbufferProjectionInverse
	uniform mat4 gbufferProjectionInverse;
#endif
#ifdef import_gbufferPreviousProjection
	uniform mat4 gbufferPreviousProjection;
#endif
#ifdef import_gbufferPreviousModelView
	uniform mat4 gbufferPreviousModelView;
#endif
#ifdef import_normalMatrix
	uniform mat3 normalMatrix;
#endif
#ifdef import_farPlusNear
	uniform float farPlusNear;
#endif
#ifdef import_farMinusNear
	uniform float farMinusNear;
#endif
#ifdef import_twoTimesNear
	uniform float twoTimesNear;
#endif
#ifdef import_twoTimesNearTimesFar
	uniform float twoTimesNearTimesFar;
#endif
#ifdef import_viewSize
	uniform vec2 viewSize;
#endif
#ifdef import_pixelSize
	uniform vec2 pixelSize;
#endif
#ifdef import_frameMod8
	uniform int frameMod8;
#endif
#ifdef import_velocity
	uniform float velocity;
#endif
#ifdef import_sharpenVelocityFactor
	uniform float sharpenVelocityFactor;
#endif
#ifdef import_betterRainStrength
	uniform float betterRainStrength;
#endif
#ifdef import_horizonAltitudeAddend
	uniform float horizonAltitudeAddend;
#endif
#ifdef import_isDay
	uniform bool isDay;
#endif
#ifdef import_isOtherLightSource
	uniform bool isOtherLightSource;
#endif
#ifdef import_isSun
	uniform bool isSun;
#endif
#ifdef import_centerDepthSmooth
	uniform float centerDepthSmooth;
#endif
#ifdef import_centerLinearDepthSmooth
	uniform float centerLinearDepthSmooth;
#endif
#ifdef import_taaOffset
	uniform vec2 taaOffset;
#endif
#ifdef import_sunriseTime
	uniform float sunriseTime;
#endif
#ifdef import_rawSkylightPercents
	uniform vec4 rawSkylightPercents;
#endif
#ifdef import_rawSunTotal
	uniform float rawSunTotal;
#endif
#ifdef import_invAspectRatio
	uniform float invAspectRatio;
#endif
#ifdef import_invFar
	uniform float invFar;
#endif
#ifdef import_invViewSize
	uniform vec2 invViewSize;
#endif
#ifdef import_invPixelSize
	uniform vec2 invPixelSize;
#endif
#ifdef import_invFrameTime
	uniform float invFrameTime;
#endif
#ifdef import_invFarMinusNear
	uniform float invFarMinusNear;
#endif
#ifdef import_mc_Entity
	attribute vec4 mc_Entity;
#endif
#ifdef import_mc_midTexCoord
	attribute vec4 mc_midTexCoord;
#endif
#ifdef import_shadowModelViewInverse
	uniform mat4 shadowModelViewInverse;
#endif
#ifdef import_shadowProjectionInverse
	uniform mat4 shadowProjectionInverse;
#endif
#ifdef import_blockFlickerAmount
	uniform float blockFlickerAmount;
#endif
