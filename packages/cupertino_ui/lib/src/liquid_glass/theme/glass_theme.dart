import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils/glass_brightness.dart';
import 'glass_theme_data.dart';

/// Provides glass theme configuration to descendant widgets.
///
/// This [InheritedWidget] allows glass widgets to access centralized theme
/// settings without passing them explicitly through the widget tree.
///
/// ## Usage
///
/// Wrap your app (or a section of it) with [GlassTheme]:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => GlassTheme(
///     data: GlassThemeData(
///       light: GlassThemeVariant(
///         settings: LiquidGlassSettings(thickness: 30),
///         quality: GlassQuality.standard,
///       ),
///       dark: GlassThemeVariant(
///         settings: LiquidGlassSettings(thickness: 40),
///         quality: GlassQuality.standard,
///       ),
///     ),
///     child: child!,
///   ),
/// )
/// ```
///
/// Access theme in widgets:
///
/// ```dart
/// final theme = GlassThemeData.of(context);
/// final settings = theme.settingsFor(context); // Auto light/dark
/// ```
///
/// ## Theme Inheritance
///
/// Widgets automatically inherit theme settings from the nearest [GlassTheme]
/// ancestor. Individual widgets can override theme values by explicitly
/// passing `settings`, `quality`, or `glowColor` parameters.
///
/// ## Light/Dark Mode
///
/// The theme automatically switches between light and dark variants using a
/// four-level priority cascade (highest first):
///
/// 1. **[GlassThemeData.brightness]** — explicit override on this theme.
/// 2. **Cupertino theme brightness** — explicit pin in [CupertinoThemeData].
/// 3. **Material [ThemeMode]** — honours [ThemeMode.light] / [ThemeMode.dark].
/// 4. **[MediaQuery.platformBrightnessOf]** — device/OS system setting.
///
/// Use [GlassTheme.brightnessOf] to resolve brightness inside glass widgets.
/// Never read [MediaQuery.platformBrightnessOf] or [CupertinoTheme.brightnessOf]
/// directly in glass widget code — those bypass the cascade.
class GlassTheme extends InheritedWidget {
  /// Creates a glass theme.
  ///
  /// The [data] parameter contains theme configuration for light and dark modes.
  const GlassTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The theme data containing light and dark configurations.
  final GlassThemeData data;

  /// Retrieves the [GlassTheme] from the widget tree.
  ///
  /// Returns null if no [GlassTheme] ancestor exists.
  static GlassTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlassTheme>();
  }

  /// Retrieves the [GlassTheme] from the widget tree.
  ///
  /// Throws if no [GlassTheme] ancestor exists. Use [maybeOf] for a
  /// null-safe alternative.
  static GlassTheme of(BuildContext context) {
    final theme = maybeOf(context);
    assert(
      theme != null,
      'No GlassTheme found in context. '
      'Wrap your app with GlassTheme to provide theme configuration.',
    );
    return theme!;
  }

  /// Resolves the effective brightness for all glass widgets in this context.
  ///
  /// This is the **single authority** for brightness within the package.
  /// All glass widgets must call this instead of querying
  /// [CupertinoTheme.brightnessOf] or [MediaQuery.platformBrightnessOf]
  /// directly.
  ///
  /// Resolution cascade (highest priority first):
  ///
  /// 1. **[GlassThemeData.brightness]** — an explicit brightness override set
  ///    by the developer on the nearest [GlassTheme] ancestor.
  /// 2. **[CupertinoThemeData.brightness]** — an explicit Cupertino brightness
  ///    pin (non-null only when the developer set it intentionally).
  /// 3. **Material [Theme] brightness** — honours [ThemeMode.light],
  ///    [ThemeMode.dark], and [ThemeMode.system].
  /// 4. **[MediaQuery.platformBrightnessOf]** — the device/OS system setting
  ///    (historical default, safe fallback).
  ///
  /// This ensures glass widgets always follow the **app's** intended
  /// brightness even when the device OS and app theme disagree (e.g. device
  /// is in Dark Mode but the app is pinned to Light Mode).
  static Brightness brightnessOf(BuildContext context) {
    // Level 1: explicit glass-theme override.
    final override = GlassTheme.maybeOf(context)?.data.brightness;
    if (override != null) return override;
    // Levels 2-4: framework cascade (Cupertino pin → Material → system).
    return resolveGlassBrightness(context);
  }

  @override
  bool updateShouldNotify(GlassTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlassThemeData>('data', data));
  }
}
