import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// A theme-aware background for showcase pages.
class ShowcaseBackground extends StatelessWidget {
  const ShowcaseBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return isDark
        ? const _DarkShowcaseBackground()
        : const _LightShowcaseBackground();
  }
}

class _DarkShowcaseBackground extends StatelessWidget {
  const _DarkShowcaseBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020715), // ChemAlert deep navy
      child: Stack(
        children: [
          // Purple glow — upper right (9B59FF / A246F7)
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA246F7).withValues(alpha: 0.32),
                    const Color(0xFF9B59FF).withValues(alpha: 0.1),
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Hot pink glow — center left (E040FB / EB66FF)
          Positioned(
            top: 280,
            left: -100,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEB66FF).withValues(alpha: 0.16),
                    const Color(0xFFE040FB).withValues(alpha: 0.05),
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Blue glow — bottom right (2077FF / 4FC3F7)
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2077FF).withValues(alpha: 0.18),
                    const Color(0xFF4FC3F7).withValues(alpha: 0.06),
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Subtle purple accent — mid-left
          Positioned(
            top: 120,
            left: 30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF9B59FF).withValues(alpha: 0.10),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          // Purple wash — center screen (behind catalog cards)
          Positioned(
            top: 500,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF9B59FF).withValues(alpha: 0.14),
                      const Color(0xFF7B3FA8).withValues(alpha: 0.05),
                      const Color(0x00000000),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LightShowcaseBackground extends StatelessWidget {
  const _LightShowcaseBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F0FA), // Very light lavender
            Color(0xFFF0F4F8), // Soft blue-grey
            Color(0xFFEEEEF2), // Light grey
          ],
        ),
      ),
      child: Stack(
        children: [
          // Muted purple glow — upper right
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA246F7).withValues(alpha: 0.15),
                    const Color(0xFF9B59FF).withValues(alpha: 0.06),
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Soft pink glow — center left
          Positioned(
            top: 280,
            left: -100,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEB66FF).withValues(alpha: 0.12),
                    const Color(0xFFE040FB).withValues(alpha: 0.05),
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Blue accent — bottom right
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2077FF).withValues(alpha: 0.12),
                    const Color(0xFF4FC3F7).withValues(alpha: 0.05),
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recommended glass settings optimized for the calibrated lightweight shader.
///
/// These settings provide the best iOS 26 liquid glass appearance across
/// both Skia (standard) and Impeller (premium) renderers.
///
/// ## lightAngle Convention
///
/// `lightAngle` is in **radians**, measured from the positive-x axis
/// (right), counter-clockwise in standard math coords (which maps
/// clockwise on screen since screen-y points down).
///
/// Common values:
/// - `0.5  * pi` = 90°  → directly above (API default)
/// - `0.75 * pi` = 135° → upper-left  (Apple standard — all iOS 26 surfaces)
///
/// Apple uses a **single consistent upper-left light source** across all glass
/// surfaces. Do not vary the angle per-component — it breaks visual coherence.
///
/// ## refractiveIndex Parameter Guide:
///
/// **Standard Quality (Lightweight Shader - Skia):**
/// - Controls rim prominence/thickness
/// - Range: 0.7-2.0
///   - `0.7-1.0`: Thin delicate rim (iOS 26 default aesthetic)
///   - `1.0-1.5`: Moderate rim visibility
///   - `1.5-2.0`: Bold prominent rim
///
/// **Premium Quality (Full Shader - Impeller):**
/// - Controls actual light refraction through glass
/// - Range: 1.0-2.0
///   - `1.0-1.2`: Subtle refraction
///   - `1.2-1.5`: Noticeable refraction
///   - `1.5-2.0`: Strong refraction
class RecommendedGlassSettings {
  const RecommendedGlassSettings._();

