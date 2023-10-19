# W42SB Documentation

## Warning: Documentaion might be out of date!

<br>

## File Structure:

### /main_files: &nbsp; Main shader code
### /lib: &nbsp; Basic code used by multiple files
### /world_*: &nbsp; The files that are actaully loaded by OptiFine / Iris. These files just use `#include` to copy-paste other files into them
### /lang: &nbsp; Shown names of setting options and setting values
### settings.glsl: &nbsp; Holds every value that can easily change the look of the shader, along with the allowed values for each option**
### common.glsl: &nbsp; Holds all commonly used code, every uniform that is used, and macros for easier programming
### shaders.properties: &nbsp; Defines the settings menu and other details about the shader internals
### blocks.properties: &nbsp; Defines what different blocks are mapped to. The shaders retrieve these value from `mc_Entity.x`

<br>

## Shading Effect Locations:

- **Shadows:**
- - Rendering:  /main_files/shadow.glsl
- - Usage:  lib/lighting.glsl
- **Reflections**
- - Water Reflections:  /main_files/water.glsl
- **Anti-Aliasing:**
- - Main Processing:  /main_files/composite4.glsl
- - TAA Jitter:  /lib/taa_jitter.glsl,  (almost) every VSH shader ('taaOffset' is added to 'gl_Position.xy')
- **SSAO**
- - Main Processing: /main_files/composite.glsl
- **Sunrays:**
- - Main processing:  /main_files/composite1.glsl
- - Application:  /main_files/composite2.glsl (works the same as bloom application)
- **Bloom:**
- - Main Processing:  /main_files/composite1.glsl
- - Pre-Processing:  /main_files/composite.glsl
- - Application:  /main_files/composite2.glsl (calculations are written to a mip-mapped buffer that is sampled with blur so that the noise is reduced)
- **Depth of Field**
- - Main Processing:  /main_files/composite3.glsl
- **Motion Blur**
- - Main Processing:  /main_files/composite4.glsl
- **Sharpening:**
- - Main Processing:  /main_files/composite5.glsl
- **Waving Blocks**
- - Main Processing:  /main_files/terrain.glsl,  /main_files.shadow.glsl
- **Fog:**
- - Main Processing:  /main_files/terrain.glsl,  /main_files/entities.glsl,  /main_files/clouds.glsl
- **Handheld Light**
- - Main Processing:  /lib/lighting.glsl
- **Underwater Waviness**
- - Main Processing:  /main_files/composite5.glsl
- **Vignette:**
- - Main Processing:  /main_files/composite5.glsl
- **Tonemapping:**
- - Main Processing:  /main_files/composite5.glsl
- **Lighting:**
- - Main Processing:  lib/lighting.glsl
- - Usage:  /main_files/terrain.glsl,  /main_files/textured.glsl,  /main_files/entities.glsl,  /main_files/hand.glsl

<br>

## Buffers:

- **texture / colortex0:  Main Image OR Debug Output** 
- **colortex1:  TAA Texture**
- **colortex2:  Bloom Texture**
- **colortex3:  Reflection Strength / Noisy Additions (RS exists from gbuffers to deffered, NA exists from composite1 and on)**
- **colortex4:  Normals**
- **colortex5 / gaux2:  Copy of colortex0, only used for water reflections**

Note: 'noisy additions' buffer is where things like bloom, sunrays, etc (anything that gives noisy results) are rendered before being added to the main image using LOD-sampling as a high-perf blur

<br>

## Uniforms System:

This shader uses a complex preprocessor system to define which uniforms are included. You only need to know how it is used, but it's also interesting how it works.

### Usage:

- For evey place that a uniform is used, there needs to be a #include statement with this format: `#include "/import/{uniform name}.glsl"`
- Every function definition needs to have `ARGS_OUT` at the end of multiple argument, or `ARG_OUT` if there are no other arguments (unless the function is in a `#ifdef FIRST_PASS` block)
- Every function call needs to have `ARGS_IN` at the end of multiple argument, or `ARG_IN` if there are no other arguments (unless the function definition is in a `#ifdef FIRST_PASS` block)
- Every `varying`, `flat`, `const`, etc. needs to be defined in a `#ifdef FIRST_PASS` block

### How it works:

Here's the basic idea: Include the main file once to test which uniforms are needed, use a 'switchboard' file to include the needed uniforms, then include the main file again for actual use.

You can just look at the files in /world0, but here's a quick explaination of the system and its quirks:

- 1: Definitions are set for 'FIRST_PASS', arguments, and 'main'
- 2: The /main file is included
- 3: The /main file sets #define-s for every uniform that is needed
- 4: 'FIRST_PASS' and 'main are un-defined
- 5: 'switchboard.glsl' is included, which uses `#if` statements to include the needed uniforms
- 6: Definitions are set for 'SECOND_PASS' and arguments
- 7: The /main file in included

Hopefully with a bit of thinking, it's very clear why the defines are needed: you can only have one definition for each function, value, and so on. It's pretty easy to put variables in a #if block, but that doesn't work with the funcitons since those need to have the `#include "/import/..."` statements. The only way for this to work is for functions to have a different signature, and as far as I know, using argument defines is the only way to do so (other than literally typing out two definitions w/ #if & #else). Also, main() functions cannot have arguments, which is why the 'main' define is needed. This took an INSANE amount of effort to devolop and implement, but there's definitely a chance that it helps performance.

<br>
<br>
<br>

## How to add / improve an effect:

- **1: Accept that what you have is kinda trash**
- **2: Try something different (whether or not it seems like a good idea)**
- **3: Probably go back to step 1**
- **4: Mess around with the formulas to simplify and optimize without compromising quality**

<br>
<br>
<br>

## Extras:

- **[Noise Functions](https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83)**
- **[Permission to use Complementary's code](https://discord.com/channels/744189556768636941/744189557913681972/1135737539412643880) (TAA and transform functions)**
