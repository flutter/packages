/// Visual style of a glass button.
enum GlassButtonStyle {
  /// Standard button with glass background and shape.
  ///
  /// Maps to iOS 26's `.glass` button configuration — a translucent, adaptive
  /// surface that blends with the content behind it.
  filled,

  /// Prominent button with higher-opacity glass for primary actions.
  ///
  /// Maps to iOS 26's `.prominentGlass` / `.glassProminent` button
  /// configuration — a thicker, more opaque glass surface that stands out
  /// from surrounding controls. Use for primary call-to-action buttons.
  ///
  /// Renders with increased glass thickness and reduced transparency compared
  /// to [filled], making the button visually heavier and more prominent.
  prominent,

  /// Transparent button (no background shape), usable within groups.
  /// Still renders interactions (glow, stretch) and content.
  transparent,
}
