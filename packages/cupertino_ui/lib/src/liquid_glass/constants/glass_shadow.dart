import 'package:flutter/widgets.dart';

/// Default light-mode glass shadow values, matching iOS 26 elevation.
///
/// Used by [AdaptiveGlass] and the internal tab indicator and search pill
/// components. Centralised here to prevent drift between the
/// independent shadow wrappers.
///
/// These shadows are inverse-clipped so they only appear *outside* the
/// glass boundary, preventing the glass from blurring its own shadow.
///
/// ## Usage
///
/// ```dart
/// // Use the defaults
/// GlassShadow.defaults
///
/// // Scale the defaults
/// GlassShadow.scaled(1.5) // 50% stronger
///
/// // Disable shadows
/// GlassShadow.scaled(0.0) // empty list
/// ```
abstract final class GlassShadow {
  /// The default elevation shadow (≈6% black, 8px blur, 2px y-offset).
  static const BoxShadow elevation = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 8,
    spreadRadius: 0,
    offset: Offset(0, 2),
  );

  /// The default contact shadow (≈2% black, 2px blur, 1px y-offset).
  static const BoxShadow contact = BoxShadow(
    color: Color(0x05000000),
    blurRadius: 2,
    spreadRadius: 0,
    offset: Offset(0, 1),
  );

  /// The unscaled default shadow list: [elevation] + [contact].
  static const List<BoxShadow> defaults = [elevation, contact];

  /// Returns the default shadows scaled by [elevation].
  ///
  /// - `0.0` → empty list (no shadow)
  /// - `1.0` → [defaults] (unchanged)
  /// - `2.0` → double opacity and blur
  ///
  /// Opacity is clamped to `0.0–1.0`; blur and offset scale linearly.
  static List<BoxShadow> scaled(double elevation) {
    if (elevation <= 0) return const [];
    if (elevation == 1.0) return defaults;
    return [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, (0.06 * elevation).clamp(0.0, 1.0)),
        blurRadius: 8 * elevation,
        spreadRadius: 0,
        offset: Offset(0, 2 * elevation),
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, (0.02 * elevation).clamp(0.0, 1.0)),
        blurRadius: 2 * elevation,
        spreadRadius: 0,
        offset: Offset(0, 1 * elevation),
      ),
    ];
  }
}
