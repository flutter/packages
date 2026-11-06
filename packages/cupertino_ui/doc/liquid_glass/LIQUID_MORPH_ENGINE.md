# Liquid Morph Engine

The Liquid Morph Engine is the centralised physics and animation system powering the iOS 26-style liquid glass morphing effect across all `liquid_glass_widgets`. This guide covers everything you need to integrate it into your own custom widgets.

---

## Overview

When a `GlassMenu` opens, two conceptual "blobs" drive the visual:

- **Blob A** (anchor) — the ghost trigger that shrinks away over the first 40 % of the animation, cleanly breaking the liquid bridge.
- **Blob B** (menu body) — travels from the trigger centre to the menu centre along a J-curve overshoot trajectory, expanding from trigger size to menu size.

The SDF metaball shader automatically creates the teardrop neck between the blobs — there is no explicit neck geometry. The engine computes exactly where each blob should be, at what scale, and how much the SDF should blend them together — for every single frame.

```
Trigger pressed
      │
      ▼
  open()
      │
      ▼  Spring (ζ ≈ 0.73, underdamped)
  rawValue 0 → ~1.05 (overshoot) → 1.0
      │
      ▼  LiquidMorphPhysics.compute()
  LiquidMorphState { pathT, sizeT, anchorScale, blend, ... }
      │
      ▼
  Widget renders two blobs via Transform + SDF shader
```

---

## Key Types

| Type | Role |
|---|---|
| `GlassMorphController` | Lifecycle owner — manages the spring, exposes `open()` / `close()` |
| `LiquidMorphState` | Immutable value object — one per frame, contains all render values |
| `MorphPhase` | Semantic lifecycle enum — tells you *where* in the animation you are |
| `MorphSpeed` | Enum — controls spring stiffness without exposing raw constants |
| `MorphStyle` | Enum — reserved for future shape variants (e.g. `bloom`) |
| `LiquidMorphPhysics` | Internal math engine — pure stateless, you generally don't call this directly |

---

## GlassMorphController

### Lifecycle

`GlassMorphController` must be created inside a `State` that mixes in `TickerProviderStateMixin` and disposed in `dispose()`:

```dart
class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
  late final GlassMorphController _morph;

  @override
  void initState() {
    super.initState();
    _morph = GlassMorphController(vsync: this);
    _morph.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _morph.dispose();
    super.dispose();
  }
}
```

### Construction parameters

```dart
GlassMorphController({
  required TickerProvider vsync,
  MorphSpeed speed = MorphSpeed.normal,   // spring stiffness profile
  MorphStyle style = MorphStyle.teardrop, // shape variant (teardrop only for now)
})
```

### Control methods

| Method | Description |
|---|---|
| `open()` | Drives the spring toward `1.0`. Resets `hasHandedOff`. Safe to call mid-close. |
| `close()` | Drives the spring toward `0.0` with `closeVelocityHint = -2.5` for the rubber-band snap. |

### Key accessors

| Accessor | Type | Description |
|---|---|---|
| `value` | `double` | Raw unclamped spring value. Can exceed `[0, 1]` during overshoot. |
| `velocity` | `double` | Instantaneous spring velocity. |
| `isClosing` | `bool` | `true` from `close()` until the spring re-settles. |
| `isShowing` | `bool` | `true` from `open()` until the spring fully returns to `0`. Use this to keep your overlay in the widget tree. |
| `hasHandedOff` | `bool` | Latches `true` exactly once when the closing spring first crosses `0`. Use this to swap the ghost overlay back for the real trigger at the right moment. |
| `animation` | `AnimationController` | The underlying controller, for callers that need to drive additional `Animation`s from it. |

---

## MorphSpeed

Controls the spring stiffness while guaranteeing the `ζ ≈ 0.73` underdamped ratio is preserved at every speed. This ratio is what produces the signature rubber-band closing bounce.

