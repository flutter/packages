// Copyright 2025, Tim Lehmann for whynotmake.it
// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Originally: Shared rendering utilities (rotate2d, computeY, getHighlightColor)
// Modifications (2026):
//   - Removed unused rotate2d() (dead code in all shader binaries).
//   - Rewrote getHighlightColor() with fast rational approximation — ~60% fewer
//     GPU operations vs. the original smoothstep path.
//   - Added getHeight(), calculateLighting(), applySaturation(), applyGlassColor(),
//     applyRefraction(), and applyChromaticAberration() for the V1 render pipeline.
//   - Switched from displacement-based to normal-based lighting model.
//   - Corrected LUMA_WEIGHTS from BT.601 to ITU-R Rec.709 (2026-09).
//
// Shared rendering functions for liquid glass shaders.
//
// Functions used by liquid_glass_render.frag:
//   getHighlightColor  — adaptive specular highlight tint
//   applySaturation    — ITU-R Rec. 709 luminance-preserving saturation
//   applyGlassColor    — iOS 26 luminosity-preserving tint

// ITU-R BT.709 / IEC 61966-2-1 (sRGB) luminance weights.
// Used by Apple's Metal/CoreImage pipeline and sRGB / Display P3 displays.
// Previously used legacy BT.601 (SDTV/NTSC) — corrected in 1.4.2.
const vec3 LUMA_WEIGHTS = vec3(0.2126, 0.7152, 0.0722);

// NOTE: rotate2d() was removed — it was never called by any shader and was
// compiled into every shader binary that includes render.glsl for no benefit.

// ── getHighlightColor ─────────────────────────────────────────────────────────
// Optimized highlight color - ~60% fewer operations than original version.
// Computes a luminosity-tinted white using a fast rational approximation for
// the lum/saturation blend weight instead of the slower smoothstep path.
vec3 getHighlightColor(vec3 backgroundColor, float targetBrightness) {
    float luminance = dot(backgroundColor, LUMA_WEIGHTS);
    
    // Fast saturation approximation using max component only
    float maxComponent = max(max(backgroundColor.r, backgroundColor.g), backgroundColor.b);
    
    // Combined color influence factor using fast rational approximation
    // x/(1+x) is faster than smoothstep and visually similar
    float lum = luminance * 2.5;
    float lumFactor = lum / (1.0 + lum);
    
    float sat = maxComponent * 2.5;
    float satFactor = sat / (1.0 + sat);
    
    float colorInfluence = lumFactor * satFactor;
    
    // Normalize and tint in one step
    vec3 tinted = (backgroundColor / max(luminance, 0.001)) * targetBrightness;
    
    return mix(vec3(targetBrightness), tinted, colorInfluence);
}

// ── applySaturation ───────────────────────────────────────────────────────────
// Rec. 709 luminance-preserving saturation.
// saturation = 1.0 → no change; > 1.0 → over-saturated; < 1.0 → desaturated.
vec3 applySaturation(vec3 color, float saturation) {
    float luminance = dot(color, LUMA_WEIGHTS);
    vec3 saturatedColor = mix(vec3(luminance), color, saturation);
    return clamp(saturatedColor, 0.0, 1.0);
}

// ── applyGlassColor ───────────────────────────────────────────────────────────
// Apply glass color tinting to the liquid color.
// iOS 26 model:
// - bodyMode == 0.0 (adaptive / Glass.regular): chromatic glass preserves
//   backdrop luminance while shifting hue; achromatic glass lifts toward white.
// - bodyMode == 1.0 (clear / Glass.clear): direct alpha-composite tint without
//   luminance normalization, preserving exact design token hex values while
//   retaining specular, Fresnel, and rim physics.
// glassColor.a = 0 naturally returns liquidColor via mix() in all paths.
vec4 applyGlassColor(vec4 liquidColor, vec4 glassColor, float bodyMode) {
    vec3 directMix = mix(liquidColor.rgb, glassColor.rgb, glassColor.a);
    if (bodyMode > 0.5) {
        return vec4(directMix, liquidColor.a);
    }

    float backdropLuminance = dot(liquidColor.rgb, LUMA_WEIGHTS);
    float glassLuminance    = dot(glassColor.rgb, LUMA_WEIGHTS);

    // Luminosity-preserving tint: shift chroma toward glass, keep backdrop brightness.
    vec3 tinted = clamp(glassColor.rgb + (backdropLuminance - glassLuminance), 0.0, 1.0);

    // Chroma of the glass colour: 0 = achromatic (white/grey/black), 1 = fully saturated.
    // Use a sharp ramp so anything with meaningful colour uses the luminosity path.
    float chroma = max(max(glassColor.r, glassColor.g), glassColor.b)
                 - min(min(glassColor.r, glassColor.g), glassColor.b);
    float chromaWeight = clamp(chroma * 8.0, 0.0, 1.0);

    // chromatic path:  mix toward luminosity-shifted tint (hue shift, brightness held)
    vec3 luminosityMix = mix(liquidColor.rgb, tinted, glassColor.a);

    return vec4(mix(directMix, luminosityMix, chromaWeight), liquidColor.a);
}

vec4 applyGlassColor(vec4 liquidColor, vec4 glassColor) {
    return applyGlassColor(liquidColor, glassColor, 0.0);
}
