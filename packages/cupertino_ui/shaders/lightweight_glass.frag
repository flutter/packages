// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Original work — Cross-platform lightweight glass shader (Skia, Web, Impeller).
// Supports standard and premium quality modes with automatic fallback.
// Fully original implementation.

#include <flutter/runtime_effect.glsl>
#include "gles_compat.glsl"

precision highp float;

/*
  Primary rendering path for all platforms (Skia, Web, Impeller).
  Standard quality default + automatic premium quality fallback on non-Impeller.
  -----------------------------------------
*/

// -----------------------------------------------------------------------------
// UNIFORMS
// -----------------------------------------------------------------------------
uniform vec4 uData0; // 0..3  (size.x, size.y, origin.x, origin.y)
uniform vec4 uData1; // 4..7  (glassColor)
uniform vec4 uData2; // 8..11 (thickness, lightDir.x, lightDir.y, lightIntensity)
uniform vec4 uData3; // 12..15 (ambientStrength, saturation, refractiveIndex, chromaticAberration)
uniform vec4 uData4; // 16..19 (cornerRadius, scale.x, scale.y, glowIntensity)
uniform vec4 uData5; // 20..23 (densityFactor, indicatorWeight, specularSharpnessF, backdropLuma)
// cornerRadius < 0 → asymmetric mode; per-corner radii come from uData6.
uniform vec4 uData6; // 24..27 (topLeft, topRight, bottomRight, bottomLeft) — asymmetric only
uniform vec4 uData7; // 28..31 (bgOrigin.x, bgOrigin.y, bgSize.width, bgSize.height)
// 32: uEdgeAbsorption — Beer-Lambert meniscus rim darkening [0..1]. Applied after
// all lighting so it dims the total rim output, matching iOS 26's darker perimeter.
uniform float uEdgeAbsorption;
// 33: uFresnelStrength — scales the grazing-angle Fresnel rim brightening [0..∞].
// Default 1.0 = calibrated iOS 26 baseline. 0.0 = no rim highlight.
uniform float uFresnelStrength;
// 34: uBodyMode — 0.0 = adaptive (default, iOS 26 Glass.regular), 1.0 = clear (iOS 26 Glass.clear).
// In clear mode, luminance normalization is bypassed for direct alpha compositing.
uniform float uBodyMode;

uniform sampler2D uBackground; // The captured background texture
// Slot 22 (uData5.z): specular sharpness level — passed as float 0.0/1.0/2.0, cast to int.
// Flutter's FragmentShader API only supports setFloat — no setInt exists.
// Passing as a float and rounding in GLSL gives an exact integer; the GPU
// compiler still sees literal-constant exponents per if/else branch.
// Slot 23 (uData5.w): backdropLuma — VQ4 content-adaptive strength proxy.
//   Dart passes MediaQuery.platformBrightness: dark=0.15, light=0.85.
//   When LiquidGlassScope is active the app is explicitly light/dark themed;
//   the brightness flag is the correct per-app signal.

// -----------------------------------------------------------------------------
// iOS 26 LIQUID GLASS: AESTHETIC PARAMETERS (ORIGINAL CALIBRATION)
// -----------------------------------------------------------------------------
// These constants were calibrated to match iOS 26's liquid glass aesthetic.
// Modifications will affect the entire visual appearance.

// Shape & Structure
const float kBorderThickness      = 0.5;   // Rim width in logical pixels (iOS 26 hairline)
const float kNormalThreshold      = 0.01;  // Minimum gradient for surface normal calculation

// Dual-Highlight Specular Model (simulates glass depth)
const float kSpecularPowerPrimary = 14.0;
const float kSpecularPowerKick    = 20.0;
const float kKickIntensity        = 0.4;

