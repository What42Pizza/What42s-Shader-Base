# W42SB Documentation

## Warning: Documentation might be out of date!

<br>

### If you want vanilla Minecraft's shader files directly ported to Optifine, you can find it [Here](https://github.com/XorDev/XorDevs-Default-Shaderpack)

<br>
<br>
<br>
<br>
<br>

# Differences from other shaders (ESSENTIAL KNOWLEDGE)

<br>

## Uniforms System:

This shader uses a complex preprocessor system to define which uniforms are included. You only need to know how to use it, but it's also pretty interesting how it works.

### Usage:

- For every place that a uniform is used, there needs to be a #include statement with this format: `#include "/import/{uniform name}.glsl"`
- Every function definition needs to have `ARGS_OUT` at the end of multiple argument, or `ARG_OUT` if there are no other arguments (unless the function is in a `#ifdef FIRST_PASS` block)
- Every function call needs to have `ARGS_IN` at the end of multiple argument, or `ARG_IN` if there are no other arguments (unless the function definition is in a `#ifdef FIRST_PASS` block)
- Every `varying`, `flat`, `const`, etc. needs to be defined in a `#ifdef FIRST_PASS` block

### How it works:

Here's the basic idea: Include the main file once to test which uniforms are needed, use a 'switchboard' file to include the needed uniforms, then include the main file again for actual use.

You can just look at the files in /world0, but here's a quick explanation of the system and its quirks:

- 1: Definitions are set for 'FIRST_PASS', arguments, and 'main'
- 2: The /main file is included
- 3: The /main file sets #define-s for every uniform that is needed
- 4: 'FIRST_PASS' and 'main are un-defined
- 5: 'switchboard.glsl' is included, which uses `#if` statements to include the needed uniforms
- 6: Definitions are set for 'SECOND_PASS' and arguments
- 7: The /main file in included

Hopefully with a bit of thinking, it's very clear why the defines are needed: you can only have one definition for each function, value, and so on. It's pretty easy to put variables in a #if block, but that doesn't work with the functions since those need to have the `#include "/import/..."` statements. The only way for this to work is for functions to have a different signature, and as far as I know, using argument defines is the only way to do so (other than literally typing out two definitions w/ #if & #else). Also, main() functions cannot have arguments, which is why the 'main' define is needed. This took an INSANE amount of effort to develop and implement, but there's definitely a chance that it helps performance.

<br>
<br>
<br>

## Settings:

In the settings menu, you can define which base style you use than override any settings that you want to change. This requires some kinda complex and really tedious code (for example, en_US.lang is over 1100 lines long), but I think it's worth it.

### Basics:

In "/shaders", you'll find "settings.glsl", "shaders.properties", "style_vanilla.glsl", "style_realistic.glsl", and so on. The "settings.glsl" file holds the initial #define-s, which are the ones modified by user settings. The "shaders.properties" file holds a ton of stuff, look elsewhere for info. The "style_..." files hold the default setting values for that style.

You should be able to figure this out yourself, but I'll still give some quick overviews

### How it works:

- 1: "/world" files #include settings.glsl
- 2: settings.glsl defines values are either -1 or the user-selected value
- 3: settings.glsl #include-s the specified style file
- 4: for each setting, the style file replaces every setting still to -1 with the style's default

### If you want to change a default setting value:

- 1: Go to each related style file
- 2: Find the setting and replace its #define

### If you want to add a setting:

- 1: Add the setting to settings.glsl, with it being -1 by default, and specify the allowed values
- 2: For every style file, copy-paste an existing setting's code, and replace the copied setting name and value with the new name and value
- 3: Add the setting to shaders.properties ('screen._=' and (optional) 'sliders=')
- 4: Add the setting to lang file(s)

### If you want to add a style: (removing is similar)

- 1: Copy-paste an existing style
- 2: Replace any values you want
- 3: Update allowed values for 'STYLE' setting (in settings.glsl)
- 4: Update "// style overrides" section (in settings.glsl)

### Important Notes:

- "On/Off" values are defined to be either -1 (use style's value), 0 (off), or 1 (on)

<br>
<br>
<br>
<br>
<br>

## File Structure:

### /main_files: &nbsp; Main shader code
### /lib: &nbsp; Basic code used by multiple files
### /world_: &nbsp; The files that are actually loaded by OptiFine / Iris. These files just use `#include` to copy-paste other files into them
### /import: &nbsp; See 'Uniforms System' above
### /utils: &nbsp; Holds common functions that use uniforms (see 'Uniforms System' above for why)
### /lang: &nbsp; Shown names of setting options and setting values
### settings.glsl: &nbsp; Holds every setting's GLSL name and allowed values, plus some other misc setting data
### common.glsl: &nbsp; Holds most commonly used code and macros for easier programming
### shaders.properties: &nbsp; Defines the settings menu and other details about the shader internals
### blocks.properties: &nbsp; Defines what different blocks are mapped to. The shaders retrieve these value from `mc_Entity.x`

<br>

## Shading Effect Locations:

- **Shadows:**
- - Rendering:  /main_files/shadow.glsl
- - Usage:  lib/lighting.glsl
- **Reflections**
- - Water Reflections:  /main_files/water.glsl
- **Colorblindness Correction**
- - Main Processing:  /main_files/composite5.glsl
- **Anti-Aliasing:**
- - Main Processing:  /main_files/composite4.glsl
- - TAA Jitter:  /lib/taa_jitter.glsl,  (almost) every VSH shader ('taaOffset' is added to 'gl_Position.xy')
- **Isometric Rendering**
- - Main Processing:  /main_files
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
- **colortex3:  Reflection Strength / Noisy Additions (RS exists from gbuffers to deferred, NA exists from composite1 and on)**
- **colortex4:  Normals**
- **colortex5 / gaux2:  Copy of colortex0, only used for water reflections**

Note: 'noisy additions' buffer is where things like bloom, sunrays, etc (anything that gives noisy results) are rendered before being added to the main image using LOD-sampling as a high-perf blur

<br>
<br>
<br>

## How to add / improve an effect:

- **1: Accept that what you have is kinda trash**
- **2: Try something different (whether or not it seems like a good idea)**
- **3: Probably go back to step 1**
- **4: Mess around with the formulas to simplify and optimize without compromising quality**
- **5: Figure out what to do next**

<br>
<br>
<br>

### Rust-Utils:

You may have noticed the 'rust-utils' folder, and that contains a program that automates some simple but tedious tasks. It's not necessary for developing this shader, but you might end up wanting to use it. There's a separate readme in the rust-utils folder that can get you started. You can also edit the rust code yourself to add more features if you want

<br>
<br>
<br>

## Extras:

- **[Noise Functions](https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83)**
- **[Permission to use Complementary's code](https://discord.com/channels/744189556768636941/744189557913681972/1135737539412643880) (TAA and transform functions)**
