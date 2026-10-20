// Copyright 2025, Tim Lehmann for whynotmake.it
// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Originally: Basic displacement encoding (R/G offset, B height, A alpha)
// Modifications (2026):
//   - Rewrote encoding scheme from displacement-based (offset vectors) to
//     true surface normal (V1): R/G store unit normal XY mapped to [0,1],
//     B stores normalized height, A stores SDF anti-aliasing alpha.
//   - Replaced encodeDisplacementData() with encodeGeometryData(normalXY, …)
//   - Added decodeNormalXY() and decodeHeight() decode helpers.
//   - Updated texture layout docs to reflect V1 format.
//
// Shared utilities for encoding and decoding geometry data.
//
// Texture layout (V1 — stores true surface normal instead of displacement):
//   R: normal.x  mapped from [-1, 1] → [0, 1]
//   G: normal.y  mapped from [-1, 1] → [0, 1]
//   B: height    normalized to [0, 1] by dividing by thickness
//   A: alpha     for SDF anti-aliasing at the glass boundary

// Encode the surface normal XY, height, and alpha into RGBA channels.
// normal.xy is the true SDF surface normal (from dFdx/dFdy in the geometry pass).
// Storing the genuine normal instead of the refraction displacement vector fixes
// lighting in blend-group neck zones, where normalize(displacement) diverges from
// the actual surface orientation.
vec4 encodeGeometryData(vec2 normalXY, float height, float thickness, float alpha) {
    // Map normal.xy from [-1, 1] to [0, 1] for texture storage.
    // normal components are already unit-length so clamping is just a guard.
    vec2 encodedNormal = clamp(normalXY * 0.5 + 0.5, 0.0, 1.0);
    float normalizedHeight = thickness > 0.0 ? clamp(height / thickness, 0.0, 1.0) : 0.0;
    return vec4(encodedNormal.x, encodedNormal.y, normalizedHeight, alpha);
}

// Decode surface normal XY from RG channels.
// Returns the XY components of the unit surface normal.
// Reconstruct normal.z in the render pass: sqrt(1.0 - dot(n.xy, n.xy)).
vec2 decodeNormalXY(vec4 encoded) {
    return encoded.rg * 2.0 - 1.0;
}

// Decode height from B channel.
float decodeHeight(vec4 encoded, float thickness) {
    return encoded.b * thickness;
}
