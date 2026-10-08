// Copyright 2025, Tim Lehmann for whynotmake.it
// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// Originally: Final render pass reading displacement texture; basic refraction
// Modifications (2026):
//   - Migrated to V1 surface normal encoding (displacement_encoding.glsl V1).
//   - Added chromatic aberration pass (RGB channel split on refraction vector).
//   - Added Rec. 709 saturation control (applySaturation).
//   - Added iOS 26-style luminosity-preserving tint (applyGlassColor).
//   - Added meniscus darkening (VQ5) for physical glass depth.
//   - Switched from mediump to highp to eliminate colour banding on mobile.
//   - Expanded from ~62 lines to full multi-pass pipeline (~487 lines).
//   - Uniform layout migrated to explicit layout(location) slots for Impeller.
//   - Added the iOS 27 material: hairline outline and rim light (uRimConfig),
//     paraxial lens (uLensModel) and the frost read from interleaved rows
//     (uFrost).
//
// Final rendering pass for liquid glass with pre-computed geometry.
// Reads surface normal data from the geometry texture (V1 encoding) and applies
// the liquid glass effect: refraction, chromatic aberration, tint, and edge lighting.
//
// Geometry texture layout (displacement_encoding.glsl):
//   R: normal.x  [-1, 1] → [0, 1]
//   G: normal.y  [-1, 1] → [0, 1]
//   B: height    normalized to thickness
//   A: foreground alpha (SDF AA)

#version 460 core
precision highp float; // mediump causes colour banding (10-bit mantissa on mobile)

#define DEBUG_GEOMETRY 0

#include <flutter/runtime_effect.glsl>
#include "displacement_encoding.glsl"
#include "gles_compat.glsl"
#include "render.glsl"

// Slot 0-1:  uSize           — physical-pixel size of the backdrop capture
// Slots 2-3: uGeometryOffset — top-left of geometry matte in physical pixels
// Slots 4-5: uGeometrySize   — size of geometry matte in physical pixels
// Slots 6-9: uGlassColor
// Slots 10-12: uOpticalProps (refractiveIndex, chromaticAberration, thickness)
// Slots 13-15: uLightConfig  (lightIntensity, ambientStrength, saturation)
// Slots 16-17: uLightDirection
// Slots 10:  uOpticalProps   — refractiveIndex, chromaticAberration, thickness, refractScale
// Slots 11:  uLightConfig    — lightIntensity, ambientStrength, saturation
// Slots 12:  uLightDirection — lightDirection.x, lightDirection.y
// Slots 13:  uWhiten, uWhitenGated, uPinchStrength
// Slots 14-15: uBackgroundFallback
// Slots 16:  uCaptureOffset  — x, y
// Slots 17:  uEdgeConfig     — ambientRim (scaled by DPR/3.0), fresnelStrength, dprScale (DPR/3.0), pad
uniform vec2 uSize;
uniform vec2 uGeometryOffset;
uniform vec2 uGeometrySize;
uniform vec4 uGlassColor;
uniform vec4 uOpticalProps; // x: refractiveIndex, y: chromaticAberration, z: thickness, w: refractScale
uniform vec3 uLightConfig;
uniform vec2 uLightDirection;
uniform float uWhiten;
// Slot 19: uWhitenGated. 1 = the whiten is luminance-gated (protects dark
// pixels — the light-mode behaviour, keeps text/icons beneath the glass dark);
// 0 = ungated, uniform whiten across the whole control (the dark-mode
// behaviour, gives dark glass a small even lift toward white).
uniform float uWhitenGated;

// Slot 20: uPinchStrength. Concave horizontal-pinch strength [0..1].
// When > 0, the pill's refraction is squeezed inward at the left/right edges,
// creating the iOS 26 "pinched through a lens" look. The centre is left flat.
uniform float uPinchStrength;

// Slot 21-24: uBackgroundFallback — Per-mode opaque stand-in for backdrop
// regions the engine can't capture (e.g. a PlatformView past the glass).
// Straight (non-premultiplied) RGBA; a == 0 disables it.
uniform vec4 uBackgroundFallback;

// Slot 25-26: uCaptureOffset — physical-pixel offset from the render surface
// origin to the capture-boundary origin. Only non-zero on the Impeller capture
// path (GlassEffect with backgroundKey on Impeller premium). When zero (the
// default / BackdropFilter path), (fragCoord + uCaptureOffset) == fragCoord, so
// this is a mathematical no-op and has zero performance impact on existing paths.
//
// BackdropFilter mode (default, uCaptureOffset == vec2(0)):
//   FlutterFragCoord() is screen-space physical pixels.
//   uSize == full-screen physical pixel size.
//   screenUV = fragCoord / uSize → samples the backdrop at screen position.
//
// Capture mode (uCaptureOffset != vec2(0)):
//   FlutterFragCoord() is RepaintBoundary-surface-space physical pixels.
//   uSize == captured image physical pixel size.
//   uCaptureOffset shifts fragCoord so that (fragCoord + offset) is the
//   position within the capture image — mapping the indicator's fragment
//   to the correct texel in the pre-captured bar texture.
uniform vec2 uCaptureOffset;

// Slot 28-31: uEdgeConfig — x: ambientRim (scaled by DPR/3.0), y: fresnelStrength, z: dprScale (DPR/3.0), w: pad
uniform vec4 uEdgeConfig;

// Slot 32: uPlatformViewMode — 0 = fallbackColor (default), 1 = passthrough.
// See PlatformViewGlassMode. At 0 this shader is bit for bit unchanged.
uniform float uPlatformViewMode;

// Slot 33: uBodyMode — 0 = adaptive (default, iOS 26 Glass.regular), 1 = clear (iOS 26 Glass.clear).
// See GlassBodyMode. In clear mode, luminance normalization is bypassed for direct alpha compositing.
uniform float uBodyMode;

// Slots 34-35: uTouchPosition — touch point in physical pixels (layer-local).
// Dart side multiplies logical-px touch coordinates by DPR before setting this
// uniform so the coordinate space matches fragCoord (physical pixels).
// Set to vec2(0.0) at rest — only meaningful when uTouchIntensity > 0.
uniform vec2 uTouchPosition;

// Slot 36: uTouchIntensity — spring-animated touch presence [0.0 at rest, 1.0 while pressed].
// Driven by GlassGlowLayerState._alphaController.value via ValueNotifier.
// When 0.0, the touch-specular block is skipped entirely (uniform coherence;
// effectively free on all GPU architectures).
uniform float uTouchIntensity;

