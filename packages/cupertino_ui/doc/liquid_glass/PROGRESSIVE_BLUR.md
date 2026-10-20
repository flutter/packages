# ProgressiveBlur

`ProgressiveBlur` is a **graduated** backdrop blur: a clean gaussian frost that
is strongest at one edge and eases to perfectly sharp at the opposite edge — the
Signal / iOS-26 header dissolve. Stack it behind a translucent app bar or bottom
bar so scrolling content dissolves beneath the bar instead of ending on a hard
cut-off.

- **Added in:** `0.22.0`
- **Self-contained:** needs no `LiquidGlassLayer` or glass ancestor.

## Why the library needs it

Every glass surface in this library applies a **uniform** blur — the same sigma
across the whole surface. That is correct for a glass *panel*, but a bar that
floats over scrolling content wants the blur to **fade out** away from the bar
edge, so content doesn't terminate on a visible hard line. That graduated blur
is the one primitive the library did not provide; `ProgressiveBlur` fills the
gap.

## The hard part — why the obvious recipe fails

The intuitive approach is "blur the backdrop, then fade the blurred layer with a
`ShaderMask` (or a gradient-masked `Opacity`)". This does **not** work: a
`BackdropFilter`'s captured backdrop is not included in an ancestor
`ShaderMask`'s layer on Impeller, so the mask has nothing to reveal and the bar
shows no blur at all.

The working approach binds a fragment shader **as the `ImageFilter` of the
`BackdropFilter` itself**:

```dart
BackdropFilter(
  filter: ui.ImageFilter.shader(myFragmentShader), // backdrop is bound to the sampler
  child: const SizedBox.expand(),
)
```

Because the shader *is* the backdrop filter, the engine binds the captured
backdrop to the shader's `sampler2D`, and it reads reliably on every backend.
`shaders/progressive_blur.frag` then samples that backdrop with a gaussian whose
sigma follows the gradient.

### Separable, two-pass gaussian

A single-pass disk blur is `O(σ²)` work per fragment and either streaks (too few
taps) or turns to noise (importance sampling). Instead the shader is **one axis**
of a separable gaussian, run twice — horizontal then vertical — via
`ui.ImageFilter.compose`:

```
inner = ImageFilter.shader(horizontalPass)
outer = ImageFilter.shader(verticalPass)
filter = ImageFilter.compose(outer: outer, inner: inner)
```

That is `O(σ)` per pass and produces a clean 2-D gaussian in one backdrop
capture + one draw, so the dissolve is band-free.

### Gradient normalisation

The bound texture is the **whole backdrop** (the screen), not the bar's own
rectangle, so `uSize` is the screen size. To make the gradient run across the
*bar* rather than the whole screen, the widget passes its own device-pixel
rectangle (`uRegionOriginPx` / `uRegionSizePx`) into the shader and normalises
the gradient over that. On Flutter 3.44/3.45 the GLES backend captured the
backdrop y-flipped, which the shader corrects under `LGR_GLES_FLIP_SAMPLE_Y`
(see `shaders/gles_compat.glsl`). Flutter 3.46+ stores render-to-texture content
top-down on every backend, so the correction is compiled out there — applying it
anyway is what caused #201.

## Usage

```dart
Stack(
  children: [
    // Graduated blur behind the bar — strong at the top, sharp toward the body.
    const Positioned(
      top: 0, left: 0, right: 0, height: 96,
      child: ProgressiveBlur(maxSigma: 20),
    ),
    // ... your translucent app bar on top ...
  ],
)
```

### Fade the blur with scroll

`maxSigma` is just a number — drive it from a scroll offset so the frost only
appears once content slides under the bar:

```dart
ProgressiveBlur(
  maxSigma: (scrollOffset / 40).clamp(0, 1) * 20, // 0 → sharp until you scroll
)
```

### Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `maxSigma` | `18` | Blur sigma (logical px) at the strong edge. `0` ⇒ no blur (passthrough). |
| `direction` | `topToBottom` | Which edge the blur is strongest at; it eases to sharp at the opposite edge. `topToBottom` / `bottomToTop` / `leftToRight` / `rightToLeft`. |
| `falloff` | `1.2` | Gradient gamma. `>1` keeps the blur strong across the strong edge, then eases to sharp near the opposite edge. |

## Shader pre-warming

`progressive_blur.frag` is pre-warmed by `LiquidGlassWidgets.initialize()`
alongside the other library shaders, so apps that already call `initialize()`
get the compiled program for free and the first bar paint isn't janky.

If you use `ProgressiveBlur` **without** `initialize()`, call
`ProgressiveBlur.preload()` once from `main()` after the binding is initialised.
It is idempotent (compiles once, process-wide) and never throws — on failure the
widget falls back to a uniform blur.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressiveBlur.preload(); // only needed if you don't call initialize()
  runApp(const MyApp());
}
```

## Graceful degradation

Where shader-based `ImageFilter`s are unavailable — Skia, or the web canvas
backend (`ui.ImageFilter.isShaderFilterSupported == false`) — or before the
shader has finished compiling, `ProgressiveBlur` renders a single **uniform**
`BackdropFilter` at a reduced sigma instead. The graduated look is lost but the
bar still frosts its backdrop and nothing crashes.
