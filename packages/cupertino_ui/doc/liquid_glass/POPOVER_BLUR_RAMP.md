# Popover blur ramp

`GlassPopover` eases its backdrop blur in over the opening morph instead of
rendering it at full strength from the first frame. This is a pure performance
optimisation for the open transition — it does not change the resting
appearance of the popover.

- **Added in:** `0.21.7`
- **Default:** on (`blurRampDuration: Duration(milliseconds: 260)`)
- **Opt out:** `blurRampDuration: Duration.zero`

## The problem

While a `GlassPopover` morphs out of its trigger, the popover body is redrawn
every frame at a new size, and a `BackdropFilter` blur is re-rasterised behind
it each of those frames. A gaussian backdrop blur is one of the most expensive
things a mobile GPU does per frame, and its cost scales with the blurred area
and the blur sigma.

Rendering that blur at **full strength from frame one** pays the maximum raster
cost during the *earliest* part of the morph — the frames where the blob is
still small and growing fastest, and where the rest of the metaball/teardrop
work is already competing for the same frame budget. That is precisely where
frames get dropped, so the transition stutters exactly when it is most visible.

## The fix

Ramp the blur sigma from `0` up to `settings.blur` over the opening morph:

```text
effective blur = settings.blur × curve(t),  t: 0 → 1 over blurRampDuration
```

- At the start of the open, `t ≈ 0` → the backdrop is (near) **sharp**, which is
  the cheapest thing the GPU can do, so the expensive early frames stay light.
- As the popover settles, `t → 1` → the blur reaches its full configured value.

Because the blur is animated continuously (not switched on after a fixed
delay), there is no visible on/off pop — the frost simply blooms in with the
glass. And because content only fades in from ~30 % of the morph (with an
`easeOut` ramp the blur is already most of the way to full by then), the popover
looks right by the time you can read it.

### Why a dedicated controller, not the morph spring

The morph is an **underdamped spring** — its value overshoots `1.0` and
oscillates before settling. If the blur were derived directly from the morph
value it would wobble ±a few percent around full strength as the spring rings
out. The ramp is therefore driven by its own short, monotonic
`AnimationController`, so the blur eases cleanly to full and holds. On close the
ramp is *frozen* (not wound back) so the blur stays coherent while the blob
collapses; it is reset to sharp once the overlay has fully hidden, ready for the
next open.

## Measured impact

These numbers come from the app this ramp was developed for. **Setup:** Android
emulator (`emulator-5554`, Android 17 / API 37, arm64, Impeller/OpenGLES),
**profile build**; `integration_test` opening and closing the notification-bell
popover **6×**, **143 frames** sampled per run via `flutter drive --profile` +
`binding.watchPerformance`. All times in milliseconds; lower is better; the
16 ms line is the 60 fps frame budget.

| Metric | Legacy overlay | GlassPopover, full blur¹ | Interim hard-switch² | Blur ramp (this)³ |
| --- | --: | --: | --: | --: |
| Frames sampled | 143 | 143 | 143 | 143 |
| Build avg | 0.31 | 0.69 | 0.66 | **0.23** |
| Build p90 | 0.64 | 1.22 | 1.15 | **0.28** |
| Build p99 | 2.38 | 4.47 | n/a | **0.67** |
| Build worst | 2.81 | 7.55 | 8.51 | **5.28** |
| Missed build budgets | 0 | 0 | 0 | **0** |
| Raster avg | 10.20 | 10.10 | 8.70 | **5.84** |
| Raster p90 | 9.21 | 16.96 | 11.27 | **6.03** |
| Raster p99 | 47.72 | 53.15 | 49.73 | **28.93** |
| Raster worst | 47.88 | 58.70 | 55.34 | **28.96** |
| Missed raster budgets | 13 | 15 | 11 | **6** |
| New-gen GC runs | n/a | 16 | n/a | **2** |
| Old-gen GC runs | n/a | 4 | n/a | **2** |

¹ Full-strength blur from frame one — the behaviour this widget has **without**
the ramp, reproduced today with `blurRampDuration: Duration.zero`.
² Interim app-side hack: blur hard-switched to full after a 450 ms timer (had a
visible blur "switch" and a brief layout overflow — both since fixed).
³ This ramp: blur eased `0 → full` over 260 ms (`easeOut`), in sync with the morph.
`n/a` = not captured for that interim run (its raw data was scratch-only and has
since been cleared).

Between the full-strength-blur baseline (col. 2) and the ramp (col. 4),
worst-case raster time fell **58.70 → 28.96 ms** and over-budget raster frames
**15 → 6**, with no perceptible change to the resting look.

**Read this honestly.** It is an *end-to-end* measurement of a real app popover,
not an isolated micro-benchmark of the parameter, and it was taken on an
**emulator** (so raster numbers carry run-to-run noise):

- Part of the delta between "full blur" and "blur ramp" comes from **app-level
  content trimming done in the same iteration** — the notification preview was
  capped at 5 rows and skeleton placeholder rows were removed (fewer widgets per
  frame). That mostly moves the *build* columns.
- The blur ramp's own contribution is in the **raster** columns: it keeps the
  full-strength `BackdropFilter` off the cheap, still-growing early morph frames.
- The residual ~29 ms raster p99/worst is the **first open frame**
  (shader/pipeline warm-up); it affects every variant equally and is not a
  regression.

To attribute the parameter precisely, run the same capture twice on one build —
`blurRampDuration: Duration.zero` vs. the default — holding content constant.

> Note on the numbers: backdrop-blur cost is GPU-bound, so it is only meaningful
> when measured on a device / emulator with a hardware rasteriser. Headless CI
> runners render in software and cannot reproduce these timings — treat any such
> measurement as a device/nightly report, not a CI gate.

## Usage

### Default — nothing to do

Every `GlassPopover` ramps its blur automatically:

```dart
GlassPopover(
  settings: const LiquidGlassSettings(blur: 24), // resting blur = ramp target
  trigger: const Icon(Icons.notifications),
  contentBuilder: (context, close) => const MyPopoverBody(),
)
```

### Tune the ramp

```dart
GlassPopover(
  blurRampDuration: const Duration(milliseconds: 320), // slower bloom
  blurRampCurve: Curves.easeOutCubic,
  settings: const LiquidGlassSettings(blur: 24),
  trigger: const Icon(Icons.notifications),
  contentBuilder: (context, close) => const MyPopoverBody(),
)
```

### Disable — render full blur immediately

Restores the pre-`0.21.7` behaviour:

```dart
GlassPopover(
  blurRampDuration: Duration.zero,
  settings: const LiquidGlassSettings(blur: 24),
  trigger: const Icon(Icons.notifications),
  contentBuilder: (context, close) => const MyPopoverBody(),
)
```

## Accessibility

When the platform **"reduce motion"** setting is active, the ramp is skipped and
the blur is shown at full strength on the first frame — the morph itself is
already near-instant in that mode, so there is nothing to ease in.

## Notes

- The ramp scales the `blur` field of the popover's effective
  `LiquidGlassSettings` only; all other glass properties (thickness, tint,
  lighting, refraction) are unchanged throughout.
- When the ramp is complete or disabled, the hoisted settings object is reused
  as-is — no per-frame `copyWith` allocation happens once the blur has settled.
