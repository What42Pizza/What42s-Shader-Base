//-------------------------------//
//        ACES TONEMAPPER        //
//-------------------------------//

// All of this code is taken from Acerola's shader
// Link: https://github.com/GarrettGunnell/Minecraft-Shaders



const mat3 ACES_INPUT_MATRIX = mat3(
	vec3(0.59719, 0.35458, 0.04823),
	vec3(0.07600, 0.90834, 0.01566),
	vec3(0.02840, 0.13383, 0.83777)
);

const mat3 ACES_OUTPUT_MATRIX = mat3(
	vec3( 1.60475, -0.53108, -0.07367),
	vec3(-0.10208,  1.10813, -0.00605),
	vec3(-0.00327, -0.07276,  1.07602)
);

vec3 matrixMult(mat3 m, vec3 v) {
	float x = m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2];
	float y = m[1][0] * v[1] + m[1][1] * v[1] + m[1][2] * v[2];
	float z = m[2][0] * v[1] + m[2][1] * v[1] + m[2][2] * v[2];
	return vec3(x, y, z);
}

vec3 rttAndOdtFit(vec3 v) {
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (v * 0.983729 + 0.4329510) + 0.238081;
	return a / b;
}

vec3 acesFitted(vec3 v) {
	v = matrixMult(ACES_INPUT_MATRIX, v);
	v = rttAndOdtFit(v);
	return matrixMult(ACES_OUTPUT_MATRIX, v);
}
