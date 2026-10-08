/// Controls which physical interaction effects are active on a glass surface
/// when the user presses it.
///
/// iOS 26 uses a layered interaction model where press events can trigger
/// two independent visual responses: a light-catching directional glow
/// (ambient refraction at the finger position) and a physical scale/squish
/// of the glass body itself.
///
/// Use [GlassTabBar.interactionBehavior] to select the desired mode.
/// Fine-tune each axis independently with [GlassTabBar.pressScale] for the scale amount, and
/// [GlassTabBar.interactionGlowColor] for the light color.
///
/// ### Physical model
///
/// | Behavior     | Glow | Scale | Typical use-case                          |
/// |--------------|------|-------|-------------------------------------------|
/// | [none]       | ✗    | ✗     | Decorative / background glass             |
/// | [glowOnly]   | ✓    | ✗     | Spatially-stable navigation bars          |
/// | [scaleOnly]  | ✗    | ✓     | Branded bars where glow competes with UI  |
/// | [full]       | ✓    | ✓     | Native iOS 26 Apple News / Safari (default)|
enum GlassInteractionBehavior {
  /// No interaction feedback — fully rigid glass, no directional glow.
  ///
  /// Use for background or decorative glass elements that should not respond
  /// visually to touch at all.
  none,

  /// Directional glow only — the glass catches ambient light at the touch
  /// point, but the body does not physically deform.
  ///
  /// Suitable for flat navigation bars that should remain spatially stable
  /// while still feeling reactive to touch.
  glowOnly,

  /// Physical spring-scale only — the bar inflates subtly on press and snaps
  /// back on release, but does not respond with a directional glow.
  ///
  /// Useful for custom-branded bars where the ambient glow would compete with
  /// foreground content colours.
  scaleOnly,

  /// Full iOS 26 interaction — directional glow **and** physical spring-scale.
  ///
  /// Matches the default Apple News / Safari bottom-bar behaviour: the glass
  /// inflates subtly (bottom-anchored spring) on touch and simultaneously
  /// projects a soft directional highlight at the finger position.
  ///
  /// This is the default for all liquid-glass bar widgets.
  full;

  /// Whether this behavior includes the directional glow effect.
  bool get hasGlow => this == glowOnly || this == full;

  /// Whether this behavior includes the spring-scale (squish) effect.
  bool get hasScale => this == scaleOnly || this == full;
}