// Slots 37-39: uRimConfig — x: rimShade, y: rimLight, z: rimShadeEnds.
// rimShade and rimLight default to 0, at which the rim passes below are
// skipped and this shader is bit for bit unchanged. See
// LiquidGlassSettings.rimShade / rimLight for the iOS 27 hairline outline
// and edge highlight they draw.
uniform vec3 uRimConfig;

// Slot 40: uLensModel — 0 = spherical (default, exact Snell refraction
// through the hemispherical bevel), 1 = paraxial (small-angle deviation,
// (n - 1) times the slope taken as sin^2 of the incidence). See
// GlassLensModel.
uniform float uLensModel;

// Slots 41-44: uFrost — x: frostOpacity (0 = no frost), y: frostClamp,
// z: ghost blur sigma in physical px, w: blurWeight (how many times a white
// texel outweighs a black one in the ghost).
// With a frost the layer runs one blur pass before this shader, clipped to
// the shape and to alternate pixel rows (those with an odd pass-relative y),
// so the backdrop this shader reads holds the frost's cloud on odd rows and
// the sharp backdrop on even rows. The ghost, the clamp and the mix are all
// done here from those two, in the one pass. See frostAt(). With a
// frostWeight both carry a weight in their alpha, colour premultiplied by
// it, which texelAt() takes back out.
uniform vec4 uFrost;

// Slot 45: uBodyShade — how far a bright backdrop is pulled down; 0, the
// default, leaves this shader bit for bit unchanged. See
// LiquidGlassSettings.bodyShade.
uniform float uBodyShade;

uniform sampler2D uBackgroundTexture;
uniform sampler2D uGeometryTexture;

layout(location = 0) out vec4 fragColor;

// ── Manual Bilinear Filtering ─────────────────────────────────────────────
// Impeller's implicit BackdropFilterLayer sampler is bound to the
// FragmentShader as Nearest-Neighbor with no Dart API to override it.
// Tracked as:
//   Flutter Issue #139887 — original bug report (NN aliasing on backdrop)
//   Flutter Issue #188365 — feature request to expose FilterQuality on
//                           BackdropFilterLayer (filed during 0.18.2 work)
// Once #188365 is resolved, this entire function can be replaced with a
// single texture() call and the physTexSize/invTexSize derivation removed.
//
// On-screen bilinear is lost without this workaround, which means continuous
// sub-pixel UV shifts (pinch lens, refraction) snap to integer texels and
// produce stair-step aliasing on high-contrast background edges.
//
// This function replaces all uBackgroundTexture lookups with 4 Nearest-Neighbor
// fetches and a standard bilinear mix, restoring perfectly smooth sub-pixel
// sampling at the cost of 3 additional cache-hot reads per invocation.
//
// NOTE: uGeometryTexture is intentionally excluded — it is a pre-rasterized
// SDF picture whose texels are pixel-aligned by construction. Bilinear
// filtering it would soften the SDF alpha channel and degrade anti-aliasing.
//
// Windows/SkSL: texture() with literal-computed UVs is legal in glslang
// SPIR-V path; floor(), fract(), and vec2 arithmetic are all universally
// supported. This function introduces no new platform compatibility issues.
vec4 textureBilinear(vec2 uv, vec2 size, vec2 invSize) {
    vec2 px = uv * size - 0.5;
    vec2 f = fract(px);
    vec2 p0 = floor(px);
    vec2 p1 = p0 + vec2(1.0, 0.0);
    vec2 p2 = p0 + vec2(0.0, 1.0);
    vec2 p3 = p0 + vec2(1.0, 1.0);

    vec4 c0 = texture(uBackgroundTexture, (p0 + 0.5) * invSize);
    vec4 c1 = texture(uBackgroundTexture, (p1 + 0.5) * invSize);
    vec4 c2 = texture(uBackgroundTexture, (p2 + 0.5) * invSize);
    vec4 c3 = texture(uBackgroundTexture, (p3 + 0.5) * invSize);

    vec4 cTop = mix(c0, c1, f.x);
    vec4 cBot = mix(c2, c3, f.x);
    vec4 bg = mix(cTop, cBot, f.y);

    // Composite the (premultiplied) backdrop sample OVER the fallback colour.
    // Where the engine couldn't capture a backdrop (a PlatformView past the bar
    // → transparent black, bg.a ≈ 0) this yields the fallback; where the
    // backdrop is real (bg.a ≈ 1) it is left untouched. uBackgroundFallback is
    // straight RGBA, so premultiply it by its own alpha before the over.
    //
    // Phase 3B (perf): The alpha check is a uniform — coherent across the entire
    // draw call — so the GPU branch predictor takes it for free. In the common
    // case (no PlatformView / platformViewFallbackColor not set) this skips 4
    // MADs and a 2× MAD per sample point.
    if (uBackgroundFallback.a > 0.0) {
        bg.rgb += uBackgroundFallback.rgb * uBackgroundFallback.a * (1.0 - bg.a);
        bg.a += uBackgroundFallback.a * (1.0 - bg.a);
    }
    return bg;
}

// Nearest texel at pixel [p] (pass-relative, whole pixels) as straight RGB.
vec3 texelAt(vec2 p, vec2 invSize) {
    vec2 uv = (p + 0.5) * invSize;
    #ifdef LGR_GLES_FLIP_SAMPLE_Y
        uv.y = 1.0 - uv.y;
    #endif
    vec4 c = texture(uBackgroundTexture, uv);
    return c.a > 0.001 ? c.rgb / c.a : c.rgb;
}