// Rim & Body Color Balance
const float kRimBaseOpacity       = 0.4;   // Base rim brightness before light modulation
const float kRimSpecularMix       = 0.6;   // How much specular highlights boost rim
const float kRimAlphaBase         = 0.65;  // Base rim opacity (calibrated to Impeller parity)
const float kRimAlphaSpecular     = 0.5;   // Additional opacity from specular highlights
// Light Intensity Response
const float kMinRimVisibility     = 0.35;  // Minimum rim brightness floor
const float kRimIntensityScale    = 0.6;   // Rim sensitivity to light intensity changes

// Thickness Response
const float kThicknessReference   = 10.0;  // Neutral thickness value (no visual modulation)
const float kThicknessRimBoost    = 0.15;  // Rim opacity boost per unit thickness deviation


// -----------------------------------------------------------------------------
// iOS 26 GLASS TINT MODEL (inlined from render.glsl::applyGlassColor)
// -----------------------------------------------------------------------------
// Luminosity-preserving glass tint — matches the Impeller final-render path.
//
// Chromatic glass (blue, amber, green): preserves backdrop luminance while
// shifting hue toward the glass colour.  Prevents the "muddy" darkening that
// a straight alpha-composite produces on saturated colours.
//
// Achromatic glass (white, grey, black): uses a direct alpha-composite so
// white glass actually lifts toward white (a brightness/frost effect).
// Without this, white glass collapses to a luminance-matched grey.
//
// The chroma factor blends smoothly between the two paths — fully branchless.
// glassColor.a = 0 → returns liquidColor unchanged via mix() in both paths.
//
// NOTE: In this shader "liquidColor" = the synthesised glass body (finalColor),
// not a background-texture sample.  The luminance-shift still applies correctly.
// ITU-R BT.709 / IEC 61966-2-1 (sRGB) luminance weights — corrected from BT.601 in 1.4.2.
const vec3 LUMA_WEIGHTS = vec3(0.2126, 0.7152, 0.0722);

vec3 applyGlassColorLW(vec3 liquidColor, vec4 glassColor) {
    float backdropLuminance = dot(liquidColor, LUMA_WEIGHTS);
    float glassLuminance    = dot(glassColor.rgb, LUMA_WEIGHTS);

    // Luminosity-preserving tint: shift chroma toward glass, keep body brightness.
    vec3 tinted = clamp(glassColor.rgb + (backdropLuminance - glassLuminance), 0.0, 1.0);

    // Chroma of the glass colour: 0 = achromatic, 1 = fully saturated.
    // Sharp ramp so anything with meaningful colour uses the luminosity path.
    float chroma = max(max(glassColor.r, glassColor.g), glassColor.b)
                 - min(min(glassColor.r, glassColor.g), glassColor.b);
    float chromaWeight = clamp(chroma * 8.0, 0.0, 1.0);

    vec3 directMix     = mix(liquidColor, glassColor.rgb, glassColor.a); // achromatic: lift toward glass
    vec3 luminosityMix = mix(liquidColor, tinted,         glassColor.a); // chromatic:  hue-shift, brightness held

    return mix(directMix, luminosityMix, chromaWeight);
}

// ── Meniscus rim absorption (Beer-Lambert) ──────────────────────────────────
// Hemisphere lens profile × light-modulated absorption strength.
// Shared by PATH A (normal + fallback) and PATH B; previously inlined 3×.
//
// distFromEdge: unsigned SDF distance from the shape boundary (px)
// zone:         edge influence zone width (px)
// surfNormal:   2D surface normal at this fragment
// lightDir:     normalised light direction
// strength:     absorption coefficient [0..1]
float meniscusAbsorption(
    float distFromEdge, float zone, vec2 surfNormal,
    vec2 lightDir, float strength) {
    // [1] Hemisphere lens profile: r_norm maps edge→interior to 0→1.
    float r_norm = clamp(distFromEdge / zone, 0.0, 1.0);
    float lensTh = sqrt(max(0.0, 1.0 - r_norm * r_norm));
    // [2] Light-modulated strength: weaker on lit side (0.6×), stronger on shadow (1.4×).
    float litness = dot(surfNormal, lightDir);
    float dirScale = mix(1.4, 0.6, litness * 0.5 + 0.5);
    return max(0.0, 1.0 - lensTh * strength * dirScale);
}

