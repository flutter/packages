import 'package:flutter/widgets.dart';
import '../../renderer/liquid_glass_renderer.dart';

// =============================================================================
// kDefaultSheetSettings — shared glass preset for sheets
// =============================================================================

/// Default [LiquidGlassSettings] for both [GlassSheet] and [GlassModalSheet].
///
/// Centralised here so that all sheet types produce visually identical glass
/// following the Apple News / iOS 26 modal aesthetic:
/// - `thickness: 10` — moderate surface feel for large overlay surfaces.
/// - `blur: 10` — standard background frosting (matches iOS 26 overlay blur).
/// - `refractiveIndex: 0.15` — minimal rim. The lightweight shader computes
///   rim alpha from kRimAlphaBase(0.65) × directional/ambient factors ×
///   refractiveIndex. At 0.15 this produces a barely-perceptible glassy
///   edge matching iOS 26's large-surface modal aesthetic.
const kDefaultSheetSettings = LiquidGlassSettings(
  glassColor: Color(0x1FFFFFFF), // ~12% white — matches iOS 26 modal tint
  thickness: 10.0,
  blur: 10.0,
  lightIntensity: 0.7,
  lightAngle: 2.356194, // 0.75 * pi — upper-left, iOS 26 standard
  chromaticAberration: 0.0,
  refractiveIndex: 0.15, // Rim opacity = 0.8 × 0.15 = 0.12 (subtle edge)
  saturation: 1.2,
  ambientStrength: 0.4,
);
