// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Original work — iOS 26-style liquid glass refraction shader for interactive
// indicators (segmented controls, pills). Fully original implementation.

#include <flutter/runtime_effect.glsl>
#include "gles_compat.glsl"

precision highp float;

/*
  iOS 26 LIQUID GLASS INDICATOR SHADER
  =====================================
  
  This shader creates the liquid glass refraction effect for interactive
  indicators (like the pill in a segmented control). It samples a captured
  background texture and applies edge distortion to simulate light bending
  through glass.
  
  COORDINATE SYSTEM:
  - All calculations use LOGICAL pixels (not physical/device pixels)
  - uBackgroundOrigin and uBackgroundSize are in logical pixels
  - This avoids DPR scaling issues across different devices
  
  MAIN EFFECTS:
  1. Edge refraction - bends the background image at the pill edges
  2. Chromatic aberration - separates RGB channels at edges for prism effect
  3. Directional lighting - rim highlights based on light angle
  4. Fresnel glow - subtle glow at grazing angles
  5. Synthetic bevel gradient - top-bright / bottom-dim rim falloff that
     simulates the view-angle gradient of a real 3D Impeller bevel
*/

// -----------------------------------------------------------------------------
// UNIFORMS
// -----------------------------------------------------------------------------
// We pack uniforms into vec4s to avoid Metal's 14 constant buffer limit on the iOS Simulator.
uniform vec4 uData0; // 0..3 (size.x, size.y, origin.x, origin.y)
uniform vec4 uData1; // 4..7 (glassColor)
uniform vec4 uData2; // 8..11 (thickness, lightDir.x, lightDir.y, lightIntensity)
uniform vec4 uData3; // 12..15 (ambientStrength, saturation, refractiveIndex, chromaticAberration)
uniform vec4 uData4; // 16..19 (cornerRadius, scale.x, scale.y, glowIntensity)
uniform vec4 uData5; // 20..23 (densityFactor, interactionIntensity, bgOrigin.x, bgOrigin.y)
uniform vec4 uData6; // 24..27 (bgSize.width, bgSize.height, hasBackground, ambientRim)
uniform vec4 uData7; // 28..31 (baseAlphaMultiplier, edgeAlphaMultiplier, rimThickness, rimSmoothing)
// 32:  uDpr (float)  — device pixel ratio for textureBilinear()
// 33:  uEdgeAbsorption — Beer-Lambert meniscus rim darkening strength [0..1]

uniform sampler2D uTexture;         // Captured background image

// 32: Device pixel ratio — passed from Dart _RenderInteractiveIndicator.
// The background texture is now captured at full DPR resolution, so the
// physical texel size = logical uBackgroundSize * uDpr.
uniform float uDpr;

// 33: Meniscus rim darkening — Beer-Lambert absorption at the pill boundary.
// Applied before specular highlights (physical ordering: light is absorbed
// first, then reflected). Same formula as liquid_glass_render.frag.
// Range: 0.0 (flat, no absorption) → 1.0 (fully dark rim).
// iOS 26 reference calibrated at ~0.15.
uniform float uEdgeAbsorption;

out vec4 fragColor;

