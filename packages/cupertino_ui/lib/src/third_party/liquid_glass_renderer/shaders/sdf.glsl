// Copyright 2025, Tim Lehmann for whynotmake.it
// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Originally: SDF primitives (sdfRRect, sdfRect, sdfSquircle) and smoothUnion;
//             MAX_SHAPES=64, dynamic array indexing, for-loop scene composition.
// Modifications (2026):
//   - Added sdfEllipse(), sdfPolygon(), and sdfStar() primitives.
//   - Rewrote scene composition to fully unrolled sdf0()…sdf15() helpers with
//     literal-only indexing for Windows/SkSL SPIR-V compatibility.
//   - Replaced for-loop sceneSDF with symmetric bidirectional blend (fwd+bwd).
//   - Reduced MAX_SHAPES from 64 to 16 to fit Impeller's uniform buffer limit.
//   - Extended shape slot from 6 to 7 floats (added shape-type discriminant).
//
// SDF primitives and scene composition for liquid glass geometry shaders.
//
// ── Windows / SkSL compatibility ─────────────────────────────────────────────
// SkSL (Skia's shader language, used on Windows) compiles GLSL to SPIR-V via
// glslang.  glslang enforces the GLSL ES 1.0 rule that array indices MUST be
// constant-integral-expressions.  Computing `index * 6 + offset` at runtime
// and using the result to index uShapeData[] fails with:
//   error: index expression must be constant
//
// Fix: every uShapeData[] access uses a literal integer index only.
// getShapeSDFFromArray() is gone; sdf0()…sdf15() helpers expand each
// shape slot with hardcoded literal offsets so glslang sees only constants.
// sceneSDF is fully unrolled — no for-loops, no dynamic indexing.
//
// ── Backward pass correctness ─────────────────────────────────────────────────
// The symmetric bidirectional blend is a left-fold in both directions:
//   fwd(n) = leftFold(smoothUnion, [s0, s1, …, s_{n-1}], k)
//   bwd(n) = leftFold(smoothUnion, [s_{n-1}, s_{n-2}, …, s0], k)
// result  = mix(fwd, bwd, 0.5)
//
// The backward pass for each n is computed with named intermediate variables
// rather than deeply-nested call expressions, so the GLSL parser never sees
// expression depth > 3 regardless of n.  This avoids the "exceeded max parse
// depth" error that the user-attempted loop-expansion triggered.
//
// ── Shape slots ──────────────────────────────────────────────────────────────
// Each shape occupies 7 consecutive floats in uShapeData[]:
//   [base+0] type             1=squircle/superellipse  2=ellipse  3=roundrect
//   [base+1] center.x
//   [base+2] center.y
//   [base+3] size.x
//   [base+4] size.y
//   [base+5] cornerRadius     (top corners; or symmetric)
//   [base+6] bottomCornerRadius (bottom corners; equals [base+5] for symmetric)

#include "gles_compat.glsl"

#ifndef MAX_SHAPES
#define MAX_SHAPES 16
#endif

// ── SDF primitives ────────────────────────────────────────────────────────────

