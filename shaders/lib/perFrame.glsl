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
	vec3 skyColor = getSkyColor(skylightPercents);
	vec3 sunraysColor = mix(skyColor, vec3(getColorLum(skyColor)), -SUNRAYS_SATURATION);
	float sunraysAmount =
		skylightPercents.x * SUNRAYS_AMOUNT_DAY +
		skylightPercents.y * SUNRAYS_AMOUNT_NIGHT +
		skylightPercents.z * SUNRAYS_AMOUNT_SUNRISE +
		skylightPercents.w * SUNRAYS_AMOUNT_SUNSET;
	return vec4(sunraysColor, sunraysAmount);
}