// ── Manual Bilinear Filtering ─────────────────────────────────────────────
// Impeller's explicit setImageSampler() binding may also default to
// Nearest-Neighbor. Even when it does not, the background texture was
// previously captured at pixelRatio: 1.0, meaning each "texel" covered
// a 3×3 block of physical pixels on a 3× Retina screen. Both issues
// produced blocky staircase aliasing on edge refraction and chromatic
// aberration.
//
// This function replaces all uTexture lookups with a 4-texel bilinear
// interpolation in GLSL, guaranteeing smooth sub-pixel sampling regardless
// of Impeller's sampler default.
//
// uv       — UV coordinate in [0,1] (relative to logical uBackgroundSize)
// logSize  — uBackgroundSize in logical pixels
// physSize — uBackgroundSize * uDpr = actual pixel dimensions of the texture
// invPhys  — 1.0 / physSize (precomputed for efficiency)
vec4 textureBilinear(vec2 uv, vec2 physSize, vec2 invPhys) {
    // Convert UV to physical texel coordinate, centre on the texel grid.
    vec2 px = uv * physSize - 0.5;
    vec2 f  = fract(px);
    vec2 p0 = floor(px);
    vec2 p1 = p0 + vec2(1.0, 0.0);
    vec2 p2 = p0 + vec2(0.0, 1.0);
    vec2 p3 = p0 + vec2(1.0, 1.0);

    // Explicitly clamp to texture bounds. In Impeller, custom FragmentShader 
    // samplers may not use ClampToEdge by default. When the indicator pill 
    // expands outside the RepaintBoundary bounds (e.g. via jelly overshoot 
    // or LiquidStretch scaling), out-of-bounds UVs cause extreme wrap-around 
    // chromatic aliasing (jagged rainbows) on the pill's top/left edges.
    vec2 maxPx = max(vec2(0.0), physSize - 1.0);
    p0 = clamp(p0, vec2(0.0), maxPx);
    p1 = clamp(p1, vec2(0.0), maxPx);
    p2 = clamp(p2, vec2(0.0), maxPx);
    p3 = clamp(p3, vec2(0.0), maxPx);

    vec4 c0 = texture(uTexture, (p0 + 0.5) * invPhys);
    vec4 c1 = texture(uTexture, (p1 + 0.5) * invPhys);
    vec4 c2 = texture(uTexture, (p2 + 0.5) * invPhys);
    vec4 c3 = texture(uTexture, (p3 + 0.5) * invPhys);

    vec4 cTop = mix(c0, c1, f.x);
    vec4 cBot = mix(c2, c3, f.x);
    return mix(cTop, cBot, f.y);
}

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
  float uDensityFactor = uData5.x;
  float uInteractionIntensity = uData5.y;
  vec2 uBackgroundOrigin = uData5.zw;
  vec2 uBackgroundSize = uData6.xy;
  float uHasBackground = uData6.z;
  float uAmbientRim = uData6.w;
  float uBaseAlphaMultiplier = uData7.x;
  float uEdgeAlphaMultiplier = uData7.y;
  float uRimThickness = uData7.z;
  float uRimSmoothing = uData7.w;

  // ==========================================================================
  // COORDINATE SETUP
  // ==========================================================================
  // FlutterFragCoord gives pixel position within the current drawing layer.
  // Since we're inside a RepaintBoundary layer, this starts at (0,0).
  
  vec2 fragPx = FlutterFragCoord().xy;
  
  // Convert to local logical position (0 to uSize)
  // Note: uOrigin is (0,0) and uScale is (1,1) due to layer boundaries
  vec2 localLogical = (fragPx - uOrigin) / uScale;
  vec2 center = uSize * 0.5;
  vec2 normalizedP = (localLogical - center) / center;
  float radialDist = length(normalizedP);  // 0 at center, 1 at edge
  
  // ==========================================================================
  // SDF PILL SHAPE
  // ==========================================================================
  // Using a standard high-fidelity Rounded Rectangle SDF for lighting stability.
  
  vec2 halfSize = uSize * 0.5;
  vec2 q = abs(localLogical - halfSize) - halfSize + uCornerRadius;
  float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - uCornerRadius;

  // Anti-aliasing: smooth transition at edge
  float smoothing = 1.0 / uScale.x;
  float mask = 1.0 - smoothstep(-smoothing, smoothing, dist);
  
  // Early exit if outside the shape
  if (mask <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }
  
  // ==========================================================================
  // SURFACE NORMAL
  // ==========================================================================
  vec2 innerHalfSize = halfSize - uCornerRadius;
  vec2 p = localLogical - halfSize;
  vec2 closestOnSkeleton = clamp(p, -innerHalfSize, innerHalfSize);
  vec2 toEdge = p - closestOnSkeleton;
  float edgeLen = length(toEdge);
  // Reuse edgeLen for the division — normalize(toEdge) would recompute length()
  // internally. Dividing by the already-computed scalar saves one length() call
  // per fragment in the surface normal path.
  vec2 surfaceNormal = (edgeLen > 0.001) ? (toEdge / edgeLen) : vec2(0.0);
  
  // ==========================================================================
  // BACKGROUND REFRACTION (THE MAIN EFFECT)
  // ==========================================================================
  // Sample the background texture with UV coordinates.
  // All values are in LOGICAL pixels for consistency.
  
  vec2 posInBg = uBackgroundOrigin + localLogical;
  vec2 uvBase = posInBg / uBackgroundSize;
  
  // --------------------------------------------------------------------------
  // EDGE DISTORTION
  // --------------------------------------------------------------------------
  // Creates the "liquid lens" effect at the pill edges by bending the
  // sampled background position inward along the surface normal.
  
  float distFromEdge = abs(dist);
  
  // TWEAK: edgeZone - How far from the edge the distortion extends (logical px)
  //   Smaller = sharper transition, concentrated at very edge
  //   Larger = softer, more gradual effect spreading inward
  float edgeZone = 14.0;
  
  // Calculate influence: 1.0 at edge, 0.0 at edgeZone pixels inward
  float edgeInfluence = smoothstep(edgeZone, 0.0, distFromEdge);
  
  // TWEAK: Quadratic falloff makes the bend gentler (less abrupt)
  //   Use edgeInfluence directly for sharper edge effect
  //   Use edgeInfluence * edgeInfluence for gentler, more natural curve
  //   Use pow(edgeInfluence, 3.0) for even gentler effect
  edgeInfluence = edgeInfluence * edgeInfluence;
  
  // TWEAK: bendStrength - Overall refraction intensity
  //   Base (0.9): stronger edge lens distortion, closer to Impeller volumetric warp
  //   Range: 0.45 (rest) → 1.17 (fully pressed)
  float bendStrength = 0.9 * (0.5 + uInteractionIntensity * 0.7);
  
  // TWEAK: The final multiplier (uSize.y * 0.35) scales by widget height
  //   0.35 means max offset is 35% of widget height
  //   Increase for more dramatic effect, decrease for subtler
  vec2 edgeOffsetLogical = surfaceNormal * edgeInfluence * bendStrength * uSize.y * 0.35;
  vec2 edgeOffsetUV = edgeOffsetLogical / uBackgroundSize;
  
  // Apply refraction offset along the surface normal.
  // On pre-3.46 OpenGL ES the background texture is stored with a bottom-left Y
  // origin, so edgeOffsetLogical.y (computed in Flutter's Y-down space) must be
  // negated to sample in the correct outward direction in the Y-up UV space.
  // Flutter 3.46+ stores it top-down on every backend (see gles_compat.glsl),
  // where negating would invert the refraction instead of correcting it.
  #ifdef LGR_GLES_FLIP_SAMPLE_Y
    vec2 localRefracted = posInBg + vec2(edgeOffsetLogical.x, -edgeOffsetLogical.y);
  #else
    vec2 localRefracted = posInBg - edgeOffsetLogical;
  #endif
  
  // --------------------------------------------------------------------------
  // CHROMATIC ABERRATION
  // --------------------------------------------------------------------------
  // Separates RGB channels slightly at edges, creating a subtle prism effect.
  // Red shifts one way, blue shifts the opposite, green stays centered.
  
  // TWEAK: (0.12) - subtle chromatic shift for "Apple style" refraction
  vec2 distort = surfaceNormal * edgeInfluence * uChromaticAberration;
  vec2 chromaticShift = distort * 0.12; 
  
  vec3 bg;
  if (uHasBackground > 0.5) {
    // Physical texture size (actual pixel dimensions after DPR capture).
    // uBackgroundSize is in LOGICAL pixels; the texture has uDpr× more texels.
    vec2 physBgSize = uBackgroundSize * uDpr;
    vec2 invPhysBgSize = 1.0 / physBgSize;

    if (uChromaticAberration < 0.001) {
      // No chromatic aberration — single bilinear fetch.
      bg = textureBilinear(localRefracted / uBackgroundSize, physBgSize, invPhysBgSize).rgb;
    } else {
      // Chromatic aberration: separate RGB channels with bilinear filtering.
      vec3 colR = textureBilinear((localRefracted + chromaticShift) / uBackgroundSize, physBgSize, invPhysBgSize).rgb;
      vec3 colG = textureBilinear(localRefracted / uBackgroundSize, physBgSize, invPhysBgSize).rgb;
      vec3 colB = textureBilinear((localRefracted - chromaticShift) / uBackgroundSize, physBgSize, invPhysBgSize).rgb;
      bg = vec3(colR.r, colG.g, colB.b);
    }
  } else {
    // SYNTHETIC LIQUID: Use the passed indicator color
    // This allows the standard mode to respect the color passed to the widget
    bg = uGlassColor.rgb;
  }
  
  // uLightDirection is passed from Dart as [cos(angle), -sin(angle)]
  float edgeLightCatch = dot(surfaceNormal, uLightDirection);
  
  // Key light: bright highlight on edges facing the light
  // PP2: pow(x, 8.0) replaced with multiply chain — zero transcendentals.
  // x^8 = ((x^2)^2)^2 — 3 multiplies vs exp(8·log(x)).
  // Same optimisation already applied in lightweight_glass.frag.
  float lc  = max(edgeLightCatch,  0.0);
  float lc2 = lc  * lc;
  float lc4 = lc2 * lc2;
  float keyHighlight = lc4 * lc4 * uLightIntensity * 0.5;  // lc^8
  
  // Kick light: subtle highlight on opposite edge (back-reflection)
  // PP2: pow(x, 12.0) = x^8 * x^4 — 4 multiplies vs transcendental.
  float kc  = max(-edgeLightCatch, 0.0);
  float kc2 = kc  * kc;
  float kc4 = kc2 * kc2;
  float kc8 = kc4 * kc4;
  float kickHighlight = kc8 * kc4 * uLightIntensity * 0.5; // kc^12
  
  // TWEAK: ambientRim - minimum rim brightness regardless of light direction
  float rimBrightness = uAmbientRim + keyHighlight + kickHighlight;
  
  // ==========================================================================
  // FRESNEL GLOW
  // ==========================================================================
  // Subtle glow at grazing angles (edges appear slightly brighter)
  
  // PP2: pow(radialDist, 2.0) → radialDist * radialDist (1 multiply, no transcendental).
  float fresnel = (radialDist * radialDist) * 0.25;
  
  // ==========================================================================
  // HAIRLINE RIM
  // ==========================================================================
  // Thin bright line at the very edge of the pill
  
  // Configurable hairline rim
  float borderMask = 1.0 - smoothstep(0.0, smoothing * uRimSmoothing, distFromEdge - uRimThickness);

  // --------------------------------------------------------------------------
  // SYNTHETIC BEVEL GRADIENT
  // --------------------------------------------------------------------------
  // The Impeller 3D bevel naturally brightens at the top because the top-face
  // normals angle toward the viewer, catching more ambient light. On a flat 2D
  // ring every point gets the same brightness, which reads as "fake".
  //
  // We simulate this by blending rim brightness with a vertical gradient derived
  // from the Y component of the surface normal:
  //   surfaceNormal.y < 0  → top of pill  → brighter (add bevelBoost)
  //   surfaceNormal.y > 0  → bottom       → dimmer   (subtract bevelDip)
  //
  // This is pure ALU — no texture samples, no uniforms required.
  // kBevelStrength: calibrated so the gradient reads clearly on large pills
  // (tab bar ~50px) without being aggressive on small elements (switch thumb ~22px).
  const float kBevelStrength = 0.18;
  // normalY range: -1 (top edge) to +1 (bottom edge) in Flutter's Y-down space
  float bevelGradient = -surfaceNormal.y * kBevelStrength;
  // Blend the gradient in only where the border mask is visible to avoid
  // affecting the body of the pill.
  // Clamp to 0.0: gradient dims the bottom rim to neutral, never to negative
  // (negative values subtract from finalColor and cause dark jagged artefacts).
  float modifiedRimBrightness = max(0.0, rimBrightness + bevelGradient * borderMask);

  // Scale rim brightness with ambientRim parameter
  vec3 rimColor = vec3(1.0) * modifiedRimBrightness * (uAmbientRim * 10.0);
  
  // ==========================================================================
  // COMPOSITE FINAL COLOR
  // ==========================================================================
  
  // Start with background — glass transmits and adds luminosity, not darkness.
  float bgBoost = uSaturation;
  vec3 finalColor = (uHasBackground > 0.5) ? (bg * bgBoost) : bg;
  
  // Rim highlight: primary + secondary bevel definition collapsed to one operation.
  // Was: finalColor += rimColor * borderMask; finalColor += rimColor * borderMask * 0.5;
  // 1.5× is mathematically identical with one fewer MAD per border fragment.
  finalColor += rimColor * borderMask * 1.5;

  // Add fresnel glow — uGlowIntensity controls how visible the glass-edge luminosity is.
  finalColor += vec3(1.0) * fresnel * uGlowIntensity;
  
  // Interior light lift — matches Premium Impeller's internal SDF specular glow.
  finalColor += vec3(uAmbientStrength);
  
  // Apply glass tint color
  finalColor = mix(finalColor, finalColor + uGlassColor.rgb * 0.2, uGlassColor.a);

  // ==========================================================================
  // MENISCUS RIM DARKENING (Beer-Lambert absorption) — applied LAST
  // ==========================================================================
  // Three physics improvements over a naive isotropic absorption:
  //
  // [1] HEMISPHERE LENS PROFILE
  //     A glass pill cross-section is a circular arc — thickest at the rim,
  //     thinning toward the interior following a hemisphere curve:
  //         thickness(r) = sqrt(1 - r²)  where r = distFromEdge / edgeZone
  //     This gives a physically correct onset: slow in the middle of the zone,
  //     sharper right at the boundary — matching a real curved glass edge.
  //     Previously: sqrt(edgeInfluence) which is a polynomial convenience, not
  //     a lens shape.
  //
  // [2] LIGHT-MODULATED ABSORPTION STRENGTH
  //     The meniscus absorbs the same amount on all sides (Beer-Lambert), but
  //     the PERCEIVED darkness differs by quadrant:
  //       • Lit side:    specular highlight partially compensates → rim appears
  //                      bright, absorption is perceptually hidden.
  //       • Shadow side: no specular compensation → dark band fully exposed.
  //     iOS 26 reference: the shadow-side meniscus is clearly darker than the
  //     lit-side meniscus, not because more absorption occurs, but because the
  //     specular energy on the lit side "fills in" the absorbed darkness.
  //     We replicate this by weakening absorption on the lit side, where it is
  //     masked anyway, and strengthening it on the shadow side, where it is the
  //     dominant visual term.
  //       dot(surfaceNormal, uLightDirection) = +1  → full facing light → litness=1
  //       dot(surfaceNormal, uLightDirection) = -1  → shadow side      → litness=0
  //     absorption scale: [0.6 × strength (lit)] … [1.4 × strength (shadow)]
  //
  // [3] CHROMATIC ABERRATION AT THE RIM
  //     Already implemented in the background sampling section above (line ~246):
  //       vec2 distort = surfaceNormal * edgeInfluence * uChromaticAberration;
  //     edgeInfluence concentrates the RGB split at the SDF boundary. No change
  //     needed here — this shader already has edge-weighted dispersion.

  // [1] Hemisphere lens thickness profile
  float r_norm = clamp(distFromEdge / edgeZone, 0.0, 1.0);
  float lensThickness = sqrt(max(0.0, 1.0 - r_norm * r_norm)); // hemisphere arc

  // [2] Light-modulated strength: weaker on lit side (0.6×), stronger on shadow (1.4×)
  float litness = dot(surfaceNormal, uLightDirection); // [-1, +1]
  float dirScale = mix(1.4, 0.6, litness * 0.5 + 0.5); // shadow → lit
  float modulatedAbsorption = uEdgeAbsorption * dirScale;

  // Combined: hemisphere profile × light-modulated strength
  float absorption = 1.0 - lensThickness * modulatedAbsorption;
  finalColor *= max(0.0, absorption);

  // Clamp to prevent over-bright pixels
  finalColor = min(finalColor, vec3(1.2));
  
  // ==========================================================================
  // ALPHA / TRANSPARENCY
  // ==========================================================================
  
  // TWEAK: baseAlpha - center transparency (lower = more see-through)
  // Standard mode: Provide a solid glassy body even at rest (Intensity 0), 
  // boosting it slightly when pressed.
  float standardBaseAlpha = uBaseAlphaMultiplier * mix(0.6, 1.0, uInteractionIntensity);
  // Restore original 0.70 when background is enabled — clear glass is translucent, not frosted.
  float baseAlpha = (uHasBackground > 0.5) ? 0.70 : standardBaseAlpha;
  
  // TWEAK: edgeAlpha - edge opacity (higher = more solid edges)
  // Standard mode: Keep a strong structural rim at rest to match 3D bevel.
  float standardEdgeAlpha = uEdgeAlphaMultiplier * mix(0.6, 1.0, uInteractionIntensity);
  float edgeAlpha = (uHasBackground > 0.5) ? 0.95 : standardEdgeAlpha;
  
  // Blend from center to edge
  float glassAlpha = mix(baseAlpha, edgeAlpha, edgeInfluence);
  float ringOpacity = borderMask * 0.9 * clamp(uAmbientRim * 10.0, 0.0, 1.0);
  glassAlpha = max(glassAlpha, ringOpacity);



  
  float alpha = glassAlpha * mask;
  
  // Premultiplied alpha output
  fragColor = vec4(finalColor * alpha, alpha);
}
