#version 130

#define SHADER_WEATHER
#define NETHER
#define FSH

#include "/settings.glsl"
#include "/common.glsl"



#define FIRST_PASS
#define ARGS_IN , false
#define ARGS_OUT , bool dummy
#define ARG_IN false
#define ARG_OUT bool dummy
#define main dummy_main
#include "/main_files/gbuffers_weather.glsl"
#undef main
#undef FIRST_PASS

#include "/import/switchboard.glsl"

#define SECOND_PASS
#define ARGS_IN
#define ARGS_OUT
#define ARG_IN
#define ARG_OUT
#include "/main_files/gbuffers_weather.glsl"
