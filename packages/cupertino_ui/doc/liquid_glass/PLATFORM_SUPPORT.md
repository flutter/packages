# Platform Support

> Last updated: 2026-07-30 · Tracks v0.25.x

This document describes the rendering behaviour, known limitations, and
developer guidance for each platform that `liquid_glass_widgets` targets.

---

## Supported Platforms

| Platform | Tier | Renderer | `GlassQuality.premium` | `GlassQuality.standard` | `GlassQuality.minimal` |
|---|---|---|---|---|---|
| iOS (Impeller) | ✅ Primary | Impeller → Metal | ✅ Full shader | ✅ Lightweight shader | ✅ BackdropFilter |
| Android (Impeller) | ✅ Primary | Impeller → Vulkan/OpenGL ES | ✅ Full shader | ✅ Lightweight shader | ✅ BackdropFilter |
| Android (Skia) | ✅ Supported | Skia → OpenGL ES | ⬇️ Capped to `standard` | ✅ Lightweight shader | ✅ BackdropFilter |
| macOS | ✅ Supported | Impeller → Metal | ✅ Full shader | ✅ Lightweight shader | ✅ BackdropFilter |
| Web (CanvasKit) | ⚠️ Partial | CanvasKit (Skia-based) | ⬇️ Capped to `standard` | ✅ Lightweight shader | ✅ BackdropFilter |
| Windows | ⚠️ Partial | Skia → ANGLE → DirectX | ⬇️ Capped to `standard` | ✅ Lightweight shader | ✅ BackdropFilter |
| Linux | ⚠️ Partial | Skia (default) / Impeller (opt-in) | ⬇️ Capped to `standard` (Skia) | ✅ Lightweight shader | ✅ BackdropFilter |

> **Tier definitions:**
> - **Primary** — fully validated on real hardware with automated and manual QA.
> - **Supported** — API-complete; runs correctly but explicit QA passes are still
>   pending (tracked in the 1.0.0 roadmap).
> - **Partial** — runs with known limitations documented below.

---

## Rendering Quality Tiers

`liquid_glass_widgets` uses a three-tier rendering system that automatically
adapts to the active renderer. The tier is exposed as `GlassQuality`.

### `GlassQuality.premium`

Full custom GLSL shader pipeline:

- Two-pass GPU render: geometry precompute → lighting + refraction
- True `refract()` call per pixel (lensing, not just blur)
- Specular highlights, chromatic aberration, and SDF metaball blend
- **Requires Impeller.** Automatically capped to `standard` on Skia, Web, and
  Windows because `ui.ImageFilter.isShaderFilterSupported` returns `false` on
  those renderers.
- **Not suitable for scrollable lists** — the texture capture is not
  scroll-position-aware. Use `standard` for any widget that scrolls.

### `GlassQuality.standard`

Lightweight custom GLSL fragment shader:

- 5–10× faster than `BackdropFilter`
- Calibrated blur, saturation, and specular rim
- Works on all platforms including Skia, CanvasKit, and Windows
- Recommended default for most widgets

### `GlassQuality.minimal`

Zero custom shader. Renders via `BackdropFilter` blur + Rec. 709 saturation + specular rim stroke:

- Cross-platform safe: Skia, Impeller, Web, Windows, Linux
- No fragment shader compilation — zero GPU-budget risk
- Use for: large lists with many glass cards, background panels, or any
  context where shader load must be kept flat
- Visually similar to frosted glass — saturation and specular rim match
  the upstream FakeGlass approach

### Automatic Quality Negotiation (`GlassAdaptiveScope`)

Wrap your app or a subtree with `GlassAdaptiveScope` to let the library
benchmark frame timing on first launch and automatically select the highest
quality tier the device can sustain:

| P75 frame time | Quality selected |
|---|---|
| < 20 ms | `premium` |
| 20–28 ms | `standard` |
| > 28 ms | `minimal` |

The settled quality is cached for the session. See
[`GlassQualityAdapter`](../lib/utils/glass_quality_adapter.dart) for full
configuration options including `minQuality`, `maxQuality`, and `allowStepUp`.

---

## iOS

**Renderer:** Impeller → SPIRV-Cross → MSL → Metal

