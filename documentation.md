# I Like Vanilla Documentation

## Warning: Documentation might be out of date!

<br>

### Note: If you want vanilla Minecraft's shader files directly ported to Optifine, you can use [XorDev's Default-Shaderpack](https://github.com/XorDev/XorDevs-Default-Shaderpack)

<br>

## Additional Documentation:

- [Iris' ShaderDoc](https://github.com/IrisShaders/ShaderDoc)
- [OptiFine Shaders (general)](https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt)
- [OptiFine Shaders (.properties)](https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.properties)
- [ShaderLABS](https://wiki.shaderlabs.org/wiki/Main_Page)

<br>
<br>
<br>
<br>
<br>

# Differences from other shaders (ESSENTIAL KNOWLEDGE)

<br>

## Custom Tooling:

Because of the extensive and tedious usage of `#define`s, this repo contains a rust program (named rust-utils) that automates many tasks. Using it isn't necessary for developing this shader, but you'll probably still want to use it. There's a (very simple) readme in the /rust-utils folder which can get you stated.

Here's a list of the commands and why they exist:

- **'export':** This takes the shader code, license, changelog, and shader readme and packages it into (broken?) zip files. It also automatically creates the OptiFine version, where it splices 'style_vanilla.glsl' with 'define_settings.glsl' (plus other fixes) to remove the styles feature, which causes the massive log file and horrendous loading time on OptiFine.
- **'build uniform imports':** This generates all the files in the /shaders/import folder, using the data in 'all_uniforms.txt'. See 'Uniforms System' below for more details on this
- **build world files':** This generates all the files in the /shaders/world_ folders, using data that is hard-coded into src/main.rs. Even if you don't know Rust, you should still be able to edit the values if needed
- **count_sloc:** Counts the significant lines of code. May not be accurate, idk. It only counts .glsl files, since the .vsh and .fsh files don't contain anything meaningful.

As always, you can edit your repo's rust-utils to add more commands and/or tweak existing commands. If you find something you consider a bug, you can contact me and I'll try to fix it

<br>
<br>
<br>

## OptiFine Support:

With the release of b1.9.0, OptiFine is treated as a second-class platform. I'll make sure it still works with OptiFine on 1.12.2, but Iris 1.20.4 is where I currently put most of my effort. The default shader code for Iris does still work on OptiFine without any modification, but the endless list of errors that OptiFine generates makes it almost unusable. The OptiFine version is generated using rust-utils, which can automatically remove the styles functionality.

If you want to develop for OptiFine first, you have 2 options:

- 1: Clone this repo into the shaders folder and deal with the initial loading time
- - Pro: you can work on both versions at once, while having OptiFine be first-class
- - Con: you have to deal with long initial loading times and huge log files
- 2: Replace this repo's /shaders folder with the /shaders folder from the latest OptiFine export
- - Pro: development is greatly simplified
- - Con: you can no longer support multiple styles

<br>
<br>
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

In "/shaders", you'll find "settings.glsl", "define_settings.glsl", "shaders.properties", "style_vanilla.glsl", "style_realistic.glsl", and so on. The "settings.glsl" file generally controls the defining of settings. The "define_settings.glsl" file holds the `#define`s which are modified by user settings. The "shaders.properties" file holds a ton of stuff, look elsewhere for info. The "style_..." files hold the default setting values for that style.

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
### /lib: &nbsp; More complex, standalone code
### /world_: &nbsp; The files that are actually loaded by OptiFine / Iris. These files just use `#include` to copy-paste other files into them
### /import: &nbsp; See 'Uniforms System' above
### /utils: &nbsp; Holds common functions that use uniforms (see 'Uniforms System' above for why)
### /lang: &nbsp; Holds shown names of setting options and setting values
### define_settings.glsl: &nbsp; Holds every setting's GLSL name and allowed values
### settings.glsl: &nbsp; Miscellaneous settings stuff
### common.glsl: &nbsp; Holds commonly used code and macros for easier programming (cannot use uniforms, see 'Uniforms System' above for why)
### shaders.properties: &nbsp; Defines the settings menu plus many other details about the shader internals
### blocks.properties: &nbsp; Defines what different blocks are mapped to. The shaders retrieve these value from `mc_Entity.x`

<br>

## Shading Effect Locations:

This describes which /main_files-s handle different effects

- **Shadows:**
- - Main Processing:  /main_files/deferred.glsl  (via sampleShadow())
- - Rendering:  /main_files/shadow.glsl
- **Reflections**
- - Main Processing:  /main_files/composite.glsl  (via doReflections())
- **Colorblindness Correction**
- - Main Processing:  /main_files/composite5.glsl  (via applyColorblindnessCorrection())
- **TAA:**
- - Main Processing:  /main_files/composite4.glsl  (via doTAA())
- - Jitter:  /main_files/*  (via doTaaJitter())
- **FXAA:**
- - Main Processing:  /main_files/composite4.glsl  (view doFxaa())
- **Isometric Rendering**
- - Main Processing:  /main_files/*  (via projectIsometric())
- **SSAO**
- - Main Processing: /main_files/deferred.glsl  (via getAoFactor())
- **Sunrays:**
- - Main Processing:  /main_files/composite1.glsl  (via getDepthSunraysAmount() and getVolSunraysAmount())
- - Application:  /main_files/composite2.glsl  (calculations are written to a mip-mapped buffer that is sampled with higher lod so that the noise is reduced)
- **Bloom:**
- - Main Processing:  /main_files/composite1.glsl  (via getBloomAddition())
- - Pre-Processing:  /main_files/composite.glsl
- - Application:  /main_files/composite2.glsl  (calculations are written to a mip-mapped buffer that is sampled with higher lod so that the noise is reduced)
- **Depth of Field**
- - Main Processing:  /main_files/composite3.glsl  (via doDOF())
- **Motion Blur**
- - Main Processing:  /main_files/composite4.glsl  (via doMotionBlur())
- **Auto Exposure**
- - Main Processing:  /main_files.composite.glsl
- **Sharpening:**
- - Main Processing:  /main_files/composite4.glsl  (via doSharpening())
- **Waving Blocks**
- - Main Processing:  /main_files/terrain.glsl  (via applyWaving())
- - Main Processing (for shadows):  /main_files/shadow.glsl  (via applyWaving())
- **Fog:**
- - Main Processing:  /main_files/deferred.glsl  (via getFogDistance(), getFogAmount(), and applyFog())
- - Main Processing (transparents):  /main_files/water.glsl  (via getFogDistance(), getFogAmount(), and applyFog())
- - Main Processing (clouds):  /main_files/clouds.glsl  (via getFogDistance(), getFogAmount(), and applyFog())
- **Handheld Light**
- - Main Processing:  /lib/lighting/basic_lighting.glsl
- **Underwater Waviness**
- - Main Processing:  /main_files/composite2.glsl
- **Vignette:**
- - Main Processing:  /main_files/composite5.glsl
- **Color Correction and/or Tonemapping:**
- - Main Processing:  /main_files/composite5.glsl  (via doColorCorrection())
- **Lighting:**
- - Main Processing:  /main_files/terrain.glsl,  /main_files/textured.glsl,  /main_files/water.glsl,  /main_files/entities.glsl,  /main_files/hand.glsl  (via doPreLighting() and getBasicLighting())

<br>

## Buffers:

- **colortex0:  Main Image**
- **colortex1:  Main Image Copy**
- **colortex2:  Opaque Data**
- - x: lmcoord.x & lmcoord.y
- - y: normal x & normal y
- - z: gl_Color brightness (squared 'length' of gl_Color) * 0.25 & material id / 1024.0
- **colortex3:  Transparent Data**
- - x: lmcoord.x & lmcoord.y
- - y: normal x & normal y
- - z: gl_Color brightness (squared 'length' of gl_Color) * 0.25 & material id / 1024.0
- **colortex4:  Prev Texture**
- **colortex5:  Bloom Texture**
- **colortex6:  Noisy Texture**

Note: the 'noisy texture' buffer is where things like bloom, sunrays, etc (anything that gives noisy results) are rendered before being added to the main image using LOD-sampling as a high-perf(?) blur

<br>
<br>
<br>

## Extras:

- **[Noise Functions](https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83)**
- **[Permission to use Complementary's code](https://discord.com/channels/744189556768636941/744189557913681972/1135737539412643880) (TAA and transform functions)**
