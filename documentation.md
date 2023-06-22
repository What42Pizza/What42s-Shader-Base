# Shader Base Documentation

<br>

## File Structure:

- **/main_files:  Main code for VSH and FSH files**
- **incl:  Basic code used by multiple files**
- - incl/settings.glsl:  Holds every value that can easily change the look of the shader, and holds the values that each option can be set to in the options menu
- - incl/common.glsl:  Holds every commonly used code and every uniform that is used
- **world_:  Basically glue code that pulls in incl/settings.glsl, incl/common.glsl, and the associated /main_files/___.glsl**
- **lang:  Shown names of setting options and setting values**
- **shaders.properties:  Defines the settings menu and other details about the shader internals**

<br>

## Shading Effect Locations:

- **Shadows:**
- - Rendering:  /main_files/shadow.glsl
- - Usage:  incl/lighting.glsl
- **Anti-Aliasing:**
- - Main Processing:  /main_files/composite4.glsl
- - TAA Jitter:  (almost) every VSH section ('taaOffset' is added to 'gl_Position')
- **Sharpening:**
- - Main Processing:  /main_files/composite5.glsl
- **Lighting:**
- - Main Processing:  incl/lighting.glsl
- - Usage:  /main_files/gbuffers_entities.glsl, /main_files/gbuffers_hand.glsl, /main_files/gbuffers_terrain.glsl
- - Per-Frame Calculations:  shaders.properties (for uniform.float.sunlightPercent)
- **Tonemapping:**
- - Main Processing:  /main_files/composite.glsl
- **Bloom:**
- - Main Processing:  /main_files/composite2.glsl
- - Pre-Processing:  /main_files/composite1.glsl
- **Sunrays:**
- - Main processing:  /main_files/composite3.glsl
- **Fog:**
- - Main Processing:  /main_files/composite.glsl
- - Exlusions:  /main_files/gbuffers_clouds.glsl

<br>

## Buffers:

- **texture / colortex0:  Main Image** 
- **colortex1:  TAA Texture**
- **colortex2:  Bloom Texture**
- **colortex3:  Clouds (used to extend fog distance for clouds)**
- **colortex4:  Sky Color (used for fog)**
- **colortex5:  Sky Color for Bloom (used for fog)**
- **colortex6:  Per-frame calculations**

<br>

## ColorTex6:

This is the buffer where things like sunlight percents are calculated. The prepare.glsl file calculates the values once and saves them to colortex6 so that the can be retrived with little performance cost (at least, in theory). This is an alternative to computing values per-frame using uniform definitions in shaders.properties, and doing it this way allows you to use already existing functions you've made. If you wanted to, you could add `const bool colortex6Clear = false;`, which would allow you to also use this buffer to store values across frames. Indicies for each value can be found in common.glsl

NOTE: I haven't seen any noticable performance increase from doing this, so it might all just be a waste of time

<br>
<br>
<br>

## How to add / improve an effect:

- **1: Accept that what you have is kinda trash**
- **2: Try something different (whether or not it seems like a good idea)**
- **3: Probably go back to step 1**
- **4: Mess around with the formulas to simplify and optimize without compromising quality**
