float getFogDistance(vec3 playerPos  ARGS_OUT) {
	
	playerPos.y /= FOG_HEIGHT_SCALE;
	float fogDistance = length(playerPos);
	
	#ifdef SHADER_GBUFFERS_CLOUDS
		fogDistance /= FOG_EXTRA_CLOUDS_DISTANCE;
	#endif
	
	return fogDistance;
}
