const float[4] wavingScales = float[4] (0.0, WAVING_AMOUNT_1, WAVING_AMOUNT_2, WAVING_AMOUNT_3);



vec3 getWavingAddition(vec3 position) {
	vec3 worldPos = position + cameraPosition;
	float timePos = frameTimeCounter + dot(worldPos, vec3(1.0, 0.1, 0.3)) * WAVING_WORLD_SCALE;
	timePos *= WAVING_SPEED * 1.75;
	uint timePos1 = uint(floor(timePos));
	uint timePos2 = timePos1 + 1u;
	uint timePos3 = timePos1 + 2u;
	uint timePos4 = timePos1 + 3u;
	vec3 pos1 = randomVec3(timePos1) * 0.08;
	vec3 pos2 = randomVec3(timePos2) * 0.08;
	vec3 pos3 = randomVec3(timePos3) * 0.08;
	vec3 pos4 = randomVec3(timePos4) * 0.08;
	return cubicInterpolate(pos1, pos2, pos3, pos4, mod(timePos, 1.0)) * vec3(1.0, 0.2, 1.0);
}



void applyWaving(inout vec3 position) {
	int rawWavingData = int(mc_Entity.x);
	if (rawWavingData < 1000) {return;}
	int wavingData = rawWavingData % 1000;
	if (wavingData < 2 || wavingData > 7) {return;}
	float wavingScale = wavingScales[wavingData / 2];
	if (wavingData % 2 == 0 && gl_MultiTexCoord0.t > mc_midTexCoord.t) {return;} // don't apply waving to base
	wavingScale *= lmcoord.y * lmcoord.y;
	wavingScale *= 1.0 + betterRainStrength * (WAVING_AMOUNT_RAIN_MULT - 1.0);
	position += getWavingAddition(position) * wavingScale;
}
