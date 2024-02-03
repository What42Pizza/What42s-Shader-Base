<br>

- b1.10.1 (24/02/02)
  - Added settings: Sun Brightness and Moon Brightness
  - Further tweaked styles
  - Settings changes:
  - - New 'BLOOM_AMOUNT' is: old 'BLOOM_AMOUNT' * 0.85

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