out vec4 fragColor;

void main() {
  vec2 uSize = uData0.xy;
  vec2 uOrigin = uData0.zw;
  vec4 uGlassColor = uData1;
  float uThickness = uData2.x;
  vec2 uLightDirection = uData2.yz;
  float uLightIntensity = uData2.w;
  float uAmbientStrength = uData3.x;
  float uSaturation = uData3.y;
  float uRefractiveIndex = uData3.z;
  float uChromaticAberration = uData3.w;
  float uCornerRadius = uData4.x;
  vec2 uScale = uData4.yz;
  float uGlowIntensity = uData4.w;
  float uDensityFactor   = uData5.x;
  float uIndicatorWeight = uData5.y;
  // VQ4 + specular: packed into uData5.z / uData5.w to use correct slot 22/23
  // (uSpecularSharpnessF was previously declared as a separate uniform at slot 24,
  // but Dart only writes 23 floats. Packing into uData5.z fixes the alignment.)
  float uSpecularSharpnessF = uData5.z; // 0=soft, 1=medium, 2=sharp
  float uBackdropLuma       = uData5.w; // VQ4: 0.15=dark platform, 0.85=light platform
  vec2 uBackgroundOrigin    = uData7.xy;
  vec2 uBackgroundSize      = uData7.zw;

  // ---- STAGE 0: COORDINATE SYNC ----
  vec2 pixelCoord = FlutterFragCoord().xy;
  vec2 localLogical = (pixelCoord - uOrigin) / uScale;

  // ---- STAGE 1: SDF SHAPE & COMBINED NORMALS ----
  // OPTIMIZATION: We merge SDF distance calculation with surface normal generation.
  // The vector maxQ generated for the SDF exactly defines the surface gradient!
  vec2 halfSize = uSize * 0.5;
  vec2 p = localLogical - halfSize;

  // Asymmetric mode: uCornerRadius < 0 means per-corner radii are in uData6.
  // Quadrant selection: p.x<0 && p.y<0 → topLeft, p.x≥0 && p.y<0 → topRight,
  //                     p.x≥0 && p.y≥0 → bottomRight, p.x<0 && p.y≥0 → bottomLeft.
  // (Y increases downward in logical coords; top = negative p.y half.)
  float r;
  if (uCornerRadius < 0.0) {
    // Select per-corner radius based on fragment quadrant
    if (p.x < 0.0 && p.y < 0.0) {
      r = uData6.x; // topLeft
    } else if (p.x >= 0.0 && p.y < 0.0) {
      r = uData6.y; // topRight
    } else if (p.x >= 0.0 && p.y >= 0.0) {
      r = uData6.z; // bottomRight
    } else {
      r = uData6.w; // bottomLeft
    }
  } else {
    r = uCornerRadius;
  }

  vec2 q = abs(p) - halfSize + r;
  
  vec2 maxQ = max(q, 0.0);
  float maxQLen = length(maxQ);
  float dist = maxQLen + min(max(q.x, q.y), 0.0) - r;
  float smoothing = 1.0 / uScale.x;
  float mask = 1.0 - smoothstep(-smoothing, smoothing, dist);

  if (mask <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  // ---- STAGE 2: SURFACE NORMALS ----
  // Since gradient is analytically derived from maximum positive divergence,
  // we do not need to re-clamp and calculate vector magnitudes.
  bool isEdge = maxQLen > kNormalThreshold;
  vec2 surfaceNormal = isEdge ? (sign(p) * maxQ / maxQLen) : vec2(0.0);

  // normalZ: the Z component of the 3D surface normal (view-facing component).
  // normalZ → 0 at the rim (surface nearly perpendicular to view ray)
  // normalZ → 1 at flat interior (surface facing camera directly)
  // Used by VQ2 Fresnel at Stage 7.8. Must be computed from dot(n,n) — not
  // collapsed to a binary int — because the SDF normal varies smoothly across
  // the corner arc, producing a continuous grazing-angle ramp that drives the
  // iOS 26 rim brightening effect. A binary snap would turn this into a hard
  // step, eliminating the smooth Fresnel highlight on rounded corners.
  float normalZ = sqrt(max(0.0, 1.0 - dot(surfaceNormal, surfaceNormal)));

  // ---- STAGE 3: HAIRLINE MASK ----
  float effectiveBorder = kBorderThickness + uIndicatorWeight * 0.2;
  float effectiveSmoothing = smoothing * (1.0 + uIndicatorWeight * 0.2);
  float borderMask = 1.0 - smoothstep(0.0, effectiveSmoothing, abs(dist) - effectiveBorder);

  // ---- STAGE 3.5: SYNTHETIC DENSITY PHYSICS ----
  // Performance Optimization: When a parent container provides blur (Batch-Blur O(1) optimization),
  // child buttons lose the visual "double-darkening" effect of nested BackdropFilters.
  // This stage ANALYTICALLY SIMULATES that visual effect without the O(n) performance cost.
  //
  // Density Factor (uDensityFactor):
  //   - Provided explicitly by AdaptiveGlass for elevated buttons
  //   - 0.0 = normal button (standalone or no elevation)
  //   - 1.0 = fully elevated button (inside glass container with shared blur)
  //
  // Four Coordinated Effects (mimic physics of nested blur):
  //   1. Sharper specular (+20% sharpness) - Appears "harder" like denser material
  //   2. Darker body (-30% ambient) - Simulates double-blur darkening
  //   3. Higher opacity (+15% alpha) - More "solid" appearance
  //   4. Brighter rim (+5% brightness) - Enhanced frost/edge definition
  float densityFactor = uDensityFactor;

  // Density elevation physics: elevated surfaces have a slightly tighter highlight.
  // Applied as a multiplier on the specular, NOT on the exponent — the exponent is
  // now fixed per enum variant (zero-transcendental multiply chain below).
  // Range: 1.0 (normal) → 1.2 (fully elevated), continuous.
  float thicknessNorm = uThickness / kThicknessReference;
  float densitySpecularBoost = (1.0 + (thicknessNorm - 1.0) * 0.15) * (1.0 + densityFactor * 0.2);

  // Decode specular level. Flutter's FragmentShader API only supports setFloat,
  // so the Dart side passes 0.0/1.0/2.0 and we round() to get an exact int.
  // The GPU compiler sees literal-constant exponents per branch and fully unrolls.
  int specLevel = int(round(uSpecularSharpnessF));

  // ---- STAGE 4: DETERMINISTIC LIGHTING (zero-transcendental specular) ----
  // PP2 optimisation: The old code was:
  //   pow(lightCatch, kSpecularPowerPrimary * specularSharpness)
  // pow(x, uniform) compiles on Metal/Vulkan as exp(n·log(x)) — two transcendental
  // ops per fragment. On Apple Metal, ARM Mali, and Qualcomm Adreno this is 4–8×
  // slower than a multiply. kSpecularPowerPrimary * specularSharpness ranged 14–20.
  //
  // Fix: uSpecularSharpness is an integer uniform (0/1/2). Each branch uses a
  // GLSL literal-constant exponent the GPU compiler sees at compilation time and
  // fully unrolls into a pure multiply chain — zero transcendentals.
  //
  // Wave coherency bonus: all fragments in a glass surface share the same value.
  // The driver eliminates dead branches for the entire draw call. In practice:
  // one branch executes, the rest are compiled away — zero warp divergence.
  //
  // Exponents chosen as powers-of-2 for minimum multiply count:
  //   n=8  → 3 multiplies  (soft:   x² → x⁴ → x⁸)
  //   n=16 → 4 multiplies  (medium: x² → x⁴ → x⁸ → x¹⁶, iOS 26 default)
  //   n=32 → 5 multiplies  (sharp:  x² → x⁴ → x⁸ → x¹⁶ → x³²)
  
  // VQ1: Anisotropic specular
  // Mathematical shortcut: surfaceNormal is strictly length 1.0 (if isEdge)
  // or 0.0. We avoid length(), division, and normalize() entirely.
  // length(surfaceNormal + tangent*0.2) = sqrt(1.0 + 0.04) = 1.0198039
  // 1.0 / 1.0198039 = 0.9805806
  vec2 anisoN = isEdge 
      ? (surfaceNormal + vec2(-surfaceNormal.y, surfaceNormal.x) * 0.2) * 0.9805806
      : vec2(0.0);

  float lightCatch = max(dot(anisoN, uLightDirection), 0.0);
  float kickCatch  = max(dot(anisoN, -uLightDirection), 0.0);

  float keySpecular;
  float kickSpecular;
  if (specLevel == 0) {
    // soft: n=8 — 3 multiplies
    float lc2 = lightCatch * lightCatch;
    float lc4 = lc2 * lc2;
    keySpecular = lc4 * lc4;
    float kc2 = kickCatch * kickCatch;
    float kc4 = kc2 * kc2;
    kickSpecular = kc4 * kc4;
  } else if (specLevel == 1) {
    // medium: n=16 — 4 multiplies (iOS 26 default)
    float lc2 = lightCatch * lightCatch;
    float lc4 = lc2 * lc2;
    float lc8 = lc4 * lc4;
    keySpecular = lc8 * lc8;
    float kc2 = kickCatch * kickCatch;
    float kc4 = kc2 * kc2;
    float kc8 = kc4 * kc4;
    kickSpecular = kc8 * kc8;
  } else {
    // sharp: n=32 — 5 multiplies
    float lc2 = lightCatch * lightCatch;
    float lc4 = lc2 * lc2;
    float lc8 = lc4 * lc4;
    float lc16 = lc8 * lc8;
    keySpecular = lc16 * lc16;
    float kc2 = kickCatch * kickCatch;
    float kc4 = kc2 * kc2;
    float kc8 = kc4 * kc4;
    float kc16 = kc8 * kc8;
    kickSpecular = kc16 * kc16;
  }
  keySpecular  *= uLightIntensity * densitySpecularBoost;
  kickSpecular *= uLightIntensity * kKickIntensity * densitySpecularBoost;
  // ---- STAGE 5: GLASS ALPHA ----
  // glassColor.a IS the opacity. 
  float glassAlpha = clamp(uGlassColor.a, 0.0, 1.0);

  // ---- STAGE 6: RIM & BEVEL LAYER ----
  float thicknessOffset = (uThickness - kThicknessReference) / kThicknessReference;
  float totalSpecular = keySpecular + kickSpecular;
  float rimBaseWithIntensity = max(kMinRimVisibility, kRimBaseOpacity * uLightIntensity * kRimIntensityScale);
  float rimBrightness = rimBaseWithIntensity + thicknessOffset * 0.10 + (densityFactor * 0.05);
  vec3 rimColorBase = vec3(1.0) * (rimBrightness + totalSpecular * kRimSpecularMix);

  // Directional light influence for a subtle lit-side bonus.
  float normalDotLight = max(0.0, dot(surfaceNormal, uLightDirection));
  float normalDotOpposite = max(0.0, dot(surfaceNormal, -uLightDirection));
  float directionalInfluence = normalDotLight + normalDotOpposite * 0.8;
  directionalInfluence *= directionalInfluence; // squared for tighter highlight

  // Constant base rim (structural edge) + small directional bonus.
  // iOS 26 uses near-invisible rims in light mode — the glass edge is
  // defined by subtle refraction and shadow, not by an opaque border.
  //
  // smoothstep(0.3, 0.5, luma) creates a sharp binary-like transition:
  //   dark  (luma=0.15) → smoothstep=0.0 → rimFade=1.0  (FULL rim, untouched)
  //   light (luma=0.85) → smoothstep=1.0 → rimFade=0.08 (near-invisible rim)
  // Dark mode is completely unaffected.
  float rimFade = 1.0 - smoothstep(0.3, 0.5, uBackdropLuma) * 0.92;
  float rimAlphaBase = kRimAlphaBase * rimFade + 0.15 * directionalInfluence * uLightIntensity;
  rimAlphaBase *= uRefractiveIndex;
  rimAlphaBase += totalSpecular * kRimAlphaSpecular * rimFade;
  rimAlphaBase *= (1.0 + thicknessOffset * kThicknessRimBoost) * (1.0 + densityFactor * 0.1);
  rimAlphaBase *= borderMask;
  rimAlphaBase = clamp(rimAlphaBase, 0.0, 1.0);

  // ---- STAGE 7: EXTRAS (fresnel) ----
  // uFresnelStrength (slot 33) scales the grazing-angle rim. Default 1.0 = calibrated
  // iOS 26 baseline. 0.0 removes the rim highlight entirely.
  float adaptiveStrength = mix(1.2, 0.8, uBackdropLuma);
  float fresnel = (1.0 - normalZ) * borderMask * 0.10 * adaptiveStrength * uFresnelStrength;

  // ---- STAGE 8: FINAL COMPOSITE ----
  float vertCoord = localLogical.y / max(uSize.y, 1.0);

  // PATH-SPECIFIC frosted-glass material weight.
  // PATH A (BG texture): background ALREADY provides visual presence. Adding white frost
  //   neutralises the warm background colours that show through the glass (wrong look).
  //   Premium shows blurred warm background through glass — so frost = 0 in PATH A.
  // PATH B (no texture): need modest opacity so glass body is visible over the blur layer.
  //   20% white lift is enough to be distinct without looking frosty.
  // Hoist edgeInfluence to outer scope — used for refraction (PATH A) and
  // meniscus rim darkening (all paths). Must be declared before PATH A/B split.
  float distFromEdge = abs(dist);
  const float edgeZone = 10.0;
  float edgeInfluence = smoothstep(edgeZone, 0.0, distFromEdge);
  edgeInfluence *= edgeInfluence; // quadratic falloff for natural lens curve

  if (uBackgroundSize.x > 1.0) {
    // PATH A: BG Sample ON
    // We have the background. We composite glass over it manually.
    // Output: fully opaque (mask) — Flutter must NOT re-composite the bg on top.
    vec2 posInBg = uBackgroundOrigin + localLogical;
    vec2 uv = posInBg / uBackgroundSize;

    // Safety valve: first do a fast baseline sample to check if the texture is valid.
    // If the texture is near-black, the GPU hasn't flushed yet.
    vec3 testRgb = texture(uBackground, uv).rgb;
    float testLuma = dot(testRgb, LUMA_WEIGHTS);

    if (testLuma < 0.02) {
      // Treat as PATH B — premultiplied transparent output.
      float isLightFallback = step(0.5, uBackdropLuma);
      float frost2 = 0.08 + densityFactor * 0.05 + isLightFallback * 0.04;
      float pmA2 = max(glassAlpha, frost2);
      vec3 frostRgb2 = vec3(isLightFallback);
      vec3 baseRgb2 = mix(frostRgb2, uGlassColor.rgb, min(glassAlpha / (frost2 + 0.01), 1.0));
      vec3 pmRgb2 = baseRgb2 * pmA2;
      
      // Min 3% ambient darkening + bottom volumetric gradient shadow
      float bottomDarken = vertCoord * 0.04;
      float ambientDarken2 = clamp((uAmbientStrength * 0.25 + 0.03) * (1.0 + densityFactor * 0.5) + bottomDarken, 0.0, 0.8);
      ambientDarken2 *= mix(1.0, 0.2, isLightFallback); // Reduce grey shadow in light mode
      pmA2 = pmA2 + ambientDarken2 * (1.0 - pmA2);
      
      float outA2 = rimAlphaBase + pmA2 * (1.0 - rimAlphaBase);
      vec3 outRgb2 = rimColorBase * rimAlphaBase + pmRgb2 * (1.0 - rimAlphaBase);
      pmRgb2 = outRgb2 + vec3(0.05) * uIndicatorWeight + vec3(fresnel);
      // Meniscus rim darkening (PATH A fallback — no valid texture)
      pmRgb2 *= meniscusAbsorption(distFromEdge, edgeZone, surfaceNormal, uLightDirection, uEdgeAbsorption);
      fragColor = vec4(clamp(pmRgb2, 0.0, 1.0) * mask, outA2 * mask);
    } else {
      // Normal PATH A — background texture is valid.
      //
      // Edge-zone refraction uses the edgeInfluence already computed above.
      vec2 edgeOffset = surfaceNormal * edgeInfluence * uThickness * 0.5;
      vec2 refractedUV = uv + edgeOffset / uBackgroundSize;

      // On pre-3.46 OpenGL ES the background texture uses bottom-left Y origin;
      // edgeOffset.y (computed in Flutter's Y-down space) must be negated.
      // Flutter 3.46+ unified the convention — see gles_compat.glsl.
      #ifdef LGR_GLES_FLIP_SAMPLE_Y
          refractedUV = uv + vec2(edgeOffset.x, -edgeOffset.y) / uBackgroundSize;
      #endif

      vec3 bgRgb;
      if (uChromaticAberration < 0.001) {
        // No chromatic aberration — single bilinear fetch.
        bgRgb = texture(uBackground, refractedUV).rgb;
      } else {
        // [3] EDGE-CONCENTRATED CHROMATIC ABERRATION
        // RGB channels split along the surface normal, weighted by edgeInfluence
        // so dispersion is concentrated at the SDF boundary (the curved glass rim)
        // and zero in the flat interior — matching the prismatic fringe visible on
        // real glass edges and iOS 26 pills.
        float abScale = uChromaticAberration * edgeInfluence * 0.006;
        vec2 abShift = surfaceNormal * abScale;
        float bgR = texture(uBackground, refractedUV + abShift).r;
        float bgG = texture(uBackground, refractedUV).g;
        float bgB = texture(uBackground, refractedUV - abShift).b;
        bgRgb = vec3(bgR, bgG, bgB);
      }
      float bgLuminance = dot(bgRgb, LUMA_WEIGHTS);

      // Apply saturation to the background to match Premium's depth.
      vec3 saturatedBg = mix(vec3(bgLuminance), bgRgb, uSaturation);

      // Min 8% ambient darkening + bottom volumetric gradient shadow
      float bottomDarken = vertCoord * 0.04;
      float ambientDarken = clamp((uAmbientStrength * 0.25 + 0.08) * (1.0 + densityFactor * 0.5) + bottomDarken, 0.0, 0.8);
      vec3 darkenedBg = saturatedBg * (1.0 - ambientDarken);

      // PATH A body: use luminosity-preserving glass tint (applyGlassColorLW) in adaptive mode.
      // In clear mode (uBodyMode > 0.5, iOS 26 Glass.clear), bypass luminosity normalization
      // and directly alpha composite the glass color over the background.
      vec3 bodyColor;
      if (uBodyMode > 0.5) {
        bodyColor = mix(saturatedBg, uGlassColor.rgb, uGlassColor.a);
      } else {
        bodyColor = applyGlassColorLW(darkenedBg, uGlassColor);
      }

      // Adaptive rim color: brighten the background at the edge (Premium's getHighlightColor).
      vec3 adaptiveRimColor = mix(bgRgb, vec3(1.0), 0.7);

      vec3 finalColor = bodyColor * (1.0 - rimAlphaBase) + adaptiveRimColor * rimAlphaBase;
      finalColor += vec3(0.05) * uIndicatorWeight;

      // Unified interactive glow: active state feedback on standard interactive widgets
      float glowMask = step(0.01, uGlowIntensity);
      finalColor += vec3(uGlowIntensity * 0.3 * glowMask);

      finalColor = clamp(finalColor + vec3(fresnel), 0.0, 1.0);

      // [1] Hemisphere lens profile + [2] light-modulated absorption (PATH A normal)
      finalColor *= meniscusAbsorption(distFromEdge, edgeZone, surfaceNormal, uLightDirection, uEdgeAbsorption);

      fragColor = vec4(finalColor * mask, mask);
    }

  } else {
    // PATH B: All Standard widgets use this path.
    // Flutter SrcOver composites us over the BackdropFilter(blur+saturation) background.
    float isLight = step(0.5, uBackdropLuma);
    float isClear = step(0.5, uBodyMode);
    
    // 8% frost floor ensures minimum material visibility in adaptive mode.
    // In clear mode, simulated frost floor is zeroed out for exact color reproduction.
    float simulatedFrost = mix(0.08 + densityFactor * 0.05 + isLight * 0.04, 0.0, isClear);
    float pmA = mix(max(glassAlpha, simulatedFrost), glassAlpha, isClear);
    
    // In light mode, transparent glass becomes white frost. In dark mode, it remains black (ambient darken).
    vec3 frostRgb = vec3(isLight);
    vec3 adaptiveBaseRgb = mix(frostRgb, uGlassColor.rgb, min(glassAlpha / (simulatedFrost + 0.01), 1.0));
    vec3 baseRgb = mix(adaptiveBaseRgb, uGlassColor.rgb, isClear);
    vec3 pmRgb = baseRgb * pmA;

    // Min 3% ambient darkening + bottom volumetric gradient shadow (adaptive mode only):
    float bottomDarken = vertCoord * 0.04;
    float ambientDarken = clamp((uAmbientStrength * 0.25 + 0.03) * (1.0 + densityFactor * 0.5) + bottomDarken, 0.0, 0.8);
    // Reduce ambient darken in light mode to prevent greyness; zero out in clear mode
    ambientDarken *= mix(1.0, 0.2, isLight);
    ambientDarken *= (1.0 - isClear);
    
    pmA = pmA + ambientDarken * (1.0 - pmA);

    // Rim color: full white in dark mode, no dimming needed in light mode
    // because rimAlphaBase is already near-zero via rimFade.
    vec3 pathBRimColor = rimColorBase;

    // Minimum border floor: only active in dark mode (rimFade=1.0).
    // In light mode rimFade≈0.08, so this floor is effectively zero.
    float minRimAlpha = borderMask * 0.06 * rimFade;
    float effectiveRimAlpha = max(rimAlphaBase, minRimAlpha);

    // Rim composited over body.
    float outA = effectiveRimAlpha + pmA * (1.0 - effectiveRimAlpha);
    vec3 outRgb = pathBRimColor * effectiveRimAlpha + pmRgb * (1.0 - effectiveRimAlpha);
    pmA = outA;
    pmRgb = outRgb;

    pmRgb += vec3(0.05) * uIndicatorWeight;
    pmRgb += vec3(fresnel);

    // Interactive glow: active state on switches/sliders (restored from main).
    float glowMask = step(0.01, uGlowIntensity);
    pmRgb += vec3(uGlowIntensity * 0.3 * glowMask);
    pmA = max(pmA, uGlowIntensity * 0.3 * glowMask);

    // [1] Hemisphere + [2] light-modulated absorption (PATH B — no background texture)
    pmRgb *= meniscusAbsorption(distFromEdge, edgeZone, surfaceNormal, uLightDirection, uEdgeAbsorption);

    fragColor = vec4(clamp(pmRgb, 0.0, 1.0) * mask, pmA * mask);
  }
}