| Value | Stiffness | ω₀ (rad/s) | Feel |
|---|---|---|---|
| `slow` | 60 | ≈ 7.7 | Deliberate. Good for tutorials or reduced-motion contexts. |
| `normal` | 120 | ≈ 11 | **Default.** iOS 26 native parity. |
| `fast` | 200 | ≈ 14 | Snappy. Good for power-user or high-frequency interactions. |
| `instant` | 500 | ≈ 22 | Near-instant. Good for `ReducedMotion` or test environments. |

> [!CAUTION]
> Do **not** construct `LiquidMorphPhysics` with custom spring constants. The physics constants are interdependent — incorrect values will break the underdamping ratio and produce physically unstable animations (jitter, no bounce, or infinite oscillation). Always use `MorphSpeed` for speed control.

---

## Accessibility — Reduced Motion

`GlassMorphController` automatically respects the platform **Reduce Motion** / **Remove Animations** accessibility setting. When the flag is active, the controller overrides its spring to the instant profile (stiffness 500), so the overlay appears and disappears in a single visual step with no teardrop neck or bounce.

### How it works in GlassMenu

`GlassMenu` wires this up automatically via `didChangeDependencies()`. You don't need to do anything — it just works.

### Wiring it in your own custom widget

Call `setDisableAnimations()` from `didChangeDependencies()` so it picks up the initial value **and** any runtime changes (user toggles the setting while the app is running):

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _morph.setDisableAnimations(
    MediaQuery.of(context).disableAnimations,
  );
}
```

### Inspecting the flag

```dart
if (_morph.disableAnimations) {
  // Skip any decorative animation driven by the morph value
}
```

---

## Computing Render State

Call `computeState()` once per frame, from your `addListener` callback:

```dart
final LiquidMorphState state = _morph.computeState(
  finalDx: menuCentreX - triggerCentreX,   // target horizontal displacement (px)
  finalDy: menuCentreY - triggerCentreY,   // target vertical displacement (px)
  horizontalOffset: _horizontalClampOffset, // screen-edge correction from layout
  verticalOffset:   _verticalClampOffset,
);
```

### LiquidMorphState fields

| Field | Type | Description |
|---|---|---|
| `pathT` | `double` | J-curve position interpolation. Can legitimately exceed `[0, 1]` during overshoot. Use to position Blob B. |
| `sizeT` | `double` | Size interpolation (`linearToEaseOut`). Stays within `[0, 1]` during normal open; slightly negative during close undershoot. Use to lerp trigger size → menu size. |
| `currentDx` | `double` | Blob B's actual horizontal displacement in px: `finalDx * pathT`. |
| `currentDy` | `double` | Blob B's actual vertical displacement in px: `finalDy * pathT`. |
| `pushDx` | `double` | Horizontal displacement applied to Blob A during the closing bounce undershoot. Zero during open. |
| `pushDy` | `double` | Vertical displacement applied to Blob A during the closing bounce undershoot. Zero during open. |
| `anchorScale` | `double` | Scale factor for Blob A in `[0, 1]`. Shrinks from `1.0` to `0.0` over the first 40 % of the opening animation. Grows back during close. |
| `blend` | `double` | SDF metaball merge intensity in blur units, clamped to `[0, 28]`. Apply this to the shader's `blendRadius` or equivalent. |
| `containerScale` | `double` | Scale pulse for Blob B. `1.0` during normal travel. Slightly above `1.0` on open overshoot; drops below `1.0` on close undershoot (visible squeeze). |
| `phase` | `MorphPhase` | Semantic lifecycle phase for this frame. |

---

## MorphPhase

Use `phase` to react to where in the animation lifecycle you are without re-deriving it from raw values.

```
open direction:   idle → detaching → travelling → arriving → settled
close direction:  settled → arriving → travelling → detaching → [bounce] → idle
```

| Value | rawValue range | Meaning |
|---|---|---|
| `idle` | `< 0.001` | At rest. Overlay can safely be removed from the tree. |
| `detaching` | `0.001 – 0.4` or `< 0` | Blob A shrinking; liquid bridge forming (or on close bounce: bouncing past zero). |
| `travelling` | `0.4 – 0.8` | Peak teardrop stretch. Neck is at maximum. |
| `arriving` | `0.8 – 1.0` | Blob B approaching its destination; neck retracting. |
| `settled` | `≥ 1.0` | Blob B fully at rest at the menu position. |

---

## Minimal Custom Widget Example

Here is the smallest possible custom widget that uses the engine to morph from a floating button into a menu:

```dart
class _MyMorphWidgetState extends State<MyMorphWidget>
    with TickerProviderStateMixin {
  late final GlassMorphController _morph;

  // Layout geometry — computed in the build phase.
  double _finalDx = 0;
  double _finalDy = -120; // menu is 120px above the trigger

  @override
  void initState() {
    super.initState();
    _morph = GlassMorphController(vsync: this, speed: MorphSpeed.normal);
    _morph.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _morph.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _morph.computeState(
      finalDx: _finalDx,
      finalDy: _finalDy,
    );

    return Stack(
      children: [
        // ── Blob A: Ghost trigger (shrinks away on open) ──────────────────
        if (_morph.isShowing && !_morph.hasHandedOff)
          Positioned(
            left: triggerLeft + state.pushDx,
            top:  triggerTop  + state.pushDy,
            child: Transform.scale(
              scale: state.anchorScale,
              child: _TriggerButton(onTap: null), // non-interactive ghost
            ),
          ),

        // ── Blob B: Morphing menu container ──────────────────────────────
        if (_morph.isShowing)
          Positioned(
            left: triggerLeft + state.currentDx,
            top:  triggerTop  + state.currentDy,
            child: Transform.scale(
              scale: state.containerScale,
              child: LiquidGlass(
                blendRadius: state.blend, // drives the SDF metaball
                child: Opacity(
                  opacity: state.sizeT.clamp(0.0, 1.0),
                  child: _MenuContent(),
                ),
              ),
            ),
          ),

        // ── Real trigger (hidden while ghost is showing) ──────────────────
        Positioned(
          left: triggerLeft,
          top:  triggerTop,
          child: Visibility(
            visible: !_morph.isShowing || _morph.hasHandedOff,
            child: _TriggerButton(onTap: _morph.open),
          ),
        ),
      ],
    );
  }
}
```

---

## The hasHandedOff Latch

The handoff latch is the key to a seamless close animation. On the return trip the spring overshoots past `0.0` (this is the rubber-band bump you feel). The ghost Blob A must stay visible during this undershoot so it can absorb the bump. Exactly when the spring first crosses `0.0`, `hasHandedOff` fires — at that precise moment you swap the ghost for the real trigger widget.

```
spring value
  1.0 ┤                 ●────────●
  0.5 ┤           ●  ●         
  0.0 ┤────●                       ← hasHandedOff fires here on close
 -0.1 ┤              (bounce)
       open →               close →
