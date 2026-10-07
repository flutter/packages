# Engine Attribution: `liquid_glass_renderer`

This directory (`lib/src/engine/`) contains the foundational rendering engine derived from [`liquid_glass_renderer`](https://github.com/whynotmake-it/flutter_liquid_glass/tree/main/packages/liquid_glass_renderer) developed by **Tim Lehmann** ([whynotmake.it](https://github.com/whynotmake-it)), licensed under the **MIT License** (see [LICENSE](LICENSE)).

These files have been significantly evolved and maintained in-tree for `liquid_glass_widgets`. They are **not a hermetic third-party snapshot** — they are deeply integrated with the surrounding package and will continue to be modified as the package evolves.

* **Upstream Baseline**: `liquid_glass_renderer` v0.2.0-dev.4
* **Forked from baseline**: 2026-03-28
* **Author / Copyright**: Tim Lehmann (`whynotmake.it`)
* **License**: MIT

---

## Architectural Role

This directory houses the foundational rendering engine created by Tim Lehmann. It provides the core fragment-shader pipeline, render proxy boxes, blend group registration, geometry matte rendering, layer compositing, and repaint boundary tracking for Flutter liquid glass.

In `liquid_glass_widgets`, these foundational primitives are wrapped, extended, and integrated into our high-level iOS 26 Cupertino glass design system via `lib/src/renderer/` (our custom transition scopes and engine barrel) and `lib/widgets/` (60+ Cupertino glass widgets).

---

## File Manifest & Authorship

Every file in this directory originated from Tim Lehmann's `liquid_glass_renderer` package and has been maintained and evolved in-tree:

| File | Upstream Origin | Modifications Made by `liquid_glass_widgets` |
|---|---|---|
| `liquid_glass.dart` | `lib/src/liquid_glass.dart` | Added non-Impeller fallback; integrated `GlassMaterializeScope.wrapContent` and opacity channel. |
| `liquid_glass_blend_group.dart` | `lib/src/liquid_glass_blend_group.dart` | Added non-Impeller Skia/web guard (B1); integrated shader pipeline; room in the matte for the native edge. |
| `liquid_glass_layer.dart` | `lib/src/rendering/liquid_glass_layer.dart` | Stripped `flutter_shaders` & `logging`; added `LiquidGlassSelfScaleScope` UV freeze coordination; added Vulkan compositing bits race fix (`markNeedsCompositingBitsUpdate`); refreshes push-back UV snapshots during paint after ancestor layout; publishes `backdropPassClipRectLocal` so descendant glass can find the enclosing Impeller compositor pass (#333); added the frost passes (a blur written to alternate pixel rows, and an optional luminance-weight pass). |
| `render_liquid_glass_geometry.dart` | `lib/src/internal/render_liquid_glass_geometry.dart` | Stripped `equatable` & `flutter_shaders`; added Android NaN/Infinity bounds guards on empty warm-up frames; optimized matte capture; rebuilds the matte when a rim outline or a frost switches the native edge. |
| `rendering/liquid_glass_render_object.dart` | `lib/src/rendering/liquid_glass_render_object.dart` | Renamed `GeometryRenderLink.markRebuilt` → `notifyGeometryChanged` (A1); added hardware bilinear filtering `FilterQuality.medium`; added Android compositing guards; capped the geometry matte's pixel budget while its shape animates, settling at full resolution at rest; fixed `uSize`/`uGeometryOffset`/`uTouchPosition` to be relative to the enclosing Impeller compositor pass rather than the screen, fixing displaced premium glass inside any `BackdropFilter` ancestor (#333); builds the frost's pixel-row clip and passes the rim, lens and frost uniforms. |
| `multi_shader_builder.dart` | `lib/src/internal/multi_shader_builder.dart` | Pure Flutter SDK fragment program loader without external helper packages. |
| `snap_rect_to_pixels.dart` | `lib/src/internal/snap_rect_to_pixels.dart` | Subpixel layout snapping extension. |
| `liquid_glass_settings.dart` | `lib/src/liquid_glass_settings.dart` | Heavily extended (5.5×): added `PlatformViewGlassMode`, `GlassBodyMode` (`clear` vs `adaptive`), `GlassSpecularSharpness`, accessibility fallbacks, and performance quality degradation tiers; the iOS 27 material terms (`frost`, `rimShade`, `rimLight`, `GlassLensModel`) and the `ios27Light` / `ios27Dark` presets. |
| `liquid_shape.dart` | `lib/src/liquid_shape.dart` | Extended shapes; stripped `equatable` in favor of pure Flutter `OutlinedBorder` equality. |
| `stretch.dart` | `lib/src/stretch.dart` | Heavily extended (3.4×): added anchor stretch fine-tuning, deadband latched continuity, and `LiquidGlassSelfScaleScope` integration. |
| `glass_glow.dart` | `lib/src/glass_glow.dart` | Heavily extended (3.1×): added Impeller multi-pass glow layers, custom touch specular propagation, and brightness adaptation. |
| `glass_drag_builder.dart` | `lib/src/internal/glass_drag_builder.dart` | Continuous drag gesture builder; integrated `InteractionNotification` for Smart Silence touch suppression. |
| `liquid_glass_render_scope.dart` | `lib/src/liquid_glass_render_scope.dart` | Render scope InheritedWidget. |
| `shaders.dart` | `lib/src/shaders.dart` | Mapped compiled shader asset keys. |
| `internal/transform_tracking_repaint_boundary_mixin.dart` | `lib/src/internal/...` | Repaint boundary transform tracking mixin; `onTransformChanged` deferred to a post-frame callback when fired from compositing, so the repaint it asks for gets a frame. |

---

## Key In-Tree Enhancements by `liquid_glass_widgets`

1. **100% Pure Flutter SDK**: Completely eliminated third-party package dependencies (`flutter_shaders`, `equatable`, `logging`), transitioning the entire engine to pure Flutter framework primitives.
2. **Android Vulkan Compositing Guard**: Fixed a race condition on Vulkan/Impeller cold launch where the first paint occurred before compositing bits were resolved (`markNeedsCompositingBitsUpdate`).
3. **Android Warm-up NaN/Infinity Protection**: Added bounds validation in geometry picture recording to prevent crashes on initial zero-size layouts.
4. **Impeller Performance**: Eliminated expensive live backdrop filter passes on Impeller in favor of hardware-cached `toImageSync` picture captures.
5. **Windows SkSL / SPIR-V Support**: Cleaned up GLSL shaders for strict compatibility with `glslangValidator` and Windows SkSL compilers.
6. **Mobile Shader Precision (B3)**: Changed `precision mediump float` → `precision highp float` in geometry shaders to eliminate 10-bit displacement quantization banding.
7. **Impeller Nested BackdropFilter Coordinate Fix (#333)**: Premium glass surfaces nested inside any ancestor that reads the backdrop (`BackdropFilter`, own-layer `GlassContainer`, `GlassSheet`) previously rendered their refraction displaced by the ancestor's screen origin. The live-path uniforms (`uSize`, `uGeometryOffset`, `uTouchPosition`) now walk the render-object tree to find the nearest enclosing Impeller compositor pass and express all coordinates relative to that pass. Top-level surfaces are unaffected.
