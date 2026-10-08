// Internal bridge — holds the single global accessibility flag set by
// LiquidGlassWidgets.initialize(). Kept in its own file to avoid circular
// imports between liquid_glass_setup.dart and glass_accessibility_scope.dart.
//
// NOT part of the public API. Do not export from the barrel.
library;

/// Whether glass widgets should auto-read system accessibility flags from
/// [MediaQuery] when no [GlassAccessibilityScope] is present.
///
/// Set by [LiquidGlassWidgets.wrap(respectSystemAccessibility: ...)].
/// Defaults to `true`.
bool respectSystemAccessibility = true;
