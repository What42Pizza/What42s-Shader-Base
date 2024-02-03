#include "/utils/depth.glsl"



vec3 sampleBloom(float sizeMult, inout uint rng  ARGS_OUT) {
	
	#include "/import/invAspectRatio.glsl"
	float random = randomFloat(rng) * 100000.0;
	mat2 rotationMatrix;
	rotationMatrix[0] = vec2(cos(random) * invAspectRatio, -sin(random) * invAspectRatio);
	rotationMatrix[1] = vec2(sin(random), cos(random));
	
	// these values were generated with https://github.com/What42Pizza/Small-Rust-Programs/tree/master/point-distribution
	vec3 bloomAddition = vec3(0.0);
	#if BLOOM_QUALITY == 2
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.069,  0.072)) * sizeMult).rgb * 0.992;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.161, -0.119)) * sizeMult).rgb * 0.967;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.212,  0.212)) * sizeMult).rgb * 0.926;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.261, -0.303)) * sizeMult).rgb * 0.873;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.497, -0.058)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.027, -0.599)) * sizeMult).rgb * 0.736;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.460,  0.528)) * sizeMult).rgb * 0.659;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.702, -0.384)) * sizeMult).rgb * 0.580;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.215,  0.874)) * sizeMult).rgb * 0.502;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.917,  0.400)) * sizeMult).rgb * 0.427;
		bloomAddition /= 7.472;
	#elif BLOOM_QUALITY == 3
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.029,  0.040)) * sizeMult).rgb * 0.998;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.094, -0.034)) * sizeMult).rgb * 0.992;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.100, -0.112)) * sizeMult).rgb * 0.981;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.101,  0.173)) * sizeMult).rgb * 0.967;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.248,  0.033)) * sizeMult).rgb * 0.948;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.028, -0.299)) * sizeMult).rgb * 0.926;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.189,  0.295)) * sizeMult).rgb * 0.901;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.353, -0.188)) * sizeMult).rgb * 0.873;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.417,  0.170)) * sizeMult).rgb * 0.842;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.159,  0.474)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.439, -0.331)) * sizeMult).rgb * 0.773;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.593, -0.091)) * sizeMult).rgb * 0.736;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.264, -0.594)) * sizeMult).rgb * 0.698;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.169, -0.679)) * sizeMult).rgb * 0.659;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.672,  0.333)) * sizeMult).rgb * 0.620;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.315,  0.736)) * sizeMult).rgb * 0.580;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.668, -0.526)) * sizeMult).rgb * 0.541;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.900,  0.010)) * sizeMult).rgb * 0.502;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.729,  0.609)) * sizeMult).rgb * 0.464;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.233,  0.972)) * sizeMult).rgb * 0.427;
		bloomAddition /= 15.239;
	#elif BLOOM_QUALITY == 4
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.003, -0.025)) * sizeMult).rgb * 0.999;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.046,  0.019)) * sizeMult).rgb * 0.998;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.002,  0.075)) * sizeMult).rgb * 0.995;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.099,  0.010)) * sizeMult).rgb * 0.992;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.080, -0.096)) * sizeMult).rgb * 0.987;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.143, -0.047)) * sizeMult).rgb * 0.981;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.032, -0.172)) * sizeMult).rgb * 0.974;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.142,  0.141)) * sizeMult).rgb * 0.967;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.190,  0.120)) * sizeMult).rgb * 0.958;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.045,  0.246)) * sizeMult).rgb * 0.948;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.253, -0.109)) * sizeMult).rgb * 0.938;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.132, -0.269)) * sizeMult).rgb * 0.926;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.189, -0.264)) * sizeMult).rgb * 0.914;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.342,  0.076)) * sizeMult).rgb * 0.901;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.180,  0.329)) * sizeMult).rgb * 0.887;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.344, -0.204)) * sizeMult).rgb * 0.873;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.425, -0.007)) * sizeMult).rgb * 0.858;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.115, -0.435)) * sizeMult).rgb * 0.842;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.425,  0.212)) * sizeMult).rgb * 0.825;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.285,  0.411)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.152, -0.502)) * sizeMult).rgb * 0.791;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.063,  0.546)) * sizeMult).rgb * 0.773;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.421, -0.392)) * sizeMult).rgb * 0.755;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.462,  0.383)) * sizeMult).rgb * 0.736;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.212,  0.588)) * sizeMult).rgb * 0.717;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.629, -0.163)) * sizeMult).rgb * 0.698;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.657,  0.155)) * sizeMult).rgb * 0.679;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.544, -0.441)) * sizeMult).rgb * 0.659;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.699, -0.194)) * sizeMult).rgb * 0.640;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.348, -0.664)) * sizeMult).rgb * 0.620;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.018, -0.775)) * sizeMult).rgb * 0.600;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.787,  0.143)) * sizeMult).rgb * 0.580;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.646,  0.513)) * sizeMult).rgb * 0.561;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.383, -0.759)) * sizeMult).rgb * 0.541;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2(-0.347,  0.803)) * sizeMult).rgb * 0.522;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.747, -0.501)) * sizeMult).rgb * 0.502;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.525,  0.762)) * sizeMult).rgb * 0.483;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.077,  0.947)) * sizeMult).rgb * 0.464;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.974, -0.054)) * sizeMult).rgb * 0.446;
		bloomAddition += texture2D(BLOOM_BUFFER, texcoord + (rotationMatrix * vec2( 0.883,  0.470)) * sizeMult).rgb * 0.427;
		bloomAddition /= 30.769;
	#endif
	
	#ifdef END
		bloomAddition *= 0.3;
	#endif
	
	return bloomAddition * 0.17;
}



vec3 getBloomAddition(inout uint rng, float depth  ARGS_OUT) {
	
	float blockDepth = toBlockDepth(depth  ARGS_IN);
	float sizeMult = inversesqrt(blockDepth) * BLOOM_SIZE * 0.15;
	
	vec3 bloomAddition = vec3(0.0);
	for (int i = 0; i < BLOOM_COMPUTE_COUNT; i++) {
		bloomAddition += sampleBloom(sizeMult, rng  ARGS_IN);
	}
	bloomAddition *= (1.0 / BLOOM_COMPUTE_COUNT) * BLOOM_AMOUNT;
	
	#ifdef NETHER
		bloomAddition *= BLOOM_NETHER_MULT;
	#endif
	
	return bloomAddition;
}
