- **1.0.0** (25/02/18)
  - Relaunched as "I Like Vanilla" (previously "What42's Shader Base")
  - Altered, added, and removed MANY settings
  - Major performance improvements from massive internal rewrites

<br>
<br>
<br>

- b1.13.2 (24/12/31)
  - Added Distant Horizons support
  - Slightly improved volumetric sunrays

<br>

- b1.13.1 (24/09/07)
  - Fixed night vision
  - Added settings 'Night Vision Brightness' and 'Night Vision Green Amount'
  - Fixed vanilla brightness slider
  - Fixed name of setting 'End Ambient Brightness'

<br>

- **b1.13.0** (24/08/11)
  - Added settings for volumetric sunrays: 'Increment Amount' and 'Enter Amount'
  - Added settings: 'Nether Ambient Brightness', 'End Ambient Brightness', and Nether Blocklight Brightness Mult'
  - Added settings: 'Sunrays Amount Max Day' and 'Sunrays Amount Max Night' (only for volumetric sunrays)
  - Moved settings: 'Sunrays Amount Sunrise' and 'Sunrays Amount Sunset' are now 'Sunrays Mult Sunrise' and 'Sunrays Mult Sunset'
  - Fixed end sky
  - Improved reflection fading
  - Tweaked styles
  - Improved motion blur
  - Fixed hand jitter
  - Fixed many setting values
  - Maybe fixed phosphor (idk when it broke, it might've worked in b1.12.0)
  - Tweaked sunrays amount calculations

<br>
<br>
<br>

- **b1.12.0** (24/04/20)
  - Added style: Cartoon (made to work with Bare Bones)
  - Added feature: black outlines
  - Added feature: cel shading
  - Added feature: hsv posterization
  - Improved Reflections
  - Swapped FXAA with Complementary's
  - Tweaked existing styles

<br>
<br>
<br>

- b1.11.5 (24/04/05)
  - Added block reflections (included settings: 'Blocks Ref Amount Surface', 'Blocks Ref Amount Underground', and 'Blocks Reflection Fresnel')
  - Fixed rain reflections
  - Disabled shadows for fire
  - Fixed Sharpening-related bugs

<br>

- b1.11.4 (24/03/30)
  - Added setting: Weather Horizontal Amount
  - Added setting: Sunrays Amount Weather Mult
  - Further tweaked Realistic and Fantasy styles
  - Added fog to particles

<br>

- b1.11.3 (24/03/26)
  - Added settings to control water waviness for both surface and underground
  - Added setting: Sunrays Brightness Increase
  - Added setting: Blocklight Flicker Amount
  - Fixed blocklight night brightness
  - Tweaked Realistic and Fantasy styles
  - Settings changes:
  - - New 'GROUND_FOG_STRENGTH' is: old 'GROUND_FOG_STRENGTH' * 0.3
  - - Replaced 'BLOCK_NIGHT_BRIGHTNESS_INCREASE' with 'BLOCK_BRIGHTNESS_NIGHT_MULT'

<br>

- b1.11.2 (24/03/24)
  - Reworked volumetric sunrays (also affects depth sunrays)
  - Added setting Block Night Brightness Increase
  - Added setting Block Brightness Curve (already in code, just forgot to add to menu)
  - Tweaked Fantasy style
  - Fixed auto exposure calculations
  - Settings changes:
  - - Removed 'SUNRAYS_CURVE_SURFACE', alternative is 'SUNRAYS_MIN_SURFACE'
  - - Removed 'SUNRAYS_CURVE_UNDERGROUND', alternative is 'SUNRAYS_MIN_UNDERGROUND'

- b1.11.2a (24/03/25)
  - Reverted depth sunrays

<br>

- b1.11.1 (24/03/12)
  - Added settings: Ground Fog Enabled, Ground Fog Strength, Ground Fog Slope, aGround Fog Offset
  - Added settings: Auto Exposure Enabled, Auto Exposure Bright Mult, Auto Exposure Dark Mult
  - Reworked Fantasy style and tweaked Realistic style
  - Settings changes:
  - - New 'SUNRAYS_AMOUNT' (for depth-based sunrays) is: old 'SUNRAYS_AMOUNT' * 0.625
  - - New 'SHARPENING_AMOUNT' is: old 'SHARPENING_AMOUNT' * 1.25

<br>

- **b1.11.0** (24/02/25)
  - Added setting: Anti-Aliasing Strategy (includes FXAA, TAA, and combinations)
  - Added 'super secret settings' easter egg from 1.8-
  - Added settings: Nether Blocklight [Red, Green, Blue] Mult
  - Many slight tweaks
  - Fixed many debug settings
  - Settings changes:
  - - New 'SUNRAYS_AMOUNT' (for depth-based sunrays) is: old 'SUNRAYS_AMOUNT' * 0.8
  - - Removed setting 'TAA_ENABLED' (replaced with 'AA_STRATEGY')

<br>
<br>
<br>

- b1.10.1 (24/02/23)
  - Added settings: Sun Brightness and Moon Brightness
  - Added settings: Sunrays Curve Surface and Sunrays Curve Underground
  - Further tweaked styles
  - Fixed short_grass not waving
  - Settings changes:
  - - New 'BLOOM_AMOUNT' is: old 'BLOOM_AMOUNT' * 0.85
  - - Fully removed setting 'SUNRAYS_COMPUTE_COUNT' (unused due to code changes)
  - - Fully removed setting 'SUNRAYS_SATURATION' (unused due to code changes)

<br>

- **b1.10.0** (24/01/22)
  - Added setting: Pixelated Shadows
  - Improved bloom performance
  - Fixed bug in shadow filtering
  - Tweaked sunrise / sunset timings (and calculations)
  - Re-tweaked styles
  - Settings changes:
  - - Removed setting 'WATER_REFLECTIONS_ENABLED'
  - - Removed setting 'RAIN_REFLECTIONS_ENABLED'
  - - Added setting 'REFLECTIONS_ENABLED'
  - - Added setting 'BLOOM_NETHER_MULT' (already existed but forgot to add to settings screen)
  - - Removed setting 'BLOOM_SKY_BRIGHTNESS' (unused due to code changes)
  - - Removed setting 'BLOOM_ENTITY_BRIGHTNESS' (unused due to code changes)
  - - Removed setting 'BLOOM_CLOUD_BRIGHTNESS' (unused due to code changes)
  - - Removed setting 'BLOOM_HAND_BRIGHTNESS' (unused due to code changes)
  - - Added setting 'SKY_BRIGHTNESS'
  - - Added setting 'CLOUDS_BRIGHTNESS'

<br>
<br>
<br>

- b1.9.6 (24/01/02)
  - Fixed isometric rendering (now with working shadows!)
  - Fixed langs for setting 'HEIGHT_BASED_WAVING_ENABLED'
  - Settings changes:
  - - New 'SHADOWS_NOISE' is: old 'SHADOWS_NOISE' * 1.25

<br>

- b1.9.5 (23/12/30)
  - Improved shadow filtering performance
  - Added setting: Shadows Noise Amount
  - Settings changes:
  - - Setting 'SHADOW_FILTERING' now only accepts [-1 (use style value), 0 (off (pixelated)), 1 (off (smooth)), 2 (on), 3 (on (legacy version))]

<br>

- b1.9.4 (23/12/27)
  - Fixed setting 'Hide Nearby Clouds'
  - Settings changes:
  - - Removed 'ENTITY_FOG_ENABLED' (unused due to code updates)
  - - Removed 'CORRECTED_LIGHTING_FOG' (unused due to code updates)

<br>

- b1.9.3 (23/12/19)
  - Improved volumetric sunrays quality and performance
  - Transparency settings have been inverted so they represent transparency and not opacity
  - Many small tweaks
  - Updated documentation
  - Settings changes:
  - - New 'WATER_TRANSPARENCY' is: 1.0 - old 'WATER_TRANSPARENCY'
  - - New 'RAIN_TRANSPARENCY' is: 1.0 - old 'RAIN_TRANSPARENCY'
  - - New 'CLOUD_TRANSPARENCY' is: 1.0 - old 'CLOUD_TRANSPARENCY'
  - - Renamed 'RAIN_TRANSPARENCY' to 'WEATHER_TRANSPARENCY'

<br>

- b1.9.2 (23/12/12)
  - Added feature: Volumetric Sunrays
  - Improved Fantasy style
  - Settings changes:
  - - Renamed 'SUNRAYS_ENABLED' to "DEPTH_SUNRAYS_ENABLED'

<br>

- b1.9.1 (23/12/09)
  - Fixed lighting on fog
  - Tweaked Realistic and Fantasy styles
  - Removed (at least some) unused settings
  - Fixed some setting combination crashes

<br>

- **b1.9.0** (23/12/07)
  - Added 'styles' system, allowing you to choose a base style and edit any values on top of it
  - Added styles: Added styles: Realistic and Fantasy (in addition to the default Vanilla style)
  - Fixed some light-value-related bugs
  - Added settings:
  - - Stars Brightness
  - - Darkened Stars Brightness
  - - Water Transparency
  - - Use Corrected Lighting Fog
  - - Apply Fog To Reflections
  - Improved bloom performance
  - Started updating documentation again (finally)
  - Updated License
  - Many small tweaks and fixes

<br>
<br>
<br>

- b1.8.4 (23/12/02)
  - Improved performance (overhauled fog logic)
  - Fixed cave brightness
  - Reworked many fog settings
  - Tweaked rain settings

<br>

- b1.8.3b
  - Added setting: Hide Nearby Clouds
  - Added 'Rain Transparency' setting to settings menu (whoops)
  - Fixed more light-value related bugs
  - Added debug setting: Reflective Everything
  - Created more example images

- b1.8.3 (23/12/01)
  - Fixed many problems related to light value detection (sometimes mods would make the moon be treated as the sun)
  - Added smoothening to rain puddle strength

<br>

- b1.8.2b
  - Improved rain reflection strength
  - Tweaked settings more
  - Created example image

- b1.8.2 (23/11/30)
  - 1.12 compat

<br>

- b1.8.1 (23/11/29)
  - Added feature: height based waviness multiplier
  - Added settings: cloud and rain transparency, and many reflection settings
  - Reworked water reflection amounts
  - Fixed lighting applied to fog with high FOV
  - Tweaked some lighting colors

<br>

- **b1.8.0** (23/11/26)
  - Improved performance (hopefully, might just apply to resolutions > 1080p, and may be nullified by next point)
  - Increased shadowmap resolution from 512 -> 768, and distance from 96 -> 112
  - Improved reflections
  - Reworked lighting values due to slight shading overhaul
  - Removed 'Ultra' profile and added 'Unplayable' profile

<br>
<br>
<br>

- b1.7.5 (23/11/23)
  - Added feature: blocklight flickering
  - Added feature: cloud color changed with sunlight color
  - Added feature: simple colorblindness correction
  - Tweaked water rendering values

<br>

- b1.7.4 (23/11/16)
  - Improved water rendering (reflections & fresnel)
  - Added setting for Shadow Distortion
  - Added feature: decrease star brightness near blocklight

<br>

- b1.7.3 (23/10/18)
  - Further improved ssao
  - Further improved nether bloom
  - Reverted shadow transparency to pre-b1.7.2
  - Added settings for cave ambient color
  - Added settings for underwater waviness

<br>

- b1.7.2 (23/10/07)
  - Added underwater waviness
  - Improved reflections (possibly just going in circles)
  - MANY general improvements

<br>

- b1.7.1 (23/10/03)
  - Massively improved SSAO
  - Massively improved missing reflection rendering
  - Fixed more crashes caused by non-default settings
  - Tweaked settings

<br>

- **b1.7.0** (23/09/28)
  - Reformatted entire shader for slightly better performance (300+ files updated)
  - Added Cave Ambient color settings for consistent underground lighting
  - Improved water waving & fresnel
  - Improved reflections
  - Improved particle lighting
  - Added High and Ultra profiles and improved other profiles
  - Fixed crash caused by non-default settings
  - Fixed special entity colors not appearing (sheep wool color, etc)
  - Significantly improved 'Show Dangerous Light' option
  - Tweaked many settings
  - Fixed settings rgb color ordering (used to be red, blue, green)
  - Fixed waving shadows moving when the camera rotates
  - Fixed sides of grass waving instead of top

<br>
<br>
<br>

- b1.6.5 (23/09/17)
  - Overhauled water rendering
  - Fixed shadow transparency
  - Probably fixed choppy waviness bug

<br>

- b1.6.4.1 (23/09/15)
  - More 1.19 tweaks

- b1.6.4 (23/09/12)
  - Added isometric rendering
  - Improved reflection performance
  - Added more reflection settings
  - Improved shadow filtering when TAA is disabled
  - Tweaks / updates for 1.19

<br>

- b1.6.3 (23/08/30)
  - Updated license

<br>

- b1.6.2 (23/08/29)
  - Added rain reflections
  - Added water fresnel addition
  - Updated license

<br>

- b1.6.1 (23/08/28)
  - Added water reflections to settings
  - Added proper waving water
  - Tweaked water reflection colors

<br>

- **b1.6.0** (23/08/26)
  - Added water reflections (more to come!)
  - Added waving water

<br>
<br>
<br>

- b1.5.2
  - Significantly improved close-up shadows
  - Fixed handheld light for blocks that were too close
  - Many small tweaks to bloom, taa, etc

<br>

- b1.5.1 (23/08/19)
  - Re-added shadow filtering levels
  - Improved handheld light (and removed 'Use Fixed Depth' option)
  - Maybe improved performance

<br>

- **b1.5.0** (23/08/18)
  - Added settings:
  - - 'Use Gamma Correction' (no new functionality, just allows stuff to be disabled)
  - - 'Show Sunlight'
  - - 'Show Brightnesses'
  - Removed settings: (to improve performance)
  - - 'Bloom Curve'
  - - 'Vignette Curve'
  - Improved effects:
  - - Shadow filtering
  - - SSAO
  - - Bloom
  - Improved performance (in multiple ways)
  - Tweaked many settings

<br>
<br>
<br>

- b1.4.4 (23/08/12)
  - Improved DOF
  - Exposed the 'DOF Show Blur Amounts' setting
  - Slight optimizations

<br>

- b1.4.3 (23/08/10)
  - Added profiles
  - Switched to purely-depth-based SSAO
  - Improved performance (mostly through new SSAO)

<br>

- b1.4.2 (23/08/09)
  - Added smoothening to sharpening velocity factor
  - Improved SSAO (probably)
  - Slight optimizations (maybe offset by ssao though)

<br>

- b1.4.1 (23/08/08)
  - Added 'Waving Night Mult' setting
  - Added 'Use Fixed Depth' to reverse new optimization
  - Added vines to waving blocks
  - Tweaked many settings
  - Optimized slightly more
  - Fixed hand color regression

<br>

- **b1.4.0** (23/08/07)
  - Improved sharpening
  - Added more DOF settings
  - Added 'Use Simple Light' setting
  - Added more debug settings
  - Optimized slightly more
  - Kinda actually fixed debug outputs
  - Reformatted changelog

<br>
<br>
<br>

- b1.3.2 (23/08/06)
  - Improved shadow filtering amount
  - Renamed all versions from alpha to beta (retroactively)

<br>

- b1.3.1 (23/08/05)
  - Fixed for Iris 1.19.4
  - Fixed and tuned sunrays color
  - Fixed some option names
  - Reworked lighting code

<br>

- **b1.3.0** (23/08/04)
  - Improved shadow filtering (maybe worse performance)
  - Fixed block outline and leash
  - Made motion blur framerate-independent
  - Slightly improved performance (in other areas)

<br>
<br>
<br>

- **b1.2.0** (23/08/03)
  - Added Motion Blur (disabled by default)
  - Added Depth of Field (disabled by default)
  - Improved lighting calculations
  - Fixed debug outputs

<br>
<br>
<br>

- b1.1.2 (23/08/02)
  - Improved shadow sampling (better and faster!)

<br>

- b1.1.1 (23/08/02)
  - More optimizations

<br>

- **b1.1.0** (23/08/02)
  - Fixed performance regressions (mostly)
  - Fixed ssao appearing over fog
  - Fixed ssao being applied on flat surfaces
  - Improved angled lighting
  - Updated documentation

<br>
<br>
<br>

- **b1.0.0** (23/08/01)
  - Added 1.12 support
  - Improved sunrays
  - Decreased buffers used, hopefully better performance now

<br>
<br>

- **Development started (23/05/19)**