// The frost at [p], a pass-relative position in physical px, with the cloud
// read at [q] (kept a few px inside the shape, where the cloud rows are).
//
// Ghost: a Gaussian of uFrost.z px over the sharp (even) rows around p,
// each texel weighted by its luminance (uFrost.w, blurWeight).
// Cloud: the two odd rows either side of q, which hold the blur pass's
// output. The ghost is held within frostClamp of the cloud on one side, then
// the cloud is laid over it at frostOpacity:
//   frost = op * cloud + (1 - op) * max(ghost, cloud - clamp)   (clamp > 0)
//   frost = op * cloud + (1 - op) * min(ghost, cloud - clamp)   (clamp < 0)
vec3 frostAt(vec2 p, vec2 q, vec2 invSize) {
    vec2 qb = floor(q);
    float ya = qb.y - mod(qb.y + 1.0, 2.0); // odd row at or above q
    float t = clamp((q.y - (ya + 0.5)) * 0.5, 0.0, 1.0);
    vec3 cloud = mix(texelAt(vec2(qb.x, ya), invSize),
                     texelAt(vec2(qb.x, ya + 2.0), invSize), t);
    // A fully opaque cloud hides the ghost: mix(held, cloud, 1.0) is cloud,
    // so skip the 45 taps it would take. uFrost.x is uniform, so the whole
    // draw takes the same branch.
    if (uFrost.x >= 1.0) {
        return cloud;
    }

    float sigma = max(uFrost.z, 0.3);
    vec2 base = floor(p);
    // Snap the centre row to the even (sharp) row at or above p.
    float cy = base.y - mod(base.y, 2.0);
    // Separable Gaussian weights over 9 columns at 1 px and 5 even rows at
    // 2 px: +-4 px, which holds the widest sigma the layer leaves to this
    // pass (2.4 px); a wider blur runs as its own pass first.
    float inv2s2 = 1.0 / (2.0 * sigma * sigma);
    float wx[9];
    for (int i = 0; i < 9; i++) {
        float dx = base.x + float(i - 4) + 0.5 - p.x;
        wx[i] = exp(-dx * dx * inv2s2);
    }
    // Each texel also weighs by its luminance, white uFrost.w times as much
    // as black: below 1 dark detail dominates the ghost.
    float slope = uFrost.w - 1.0;
    vec3 acc = vec3(0.0);
    float wsum = 0.0;
    if (uFrost.z <= 0.3) {
        // At the floor sigma of 0.3 px only the three columns around p on
        // the two even rows either side of it carry weight: every other tap
        // weighs under 4e-6 of the centre, so these 6 taps come out within
        // 0.03/255 of all 45, with the luminance weighting at its extremes
        // (frost_ghost_taps_test.dart). That is the sigma whenever the blur
        // runs as its own pass or is 0. uFrost.z is uniform.
        for (int j = 0; j <= 1; j++) {
            float y = cy + 2.0 * float(j);
            float dy = y + 0.5 - p.y;
            float wy = exp(-dy * dy * inv2s2);
            for (int i = 3; i <= 5; i++) {
                float x = base.x + float(i - 4);
                vec3 c = texelAt(vec2(x, y), invSize);
                float w = wy * wx[i] * (1.0 + slope * dot(c, LUMA_WEIGHTS));
                acc += w * c;
                wsum += w;
            }
        }
    } else {
        for (int j = -2; j <= 2; j++) {
            float y = cy + 2.0 * float(j);
            float dy = y + 0.5 - p.y;
            float wy = exp(-dy * dy * inv2s2);
            for (int i = 0; i < 9; i++) {
                float x = base.x + float(i - 4);
                vec3 c = texelAt(vec2(x, y), invSize);
                float w = wy * wx[i] * (1.0 + slope * dot(c, LUMA_WEIGHTS));
                acc += w * c;
                wsum += w;
            }
        }
    }
    vec3 ghost = acc / max(wsum, 1e-5);

    // frostClamp 0 leaves both sides free.
    float k = uFrost.y;
    vec3 held = k > 0.0 ? max(ghost, cloud - k)
              : k < 0.0 ? min(ghost, cloud - k)
              : ghost;
    return mix(held, cloud, clamp(uFrost.x, 0.0, 1.0));
}

