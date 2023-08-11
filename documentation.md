# Shader Base Documentation

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
- **colortex3:  Noisy Additions (things like bloom, sunrays, etc (anything that gives noisy results) are rendered to this buffer then LOD-sampled when added to the image)**

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