- All three quality tiers work correctly.
- `GlassQuality.premium` is the full native shader pipeline.
- PlatformView compositing (e.g. `webview_flutter`, `google_maps_flutter`):
  see the [`platformViewBackdrop` section](#platformviewbackdrop-quality-cliff)
  below.

### Known iOS Engine Quirks

- **`ClipRRect(borderRadius: 9999)` / PlatformView mutator stack** — Flutter
  PR [#177551](https://github.com/flutter/flutter/pull/177551) (merged Dec 2025,
  available in Flutter 3.41+) forwards `ClipRRect` clip data to the iOS
  PlatformView compositor. `LiquidOval` uses `BorderRadius.circular(9999)` as
  its approximation specifically to benefit from this forwarding. Shapes that
  cannot be expressed as `ClipRRect` (arbitrary `ClipPath`) still require
  `platformViewBackdrop: true` to clip correctly over a PlatformView.

---

## Android

**Renderer:** Impeller → SPIRV-Cross → GLSL ES → Vulkan or OpenGL ES (Impeller)
             Skia → OpenGL ES (legacy)

### Impeller (Default Since Flutter 3.27)

- All three quality tiers work correctly.
- `GlassQuality.premium` is enabled by default on hardware that passes the
  warm-up benchmark (P75 < 20 ms).
- Devices below the warm-up threshold fall back to `standard` or `minimal`
  automatically when `GlassAdaptiveScope` is used.

### Skia (Legacy — `--no-enable-impeller`)

- `GlassQuality.premium` is **not available**. `ui.ImageFilter.isShaderFilterSupported`
  returns `false` on Skia. Requests for `premium` are silently capped to
  `standard` at render time.
- `standard` and `minimal` both work correctly.

**Detection at runtime:**

```dart
import 'dart:ui' as ui;
final bool impellerAvailable = ui.ImageFilter.isShaderFilterSupported;
```

---

## Web (CanvasKit)

**Renderer:** CanvasKit (Skia-based WASM)

### Quality Limits

`GlassQuality.premium` is not available on Web. `kIsWeb` is checked at render
time and the effective quality is capped to `GlassQuality.standard`. This cap
is applied inside `AdaptiveGlass` before the shader decision tree runs.

### Known Bug: `LiquidOval` Circular Clipping (CanvasKit)

**Status:** Active — no upstream fix available yet.

`LiquidOval` uses `ClipRRect(borderRadius: BorderRadius.circular(9999))` inside
`_ShapeClip` to work around an iOS PlatformView compositing limitation
(Flutter #177551). On Web/CanvasKit, this large radius breaks path clipping:
the clipping path computed from `circular(9999)` overflows the widget bounds,
causing the interactive `GlassGlow` effect to spill outside the pill boundary
and destroying the CSS/SVG drop-shadow extraction on `DecoratedBox`.

**Symptoms:**
- `GlassButton` (default `LiquidOval` shape) shows a large rectangular glow
  halo instead of a pill-shaped glow on Web
- Drop shadows may render as a bounding-box rectangle rather than following
  the shape

**Proposed fix:** Branch on `kIsWeb` and substitute `ClipOval` /
`BoxShape.circle` for Web/CanvasKit paths, or wait for the upstream engine fix
for `ClipRRect(9999)` bounds calculation on Web.

**Workaround:** Use `GlassQuality.minimal` on Web if the glow artefact is
unacceptable, or use `LiquidRoundedRectangle` instead of `LiquidOval` shapes
on buttons and pills where the exact oval clip is not critical.

### Drop-Shadow Rendering

On Web, `AdaptiveGlass` substitutes a `DecoratedBox` `BoxShadow` in place of
the `GlassShadow` inverse-clipped `saveLayer` shadow used on native. This is
the correct path for Web — the inverse-clipped `saveLayer` compositing model is
not CanvasKit-compatible. The shadow is rendered by the CanvasKit (Skia WASM)
engine, not by CSS or the browser's compositor.

---

## macOS

**Renderer:** Impeller → SPIRV-Cross → MSL → Metal

macOS uses the same Impeller/Metal pipeline as iOS. All three quality tiers
work correctly. The main differences from iOS:

- `GlassAdaptiveScope` warm-up benchmarks reflect desktop GPU headroom, which
  is typically much higher than mobile — most Mac hardware will settle at
  `GlassQuality.premium`.
- Keyboard focus traversal and Tab/Enter/Space activation are required on
  macOS. This is a tracked 1.0.0 blocker — see the
  [accessibility section of the roadmap](./ROADMAP.md#biggest-blocker-accessibility--keyboard-support).
- No known platform-specific rendering bugs beyond the shared
  `platformViewBackdrop` limitation documented below.

---

## Windows

**Renderer:** Skia → ANGLE → OpenGL ES → DirectX (default). Impeller on
Windows is opt-in only (`flutter run --enable-impeller`) and still experimental
as of 0.25.x — not used in any validated configuration.

**Shader compilation path (Skia):** SkSL → glslang → SPIR-V → OpenGL via ANGLE.

### Quality Limits

`GlassQuality.premium` is capped to `GlassQuality.standard` on Windows (Skia
path). The detection gate is `ui.ImageFilter.isShaderFilterSupported`, which
returns `false` on the Skia/ANGLE path, so the premium shader pipeline is
never entered.

### Shader Compatibility (SkSL / glslang)

The Windows Flutter engine compiles shaders via **glslang**, which enforces
GLSL ES 1.0 rules more strictly than the Impeller/Metal path. All shaders
in this package have been written and validated to comply. The six rules
that must be respected when modifying any `.frag` or `.glsl` file are:

1. **No dynamic array indexing** — indices must be compile-time constants or
   literal integers. All `uShapeData[]` accesses use hardcoded literal offsets
   via the `SDF_SHAPE_N(BASE)` macro.
2. **No `dFdx`/`dFdy` on scalar `float`** — guarded with
   `#ifdef IMPELLER_TARGET_METAL` in `liquid_glass_geometry_blended.frag`.
3. **No `min(int, int)`** — use a ternary expression instead.
4. **No non-constant global initialisers** — unpack uniforms inside `main()`.
5. **Loop bounds must be compile-time constants** — use `const int` literals
   or fully-unrolled patterns (see `sceneSDF()` in `sdf.glsl`).
6. **No array parameters by value** — access global arrays directly inside
   functions.

**Validating shaders on macOS (without a Windows machine):**

```bash
brew install glslang
bash scripts/validate_shaders.sh
```

Run this before committing any change to `shaders/`. The full six-rule reference
and the history of how `sdf.glsl` was fixed in 0.7.12 are documented in
`.internal/FLUTTER_ISSUES.md` and `.internal/PERFORMANCE_AUDIT.md`.

### Drop-Shadow Rendering

`AdaptiveGlass` detects Windows via `defaultTargetPlatform == TargetPlatform.windows`
and uses a `DecoratedBox` `BoxShadow` in place of the inverse-clipped `saveLayer`
shadow. This is the correct path — the `saveLayer` shadow compositing model is
unreliable on the Windows OpenGL/ANGLE backend.

---

## Linux

**Renderer:** Skia (default). Impeller on Linux is **not yet the default** on
the stable channel as of 0.25.x — the Flutter team is actively working toward
it but has not shipped it as stable-default for desktop.

Linux follows the same Skia rules as Android (legacy mode):

- Skia (default) → `premium` capped to `standard`; `standard` and `minimal` work correctly
- Impeller (opt-in via `--enable-impeller`) → all three quality tiers available,
  but this configuration is untested and unsupported for this package

No Linux-specific rendering bugs are currently tracked.

---

## `platformViewBackdrop` Quality Cliff

**Affects:** iOS, Android, macOS, Windows, Linux — any platform that embeds a
`PlatformView` (e.g. `webview_flutter`, `google_maps_flutter`, `MapboxMap`).

### The Problem

When `platformViewBackdrop: true` is set on any `AdaptiveGlass`-backed widget
(tab bar body, indicator, extra button, `GlassContainer`, etc.), rendering is
forced to `_FrostedFallback` — a live `BackdropFilter` — regardless of the
requested `GlassQuality` tier. This is the only technically correct path: the
Impeller shader reads a captured backdrop snapshot that **excludes**
hybrid-composed PlatformViews. A live `BackdropFilter` re-samples the
composited scene each frame and therefore correctly blurs the map/webview
content underneath.

**Consequences:**

1. **Silent quality degradation** — `GlassQuality.premium` requested → renders
   as `GlassQuality.minimal` (`BackdropFilter`) with no error or warning.
2. **Continuous BackdropFilter during gesture** — the `isInteractive` blur
   omission (which normally skips the `BackdropFilter` during drag to save GPU)
   is overridden. The draggable indicator also runs a `BackdropFilter`
   continuously while repositioning. This is GPU-expensive on complex map views.
3. **Per-widget cost** — every widget with `platformViewBackdrop: true` in the
   same scene adds one live `BackdropFilter` per frame.

### API Guidance

```dart
// ❌ Don't do this unless your widget is literally over a PlatformView:
AdaptiveGlass(
  platformViewBackdrop: true,
  quality: GlassQuality.premium, // silently ignored — renders as minimal
  child: ...,
)

// ✅ Only set platformViewBackdrop when you know a PlatformView is beneath:
GlassTabBar.bottom(
  platformViewBackdrop: myPageHasMapView, // conditional
  ...
)
```

**Dartdoc note:** The `platformViewBackdrop` parameter dartdoc on `AdaptiveGlass`
documents the quality cap. A dedicated API note is tracked as a pre-1.0 item
in the roadmap.

### Long-Term Fix

Flutter engine progress on making `RepaintBoundary` / `ImageFilter` capture
include hybrid-composed PlatformViews is being tracked. When that lands,
`platformViewBackdrop` can route back to the native shader and this quality
cliff disappears. No ETA from the Flutter team at time of writing.

> Introduced in 0.19.2 — PR [#128](https://github.com/sdegenaar/liquid_glass_widgets/pull/128)
> by [@jfhair](https://github.com/jfhair).
> `platformViewFallbackColor` added in 0.19.5 to separate backer aesthetics
> from shader uniform fill — PR [#138](https://github.com/sdegenaar/liquid_glass_widgets/pull/138).

---

## Skia vs Impeller Visual Comparison

| Feature | Impeller (iOS/Android/macOS) | Skia / CanvasKit / Windows |
|---|---|---|
| True refraction (`refract()`) | ✅ `premium` only | ❌ Not available |
| Specular highlights | ✅ `premium` only | ❌ Not available |
| Chromatic aberration | ✅ `premium` only | ❌ Not available |
| SDF metaball blend | ✅ `premium` only | ❌ Not available |
| Lightweight shader blur | ✅ `standard` | ✅ `standard` |
| `BackdropFilter` fallback | ✅ `minimal` | ✅ `minimal` |
| `GlassGlow` interactive glow | ✅ Widget-based | ⚠️ Shader-based (`glowIntensity`) |
| Drop shadow | Inverse-clipped `saveLayer` | `DecoratedBox` drop shadow |
| `LiquidOval` clip on Web | — | ⚠️ Known bug (glow spill) |

---

## QA Status

| Platform | Device / Environment | Impeller | Skia | Last Validated |
|---|---|---|---|---|
| iOS | iPhone 15 Pro, iPhone 13 | ✅ | N/A | 0.25.x |
| Android | Pixel 8 (Impeller/Vulkan) | ✅ | — | 0.25.x |
| Android | Pixel 4 (Skia fallback) | — | ✅ | 0.25.x |
| macOS | Apple Silicon, Intel | ✅ | — | Needs explicit pass |
| Web | Chrome (CanvasKit) | N/A | ✅ | Needs explicit pass |
| Windows | Windows 11 (Skia/ANGLE) | N/A | ✅ | Needs explicit pass |
| Linux | Ubuntu 24 (Skia default) | N/A | ✅ | Needs explicit pass |

> Cells marked "Needs explicit pass" are tracked as 1.0.0 entry criteria. See
> [`ROADMAP.md`](./ROADMAP.md#platform-testing-matrix-complete).

---

## Filing Platform-Specific Issues

When filing a bug that is platform-specific, include:

- `flutter --version` output
- `flutter doctor -v` output
- Target platform and device (e.g. "Windows 11, AMD Radeon RX 6700, OpenGL")
- Whether Impeller is enabled (`flutter run --enable-impeller` /
  `--no-enable-impeller`)
- A minimal reproduction if possible

Issues: [github.com/sdegenaar/liquid_glass_widgets/issues](https://github.com/sdegenaar/liquid_glass_widgets/issues)
