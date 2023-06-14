const float[4] wavingScales = float[4] (0.0, WAVING_AMOUNT_1, WAVING_AMOUNT_2, WAVING_AMOUNT_3);



vec3 getWavingAddition(vec3 worldPos) {
	float timePos = frameTimeCounter + dot(worldPos, vec3(1.0, 0.1, 0.3)) * WAVING_WORLD_SCALE;
	int timePos1 = int(floor(timePos));
	int timePos2 = timePos1 + 1;
	int timePos3 = timePos1 + 2;
	int timePos4 = timePos1 + 3;
	vec3 pos1 = noiseVec3D(timePos1) * 0.08;
	vec3 pos2 = noiseVec3D(timePos2) * 0.08;
	vec3 pos3 = noiseVec3D(timePos3) * 0.08;
	vec3 pos4 = noiseVec3D(timePos4) * 0.08;
	return cubicInterpolate(pos1, pos2, pos3, pos4, mod(timePos, 1.0)) * vec3(1.0, 0.1, 1.0);
}



void applyWaving(inout vec3 position) {
	vec3 worldPos = position + cameraPosition;
	int wavingData = int(mc_Entity.x) % 1000;
	if (wavingData < 2 || wavingData > 7) {return;}
	float wavingScale = wavingScales[wavingData / 2];
	if (wavingData % 2 == 0 && gl_MultiTexCoord0.t > mc_midTexCoord.t) {return;} // don't apply waving to base
	wavingScale *= lmcoord.y * lmcoord.y;
	wavingScale *= 1.0 + betterRainStrength * (WAVING_AMOUNT_RAIN_MULT - 1.0);
	position += getWavingAddition(worldPos) * wavingScale;
}
