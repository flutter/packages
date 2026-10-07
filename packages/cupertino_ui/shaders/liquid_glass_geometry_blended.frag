// Copyright 2025, Tim Lehmann for whynotmake.it
// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Originally: Geometry precomputation shader using displacement-based encoding
// Modifications (2026):
//   - Migrated from displacement encoding to true surface normal encoding (V1).
//   - Switched precision from mediump to highp to fix ~1.5px banding on mobile.
//   - Added Windows/SkSL SPIR-V compatibility (literal-only indexing).
//   - Normal computed via dFdx/dFdy on the SDF field for accurate blend zones.
//   - MAX_SHAPES reduced from 64 to 16 to fit Impeller uniform buffer limits.
//   - Native iOS 27 edge (uNativeEdge) under a rim outline.
//
// Geometry precomputation shader for blended liquid glass shapes
// This shader pre-computes the surface normal and encodes it into a texture.
// Only needs to be re-run when shape geometry or layout changes.
//
// Texture layout (slots → displacement_encoding.glsl):
//   R: normal.x  [-1, 1] → [0, 1]
//   G: normal.y  [-1, 1] → [0, 1]
//   B: height    normalized to thickness
//   A: foreground alpha (SDF anti-aliasing)

#version 460 core
precision highp float; // mediump caused ~1.5px displacement banding on mobile (10-bit mantissa)

#include <flutter/runtime_effect.glsl>

// MAX_SHAPES must be defined before uShapeData so the array size is known.
// sdf.glsl uses an #ifndef guard so this definition takes precedence.
#define MAX_SHAPES 16

layout(location = 0) uniform vec2 uSize;
layout(location = 1) uniform vec4 uOpticalProps;
layout(location = 2) uniform vec2 uShapeSettings; // x = numShapes, y = dpr
layout(location = 3) uniform float uShapeData[MAX_SHAPES * 7];
// 1 with a rim outline or a frost (LiquidGlassSettings.rimShade or frost
// above 0): the native edge below. 0 leaves the geometry exactly as it was. Location 3 + MAX_SHAPES * 7,
// each element of uShapeData taking one.
layout(location = 115) uniform float uNativeEdge;

// sdf.glsl functions access uShapeData as a global (no array-by-value parameters,
// which are rejected by glslang on Windows/Vulkan SPIR-V compilation).
#include "sdf.glsl"
#include "displacement_encoding.glsl"

layout(location = 0) out vec4 fragColor;

void main() {
    // Unpacked here rather than at global scope: global non-constant initialisers
    // (e.g. float x = uniform.y) are valid in desktop GLSL 4.6 but rejected by
    // SkSL / glslang on Windows.
    float uThickness = uOpticalProps.z;
    float uBlend = uOpticalProps.w;

    float uNumShapes = uShapeSettings.x;
    float uDpr = uShapeSettings.y;

    vec2 fragCoord = FlutterFragCoord().xy;

    float sd = sceneSDF(fragCoord, int(uNumShapes), uBlend);

    // Compute the SDF gradient for surface normal generation.
    //
    // The tap spacing acts as a spatial low-pass filter. To ensure the normal
    // is smoothed identically on all devices regardless of pixel density, the
    // physical tap distance must scale with DPR. Since the baseline tuning was
    // done on a 3x Retina display with a 1.0px tap, the universal tap step
    // is (uDpr / 3.0).
    float stepDist = uDpr / 3.0;
    float sdPX = sceneSDF(fragCoord + vec2(stepDist, 0.0), int(uNumShapes), uBlend);
    float sdMX = sceneSDF(fragCoord - vec2(stepDist, 0.0), int(uNumShapes), uBlend);
    float sdPY = sceneSDF(fragCoord + vec2(0.0, stepDist), int(uNumShapes), uBlend);
    float sdMY = sceneSDF(fragCoord - vec2(0.0, stepDist), int(uNumShapes), uBlend);

    // Span is 2.0 * stepDist, so divide by it for the unit gradient.
    float dx = (sdPX - sdMX) / (2.0 * stepDist);
    float dy = (sdPY - sdMY) / (2.0 * stepDist);

    float gradMag = sqrt(dx * dx + dy * dy);
    // Normalize the SDF using the gradient magnitude. This converts a pseudo-SDF
    // (like our continuous superellipse) into a true Euclidean distance metric.
    float sdN = (gradMag > 0.1) ? sd / gradMag : sd;

    // Apply logical-pixel anti-aliasing using the NORMALIZED distance (sdN).
    // Using raw `sd` for pseudo-SDFs causes pixelated edges because the field
    // crosses zero too quickly. `sdN` guarantees exact 1-pixel wide gradients.
    // 
    // Note: The physical radius here scales directly by raw `uDpr`, not by `uDpr / 3.0`.
    // This is correct because we want a 1.5 logical-pixel wide smoothing radius on all
    // screens. A 1.5 logical-pixel radius naturally maps to `1.5 * uDpr` physical pixels.
    // This guarantees a pristine edge that survives the 4% bilinear scaling of press 
    // animations without stair-stepping, on every device density.
    float smoothing = 1.5 * max(1.0, uDpr);
    if (uNativeEdge > 0.5) {
        // iOS 27 glass ends in a single anti-aliased pixel, and the outline
        // and the frost the render pass draws have to reach an opaque pixel
        // at the edge:
        // narrow the window to half a logical pixel (never under one
        // physical pixel). The native silhouette also measures a third of a
        // point larger than its frame, the outline sitting just outside it,
        // so grow by a physical pixel at 3x; gatherShapeData makes room.
        smoothing = max(1.0, 0.5 * uDpr);
        sdN -= max(1.0, uDpr / 3.0);
    }
    float foregroundAlpha = smoothstep(smoothing * 0.5, -smoothing * 0.5, sdN);
    if (foregroundAlpha < 0.01) {
        fragColor = vec4(0.0);
        return;
    }

    float n_cos = max(uThickness + sdN, 0.0) / uThickness;
    float n_sin = sqrt(max(0.0, 1.0 - n_cos * n_cos));

    // True surface normal from the SDF gradient — this is what we store.
    // In blend-group neck zones the displacement vector diverges from this
    // normal, which is why storing the normal (not displacement) fixes lighting.
    vec3 normal = normalize(vec3(dx * n_cos, dy * n_cos, n_sin));

    if (sdN >= 0.0 || uThickness <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float x = uThickness + sdN;
    float sqrtTerm = sqrt(max(0.0, uThickness * uThickness - x * x));
    float height = mix(sqrtTerm, uThickness, float(sdN < -uThickness));

    // Encode normal.xy + height + alpha.
    // The render pass recomputes displacement = refract(incident, normal, 1/n)
    // so there is no information loss compared to storing displacement directly.
    fragColor = encodeGeometryData(normal.xy, height, uThickness, foregroundAlpha);
}