void main() {
    // Unpacked here rather than at global scope: global non-constant initialisers
    // (e.g. float x = uniform.y) are valid in desktop GLSL 4.6 but rejected by
    // SkSL / glslang on Windows (SPIR-V path). Same fix as 0.7.10 geometry shader.
    float uRefractiveIndex     = uOpticalProps.x;
    float uChromaticAberration = uOpticalProps.y;
    float uThickness           = uOpticalProps.z;
    float uLightIntensity      = uLightConfig.x;
    float uAmbientStrength     = uLightConfig.y;
    float uSaturation          = uLightConfig.z;

    vec2 fragCoord = FlutterFragCoord().xy;

    vec2 physTexSize = uSize;
    vec2 invTexSize = 1.0 / physTexSize;
    // uCaptureOffset shifts the fragment into capture-image space.
    // In BackdropFilter mode uCaptureOffset == vec2(0) so this is a no-op.
    vec2 screenUV = (fragCoord + uCaptureOffset) * invTexSize;

    // Pre-3.46 GLES stored render-to-texture content bottom-up; see
    // gles_compat.glsl. On 3.46+ the backend absorbs the difference and this
    // flip must NOT be applied, or the glass samples the backdrop mirrored
    // about the screen's horizontal centre line.
    #ifdef LGR_GLES_FLIP_SAMPLE_Y
        screenUV.y = 1.0 - screenUV.y;
    #endif

    vec2 geometryUV = (fragCoord - uGeometryOffset) / uGeometrySize;
    #ifdef LGR_GLES_FLIP_SAMPLE_Y
        geometryUV.y = 1.0 - geometryUV.y;
    #endif

    // Clamp geometryUV to [0, 1] for two reasons:
    // 1. Impeller's texture samplers may default to Repeat mode. Without this
    //    clamp, a fragment slightly outside uGeometrySize (e.g. during
    //    LiquidStretch scaling overshoot) wraps around and samples the opposite
    //    edge of the geometry SDF, producing inverted normals and extreme
    //    chromatic aliasing (jagged rainbows).
    // 2. Fragments genuinely outside the pill (the _clipExpansion zone) get
    //    clamped to the SDF edge, which has near-zero alpha. The
    //    `geometryData.a < 0.01` early-out below discards them efficiently
    //    without needing a separate bounds check here.
    geometryUV = clamp(geometryUV, 0.0, 1.0);

    vec4 geometryData = texture(uGeometryTexture, geometryUV);

    #if DEBUG_GEOMETRY
        fragColor = geometryData;
        return;
    #endif

    if (geometryData.a < 0.01) {
        fragColor = vec4(0);
        return;
    }

    // --- V1: Decode true surface normal from geometry texture ---
    //
    // The geometry pass stores the SDF-gradient-derived normal in RG.
    // Before V1 this stored displacement XY, and the render pass called
    // normalize(displacement) as a proxy for the normal — which diverges
    // from the true normal in blend-group neck zones (smooth-union joins).
    // The true normal is now decoded and used for both refraction and lighting.
    vec2 normalXY = decodeNormalXY(geometryData);
    float normalZSq = max(0.0, 1.0 - dot(normalXY, normalXY));
    float normalZ   = sqrt(normalZSq);
    vec3  normal    = vec3(normalXY, normalZ);   // unit-length surface normal

    // Recompute refraction displacement from the true normal.
    // This is the same refract() call used in the geometry pass — exact, not
    // approximated.  Height is still read from the B channel.
    float height = decodeHeight(geometryData, uThickness);
    float baseHeight = uThickness * 8.0;
    vec2  displacement;
    if (uLensModel > 0.5) {
        // Paraxial lens: the thin-prism law, deviation = (n - 1) * slope,
        // with the slope taken as sin(incidence)^2. normalXY is
        // sin(incidence) and falls off linearly across the bevel, so the
        // displacement runs up quadratically from the bevel's inner edge and
        // folds past the point where it outgrows the distance to the rim:
        // the band shows a mirrored, compressed copy of the interior. That
        // is the native rim, measured with line probes on a 56 pt circle:
        // the lens starts 0.6 of the radius out, the fold at 0.76, and the
        // outer band is an inverted 1.9:1 image of the backdrop from 0.27 to
        // 0.72 of the radius — thickness 32 (3x px) and n = 1.24 here. The
        // exact refraction below folds far harder toward the edge.
        displacement = -normalXY * length(normalXY) * baseHeight
                     * (uRefractiveIndex - 1.0);
    } else {
        vec3  incident    = vec3(0.0, 0.0, -1.0);
        float invN        = 1.0 / max(uRefractiveIndex, 0.001);
        vec3  baseRefract = refract(incident, normal, invN);
        float refractLen  = (height + baseHeight)
                          / max(0.001, abs(baseRefract.z));
        displacement = baseRefract.xy * refractLen;
    }
    // Scale displacement by uRefractScale (uOpticalProps.w) to ensure logical-pixel
    // identical refraction magnitude across all device pixel ratios.
    displacement *= uOpticalProps.w;

    // A lens cannot show what lies beyond its far side. At the rim the normal is
    // nearly horizontal and refract() returns a displacement that grows with
    // uThickness, not with the shape: on a pill a few dozen pixels tall the
    // bottom rim sampled the backdrop well above the pill's top edge, so any
    // text sitting there — a page title, a logo — came through as noise along
    // the rim, split into red, green and blue by the dispersion below.
    // Holding the reach to half the matte's shorter side keeps every sample,
    // chromatic offsets included, inside the glass's own footprint. Surfaces
    // large enough that the displacement never came near that bound are
    // unchanged.
    float maxReach = 0.5 * min(uGeometrySize.x, uGeometrySize.y);
    float reach = length(displacement);
    if (reach > maxReach) {
        displacement *= maxReach / reach;
    }

    // Distance from the rim, in the same physical-pixel units as uThickness:
    // the bevel is a quarter circle of radius uThickness, so the encoded
    // height gives it back exactly. Saturates at uThickness on the flat face.
    float normalizedHeight = geometryData.b;
    float cosTerm = sqrt(max(0.0, 1.0 - normalizedHeight * normalizedHeight));
    float rimDist = uThickness * (1.0 - cosTerm);
    float dprScale = max(0.1, uEdgeConfig.z);

    // iOS 27 hairline (uRimConfig.x): a half-point line on the very edge of
    // the glass. Measured against the native material it is the backdrop at
    // its own position, unblurred and untinted, darkened by a constant that
    // is strongest across the light axis and weakest at its ends. So within
    // the line the lens and the body tint are switched off below, and the
    // darkening is applied last.
    vec2 lensDisplacement = displacement;
    float hairline = 0.0;
    if (uRimConfig.x > 0.001) {
        hairline = 1.0 - smoothstep(0.75 * dprScale, 2.0 * dprScale, rimDist);
        // rimDist saturates at uThickness on the flat face, which on thin
        // glass is inside the line's width: keep the line off the face.
        hairline *= 1.0 - step(0.999, normalizedHeight);
        // Within the line, sample just outside the shape instead of under
        // it: the backdrop there has not been through the frost, which is
        // what the native line sits on (over text it reads page - 80, not
        // cloud - 80).
        vec2 outward = normalXY / max(length(normalXY), 1e-4)
                     * (2.5 * dprScale);
        displacement = mix(displacement, outward, hairline);
    }
    // On pre-3.46 OpenGL ES, screenUV.y is flipped to (1.0 - y) above to
    // compensate for the bottom-left texture-origin convention.  The
    // displacement is computed in Flutter's native Y-down space (outward normal
    // at the bottom edge has +Y), but adding a positive Y delta to the flipped
    // UV moves the sample TOWARD the centre rather than away — inverting the
    // refraction.  Negating displacement.y re-aligns it with the Y-up UV
    // sampling space.  Gated on the same condition as the UV flip itself: on
    // 3.46+ the UV is not flipped, so negating here would invert refraction.
    #ifdef LGR_GLES_FLIP_SAMPLE_Y
        displacement.y = -displacement.y;
    #endif

    // ── Concave horizontal pinch ──────────────────────────────────────────────
    // iOS 26 indicator pills make the bar content behind the left/right edges
    // appear slightly compressed inward — as if the pill is a convex lens
    // squeezing the bar through its edges. The effect is HORIZONTAL ONLY:
    // the bar content at the pill edges is sampled from a position slightly
    // closer to the pill centre, making those edge regions appear to pinch in.
    //
    // The centre of the pill (over the icon/label) is left completely flat.
    //
    // Scale: shifts are in UV space relative to the FULL backdrop (uSize).
    // 0.015 UV on a 390pt screen ≈ 6pt logical pixels — subtle but visible.
    //
    // ── iOS 26 Concave Lens Pinch ─────────────────────────────────────────────
    if (uPinchStrength > 0.001) {
        // We cannot use normalXY because it is 0.0 in the flat interior of the pill,
        // which prevents the background from being pinched at all.
        // We also cannot use a circular distance field, because a circle mapped to a
        // wide pill creates an elliptical lens that curves the flat top/bottom edges.
        //
        // Solution: Use an L6 norm (superellipse/squircle) distance field.
        // This mathematically mimics the physical shape of a rounded rectangle:
        // perfectly flat on the top/bottom/sides, and perfectly rounded in the corners.
        vec2 centered = geometryUV - vec2(0.5);
        vec2 absCentered = abs(centered) * 2.0; // 0.0 to 1.0

        // Compute x^4 and y^4 using multiply chains instead of pow().
        float x2 = absCentered.x * absCentered.x;
        float ax4 = x2 * x2;
        float y2 = absCentered.y * absCentered.y;
        float ay4 = y2 * y2;

        // L4 norm: (x^4 + y^4)^(1/4). 
        // Flatter than a circle (L2), but much softer in the corners than L6/L8.
        // ⁴√s = √(√(s)) — two sqrt() calls, mathematically exact.
        float s = ax4 + ay4;
        float squircleDist = sqrt(sqrt(s));

        // Map the squircle distance to a 0..1 smooth curve.
        float pinchRamp = smoothstep(0.0, 1.0, squircleDist);

        // Vector pointing outwards from the pill centre, scaled by the ramp.
        // uPinchStrength interpolates the effect during spring animations.
        // 0.025 is the baseline UV shift magnitude (subtle but visible).
        vec2 pinchShift = centered * pinchRamp * uPinchStrength * 0.025;

        // Feather the pinch shift to zero at the pill's SDF boundary.
        // Without this, there is a hard UV discontinuity at the pill edge:
        // the background content inside the pill is sampled from a shifted UV
        // while the content immediately outside is at the natural UV — this
        // mismatch produces the "stepped/aliased" edge visible through the lens,
        // especially where the bar's own clip edge is refracted inward.
        // Multiplying by geometryData.a (which is 0 at the boundary and 1 by 2 px
        // inside) ramps the shift smoothly from 0 → full pinch over the same AA
        // zone as the pill alpha, eliminating the hard UV seam.
        pinchShift *= geometryData.a;

        screenUV += pinchShift;
        
        // Guarantee we never sample outside the valid backdrop capture bounds,
        // preventing black/void artifacts if the pill is pressed tightly against the edge.
        screenUV = clamp(screenUV, vec2(0.001), vec2(0.999));
    }

    // PP1 optimisation: when the surface normal is flat (pointing straight up,
    // i.e. normalXY ≈ 0), refract() always produces displacement = vec2(0) and
    // the refracted UV is identical to screenUV.  Skip refract() entirely and
    // take a single background sample.  This covers the majority of pixels on
    // large surfaces (GlassAppBar, GlassPanel), where the edge zone is a small
    // fraction of the total area.
    //
    // Threshold chosen conservatively: 1e-4 in squared magnitude corresponds to
    // a normal tilted < 0.6° from vertical — visually indistinguishable from a
    // zero-displacement sample at any display resolution.
    vec4 refractColor;
    if (uFrost.x > 0.0 && hairline <= 0.0) {
        // Frosted body: the frost below replaces the colour, and only whether
        // a backdrop was captured here is kept (its alpha, see below). One
        // texel answers that; the bilinear sample would take 4 (12 with
        // chromatic aberration).
        float a = texture(uBackgroundTexture, screenUV).a;
        if (uBackgroundFallback.a > 0.0) {
            a += uBackgroundFallback.a * (1.0 - a);
        }
        refractColor = vec4(0.0, 0.0, 0.0, a);
    } else if (dot(normalXY, normalXY) < 1e-4) {
        // Flat interior — zero displacement, sample directly.
        refractColor = textureBilinear(screenUV, physTexSize, invTexSize);
    } else if (uChromaticAberration < 0.01) {
        vec2 refractedUV = screenUV + displacement * invTexSize;
        refractColor = textureBilinear(refractedUV, physTexSize, invTexSize);
        if (hairline > 0.0) {
            // The line runs along the edge, so average it along the edge:
            // three taps 1.5 px apart keep it a line over a busy backdrop.
            vec2 tangent = vec2(-normalXY.y, normalXY.x)
                         / max(length(normalXY), 1e-4)
                         * (1.5 * dprScale) * invTexSize;
            vec4 side = textureBilinear(refractedUV + tangent, physTexSize, invTexSize)
                      + textureBilinear(refractedUV - tangent, physTexSize, invTexSize);
            refractColor = mix(refractColor, (refractColor + side) / 3.0, hairline);
        }
    } else {
        float dispersionStrength = uChromaticAberration * 0.5;
        vec2 redOffset  = displacement * (1.0 + dispersionStrength);
        vec2 blueOffset = displacement * (1.0 - dispersionStrength);

        vec2 redUV   = screenUV + redOffset   * invTexSize;
        vec2 greenUV = screenUV + displacement * invTexSize;
        vec2 blueUV  = screenUV + blueOffset  * invTexSize;

        float red         = textureBilinear(redUV, physTexSize, invTexSize).r;
        vec4  greenSample = textureBilinear(greenUV, physTexSize, invTexSize);
        float blue        = textureBilinear(blueUV, physTexSize, invTexSize).b;

        refractColor = vec4(red, greenSample.g, blue, greenSample.a);
    }

    // Un-premultiply the background sample before refraction math.
    // BackdropFilter delivers premultiplied RGBA; toImageSync captures also
    // deliver premultiplied RGBA. Without un-premultiply, the chromatic
    // aberration dispersion channels (red/blue split) operate on premultiplied
    // values, which biases saturated colours toward grey at the edges.
    // On fully-opaque backdrops (refractColor.a == 1.0) this is a no-op.
    if (refractColor.a > 0.001) {
        refractColor.rgb /= refractColor.a;
    }

    if (uFrost.x > 0.0) {
        // The frosted, lensed body; the hairline keeps the sharp sample just
        // outside the shape that it was given above.
        vec2 p = fragCoord + uCaptureOffset + lensDisplacement;
        vec2 inward = normalXY / max(length(normalXY), 1e-4)
                    * max(0.0, 4.0 * dprScale - rimDist);
        vec2 q = fragCoord + uCaptureOffset - inward;
        vec3 frost = frostAt(p, q, invTexSize);
        refractColor.rgb = mix(frost, refractColor.rgb, hairline);
        // A frostWeight leaves its weight in the backdrop's alpha; only
        // whether a backdrop was captured at all matters below.
        refractColor.a = step(0.001, refractColor.a);
    }

    vec4 bodyGlassColor = uGlassColor;
    bodyGlassColor.a *= 1.0 - hairline;
    vec4 finalColor = applyGlassColor(refractColor, bodyGlassColor, uBodyMode);

    // VQ4: Content-adaptive glass strength.
    //
    // iOS 26 glass dynamically adjusts its material intensity based on the
    // luminance of the content beneath it.  Dark backdrops produce richer,
    // more vivid glass; bright or uniform backdrops produce a subtler material
    // to avoid overwhelming the UI.
    //
    // Implementation: dot-product backdrop luminance from refractColor —
    // the already-sampled background at the refracted UV.  Zero extra texture
    // reads; the sample is already in the register file.
    //
    // LUMA_WEIGHTS = vec3(0.2126, 0.7152, 0.0722) (ITU-R Rec.709, defined in render.glsl)
    //
    // adaptiveStrength range [0.8, 1.2]:
    //   • backdropLuma = 0.0 (black)  → strength 1.2 (richer glass)
    //   • backdropLuma = 1.0 (white)  → strength 0.8 (subtler glass)
    //
    // Cost: 1 dot product + 1 mix() + 1 extra mix() for tint = 3 MADs.
    // Effectively free on modern GPUs.
    float backdropLuma     = dot(refractColor.rgb, LUMA_WEIGHTS);
    float adaptiveStrength = mix(1.2, 0.8, backdropLuma);

    // Apply saturation with adaptive scaling.
    // adaptiveStrength > 1.0 → more vivid (dark backdrop).
    // adaptiveStrength < 1.0 → more muted (bright/uniform backdrop).
    // uSaturation is the artist-set base; we only modulate it, never replace it.
    // The hairline shows the backdrop as it is, so it takes no saturation.
    finalColor.rgb = applySaturation(
        finalColor.rgb, mix(uSaturation * adaptiveStrength, 1.0, hairline));

    // Modulate glass tint blend weight by adaptiveStrength.
    // On dark backgrounds the tint reads heavier (+20%); on bright backgrounds
    // it reads lighter (-20%).  The delta is small (max ±20% of the 12% base
    // weight = ±2.4%) — within a single JND step, noticeable as a property
    // not a glitch.  Uses mix() to re-blend toward uGlassColor.rgb over the
    // already-tinted finalColor, scaled by the adaptive delta only.
    // In clear mode (uBodyMode == 1.0), adaptive tint modulation is bypassed.
    finalColor.rgb = mix(finalColor.rgb,
                         uGlassColor.rgb,
                         uGlassColor.a * 0.12 * (adaptiveStrength - 1.0) * (1.0 - uBodyMode)
                         * (1.0 - hairline));

    // Whitening veil — applied here, right after the body tint and BEFORE the
    // rim/fresnel passes. Applying it before the edge lighting means the rim
    // and fresnel highlights are drawn on top of the whitened body, so the
    // bright edges stay crisp even when the body is heavily whitened —
    // matching iOS 26's light-mode bar, where the white ring / edge
    // reflections stay sharp over a whitened interior.
    //
    // Luminance-gated mode: scale the whiten by how bright this pixel already
    // is, so near-white content beneath the glass lifts to pure white while
    // darks (text, icons) are left untouched — instead of a uniform veil that
    // grays the darks too. This is a point operation (per-pixel, depending
    // only on this pixel's own luminance — no neighbourhood sampling), so
    // unlike a spatial content detector it cannot produce a halo or seam; at
    // a dark-on-light edge it just steepens the existing gradient (crisper
    // edge, no gray ring).
    //
    // WHITEN_LO / WHITEN_HI are content-classification thresholds (what
    // luminance counts as "a dark to protect" vs "a white to push"), not
    // aesthetic per-recipe values — so they are hardcoded rather than passed
    // as uniforms. The single tunable lever is uWhiten (the strength).
    //   below WHITEN_LO → gate 0 (fully protected, stays dark)
    //   above WHITEN_HI → gate 1 (fully whitened, lifts to white)
    const float WHITEN_LO = 0.40;
    const float WHITEN_HI = 0.80;
    float whitenLuma = dot(finalColor.rgb, LUMA_WEIGHTS);
    // uWhitenGated 1 → gate by luminance (light mode, protects darks);
    // uWhitenGated 0 → gate = 1, uniform whiten (dark mode, even lift).
    float whitenGate =
        mix(1.0, smoothstep(WHITEN_LO, WHITEN_HI, whitenLuma), uWhitenGated);
    finalColor.rgb = mix(finalColor.rgb, vec3(1.0),
                         clamp(uWhiten, 0.0, 1.0) * whitenGate * (1.0 - hairline));
    // iOS 27 body shade (uBodyShade): the dark material pulls a bright
    // backdrop down, white to about 184/255, where its tint alone would lift
    // it. Scaled by 1 - shade * luma^2, so darks keep the tint's lift. The
    // hairline is shaded too, and the rim shade below then sits its fixed
    // step under the darkened backdrop, as the native dark outline does.
    if (uBodyShade > 0.0) {
        float shadeLuma = dot(finalColor.rgb, LUMA_WEIGHTS);
        finalColor.rgb *= 1.0 - uBodyShade * shadeLuma * shadeLuma;
    }
    // Edge lighting — uses the true normal.xy (V1; was normalize(displacement))
    // The 40.0 constant was calibrated on a 3x Retina display.
    // We scale it by uEdgeConfig.z (which contains devicePixelRatio / 3.0) 
    // so the edge clamp ratio behaves identically on all pixel densities.
    float baseScale        = 40.0 * max(0.1, uEdgeConfig.z);
    float thicknessScale   = clamp(baseScale / max(uThickness, 1.0), 1.0, 4.0);
    float edgeThreshold    = mix(0.8, 0.5, 1.0 / thicknessScale);
    float edgeFactor       = uThickness < 0.01 ? 0.0 : 1.0 - smoothstep(0.0, edgeThreshold, normalizedHeight);

    // VQ5: Meniscus darkening — three physics improvements.
    //
    // [1] HEMISPHERE LENS PROFILE
    //     A glass pill cross-section follows a circular arc. The physically correct
    //     thickness profile is hemisphere-shaped: thickest at the rim boundary,
    //     thinning toward the interior following sqrt(1 - r²) where r = normalizedHeight.
    //     This gives a sharp onset at the rim and a gentler fade inward, matching
    //     real curved glass rather than the previous polynomial approximation.
    //
    // [2] LIGHT-MODULATED ABSORPTION STRENGTH
    //     On the lit side, the specular highlight compensates for absorption —
    //     the rim appears bright regardless. On the shadow side, no compensation
    //     occurs and the dark meniscus band is fully exposed. We reduce absorption
    //     strength on the lit side (0.6×) and increase it on the shadow side (1.4×)
    //     so the contrast between lit and shadow rim matches iOS 26's reference.
    //       normalXY is the 2D surface normal at this pixel (rim = non-zero, interior = 0).
    //       dot(n, L) = +1 → full lit → scale 0.6 (absorption hidden by specular)
    //       dot(n, L) = -1 → shadow  → scale 1.4 (absorption fully exposed)
    //
    // [3] CHROMATIC ABERRATION AT THE RIM
    //     Already correct here: displacement magnitude is proportional to normalXY
    //     which is zero at the interior and maximum at the rim — so the RGB split
    //     in the refraction sampling above (lines ~338-350) is already edge-weighted.
    //     No change needed.

    // [1] Hemisphere profile: use normalizedHeight as the radial parameter.
    //     normalizedHeight ≈ 0 at the interior flat face, ≈ 1 at the rim boundary.
    //     Invert: r_rim = 1 - normalizedHeight → 1 at rim, 0 interior.
    float r_rim = clamp(1.0 - normalizedHeight, 0.0, 1.0);
    float lensThickness = uThickness < 0.01 ? 0.0 : sqrt(max(0.0, 1.0 - r_rim * r_rim));
    // lensThickness: 1.0 at interior (r_rim=0), 0.0 at rim (r_rim=1) — correct:
    // interior glass is thinnest, rim is thickest → invert for absorption weight.
    float rimThickness = 1.0 - lensThickness; // 0 interior → 1 rim

    // [2] Light-modulated strength
    float len2D = max(length(normalXY), 1e-4);
    vec2  rimN  = normalXY / len2D; // safe normalized 2D rim normal
    float litness   = dot(rimN, uLightDirection); // [-1, +1]
    float dirScale  = mix(1.4, 0.6, litness * 0.5 + 0.5);

    float absorption = 1.0 - sqrt(rimThickness) * uEdgeConfig.w * dirScale;
    finalColor.rgb *= max(0.0, absorption);

    // With no light and no ambient term the block below mixes by 0 (the touch
    // glint also scales by uLightIntensity), so skip it: the iOS 27 presets
    // set lightIntensity to 0.
    if (edgeFactor > 0.01 && (uLightIntensity > 0.0 || uAmbientStrength > 0.0)) {
        // Re-normalize the bilinearly interpolated normal.
        // Interpolating normals across pixels shrinks their magnitude (the 'chord' effect).
        // If we don't re-normalize, this magnitude oscillation causes severe flickering
        // when amplified by non-linear specular curves.
        float len = max(length(normalXY), 1e-4);
        vec2 anisoN = normalXY / len;

        float mainLight     = max(0.0, dot(anisoN, uLightDirection));
        float oppositeLight = max(0.0, dot(anisoN, -uLightDirection));
        float totalInfluence = mainLight + oppositeLight * 0.8;

        // Restore the thin, sharp iOS 26 highlight lobe!
        // pow(x, 1.5) = x * sqrt(x). This thins out the highlight without causing
        // flickering because we properly re-normalized anisoN above.
        float directional = totalInfluence * sqrt(totalInfluence) * uLightIntensity * 3.0;
        float ambient     = uAmbientStrength * 0.5;

        // Soft-clamp brightness with x/(1+x) to prevent mix() extrapolating
        // beyond highlightColor.
        float brightnessRaw = (directional + ambient) * edgeFactor * thicknessScale * 0.8;
        float brightness    = brightnessRaw / (1.0 + brightnessRaw);

        vec3 highlightColor = getHighlightColor(refractColor.rgb, 1.0);
        finalColor.rgb = mix(finalColor.rgb, highlightColor, brightness);

        // Touch-driven specular highlight (Shader-Level Touch Specular, 1.5.0)
        //
        // When a touch is active (uTouchIntensity > 0), calculate an isotropic
        // touch-specular highlight focused on the glass rim nearest the touch.
        // This makes the rim of the glass glint dynamically as the finger
        // interacts with it, matching the Apple iOS 26 Liquid Glass optical model.
        //
        // 1. Isotropic coordinates: fragCoord and uTouchPosition are both in
        //    physical pixels (Dart multiplies logical touch coords by DPR).
        //    Calculating (fragCoord - uTouchPosition) directly in physical pixels
        //    ensures circular, non-distorted distance and direction across all
        //    aspect ratios (e.g. wide pills, app bars, buttons).
        //
        // 2. Contact distance falloff: The specular highlight attenuates
        //    smoothly away from the contact point using smoothstep with an
        //    adaptive touch radius, preventing distant rims from erroneously lighting.
        //
        // 3. Rim alignment: Light radiating outward through the glass from
        //    the touch point reaches the outer rim in the direction:
        //    touchDir = toFragPx / touchDist.
        //    The outward rim normal (anisoN) aligns with this direction on the
        //    side closest to the touch: dot(anisoN, touchDir) > 0.
        //
        // 4. Tight specular lobe: pow(rimTouchDot, 6.0) produces the crisp,
        //    clean glint characteristic of Apple's glass materials.
        //
        // Cost at rest: uTouchIntensity == 0.0 — the GPU's uniform
        // coherence mechanism culls the entire block before fragment work.
        if (uTouchIntensity > 0.001) {
            vec2 toFragPx = fragCoord - uTouchPosition;
            float touchDist = length(toFragPx);

            // Isotropic touch influence radius in physical pixels.
            // Scaled by DPR (uEdgeConfig.z contains dpr / 3.0).
            float dpr = max(1.0, uEdgeConfig.z * 3.0);
            float touchRadius = max(70.0 * dpr, uSize.y * 1.5);
            float distFactor = smoothstep(touchRadius, 0.0, touchDist);

            if (distFactor > 0.001 && touchDist > 1.0) {
                vec2 touchDir = toFragPx / touchDist;

                // Outward rim normal (anisoN) dotted with outward ray from touch (touchDir).
                // Rim fragments facing the contact point align with touchDir (dot > 0).
                float rimTouchDot = max(0.0, dot(anisoN, touchDir));

                // Tight specular glint curve (x⁶) scaled by touch distance falloff.
                // (x²)³ = x⁶ — two multiplies, zero transcendentals (pow() compiles
                // as exp2(6·log2(x)) on Mali/Adreno/Apple GPU).
                float rtd2 = rimTouchDot * rimTouchDot;
                float tSpec = rtd2 * rtd2 * rtd2 * distFactor;

                // Scale by touch intensity, light intensity, and Reinhard compress.
                float tBrightnessRaw = tSpec * uTouchIntensity * uLightIntensity * 2.5;
                float tBrightness    = tBrightnessRaw / (1.0 + tBrightnessRaw);

                // Blend toward highlightColor, gated by edgeFactor so it stays on the curved rim.
                finalColor.rgb = mix(finalColor.rgb, highlightColor,
                                     tBrightness * edgeFactor);
            }
        }
    }

    // VQ2: Fresnel edge luminosity ramp.
    //
    // iOS 26 glass is subtly brighter at grazing angles (the rim) even when
    // no directional specular highlight lands there.  This is the Fresnel term:
    // at near-normal incidence (flat interior) reflected light is minimal;
    // at grazing incidence (edges) it increases.
    //
    // normalZ → 0 at the rim (surface nearly perpendicular to view ray),
    // normalZ → 1 at flat interior (surface facing the camera directly).
    // So (1.0 - normalZ) gives a smooth 0→1 ramp from interior to rim.
    //
    // Gated by edgeFactor so the effect is naturally confined to the rim zone
    // and doesn't accumulate on interior pixels where edgeFactor ≈ 0.
    //
    // Strength 0.10 produces a gentle brightening calibrated against Apple
    // reference screenshots. Fully branchless — no extra GPU divergence.
    // Fresnel strength 0.12 (was 0.10 in the calibration build).
    // The extra 0.02 restores the subtle rim luminosity that the geometry AA band
    // experiment temporarily reduced — keeping the glass edge visually present
    // against dark bar backgrounds without making it glowing or harsh.
    float rimBase = (1.0 - normalZ) * edgeFactor;
    // uEdgeConfig.x (uAmbientRim) > 0 draws an ADDITIONAL rim band of that width (in the
    // normalized space of rimDist). This gives indicator pills a crisp, physical
    // illuminated edge that is thicker than a standard Fresnel gradient.
    // 
    // At uEdgeConfig.x = 0 rendering is exactly stock.
    // At uEdgeConfig.x = 2 the rim is noticeably thicker.
    // At uEdgeConfig.x = 3 the rim is very prominent.
    // Scale the anti-aliasing window by the same DPR scale applied to the thickness,
    // so the edge remains perfectly sharp (and exactly the same logical width) across all screens.
    float ringWindow = 0.75 * max(0.1, uEdgeConfig.z);
    
    float ring    = (1.0 - smoothstep(uEdgeConfig.x - ringWindow, uEdgeConfig.x + ringWindow, rimDist))
                  * step(0.001, uEdgeConfig.x);
    float fresnel = rimBase * 0.12 * uEdgeConfig.y + ring * 0.45;
    finalColor.rgb = clamp(finalColor.rgb + vec3(fresnel), 0.0, 1.0);

    // iOS 27 rim light (uRimConfig.y): two lobes at the ends of the light
    // axis, each a sharp core one pixel inside the hairline with a soft tail
    // reaching a few points into the body. Measured on both the light and
    // the dark native material the core adds 50/255 on black, easing to
    // about 27/255 on a near-white body: 0.196 * (1 - luma)^0.3, added in
    // sRGB. Widths are in physical pixels at 3x, hence the dprScale.
    if (uRimConfig.y > 0.001 && rimDist < 30.0 * dprScale) {
        // The lobe on the lit side is a little stronger: on a black page
        // the light material reads +50 there and +32 opposite, the dark
        // material about equal.
        float along = dot(rimN, uLightDirection);
        float lit  = max(along, 0.0);
        float opp  = max(-along, 0.0);
        float lobe = lit * lit * lit + 0.85 * opp * opp * opp;
        float inset = max(0.0, rimDist - 2.25 * dprScale) / dprScale;
        float core = exp(-inset / 1.5);
        float tail = exp(-inset / 8.0);
        float bodyLuma = clamp(dot(finalColor.rgb, LUMA_WEIGHTS), 0.0, 1.0);
        float ease = pow(1.0 - bodyLuma, 0.3);
        // The hairline itself stays dark; the highlight peaks just inside it.
        float rimLight = uRimConfig.y * lobe * ease
                       * (0.175 * core + 0.035 * tail) * (1.0 - hairline);
        finalColor.rgb = clamp(finalColor.rgb + vec3(rimLight), 0.0, 1.0);
    }

    // iOS 27 hairline darkening: 0.31 across the light axis, uRimConfig.z
    // of that at its ends (0.2 on the light material, 0 on the dark, where
    // the line dissolves into the lobes), falling off as cos^3.5 of the
    // angle from the axis' perpendicular. Subtracted (a linear burn) rather
    // than blended, which is how the native line stays a fixed step below
    // any backdrop colour.
    if (hairline > 0.0) {
        float across = 1.0 - dot(rimN, uLightDirection) * dot(rimN, uLightDirection);
        across = pow(max(across, 0.0), 1.75);
        float shade = uRimConfig.x * 0.314 * mix(uRimConfig.z, 1.0, across);
        finalColor.rgb = max(finalColor.rgb - vec3(shade * hairline), 0.0);
    }

    // sortd patch: PASSTHROUGH mode, for glass over a platform view.
    //
    // Stock, the body is opaque over its whole shape. Over a platform view
    // (a map, camera preview, video, webview) the backdrop texture holds
    // nothing, so the body resolved to opaque BLACK - the black pill.
    //
    // The tab bar's own answer over a platform view is to refract its ICON
    // LAYER instead of the uncapturable backdrop. That is why simply making
    // the body transparent is not enough: the icon layer is also drawn
    // directly, so a see-through body reveals the crisp copy next to the
    // refracted one, i.e. doubled labels. The opaque body was hiding it.
    //
    // In passthrough the body is therefore dropped entirely and only the
    // rim and its highlights are drawn. What shows inside the shape is the
    // real content beneath, at its own crisp scale, over the live platform
    // view - no black, no invented fill colour, and nothing drawn twice.
    //
    bool passthrough = uPlatformViewMode > 0.5;
    float alpha = geometryData.a;
    if (passthrough) {
        // Body coverage follows what was actually sampled: opaque where the
        // refracted content is real, clear where the backdrop held nothing,
        // so the platform view shows through instead of resolving to black.
        // The rim keeps its own coverage so the edge still reads.
        // The doubling this used to cause is handled above the shader: the
        // content under the shape is not drawn there at all (see
        // SearchableTabIndicator.passthroughOverPlatformView).
        float rim = clamp(fresnel * 3.0, 0.0, 1.0);
        alpha *= max(refractColor.a, rim);
        // Over an empty backdrop the body contributes no colour, so the edge
        // would resolve to a flat grey band. Glass edges read as SPECULAR:
        // push the rim toward white in proportion to its own strength, so
        // the droplet keeps a lit, reflective edge over the platform view.
        finalColor.rgb = mix(finalColor.rgb, vec3(1.0),
                             rim * (1.0 - refractColor.a) * 0.85);
    }
    fragColor    = vec4(finalColor.rgb * alpha, alpha);
}