```

This means the real trigger widget is never visible during the undershoot — the ghost handles the bump — and when the real trigger reappears it is already at rest at `value = 0`.

---

## Physics Reference (for contributors)

`LiquidMorphPhysics` is a pure stateless utility class. You should not need to call it directly; use `GlassMorphController.computeState()` instead.

### Spring constants

Both open and close use the same underdamped spring:

```
mass:      1.0
stiffness: 120.0  →  ω₀ ≈ 11 rad/s
damping:   16.0   →  ζ  ≈ 0.73
```

The underdamping is intentional. `ζ < 1` lets the spring overshoot, which drives the teardrop neck on open and the bump on close. `closeVelocityHint = -2.5` injects negative velocity at the moment of close to amplify the bounce amplitude to match iOS native.

### J-curve back-out position curve

`pathT` is computed via `_BackOutCurve(amplitude: 2.5)`:

```dart
// t ∈ [0, 1]
double transform(double t) {
  return (t -= 1.0) * t * ((amplitude + 1.0) * t + amplitude) + 1.0;
}
```

At `t = 0.5` the curve has already overshot past `1.0` before snapping back — this is the visible "string pull" of the teardrop neck at maximum separation.

### Anchor scale

```dart
anchorScale = (1.0 - clampedValue / 0.4).clamp(0.0, 1.0)
```

Linear decay from `1.0` at `rawValue = 0` to `0.0` at `rawValue = 0.4`. After 40 % the ghost is fully gone and the liquid bridge is broken.

### Blend (metaball merge)

```dart
separation = (pathT - sizeT).abs()
blend = (separation * 150.0).clamp(0.0, 28.0)
```

The separation between the position curve and the size curve represents how far Blob B has pulled away from its anchor. Zero when perfectly overlapped, maximum at peak teardrop stretch.

---

## Engine consumers

| Widget | What it morphs | Source |
|---|---|---|
| `GlassMenu` / `GlassMenuItem` | Trigger button → floating menu | `lib/widgets/overlays/shared/glass_menu_internal.dart` |
| `GlassModalSheet.show(morphFrom:)` | Trigger button → presented modal sheet | `lib/widgets/overlays/shared/glass_modal_sheet_morph.dart` |

### GlassMenu — the reference implementation

`GlassMenu` is the canonical integration; if you want to see a production-grade one, start there. The key sections are `_GlassMenuState.initState` (controller lifecycle), `_buildMorphingContainer` (Blob B layout), and `_buildAnchorBlob` (Blob A + handoff logic).

### GlassModalSheet — morphing into a presented route

`GlassModalSheet.show(morphFrom:)` presents the sheet by morphing out of a trigger instead of sliding up from the edge. The trigger is wrapped in a `GlassMorphTrigger`, which hands its builder a `GlassMorphAnchor` to present with:

```dart
GlassMorphTrigger(
  builder: (context, anchor) => GlassButton(
    onTap: () => GlassModalSheet.show(
      context: context,
      morphFrom: anchor,
      morphSpeed: MorphSpeed.normal,  // the engine's own vocabulary
      builder: (context) => const MySheetBody(),
    ),
    child: const Icon(CupertinoIcons.add),
  ),
)
```

Three things differ from `GlassMenu`, all of them consequences of the destination being a *route* rather than an overlay:

- **The trigger has to be handed over, not just located.** `GlassMenu` owns its trigger and can empty it; a sheet presented from a route cannot hide a widget it does not own, and nothing in Flutter lets it. A `GlobalKey` would only resolve the rect — enough to aim the morph, but the trigger would keep painting under the droplet, which reads as a duplicated button. `GlassMorphTrigger` owns the key *and* the opacity, so the trigger empties for the duration and is handed back the instant the droplet is caught, carrying the spring's closing momentum so it visibly takes the hit. `morphFromRect` remains for triggers that can't be wrapped; the anchor blob is suppressed there and the droplet blooms from a point.
- **The droplet is not the sheet.** The metaball neck only bridges shapes inside one glass layer's blend group, and the real sheet owns its own layer — so the morph renders its own two-blob droplet and hands off to the sheet at the settled instant, when both are motionless on the identical frame. The sheet stays mounted underneath for the whole morph; it is revealed, never inserted (remounting a glass widget mid-animation re-seeds its layers and shows as a glitch frame).
- **The route animation is a signal, not a clock.** The engine keeps its own spring; the route's reverse status is only what tells the presenter to start closing. The route duration is sized to outlast the spring's *full* settle rather than the moment the droplet lands — the trigger's closing bounce is driven by that presenter, so unmounting early truncates it mid-swing and the button snaps instead of easing home.

`SheetMorphGeometry` holds the pure part — where the sheet rests, where the droplet is on any given frame — and derives the destination from `SheetGeometry.positionForState`, the same call the sheet's own metrics use, so the two cannot drift apart.

The morph falls back to the ordinary slide transition wherever the metaball blend is unavailable: Skia/web, `GlassQuality.minimal`, and `platformViewBackdrop`. A degraded morph — two glass shapes with no bridge between them — reads worse than the slide it would replace.

---

## See Also

- [GLASS_MODAL_SHEETS_GUIDE.md](GLASS_MODAL_SHEETS_GUIDE.md) — complete reference for `GlassModalSheet`
- [ARCHITECTURE.md](../ARCHITECTURE.md) — package architecture, quality system, release process