  /// Standard settings for scrollable content.
  ///
  /// Optimized for performance with excellent visual quality.
  /// Use with `GlassQuality.standard` (default).
  ///
  /// - refractiveIndex: 0.7 = thin delicate rim (standard) / subtle refraction (premium)
  static const standard = LiquidGlassSettings(
    blur: 4,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.08),
    lightAngle: 0.75 * math.pi, // 135° — upper-left, matches iOS 26
    lightIntensity: 0.7,
    ambientStrength: 0,
    saturation: 1.2,
    refractiveIndex: 1.2,
    chromaticAberration: 0.01,
    specularSharpness: GlassSpecularSharpness.medium,
  );

  /// Settings for buttons and interactive elements.
  ///
  /// Optimized for interactive feedback with adaptive glow effects.
  ///
  /// - refractiveIndex: 0.7 = thin delicate rim (iOS 26 aesthetic)
  /// - saturation: 0.0 at rest, automatically animated to 1.0 on press
  ///   - On Impeller: GlassGlow handles advanced compositing
  ///   - On Skia: Shader glow provides frosted press feedback
  static const interactive = LiquidGlassSettings(
    blur: 10,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.2),
    lightAngle: 0.75 * math.pi, // 135° — upper-left, matches iOS 26
    lightIntensity: 0.7,
    ambientStrength: 0.3,
    saturation: 0.0, // Glow intensity (0.0=off, animated on press)
    refractiveIndex: 0.7, // Thin rim (standard) / subtle refraction (premium)
    chromaticAberration: 0.0,
  );

  /// Settings for static surfaces (app bars, toolbars).
  ///
  /// Can use premium quality for best visual impact.
  ///
  /// - refractiveIndex: 1.15 = moderate rim (standard) / subtle refraction (premium)
  static const surface = LiquidGlassSettings(
    blur: 10,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.2),
    lightAngle: 0.75 * math.pi, // 135° — upper-left, matches iOS 26
    lightIntensity: 0.7,
    ambientStrength: 0.3,
    saturation: 1.2,
    refractiveIndex:
        1.15, // Moderate rim (standard) / subtle refraction (premium)
    chromaticAberration: 0.0,
  );

  /// Settings for bottom navigation bars.
  ///
  /// Tuned to Apple's iOS 26 bottom bar specification:
  /// - blur: 20 — Apple's nav chrome uses ~20pt heavy frost
  /// - glassColor: 15% white — adequate weight on diverse wallpapers
  /// - lightAngle: 0.75*pi — upper-left, same as all other surfaces (Apple standard)
  /// - refractiveIndex: 1.2 = moderate rim (standard) / noticeable refraction (premium)
  static const bottomBar = LiquidGlassSettings(
    blur: 20,
    thickness: 20,
    glassColor: Color.fromRGBO(255, 255, 255, 0.15),
    lightAngle: 0.75 *
        math.pi, // 135° — upper-left, Apple standard (consistent across all surfaces)
    lightIntensity: 0.7,
    ambientStrength: 0.5,
    saturation: 1.2,
    refractiveIndex:
        1.2, // Moderate rim (standard) / noticeable refraction (premium)
    chromaticAberration: 0.0,
  );

  /// Settings for overlay page layers, cards, and buttons.
  ///
  /// Use this for [AdaptiveLiquidGlassLayer] and [GlassCard]/[GlassButton]
  /// within an overlays page context.
  ///
  /// - refractiveIndex: 0.7 = thin delicate rim (iOS 26 aesthetic for small widgets)
  static const overlay = LiquidGlassSettings(
    blur: 10,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.12),
    lightAngle: 0.75 * math.pi, // 135° — upper-left, matches iOS 26
    lightIntensity: 0.7,
    ambientStrength: 0.4,
    saturation: 1.2,
    refractiveIndex:
        0.7, // Thin rim for cards/buttons (standard / subtle refraction premium)
    chromaticAberration: 0.0,
  );

  /// Settings specifically for large bottom sheets and modal overlays.
  ///
  /// Use this as the [settings] parameter in [GlassSheet.show] and
  /// [GlassModalSheet.show] to avoid the hard "line" artifact on large
  /// surfaces that use the lightweight shader.
  ///
  /// The lightweight shader's rim opacity is derived from kRimAlphaBase(0.65)
  /// × directional/ambient factors × refractiveIndex.
  /// - At 0.7 (overlay preset): visible rim border on sheets
  /// - At 0.15 (this preset):   barely-perceptible glassy edge
  static const sheet = LiquidGlassSettings(
    blur: 10,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.12),
    lightAngle: 0.75 * math.pi, // 135° — upper-left, matches iOS 26
    lightIntensity: 0.7,
    ambientStrength: 0.4,
    saturation: 1.2,
    refractiveIndex:
        0.15, // Near-invisible rim — correct for large sheet surfaces
    chromaticAberration: 0.0,
  );

  /// Settings for input fields.
  ///
  /// Subtle appearance that doesn't distract from content.
  ///
  /// - refractiveIndex: 0.7 = thin delicate rim (iOS 26 aesthetic)
  static const input = LiquidGlassSettings(
    blur: 20,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.12),
    lightAngle: 0.75 * math.pi, // 135° — upper-left, matches iOS 26
    lightIntensity: 0.7,
    ambientStrength: 0.4,
    saturation: 1.2,
    refractiveIndex: 0.7, // Thin rim (standard) / subtle refraction (premium)
    chromaticAberration: 0.0,
  );
}
