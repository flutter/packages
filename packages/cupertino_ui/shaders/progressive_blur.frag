// Copyright 2026, Rebar Ahmad. Licensed under the package's MIT License.
// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Originally: Separable Gaussian blur with 97 taps and per-tap exp() calls.
// Modifications (2026):
//   - Reduced taps from 97 to 49 (kHalf = 24), halving texture fetch bandwidth.
//   - Replaced transcendental exp() with incremental IIR Gaussian multiply recurrence.
//
// One axis of a SEPARABLE gaussian, used twice (horizontal then vertical) via
// ImageFilter.compose to build a full, clean 2-D gaussian in O(σ) work per pass
// instead of the O(σ²) a single-pass disk needs (a disk either streaks with too
// few taps or turns to noise with importance sampling — this avoids both).
//
// The blur radius follows a gradient (strong at one edge, easing to sharp at the
// other). The bound texture is the whole backdrop (screen), so the gradient is
// normalised over the widget's own device-pixel rectangle passed from Dart.

#include <flutter/runtime_effect.glsl>
#include "gles_compat.glsl"

uniform vec2 uSize;          // 0,1  bound-texture size, device px (engine)
uniform float uMaxSigma;     // 2    sigma at the strong edge, device px
uniform float uFalloff;      // 3    gradient gamma
uniform float uDirection;    // 4    strong edge: 0 top,1 bottom,2 left,3 right
uniform float uAxis;         // 5    blur axis: 0 = X (horizontal), 1 = Y (vertical)
uniform vec2 uRegionOriginPx;// 6,7  region top-left, device px
uniform vec2 uRegionSizePx;  // 8,9  region size, device px
uniform sampler2D uTexture;  //      input (backdrop for pass 1, pass-1 out for pass 2)

out vec4 fragColor;

// Half-kernel taps per side. Taps are placed with a stride that covers ±3σ, and
// the sampler's bilinear filtering smooths between them — enough for a clean
// gaussian at the gentle sigmas we use.
//
// Phase 1 (perf): Reduced from 48 → 24. The stride formula
// max(1, 3σ/kHalf) widens proportionally, keeping ±3σ coverage identical.
// At max sigma ≈ 30px, 24 taps + bilinear gives equivalent quality to 48
// taps at half the texture read cost.
const int kHalf = 24;

void main() {
  // Gradient sigma from the fragment's position within the region.
  vec2 rn = clamp(
      (FlutterFragCoord().xy - uRegionOriginPx) / uRegionSizePx, 0.0, 1.0);
  float g;
  if (uDirection < 0.5)      g = rn.y;        // strong TOP
  else if (uDirection < 1.5) g = 1.0 - rn.y;  // strong BOTTOM
  else if (uDirection < 2.5) g = rn.x;        // strong LEFT
  else                       g = 1.0 - rn.x;  // strong RIGHT
  float sigma = uMaxSigma * pow(1.0 - g, uFalloff);

  // Screen-normalised sampling UV. Pre-3.46 GLES captured the backdrop
  // y-flipped; 3.46+ stores it top-down like every other backend. See
  // gles_compat.glsl.
  vec2 uv = FlutterFragCoord().xy / uSize;
#ifdef LGR_GLES_FLIP_SAMPLE_Y
  uv.y = 1.0 - uv.y;
#endif

  if (sigma < 0.5) {
    fragColor = texture(uTexture, uv);
    return;
  }

  // 1px step in uv along the blur axis.
  vec2 axis = (uAxis < 0.5) ? vec2(1.0 / uSize.x, 0.0) : vec2(0.0, 1.0 / uSize.y);
  float stride = max(1.0, 3.0 * sigma / float(kHalf)); // device px between taps

  // Phase 3A (perf): Replace per-tap exp(-d²/2σ²) with a multiply recurrence.
  //
  // The IIR Gaussian trick: given w(i) = exp(-(i*stride)² * inv2s2),
  //   g1 = exp(-stride² * inv2s2)   [ratio w(1)/w(0)]
  //   g2 = g1 * g1                  [g2 = exp(-2*stride²*inv2s2)]
  //
  // Recurrence (per iteration):
  //   w ← w * g1
  //   g1 ← g1 * g2
  //
  // Proof: after k steps, g1 = exp(-(2k+1)*stride²*inv2s2), so
  //   w = exp(-1*inv) * exp(-3*inv) * … * exp(-(2k-1)*inv)
  //     = exp(-(1+3+…+(2k-1))*inv) = exp(-k²*stride²*inv2s2) = w(k). ✓
  //
  // Two multiplies per tap vs one exp() per tap. On Mali/Adreno/Apple GPU,
  // exp() costs ~4–8× a multiply — this saves kHalf transcendental calls.
  float inv2s2 = 1.0 / (2.0 * sigma * sigma);
  float g1 = exp(-stride * stride * inv2s2);
  float g2 = g1 * g1;

  vec4 acc = texture(uTexture, uv); // centre tap, weight 1
  float wsum = 1.0;
  float w = 1.0; // will be multiplied by g1 at top of first iteration
  for (int i = 1; i <= kHalf; i++) {
    float d = float(i) * stride;    // device px offset (needed for UV)
    w *= g1;                        // w = exp(-(i*stride)² * inv2s2) ✓
    g1 *= g2;                       // advance g1 for next iteration
    vec2 off = axis * d;            // uv offset
    vec2 sp = uv + off;
    vec2 sm = uv - off;
    // Discard out-of-bounds taps (clamping would smear the edge pixel).
    float ip = step(0.0, sp.x) * step(sp.x, 1.0) * step(0.0, sp.y) * step(sp.y, 1.0);
    float im = step(0.0, sm.x) * step(sm.x, 1.0) * step(0.0, sm.y) * step(sm.y, 1.0);
    acc += texture(uTexture, clamp(sp, 0.0, 1.0)) * (w * ip);
    acc += texture(uTexture, clamp(sm, 0.0, 1.0)) * (w * im);
    wsum += w * ip + w * im;
  }

  fragColor = acc / wsum;
}
