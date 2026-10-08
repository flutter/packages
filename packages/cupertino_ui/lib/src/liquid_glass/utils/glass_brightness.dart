// Package-private brightness resolution utility.
//
// NOT part of the public API — do not export from liquid_glass_widgets.dart.
library;

import 'package:flutter/cupertino.dart';

// ── External brightness resolver ──────────────────────────────────────────────
//
// MaterialApp users need the package to honour ThemeMode (light/dark/system).
// Because this package has zero flutter/material.dart imports (required for the
// cupertino_ui split), we cannot call Theme.maybeBrightnessOf ourselves.
//
// Instead, LiquidGlassWidgets.wrap() accepts an optional [brightnessResolver]
// callback that the caller provides from their own code (where they may freely
// import material). The resolved value is stored here and checked as Level 2
// of the cascade.
//
// Default: null (no resolver — falls straight to MediaQuery OS fallback).
// MaterialApp setup:
//
//   runApp(LiquidGlassWidgets.wrap(
//     child: const MyApp(),
//     brightnessResolver: Theme.maybeBrightnessOf, // ← user's code, not ours
//   ));
// ignore: public_member_api_docs
Brightness? Function(BuildContext)? glassExternalBrightnessResolver;

/// Resolves the effective brightness for glass widgets.
///
/// Three-level cascade (highest priority first):
///
/// 1. **External resolver** — a `Brightness? Function(BuildContext)` callback
///    registered via [LiquidGlassWidgets.wrap]'s `brightnessResolver` parameter.
///    MaterialApp users pass `Theme.maybeBrightnessOf` here. This correctly
///    honours [ThemeMode.light] / [ThemeMode.dark] / [ThemeMode.system] without
///    requiring this package to import `flutter/material.dart`.
///
///    If no resolver is registered (pure [CupertinoApp] or [CupertinoApp]-only
///    users who have no Material tree), this level returns null and is skipped.
///
/// 2. **[CupertinoThemeData.brightness]** — an explicit developer Cupertino pin
///    (non-null only when the developer set it intentionally via [CupertinoApp]
///    or a manual [CupertinoTheme] widget).
///
/// 3. **[MediaQuery.platformBrightnessOf]** — the device/OS system setting.
///    Safe fallback for pure [CupertinoApp] with no explicit brightness pin.
///
/// The [GlassThemeData.brightness] explicit glass-theme override is checked
/// by [GlassTheme.brightnessOf] **before** calling this function.
///
/// **Never call this function directly from widgets.** Always use
/// [GlassTheme.brightnessOf] so the glass-theme override is correctly honoured.
///
/// ## ⚠ Manual testing required
///
/// See MANUAL_TEST_CHECKLIST.md for the required pre-release device check
/// (OS Dark Mode + ThemeMode.light → shadows must remain visible).
Brightness resolveGlassBrightness(BuildContext context) {
  // Level 1: external resolver provided by the app (e.g. Theme.maybeBrightnessOf
  // from a MaterialApp integration). Zero material imports required in this file.
  final externalBrightness = glassExternalBrightnessResolver?.call(context);
  if (externalBrightness != null) return externalBrightness;

  // Level 2: explicit CupertinoTheme pin.
  final cupertinoBrightness = CupertinoTheme.of(context).brightness;
  if (cupertinoBrightness != null) return cupertinoBrightness;

  // Level 3: device/OS system brightness (safe fallback).
  return MediaQuery.platformBrightnessOf(context);
}