float sdfRRect(in vec2 p, in vec2 b, in float r) {
    float shortest = min(b.x, b.y);
    r = min(r, shortest);
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

// Asymmetric rounded-rect SDF: independent top/bottom corner radii.
//
// Computes two `sdfRRect` evaluations (one with rTop applied to all corners,
// one with rBottom) and `mix`es them along p.y with a smooth `smoothstep`
// across the horizontal centerline. This keeps the SDF — and therefore its
// gradient — continuous across the centerline, which matters for the
// geometry-blended pipeline that derives surface normals from dFdx/dFdy of
// the SDF: a per-quadrant `r = p.y < 0 ? rTop : rBottom` lookup would emit
// garbage normals along the centerline. 2-pixel half-width matches the
// typical anti-aliasing band on Skia/Impeller.
//
// Outside the corner regions both inner SDFs agree (the radius doesn't enter
// the distance formula along the straight edges), so the blend is a no-op
// there and only the corner regions actually differ. When rTop == rBottom,
// dT == dB and `mix` returns either value unchanged — symmetric shapes are
// bit-exact identical to a plain `sdfRRect(p, b, r)` call.
float sdfRRectAsym(in vec2 p, in vec2 b, in float rTop, in float rBottom) {
    float dT = sdfRRect(p, b, rTop);
    float dB = sdfRRect(p, b, rBottom);
    float t = smoothstep(-2.0, 2.0, p.y);
    return mix(dT, dB, t);
}

float sdfRect(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// ── Analytic Squircle SDF (Ln-Norm) ─────────────────────────────────────────
// Matches Flutter's native RoundedSuperellipseBorder (ClipRSuperellipse).
// Uses a pure Lamé curve (|x|^n + |y|^n = 1) instead of a piecewise seam.
// This completely eliminates the 45-degree seam blending artifacts.

float fastPow(float x, float n) { 
    return exp2(n * log2(max(x, 1e-4))); 
}

float squircleShape(vec2 p, vec2 b, float zone, float n) {
    vec2 q = abs(p) - b + zone;
    vec2 m = max(q, 0.0);
    float M = max(m.x, m.y);
    float corner = 0.0;
    if (M > 1e-4) {
        vec2 mNorm = m / M;
        corner = M * fastPow(fastPow(mNorm.x, n) + fastPow(mNorm.y, n), 1.0 / n);
    }
    return min(max(q.x, q.y), 0.0) + corner - zone;
}

// sdfSquircle: analytic squircle SDF with graceful degradation.
//
// CRITICAL: n (the Lamé exponent) is derived from the CLAMPED zone, not the
// raw r*1.528 zone. This ensures the SDF's lighting and gradient match
// Flutter's RoundedSuperellipseBorder path exactly:
//
//   Normal squircle  → zone = r*1.528 (unclamped) → n ≈ 3.26
//   Partial clamp    → zone < r*1.528              → n smoothly decreases
//   Full pill clamp  → zone = r (r ≥ half-height)  → n = 2.0 (pure circle)
//
// Without this, the shader draws a squarish SDF (n≈3.26) inside a clip that
// Flutter already forced to a circle (n=2), causing the lighting/glow to
// appear misaligned from the visual edge on pill-shaped squircles.
float sdfSquircle(in vec2 p, in vec2 b, in float r) {
    float boxShort = min(b.x, b.y);
    r    = min(r, boxShort);
    float zone = min(r * 1.528, boxShort);
    float base = 1.0 - 0.29289322 * (r / max(zone, 1e-4));
    float n    = -1.0 / log2(clamp(base, 0.5, 0.9999));
    return squircleShape(p, b, zone, n);
}

float sdfSquircleAsym(in vec2 p, in vec2 b, in float rTop, in float rBottom) {
    // Most shapes round all four corners alike, and then both halves below
    // are the same squircle: evaluate it once.
    if (rTop == rBottom) {
        return sdfSquircle(p, b, rTop);
    }
    float boxShort = min(b.x, b.y);
    rTop    = min(rTop,    boxShort);
    rBottom = min(rBottom, boxShort);

    float zoneT = min(rTop    * 1.528, boxShort);
    float baseT = 1.0 - 0.29289322 * (rTop    / max(zoneT, 1e-4));
    float nT    = -1.0 / log2(clamp(baseT, 0.5, 0.9999));
    float dT    = squircleShape(p, b, zoneT, nT);

    float zoneB = min(rBottom * 1.528, boxShort);
    float baseB = 1.0 - 0.29289322 * (rBottom / max(zoneB, 1e-4));
    float nB    = -1.0 / log2(clamp(baseB, 0.5, 0.9999));
    float dB    = squircleShape(p, b, zoneB, nB);

    float t = smoothstep(-2.0, 2.0, p.y);
    return mix(dT, dB, t);
}

float sdfEllipse(vec2 p, vec2 r) {
    r = max(r, 1e-4);
    vec2 invR   = 1.0 / r;
    vec2 invR2  = invR * invR;
    vec2 pInvR  = p * invR;
    float k1    = length(pInvR);
    vec2  pInvR2 = p * invR2;
    float k2    = length(pInvR2);
    return (k1 * (k1 - 1.0)) / max(k2, 1e-4);
}

// Branchless smooth-union.
// When k=0: e=0, result = min(d1,d2) — identical to the branching form.
float smoothUnion(float d1, float d2, float k) {
    float e = max(k - abs(d1 - d2), 0.0);
    return min(d1, d2) - e * e * 0.25 / max(k, 1e-5);
}

// ── Per-type dispatch ─────────────────────────────────────────────────────────

// rTop / rBottom collapse to a single radius for symmetric shapes (caller
// writes rBottom == rTop), so this dispatch is back-compat: routing through
// `sdfRRectAsym` with equal radii is bit-identical to `sdfRRect`.
float getShapeSDF(float type, vec2 p, vec2 center, vec2 size, float rTop, float rBottom) {
    if      (type == 1.0) return sdfSquircleAsym(p - center, size / 2.0, rTop, rBottom);
    else if (type == 2.0) return sdfEllipse  (p - center, size / 2.0);
    else if (type == 3.0) return sdfRRectAsym(p - center, size / 2.0, rTop, rBottom);
    return 0.0;
}

// ── Constant-index shape accessors ───────────────────────────────────────────
// Macro reads uShapeData[] with *literal* offsets only — satisfies the GLSL ES
// / SkSL / glslang requirement that array indices be constant expressions.
// uShapeData[] is declared by the including shader before #include "sdf.glsl".
//
// Stride: 7 floats per shape (was 6). Slot +6 is the bottom corner radius;
// see the layout comment near the top of this file.

#define SDF_SHAPE_N(BASE) \
    getShapeSDF(uShapeData[BASE], p, \
                vec2(uShapeData[BASE+1], uShapeData[BASE+2]), \
                vec2(uShapeData[BASE+3], uShapeData[BASE+4]), \
                uShapeData[BASE+5], \
                uShapeData[BASE+6])

float sdf0(vec2 p)  { return SDF_SHAPE_N(0);   }
float sdf1(vec2 p)  { return SDF_SHAPE_N(7);   }
float sdf2(vec2 p)  { return SDF_SHAPE_N(14);  }
float sdf3(vec2 p)  { return SDF_SHAPE_N(21);  }
float sdf4(vec2 p)  { return SDF_SHAPE_N(28);  }
float sdf5(vec2 p)  { return SDF_SHAPE_N(35);  }
float sdf6(vec2 p)  { return SDF_SHAPE_N(42);  }
float sdf7(vec2 p)  { return SDF_SHAPE_N(49);  }
#ifndef LGR_OPENGLES_CAP_SHAPES
float sdf8(vec2 p)  { return SDF_SHAPE_N(56);  }
float sdf9(vec2 p)  { return SDF_SHAPE_N(63);  }
float sdf10(vec2 p) { return SDF_SHAPE_N(70);  }
float sdf11(vec2 p) { return SDF_SHAPE_N(77);  }
float sdf12(vec2 p) { return SDF_SHAPE_N(84);  }
float sdf13(vec2 p) { return SDF_SHAPE_N(91);  }
float sdf14(vec2 p) { return SDF_SHAPE_N(98);  }
float sdf15(vec2 p) { return SDF_SHAPE_N(105); }
#endif

// ── sceneSDF — fully unrolled, no loops, no dynamic indices ──────────────────
//
// MAINTAINER GUIDE — READ BEFORE EDITING
// ────────────────────────────────────────
// This function is intentionally written in a fully-unrolled style.
// This is NOT a code-quality issue; it is the correct cross-platform
// approach for GLSL that must compile on both Impeller/Metal AND
// SkSL/glslang (Windows), where dynamic array indices are illegal.
//
// HOW IT WORKS
//   Symmetric bidirectional smooth-union, averaged 50/50:
//     fwd(n) = leftFold(smoothUnion, [s0,  s1, …, s_{n-1}], k)  (L→R)
//     bwd(n) = leftFold(smoothUnion, [s_{n-1}, …, s1,  s0], k)  (R→L)
//     result = mix(fwd, bwd, 0.5)
//   This cancels the blend-influence asymmetry in multi-shape groups.
//   For n=2 smoothUnion is commutative so fwd==bwd (no visual change vs n=1).
//
// WHAT IS SAFE TO CHANGE — single touch points that propagate everywhere:
//   • Shape type logic        → edit getShapeSDF()     above
//   • Blend formula           → edit smoothUnion()     above
//   • Shape data layout       → edit SDF_SHAPE_N macro above (and sdf0…sdf15)
//
// WHAT REQUIRES UNROLL UPDATE — mechanical but must be consistent:
//   • Increasing MAX_SHAPES   → add sdfN() below, add one more n==N block
//     with the same bNa/bNb/… intermediate-variable pattern shown for n=16.
//   • Changing the fwd/bwd averaging strategy → update all 16 n-blocks;
//     they all follow the same pattern so find-replace is reliable.
//
// WHY NOT #ifdef IMPELLER_TARGET_METAL + dynamic fallback?
//   That would require maintaining two separate algorithm copies that must
//   be kept in sync — a higher maintenance burden than the unrolled form.
//   The literal-index version is equally or more efficient on Metal too,
//   since the compiler can constant-fold and prefetch known offsets.

float sceneSDF(vec2 p, int n, float k) {
    if (n <= 0) return 1e9;

    // ── n = 1 ────────────────────────────────────────────────────────────────
    float s0 = sdf0(p);
    if (n == 1) return s0;

    // ── n = 2 ────────────────────────────────────────────────────────────────
    float s1  = sdf1(p);
    float fwd = smoothUnion(s0, s1, k);
    // bwd(2): smooth(s1, s0) — smoothUnion is commutative for n=2
    float bwd = smoothUnion(s1, s0, k);
    if (n == 2) return mix(fwd, bwd, 0.5);

    // ── n = 3 ────────────────────────────────────────────────────────────────
    float s2  = sdf2(p);
    fwd = smoothUnion(fwd, s2, k);
    // bwd(3): leftFold([s2, s1, s0])
    // = smooth(smooth(s2, s1), s0)
    float b3a = smoothUnion(s2, s1, k);
    bwd       = smoothUnion(b3a, s0, k);
    if (n == 3) return mix(fwd, bwd, 0.5);

    // ── n = 4 ────────────────────────────────────────────────────────────────
    float s3  = sdf3(p);
    fwd = smoothUnion(fwd, s3, k);
    // bwd(4): smooth(smooth(smooth(s3, s2), s1), s0)
    float b4a = smoothUnion(s3, s2, k);
    float b4b = smoothUnion(b4a, s1, k);
    bwd       = smoothUnion(b4b, s0, k);
    if (n == 4) return mix(fwd, bwd, 0.5);

    // ── n = 5 ────────────────────────────────────────────────────────────────
    float s4  = sdf4(p);
    fwd = smoothUnion(fwd, s4, k);
    float b5a = smoothUnion(s4, s3, k);
    float b5b = smoothUnion(b5a, s2, k);
    float b5c = smoothUnion(b5b, s1, k);
    bwd       = smoothUnion(b5c, s0, k);
    if (n == 5) return mix(fwd, bwd, 0.5);

    // ── n = 6 ────────────────────────────────────────────────────────────────
    float s5  = sdf5(p);
    fwd = smoothUnion(fwd, s5, k);
    float b6a = smoothUnion(s5, s4, k);
    float b6b = smoothUnion(b6a, s3, k);
    float b6c = smoothUnion(b6b, s2, k);
    float b6d = smoothUnion(b6c, s1, k);
    bwd       = smoothUnion(b6d, s0, k);
    if (n == 6) return mix(fwd, bwd, 0.5);

    // ── n = 7 ────────────────────────────────────────────────────────────────
    float s6  = sdf6(p);
    fwd = smoothUnion(fwd, s6, k);
    float b7a = smoothUnion(s6, s5, k);
    float b7b = smoothUnion(b7a, s4, k);
    float b7c = smoothUnion(b7b, s3, k);
    float b7d = smoothUnion(b7c, s2, k);
    float b7e = smoothUnion(b7d, s1, k);
    bwd       = smoothUnion(b7e, s0, k);
    if (n == 7) return mix(fwd, bwd, 0.5);

    // ── n = 8 ────────────────────────────────────────────────────────────────
    float s7  = sdf7(p);
    fwd = smoothUnion(fwd, s7, k);
    float b8a = smoothUnion(s7, s6, k);
    float b8b = smoothUnion(b8a, s5, k);
    float b8c = smoothUnion(b8b, s4, k);
    float b8d = smoothUnion(b8c, s3, k);
    float b8e = smoothUnion(b8d, s2, k);
    float b8f = smoothUnion(b8e, s1, k);
    bwd       = smoothUnion(b8f, s0, k);
    if (n == 8) return mix(fwd, bwd, 0.5);

#ifdef LGR_OPENGLES_CAP_SHAPES
    // On OpenGL ES / ANGLE (Windows and Android GLES), clamp evaluation to 8
    // shapes maximum to avoid AST node explosion in runtime JIT compilers
    // (e.g. Intel Arc ANGLE / PowerVR GE8320).
    return mix(fwd, bwd, 0.5);
#else
    // ── n = 9 ────────────────────────────────────────────────────────────────
    float s8  = sdf8(p);
    fwd = smoothUnion(fwd, s8, k);
    float b9a = smoothUnion(s8, s7, k);
    float b9b = smoothUnion(b9a, s6, k);
    float b9c = smoothUnion(b9b, s5, k);
    float b9d = smoothUnion(b9c, s4, k);
    float b9e = smoothUnion(b9d, s3, k);
    float b9f = smoothUnion(b9e, s2, k);
    float b9g = smoothUnion(b9f, s1, k);
    bwd       = smoothUnion(b9g, s0, k);
    if (n == 9) return mix(fwd, bwd, 0.5);

    // ── n = 10 ───────────────────────────────────────────────────────────────
    float s9   = sdf9(p);
    fwd = smoothUnion(fwd, s9, k);
    float b10a = smoothUnion(s9, s8, k);
    float b10b = smoothUnion(b10a, s7, k);
    float b10c = smoothUnion(b10b, s6, k);
    float b10d = smoothUnion(b10c, s5, k);
    float b10e = smoothUnion(b10d, s4, k);
    float b10f = smoothUnion(b10e, s3, k);
    float b10g = smoothUnion(b10f, s2, k);
    float b10h = smoothUnion(b10g, s1, k);
    bwd        = smoothUnion(b10h, s0, k);
    if (n == 10) return mix(fwd, bwd, 0.5);

    // ── n = 11 ───────────────────────────────────────────────────────────────
    float s10   = sdf10(p);
    fwd = smoothUnion(fwd, s10, k);
    float b11a  = smoothUnion(s10, s9, k);
    float b11b  = smoothUnion(b11a, s8, k);
    float b11c  = smoothUnion(b11b, s7, k);
    float b11d  = smoothUnion(b11c, s6, k);
    float b11e  = smoothUnion(b11d, s5, k);
    float b11f  = smoothUnion(b11e, s4, k);
    float b11g  = smoothUnion(b11f, s3, k);
    float b11h  = smoothUnion(b11g, s2, k);
    float b11i  = smoothUnion(b11h, s1, k);
    bwd         = smoothUnion(b11i, s0, k);
    if (n == 11) return mix(fwd, bwd, 0.5);

    // ── n = 12 ───────────────────────────────────────────────────────────────
    float s11   = sdf11(p);
    fwd = smoothUnion(fwd, s11, k);
    float b12a  = smoothUnion(s11, s10, k);
    float b12b  = smoothUnion(b12a, s9, k);
    float b12c  = smoothUnion(b12b, s8, k);
    float b12d  = smoothUnion(b12c, s7, k);
    float b12e  = smoothUnion(b12d, s6, k);
    float b12f  = smoothUnion(b12e, s5, k);
    float b12g  = smoothUnion(b12f, s4, k);
    float b12h  = smoothUnion(b12g, s3, k);
    float b12i  = smoothUnion(b12h, s2, k);
    float b12j  = smoothUnion(b12i, s1, k);
    bwd         = smoothUnion(b12j, s0, k);
    if (n == 12) return mix(fwd, bwd, 0.5);

    // ── n = 13 ───────────────────────────────────────────────────────────────
    float s12   = sdf12(p);
    fwd = smoothUnion(fwd, s12, k);
    float b13a  = smoothUnion(s12, s11, k);
    float b13b  = smoothUnion(b13a, s10, k);
    float b13c  = smoothUnion(b13b, s9, k);
    float b13d  = smoothUnion(b13c, s8, k);
    float b13e  = smoothUnion(b13d, s7, k);
    float b13f  = smoothUnion(b13e, s6, k);
    float b13g  = smoothUnion(b13f, s5, k);
    float b13h  = smoothUnion(b13g, s4, k);
    float b13i  = smoothUnion(b13h, s3, k);
    float b13j  = smoothUnion(b13i, s2, k);
    float b13k  = smoothUnion(b13j, s1, k);
    bwd         = smoothUnion(b13k, s0, k);
    if (n == 13) return mix(fwd, bwd, 0.5);

    // ── n = 14 ───────────────────────────────────────────────────────────────
    float s13   = sdf13(p);
    fwd = smoothUnion(fwd, s13, k);
    float b14a  = smoothUnion(s13, s12, k);
    float b14b  = smoothUnion(b14a, s11, k);
    float b14c  = smoothUnion(b14b, s10, k);
    float b14d  = smoothUnion(b14c, s9, k);
    float b14e  = smoothUnion(b14d, s8, k);
    float b14f  = smoothUnion(b14e, s7, k);
    float b14g  = smoothUnion(b14f, s6, k);
    float b14h  = smoothUnion(b14g, s5, k);
    float b14i  = smoothUnion(b14h, s4, k);
    float b14j  = smoothUnion(b14i, s3, k);
    float b14k  = smoothUnion(b14j, s2, k);
    float b14l  = smoothUnion(b14k, s1, k);
    bwd         = smoothUnion(b14l, s0, k);
    if (n == 14) return mix(fwd, bwd, 0.5);

    // ── n = 15 ───────────────────────────────────────────────────────────────
    float s14   = sdf14(p);
    fwd = smoothUnion(fwd, s14, k);
    float b15a  = smoothUnion(s14, s13, k);
    float b15b  = smoothUnion(b15a, s12, k);
    float b15c  = smoothUnion(b15b, s11, k);
    float b15d  = smoothUnion(b15c, s10, k);
    float b15e  = smoothUnion(b15d, s9, k);
    float b15f  = smoothUnion(b15e, s8, k);
    float b15g  = smoothUnion(b15f, s7, k);
    float b15h  = smoothUnion(b15g, s6, k);
    float b15i  = smoothUnion(b15h, s5, k);
    float b15j  = smoothUnion(b15i, s4, k);
    float b15k  = smoothUnion(b15j, s3, k);
    float b15l  = smoothUnion(b15k, s2, k);
    float b15m  = smoothUnion(b15l, s1, k);
    bwd         = smoothUnion(b15m, s0, k);
    if (n == 15) return mix(fwd, bwd, 0.5);

    // ── n = 16 (MAX_SHAPES) ───────────────────────────────────────────────────
    float s15   = sdf15(p);
    fwd = smoothUnion(fwd, s15, k);
    float b16a  = smoothUnion(s15, s14, k);
    float b16b  = smoothUnion(b16a, s13, k);
    float b16c  = smoothUnion(b16b, s12, k);
    float b16d  = smoothUnion(b16c, s11, k);
    float b16e  = smoothUnion(b16d, s10, k);
    float b16f  = smoothUnion(b16e, s9, k);
    float b16g  = smoothUnion(b16f, s8, k);
    float b16h  = smoothUnion(b16g, s7, k);
    float b16i  = smoothUnion(b16h, s6, k);
    float b16j  = smoothUnion(b16i, s5, k);
    float b16k  = smoothUnion(b16j, s4, k);
    float b16l  = smoothUnion(b16k, s3, k);
    float b16m  = smoothUnion(b16l, s2, k);
    float b16n  = smoothUnion(b16m, s1, k);
    bwd         = smoothUnion(b16n, s0, k);
    return mix(fwd, bwd, 0.5);
#endif
}
