const float[4] wavingScales = float[4] (0.0, WAVING_AMOUNT_1, WAVING_AMOUNT_2, WAVING_AMOUNT_3);
const vec3 windDirection = vec3(1.0, 0.1, 0.3); // another way to think of it: weights for timePos influence



vec3 getWavingAddition(vec3 position) {
	vec3 worldPos = position + cameraPosition;
	float timePos = frameTimeCounter + dot(worldPos, windDirection) * WAVING_WORLD_SCALE;
	timePos *= WAVING_SPEED * 1.75;
	uint timePosFloor = uint(floor(timePos));
	vec3 pos1 = randomVec3FromRValue(timePosFloor);
	vec3 pos2 = randomVec3FromRValue(timePosFloor + 1u);
	vec3 pos3 = randomVec3FromRValue(timePosFloor + 2u);
	vec3 pos4 = randomVec3FromRValue(timePosFloor + 3u);
	return cubicInterpolate(pos1, pos2, pos3, pos4, mod(timePos, 1.0)) * vec3(1.0, 0.2, 1.0) * 0.08;
}



void applyWaving(inout vec3 position) {
	int rawWavingData = int(mc_Entity.x);
	if (rawWavingData < 1000) {return;}
	int wavingData = rawWavingData % 1000;
	if (wavingData < 2 || wavingData > 7) {return;}
	float wavingScale = wavingScales[wavingData / 2];
	if (wavingData % 2 == 0 && gl_MultiTexCoord0.t > mc_midTexCoord.t) {return;} // don't apply waving to base
	#if !defined SHADER_SHADOW
		wavingScale *= lmcoord.y * lmcoord.y;
	#endif
	wavingScale *= 1.0 + betterRainStrength * (WAVING_RAIN_MULT - 1.0);
	wavingScale *= WAVING_NIGHT_MULT + rawSunTotal * (1.0 - WAVING_NIGHT_MULT);
	position += getWavingAddition(position) * wavingScale;
}
