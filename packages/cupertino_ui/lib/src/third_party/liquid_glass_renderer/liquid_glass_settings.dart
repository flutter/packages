// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import '../../constants/glass_defaults.dart';
import '../../constants/glass_shadow.dart';
import '../../types/glass_specular_sharpness.dart';
import 'liquid_glass_render_scope.dart';

/// How a glass surface resolves the parts of its body that had nothing to
/// sample.
///
/// The body's colour comes from the backdrop texture. Over a platform view
/// (a map, a camera preview, a video, a webview) that texture is empty, which
/// in premultiplied terms is transparent black, so a body that is forced fully
/// opaque resolves to solid black.
enum PlatformViewGlassMode {
  /// The body stays fully opaque over the whole shape. Where nothing was
  /// sampled it resolves to [LiquidGlassSettings.platformViewFallbackColor],
  /// or to black when that is unset.
  ///
  /// This is the default and the historical behaviour.
  fallbackColor,

  /// Coverage follows what was actually sampled: opaque where the backdrop
  /// held content, clear where it held nothing, so the platform view shows
  /// through instead of a black or invented fill. The rim keeps its own
  /// coverage, so the edge still reads.
  ///
  /// On an ordinary backdrop every sample is opaque, so this is identical to
  /// [fallbackColor]. It only differs where there was nothing to read.
  ///
  /// Note for tab bars: over a platform view the indicator refracts the bar's
  /// own icon layer, and that layer is drawn on screen as well. With a body
  /// that is no longer opaque, both copies become visible. See
  /// `SearchableTabIndicator.passthroughOverPlatformView`.
  passthrough,
}

/// Controls how the glass body blends color over the background.
///
/// Matches Apple's iOS 26 Liquid Glass material styling in Swift / UIKit:
/// - [adaptive]: matches `Glass.regular` — adaptive luminance-preserving tint
///   that takes the color's hue while holding the background's perceived brightness.
/// - [clear]: matches `Glass.clear` — direct alpha-composited tint with no
///   luminance normalization, preserving exact design token hex values while
///   retaining specular, Fresnel, and rim physics.
enum GlassBodyMode {
  /// Adaptive luminance-preserving tint (default, matches Apple's Glass.regular).
  adaptive,

  /// Direct alpha-composite tint with no luminance normalization (matches Apple's Glass.clear).
  /// Preserves exact design token hex values while retaining specular, Fresnel, and rim physics.
  clear,
}

/// How the glass bevel bends the backdrop it refracts.
///
/// Both models use the same hemispherical bevel; they differ in how the
/// deviation of a ray is derived from the surface slope at each pixel.
enum GlassLensModel {
  /// Exact Snell refraction through the bevel (default).
  ///
  /// The deviation climbs steeply toward grazing incidence, so the outermost
  /// pixels of the rim sample far into the body and the fold in the rim band
  /// steepens toward the edge instead of staying even.
  spherical,

  /// Small-angle (thin-prism) refraction: deviation is `(n - 1)` times the
  /// bevel slope, the slope taken as sin² of the incidence angle.
  ///
  /// The displacement runs up quadratically from the inner edge of the
  /// bevel, `8 (n - 1)` times the bevel depth at the rim, so past
  /// `n = 1.125` the band folds and shows a mirrored, compressed copy of the
  /// interior. At `thickness: 32, refractiveIndex: 1.24` that is the native
  /// rim band: identity out to 0.6 of the radius, then an even fold. Under a
  /// [LiquidGlassSettings.frost] the band folds the copy of the content that
  /// shows through the cloud.
  ///
  /// Only affects the Premium (Impeller) path.
  paraxial,
}

/// Represents the settings for a liquid glass effect.
class LiquidGlassSettings {
  /// Creates a new [LiquidGlassSettings] with the given settings.
  /// Public constructor — all material glass properties.
  ///
  /// [pinchStrength] is intentionally absent here. It is an internal
  /// shader-transport value set only by [AnimatedGlassIndicator] via
  /// [copyWithPinch]. Users configure the effect through the hosting
  /// widget's `indicatorPinchStrength` parameter instead.
  const LiquidGlassSettings({
    this.visibility = 1.0,
    this.glassColor = const Color.fromARGB(0, 255, 255, 255),
    this.thickness = 20,
    this.blur = 5,
    this.frost = 0.0,
    this.frostOpacity = 1.0,
    this.frostClamp = 0.0,
    this.frostWeight = 1.0,
    this.blurWeight = 1.0,
    this.chromaticAberration = .01,
    this.lightAngle = GlassDefaults.lightAngle,
    this.lightIntensity = .5,
    this.ambientStrength = 0,
    this.ambientRim = 0,
    this.fresnelStrength = 1.0,
    this.refractiveIndex = 1.2,
    this.saturation = 1.5,
    this.glowIntensity = 0.75,
    this.specularSharpness = GlassSpecularSharpness.medium,
    this.standardOpacityMultiplier = 1.0,
    this.shadowElevation = 1.0,
    this.shadow,
    this.whitenStrength = 0.0,
    this.whitenGated = true,
    this.edgeAbsorption = 0.0,
    this.rimShade = 0.0,
    this.rimShadeEnds = 0.2,
    this.rimLight = 0.0,
    this.bodyShade = 0.0,
    this.lensModel = GlassLensModel.spherical,
    this.backerColor,
    this.platformViewFallbackColor,
    this.platformViewMode = PlatformViewGlassMode.fallbackColor,
    this.bodyMode = GlassBodyMode.adaptive,
  }) : pinchStrength = 0.0;

  /// Private constructor used exclusively by [copyWithPinch].
  ///
  /// Carries the full field set including [pinchStrength] so that
  /// [AnimatedGlassIndicator] can thread the animated pinch value to
  /// the render shader without exposing [pinchStrength] in the public API.
  const LiquidGlassSettings._withPinch({
    required this.visibility,
    required this.glassColor,
    required this.thickness,
    required this.blur,
    this.frost = 0.0,
    this.frostOpacity = 1.0,
    this.frostClamp = 0.0,
    this.frostWeight = 1.0,
    this.blurWeight = 1.0,
    required this.chromaticAberration,
    required this.lightAngle,
    required this.lightIntensity,
    required this.ambientStrength,
    this.ambientRim = 0,
    this.fresnelStrength = 1.0,
    required this.refractiveIndex,
    required this.saturation,
    required this.glowIntensity,
    required this.specularSharpness,
    required this.standardOpacityMultiplier,
    required this.shadowElevation,
    required this.shadow,
    required this.whitenStrength,
    required this.whitenGated,
    required this.edgeAbsorption,
    this.rimShade = 0.0,
    this.rimShadeEnds = 0.2,
    this.rimLight = 0.0,
    this.bodyShade = 0.0,
    this.lensModel = GlassLensModel.spherical,
    this.backerColor,
    this.platformViewFallbackColor,
    this.platformViewMode = PlatformViewGlassMode.fallbackColor,
    this.bodyMode = GlassBodyMode.adaptive,
    required this.pinchStrength,
  });

  /// Creates [LiquidGlassSettings] using Figma-inspired parameter names.
  ///
  /// **Important — units are not Figma percentages:**
  ///
  /// | Parameter | Range | Maps to |
  /// |-----------|-------|---------|
  /// | [refraction] | 0–100 % | [refractiveIndex] via `1 + (v/100) × 0.2` |
  /// | [depth] | logical pixels | [thickness] **directly** (not a Figma %) |
  /// | [dispersion] | 0–100 % | [chromaticAberration] via `4 × (v/100)` |
  /// | [frost] | logical pixels | [blur] **directly** (not a Figma %) |
  ///
  /// Figma's internal `depth` and `frost` use proprietary units with no public
  /// pixel-equivalent formula. Pass [depth] and [frost] as the logical-pixel
  /// values you want — typical ranges: depth 10–40, frost 2–8.
  ///
  /// [frost] here is the Figma blur slider: it maps to [blur] (a Gaussian
  /// sigma), not to the iOS 27 cloud of [LiquidGlassSettings.frost].
  const LiquidGlassSettings.figma({
    required double refraction,
    required double depth,
    required double dispersion,
    required double frost,
    double visibility = 1.0,
    double lightIntensity = 50,
    double lightAngle = GlassDefaults.lightAngle,
    Color glassColor = const Color.fromARGB(0, 255, 255, 255),
    GlassSpecularSharpness specularSharpness = GlassSpecularSharpness.medium,
    double standardOpacityMultiplier = 1.0,
  }) : this(
          visibility: visibility,
          refractiveIndex: 1 + (refraction / 100) * 0.2,
          thickness: depth,
          chromaticAberration: 4 * (dispersion / 100),
          lightIntensity: lightIntensity / 100,
          blur: frost,
          lightAngle: lightAngle,
          ambientStrength: 0.1,
          saturation: 1.5,
          glassColor: glassColor,
          specularSharpness: specularSharpness,
          standardOpacityMultiplier: standardOpacityMultiplier,
          // shadowElevation and shadow use their defaults (1.0 / null)
        );

  /// iOS 27 `glassEffect(.regular)` in the light appearance.
  ///
  /// Measured against the native control on the same screen: the body tint
  /// and saturation, the [frost] and the copy of the content showing
  /// through it, the [rimShade] outline and [rimLight] highlight, and the
  /// [GlassLensModel.paraxial] rim band. Tuned for [GlassQuality.premium],
  /// which draws the full material. The standard path and web approximate it:
  /// the regular blur stands in for the [frost] and the specular highlight for
  /// the [rimLight], while the [rimShade] outline, [bodyShade] and the paraxial
  /// lens band are premium-only.
  ///
  /// ```dart
  /// GlassButton(
  ///   settings: isDark
  ///       ? LiquidGlassSettings.ios27Dark
  ///       : LiquidGlassSettings.ios27Light,
  ///   quality: GlassQuality.premium,
  ///   ...
  /// )
  /// ```
  static const LiquidGlassSettings ios27Light = LiquidGlassSettings(
    glassColor: Color(0x87F8F8F8),
    saturation: 2.1,
    blur: 0.6,
    blurWeight: 0.8,
    frost: 14,
    frostOpacity: 0.73,
    frostClamp: 0.4,
    frostWeight: 2.0,
    thickness: 32,
    refractiveIndex: 1.24,
    lensModel: GlassLensModel.paraxial,
    lightAngle: 1.5707963267948966, // pi / 2: lit from the top
    lightIntensity: 0,
    fresnelStrength: 0,
    chromaticAberration: 0,
    edgeAbsorption: 0.035,
    rimShade: 1,
    rimLight: 1,
    shadow: [
      BoxShadow(color: Color(0x04000000), blurRadius: 10, offset: Offset(0, 7)),
    ],
  );

  /// iOS 27 `glassEffect(.regular)` in the dark appearance; see
  /// [ios27Light].
  static const LiquidGlassSettings ios27Dark = LiquidGlassSettings(
    glassColor: Color(0x1FFFFFFF),
    saturation: 1.4,
    blur: 0.6,
    blurWeight: 2.5,
    frost: 14,
    frostOpacity: 0.85,
    frostClamp: -0.45,
    frostWeight: 0.5,
    thickness: 32,
    refractiveIndex: 1.24,
    lensModel: GlassLensModel.paraxial,
    lightAngle: -1.5707963267948966, // -pi / 2: lit from the bottom
    lightIntensity: 0,
    fresnelStrength: 0,
    chromaticAberration: 0,
    edgeAbsorption: 0.035,
    rimShade: 1,
    rimShadeEnds: 0,
    rimLight: 1.15,
    bodyShade: 0.28,
    shadowElevation: 0,
  );

  /// Retrieves the nearest [LiquidGlassSettings] from the widget tree.
  ///
  /// This will look for the nearest ancestor [LiquidGlassLayer] or
  /// [LiquidGlassRenderScope] widget in the widget tree.
  static LiquidGlassSettings of(BuildContext context) {
    return LiquidGlassRenderScope.of(context).settings;
  }

  /// A factor that can be used to scale all thickness-related properties.
  ///
  /// Defaults to 1.0.
  final double visibility;

  /// The color tint of the glass effect.
  ///
  /// Opacity defines the intensity of the tint.
  ///
  /// **How the color is applied (Standard & Premium quality):**
  /// The shader uses a luminance-preserving tint (`applyGlassColorLW`): it takes
  /// your color's hue but holds the background's perceived brightness, preventing
  /// the glass from darkening or muddying the scene behind it. This means the
  /// rendered color will differ from the raw [Color] value — the shift is
  /// intentional optical glass behaviour, not a bug.
  ///
  /// **If you need a pixel-accurate, unmodified color overlay** with no luminance
  /// normalization or chromatic drift across any quality tier (including [GlassQuality.premium]
  /// and [GlassQuality.standard]), set [bodyMode] to [GlassBodyMode.clear]:
  ///
  /// ```dart
  /// LiquidGlassSettings(
  ///   bodyMode: GlassBodyMode.clear,
  ///   blur: 0,
  ///   glassColor: Color(0xD9C3E0F5),
  /// )
  /// ```
  ///
  /// In clear mode, the body tint is composited with exact alpha blending while
  /// still preserving specular highlights, Fresnel sheen, and 3D meniscus edge refraction.
  final Color glassColor;

  /// The effective glass color taking visibility into account.
  Color get effectiveGlassColor =>
      glassColor.withValues(alpha: glassColor.a * visibility);

  /// The thickness of the glass surface.
  ///
  /// Thicker surfaces refract the light more intensely.
  final double thickness;

  /// The effective thickness taking visibility into account.
  double get effectiveThickness => thickness * visibility;

  /// The blur (frost) radius of the glass effect.
  ///
  /// Higher values create a more frosted appearance.
  ///
  /// Defaults to 0.
  ///
  /// **`blur: 0` means clear optical glass, not a flat color fill.**
  /// At `blur: 0` the blur pass is skipped, but the surface retains its glass
  /// characteristics — specular rim highlight, Fresnel edge brightening, and
  /// sub-pixel edge refraction. This matches iOS 26 clear glass where zero frost
  /// still looks like a crystal pane, not a plain translucent container.
  ///
  /// To get a completely flat, shader-free color overlay (no optical effects at
  /// all), use [GlassQuality.minimal] instead of relying on `blur: 0`.
  final double blur;

  /// The effective blur taking visibility into account.
  double get effectiveBlur => blur * visibility;

  /// Heavy blur of the backdrop, as a Gaussian sigma in logical pixels,
  /// composited at [frostOpacity]. Defaults to 0, off.
  ///
  /// This is the cloud of iOS 27 glass: a blur far wider than [blur] that a
  /// copy of the lightly blurred content still shows through, so text under
  /// a control reads as pale ghosts rather than going out of focus. On a
  /// 56 pt control it measures at about `frost: 14, frostOpacity: 0.73`,
  /// with `blur: 0.6` barely softening the copy: the ghosts keep their
  /// edges.
  ///
  /// Costs one blur pass, written to alternate pixel rows of the shape; the
  /// glass shader makes the ghosts from the sharp rows between (about 45
  /// texture reads a pixel) and mixes the two, so a [blur] up to about
  /// 0.8 pt at 3x adds no pass of its own. A [frostWeight] other than 1
  /// adds one colour pass ahead of it. Like [rimShade], a frost also draws
  /// the glass's edge the native way.
  ///
  /// Not drawn on a rotated or skewed surface, or on the capture path; the
  /// neck between blended shapes is left unfrosted.
  ///
  /// Only affects the Premium (Impeller) path.
  final double frost;

  /// The effective frost taking visibility into account.
  double get effectiveFrost => frost * visibility;

  /// Opacity of the [frost] over the backdrop beneath it, from 0 to 1.
  ///
  /// At `1.0` (the default) the frost replaces the content under it. Below
  /// that a copy of the content, blurred by [blur], shows through and keeps
  /// `1 - frostOpacity` of its contrast against the cloud; see [frostClamp]
  /// for the side of it that is held back. The native material measures
  /// `0.73` light, `0.85` dark.
  final double frostOpacity;

  /// How far the copy of the content showing through the [frost] may stray
  /// from the cloud on one side, as a fraction of full scale before
  /// [frostOpacity] is applied; 0 (the default) leaves both sides free.
  ///
  /// Positive holds it from going darker than the cloud by more than this,
  /// negative from going lighter. That is the asymmetry of the native
  /// material: through the light glass a black stripe is a flat pale band
  /// and a white one a narrow bright hump, so dark detail reads bolder and
  /// light detail finer, and through the dark glass the reverse. Light
  /// measures `0.4`, dark `-0.45`.
  final double frostClamp;

  /// How many times a white pixel outweighs a black one in the [frost]'s
  /// average; 1 (the default) is a plain mean.
  ///
  /// The native frost is not a plain mean of the content beneath it: the
  /// light material's cloud over black-on-white detail reads brighter than
  /// the mean, the dark material's over white-on-black darker. Above 1
  /// light detail weighs more, below 1 dark detail; flat colour is
  /// unchanged either way. The light material measures `2.0`, the dark
  /// `0.5`, on a 56 pt control: the weighting covers the part of the blur
  /// that falls inside the shape, so it tells more on larger surfaces.
  final double frostWeight;

  /// How many times a white pixel outweighs a black one in the copy of the
  /// content that shows through a [frost], as [frostWeight] is for the
  /// cloud; 1 (the default) is a plain [blur].
  ///
  /// Below 1 dark detail dominates the copy, so through a [frost] a black
  /// stripe stays a flat, wide band while a white one thins to a hump: that
  /// is what makes dark content read bolder through the native light
  /// material (`0.8`). Above 1 the reverse, as under its dark material
  /// (`2.5`). Applies while the [blur] is one the glass shader draws itself
  /// (see [frost]).
  final double blurWeight;

  /// The chromatic aberration of the glass effect (WIP).
  ///
  /// This is a little ugly still.
  ///
  /// Higher values create more pronounced color fringes.
  final double chromaticAberration;

  /// The effective chromatic aberration taking visibility into account.
  double get effectiveChromaticAberration => chromaticAberration * visibility;

  /// The angle of the light source in radians.
  ///
  /// This determines where the highlights on shapes will come from.
  final double lightAngle;

  /// The intensity of the light source.
  ///
  /// Higher values create more pronounced highlights.
  final double lightIntensity;

  /// The effective light intensity taking visibility into account.
  double get effectiveLightIntensity => lightIntensity * visibility;

  /// The strength of the ambient light.
  ///
  /// Higher values create more pronounced ambient light.
  final double ambientStrength;

  /// Full-perimeter rim ("ring") boost, 0 to ~1.
  ///
  /// Premium: added to the Fresnel edge-luminosity strength (base 0.12), so
  /// the glass edge reads as a bright ring regardless of light direction —
  /// the iOS 26 in-motion pill look. Standard interactive glass: overrides
  /// the hardcoded ambientRim floor in [AnimatedGlassIndicator]. Default 0 =
  /// existing rendering everywhere.
  final double ambientRim;

  /// Scales the natural Fresnel edge luminosity on the Premium (Impeller) path.
  ///
  /// The Premium shader always computes a physics-based Fresnel rim from the
  /// 3D surface normals of the glass bevel. This is the "lit physical glass"
  /// appearance. [fresnelStrength] multiplies the coefficient of that term:
  ///
  /// - `1.0` (default) — full Fresnel, matching iOS 26 glass buttons and panels
  ///   that simulate real optical glass.
  /// - `0.0` — no Fresnel; the glass reads as a pure blur overlay with zero
  ///   physics-based rim. Matches iOS 26 system UI glass such as Messages
  ///   buttons, notification banners, and lock screen controls.
  /// - Intermediate values fade smoothly between the two appearances.
  ///
  /// This has no effect on the Standard or Frosted rendering paths, which do
  /// not compute a 3D Fresnel term.
  ///
  /// Defaults to `1.0`.
  final double fresnelStrength;

  /// The effective Fresnel strength taking visibility into account.
  ///
  /// The rim is the last thing to go when a surface fades, so it has to fade
  /// with it: left at full strength it outlives every other channel and
  /// strands a bright outline where the glass used to be.
  double get effectiveFresnelStrength => fresnelStrength * visibility;

  /// The effective ambient rim taking visibility into account.
  double get effectiveAmbientRim => ambientRim * visibility;

  /// The effective ambient strength taking visibility into account.
  double get effectiveAmbientStrength => ambientStrength * visibility;

  /// The strength of the refraction.
  ///
  /// Higher values create more pronounced refraction.
  /// Defaults to 1.51
  final double refractiveIndex;

  /// The saturation adjustment for pixels that shine through the glass.
  ///
  /// 1.0 means no change, values < 1.0 desaturate the background,
  /// values > 1.0 increase saturation.
  /// Defaults to 1.0
  final double saturation;

  /// The intensity of the fresnel edge glow on the glass rim.
  ///
  /// Controls how visible the glass-edge luminosity is on the Standard
  /// (2D shader) rendering path. Higher values create a more pronounced
  /// glowing edge. Premium (Impeller) path ignores this value.
  ///
  /// Defaults to 0.75.
  final double glowIntensity;

  /// The sharpness of the specular highlight on the glass rim.
  ///
  /// Controls how tightly focused the specular lobe is. Each variant maps to
  /// a fixed power-of-2 exponent the shader computes with a zero-transcendental
  /// multiply chain — 3–5× faster than `pow()` on mobile GPUs.
  ///
  /// Defaults to [GlassSpecularSharpness.medium] which matches iOS 26.
  final GlassSpecularSharpness specularSharpness;

  /// A multiplier applied to the alpha channel of [glassColor] when rendering
  /// in Standard mode. This allows tuning the Standard 2D compositing opacity
  /// to achieve parity with the Premium 3D volumetric refraction, without
  /// needing separate color values for each mode.
  ///
  /// Defaults to 1.0. A common "magic number" for light mode is ~0.4.
  final double standardOpacityMultiplier;

  /// Scales the built-in light-mode drop shadow on glass surfaces.
  ///
  /// The shadow only appears in light mode and uses Apple's iOS 26 elevation
  /// values as the baseline. This multiplier scales opacity and blur
  /// proportionally:
  ///
  /// - `0.0` — no shadow (flat glass)
  /// - `1.0` — default Apple-matching elevation (6% opacity, 8px blur)
  /// - `2.0` — double intensity (12% opacity, 16px blur)
  ///
  /// Has no effect in dark mode.
  ///
  /// For full control over shadow appearance, use [shadow] instead.
  /// If [shadow] is non-null, [shadowElevation] is ignored.
  ///
  /// Defaults to 1.0.
  final double shadowElevation;

  /// Custom light-mode drop shadow for glass surfaces.
  ///
  /// When non-null, this replaces the built-in elevation shadow entirely.
  /// The shadows are inverse-clipped to only appear outside the glass
  /// boundary, preventing the glass from blurring its own shadow.
  ///
  /// When null (the default), the built-in Apple-matching shadow is used,
  /// scaled by [shadowElevation].
  ///
  /// Has no effect in dark mode.
  final List<BoxShadow>? shadow;

  /// The effective elevation taking visibility into account.
  double get effectiveShadowElevation => shadowElevation * visibility;

  /// Returns the effective shadow list for light-mode rendering.
  ///
  /// Resolves [shadow] (full override) vs [shadowElevation] (scalar), and
  /// scales both by [visibility] — a surface that is fading out has to take
  /// its shadow with it, or the elevation stays at full strength underneath
  /// vanishing glass and then snaps away with it.
  List<BoxShadow> get effectiveShadow {
    if (shadow != null) {
      if (visibility >= 1.0) return shadow!;
      return <BoxShadow>[
        for (final s in shadow!)
          BoxShadow(
            color: s.color.withValues(alpha: s.color.a * visibility),
            offset: s.offset,
            blurRadius: s.blurRadius,
            spreadRadius: s.spreadRadius,
            blurStyle: s.blurStyle,
          ),
      ];
    }
    return GlassShadow.scaled(effectiveShadowElevation);
  }

  /// Light-mode whitening ("legibility veil") amount, from 0 to 1.
  ///
  /// On the Premium (Impeller) path this is applied as the last step of the
  /// render: the finished glass is mixed uniformly toward white,
  /// `mix(glass, white, whitenStrength)`. Because it is a single control-wide
  /// value (not per-pixel) there is no spatial seam, so no halo or outline
  /// artifacts. This models iOS 26 light-mode glass, which lays an even
  /// whitening layer over the refracted content for legibility on bright
  /// backgrounds — content stays visible, just whiter.
  ///
  /// The Standard and Frosted paths approximate the same knob by lifting the
  /// glass tint toward white (a "veil"), so a single value reads consistently
  /// across all quality tiers.
  ///
  /// Defaults to 0.0, which disables whitening entirely.
  final double whitenStrength;

  /// The effective whitening taking visibility into account.
  ///
  /// The veil is opaque paint laid over the finished glass, so a surface
  /// fading out has to take it with it — left raw it survives the glass and
  /// leaves a white patch behind.
  double get effectiveWhitenStrength => whitenStrength * visibility;

  /// Whether [whitenStrength] is luminance-gated (true, the default) or
  /// applied uniformly (false).
  ///
  /// Gated: the lift only affects brighter pixels and leaves dark content
  /// (text, icons) crisp — the light-mode behaviour. Ungated: an even lift
  /// across the whole control — useful in dark mode to give dark glass a
  /// subtle frost, where a per-pixel gate over an all-dark backdrop would
  /// zero the whitening out entirely.
  ///
  /// Only affects the Premium (Impeller) path; the Standard and Frosted
  /// approximations are always uniform.
  final bool whitenGated;

  /// Meniscus darkening strength at the glass rim, from 0 to 1.
  ///
  /// Physical glass is thicker at the curved rim (the meniscus). Light
  /// traversing more material loses energy, making the refracted scene subtly
  /// darker at the edge zone. The bright Fresnel and specular rim highlights
  /// then sit on top of this dark band, creating the visual depth that
  /// distinguishes real glass from a simple blur overlay.
  ///
  /// - `0.0` — no darkening (default; matches iOS 26 visual baseline)
  /// - `0.12` — subtle physical darkening (dark-mode depth effect)
  /// - `0.3` — pronounced rim darkening (thick or frosted glass look)
  final double edgeAbsorption;

  /// The effective meniscus darkening taking visibility into account.
  double get effectiveEdgeAbsorption => edgeAbsorption * visibility;

  /// Strength of the hairline outline on the very edge of the glass, 0 to 1.
  ///
  /// iOS 27 glass is bounded by a half-point line that is the backdrop at
  /// its own position, untinted and unblurred, darkened by a fixed step:
  /// about 31% across the light axis and a fifth of that at its ends, where
  /// the rim light sits ([rimShadeEnds]). Together with [rimLight] this is
  /// what reads as the "bubble" edge of a native control. `1.0` matches both
  /// native materials, the dark one's taken below a [bodyShade].
  ///
  /// Unlike [edgeAbsorption], which darkens the whole bevel, this touches
  /// only the outermost pixels. The line is subtracted from the colour
  /// beneath it rather than blended, so it stays the same step below any
  /// backdrop.
  ///
  /// Above zero (or under a [frost]) the glass's edge is also drawn as the
  /// native one is: its anti-aliasing narrows to half a logical pixel, so the
  /// outline lands on an opaque pixel, and the silhouette grows by a
  /// physical pixel at 3x, where the native outline sits outside the frame.
  ///
  /// Only affects the Premium (Impeller) path. Defaults to `0.0`, off.
  final double rimShade;

  /// The effective rim shade taking visibility into account.
  double get effectiveRimShade => rimShade * visibility;

  /// How much of [rimShade] survives at the ends of the light axis, where
  /// the [rimLight] lobes sit, as a fraction of its strength across it.
  ///
  /// The native light material keeps about a fifth of the outline there
  /// (`0.2`, the default); the dark material's outline dissolves into the
  /// lobes entirely (`0.0`).
  final double rimShadeEnds;

  /// Strength of the iOS 27 rim highlight.
  ///
  /// Two lobes at the ends of the light axis ([lightAngle]), the lit end
  /// stronger, each a sharp core one pixel inside the outline with a soft
  /// tail reaching a couple of points into the body. Additive, easing off as
  /// the body brightens so it reads the same over black and over white.
  /// `1.0` matches the native light material, `1.15` the dark; the wide
  /// specular controlled by [lightIntensity] is independent and can be left
  /// at zero alongside it.
  ///
  /// Only affects the Premium (Impeller) path. Defaults to `0.0`, off.
  final double rimLight;

  /// The effective rim light taking visibility into account.
  double get effectiveRimLight => rimLight * visibility;

  /// How far a bright backdrop is pulled down under the glass, 0 to 1.
  ///
  /// The native dark material does not lift a backdrop the way its tint
  /// alone would: over mid-grey and above it reads darker than the
  /// backdrop, and a white page comes out at about 184/255. Each pixel is
  /// scaled by `1 - bodyShade * luma²`, so dark content is barely touched and
  /// white loses [bodyShade] of itself. `0.28` matches the dark material.
  ///
  /// It takes the [rimShade] outline with it, which then sits its fixed step
  /// below the darkened backdrop: that is the dark outline the native
  /// control keeps over a white page.
  ///
  /// Only affects the Premium (Impeller) path. Defaults to `0.0`, off.
  final double bodyShade;

  /// The effective body shade taking visibility into account.
  double get effectiveBodyShade => bodyShade * visibility;

  /// How the bevel bends the backdrop. See [GlassLensModel].
  ///
  /// Defaults to [GlassLensModel.spherical], the existing rendering.
  final GlassLensModel lensModel;

  /// Internal shader transport — the animated pinch strength for the concave
  /// lens effect on indicator pills.
  ///
  /// Always `0.0` on instances created via the public constructor.
  /// Only non-zero when set by [AnimatedGlassIndicator] via [copyWithPinch].
  /// Configure from outside via the hosting widget's `indicatorPinchStrength`.
  final double pinchStrength;

  /// Returns a copy of these settings with [pinchStrength] set to [value].
  ///
  /// **Internal use only** — called exclusively by [AnimatedGlassIndicator]
  /// to thread the animated pinch value into the render shader.
  /// Users should configure this via `indicatorPinchStrength` on
  /// [GlassTabBar] or [GlassSegmentedControl].
  LiquidGlassSettings copyWithPinch(double value) =>
      LiquidGlassSettings._withPinch(
        visibility: visibility,
        glassColor: glassColor,
        thickness: thickness,
        blur: blur,
        frost: frost,
        frostOpacity: frostOpacity,
        frostClamp: frostClamp,
        frostWeight: frostWeight,
        blurWeight: blurWeight,
        chromaticAberration: chromaticAberration,
        lightAngle: lightAngle,
        lightIntensity: lightIntensity,
        ambientStrength: ambientStrength,
        ambientRim: ambientRim,
        fresnelStrength: fresnelStrength,
        refractiveIndex: refractiveIndex,
        saturation: saturation,
        glowIntensity: glowIntensity,
        specularSharpness: specularSharpness,
        standardOpacityMultiplier: standardOpacityMultiplier,
        shadowElevation: shadowElevation,
        shadow: shadow,
        whitenStrength: whitenStrength,
        whitenGated: whitenGated,
        edgeAbsorption: edgeAbsorption,
        rimShade: rimShade,
        rimShadeEnds: rimShadeEnds,
        rimLight: rimLight,
        bodyShade: bodyShade,
        lensModel: lensModel,
        backerColor: backerColor,
        platformViewFallbackColor: platformViewFallbackColor,
        platformViewMode: platformViewMode,
        bodyMode: bodyMode,
        pinchStrength: value,
      );

  /// Optional dimming "backer" painted directly behind the glass.
  ///
  /// A shape-matched, color-filled pad composited *behind* the glass surface —
  /// the inverse of [shadow], which sits outside the boundary. It provides
  /// contrast for a control's content over rich or colorful backdrops where the
  /// glass tint alone can't: video, maps, photography, or any control floating
  /// over busy content. This is Apple's "dimming layer" guidance for keeping
  /// glass controls legible (see the Materials section of the Human Interface
  /// Guidelines, and SwiftUI's clear `Glass` variant).
  ///
  /// The color's alpha *is* the dimming opacity. Apple suggests roughly 35% as
  /// a starting point — e.g. `Color(0x59000000)` for a neutral dark dim.
  ///
  /// Rendered at the widget level (like [shadow]), clipped to the glass shape,
  /// so it composites correctly even over a PlatformView — where a shader-side
  /// tint cannot reach.
  ///
  /// Defaults to null: no backer, and no change to existing rendering.
  final Color? backerColor;

  /// The effective backer taking visibility into account.
  ///
  /// Like the veil and the shadow, the pad is painted outside the shader and
  /// would otherwise stay at full strength while the glass in front of it
  /// dissolves, leaving a bare dimmed disc.
  Color? get effectiveBackerColor => backerColor == null || visibility >= 1.0
      ? backerColor
      : backerColor!.withValues(alpha: backerColor!.a * visibility);

  /// Solid stand-in color the lens composites where the engine can't capture the
  /// backdrop — i.e. behind a PlatformView past the glass, which the lens would
  /// otherwise render black (see `platformViewBackdrop` on the glass widgets).
  ///
  /// Distinct from [backerColor]: [backerColor] is an *aesthetic* dimming pad
  /// painted behind the glass everywhere; this is the *fallback fill* used only
  /// where the shader has no backdrop to sample. Splitting them lets a control
  /// have one without the other (e.g. a transparent over-map fill with no dim, or
  /// a dim pad off-PlatformView with no fill).
  ///
  /// Defaults to null, in which case it falls back to [backerColor] — so existing
  /// recipes that relied on `backerColor` doubling as the PlatformView fill are
  /// unchanged.
  final Color? platformViewFallbackColor;

  /// How the body resolves where the backdrop had nothing to sample.
  ///
  /// Defaults to [PlatformViewGlassMode.fallbackColor], which is the existing
  /// behaviour, so this changes nothing unless it is asked for.
  final PlatformViewGlassMode platformViewMode;

  /// How the glass body blends color over the background.
  ///
  /// Defaults to [GlassBodyMode.adaptive], which matches Apple's `Glass.regular`
  /// (luminance-preserving tint). Set to [GlassBodyMode.clear] to match Apple's
  /// `Glass.clear` (direct alpha-composite tint without luminance normalization).
  final GlassBodyMode bodyMode;

  /// The effective saturation taking visibility into account.
  double get effectiveSaturation => 1 + (saturation - 1) * visibility;

  /// The effective refractive index taking visibility into account.
  ///
  /// Lerps from 1.0 (no refraction) at [visibility]=0 toward the configured
  /// [refractiveIndex] as visibility increases. This matches how [Opacity]
  /// would fade the refraction distortion — at zero visibility there is no
  /// lens warp, at full visibility the warp is at its configured strength.
  double get effectiveRefractiveIndex =>
      1.0 + (refractiveIndex - 1.0) * visibility;

  /// Linearly interpolates between two [LiquidGlassSettings].
  static LiquidGlassSettings lerp(
    LiquidGlassSettings? a,
    LiquidGlassSettings? b,
    double t,
  ) {
    if (a == null && b == null) return const LiquidGlassSettings();
    if (a == null) return b!;
    if (b == null) return a;

    return LiquidGlassSettings._withPinch(
        visibility: lerpDouble(a.visibility, b.visibility, t)!,
        glassColor: Color.lerp(a.glassColor, b.glassColor, t)!,
        thickness: lerpDouble(a.thickness, b.thickness, t)!,
        blur: lerpDouble(a.blur, b.blur, t)!,
        frost: lerpDouble(a.frost, b.frost, t)!,
        frostOpacity: lerpDouble(a.frostOpacity, b.frostOpacity, t)!,
        frostClamp: lerpDouble(a.frostClamp, b.frostClamp, t)!,
        frostWeight: lerpDouble(a.frostWeight, b.frostWeight, t)!,
        blurWeight: lerpDouble(a.blurWeight, b.blurWeight, t)!,
        chromaticAberration:
            lerpDouble(a.chromaticAberration, b.chromaticAberration, t)!,
        lightAngle: lerpDouble(a.lightAngle, b.lightAngle, t)!,
        lightIntensity: lerpDouble(a.lightIntensity, b.lightIntensity, t)!,
        ambientStrength: lerpDouble(a.ambientStrength, b.ambientStrength, t)!,
        ambientRim: lerpDouble(a.ambientRim, b.ambientRim, t)!,
        fresnelStrength: lerpDouble(a.fresnelStrength, b.fresnelStrength, t)!,
        refractiveIndex: lerpDouble(a.refractiveIndex, b.refractiveIndex, t)!,
        saturation: lerpDouble(a.saturation, b.saturation, t)!,
        glowIntensity: lerpDouble(a.glowIntensity, b.glowIntensity, t)!,
        specularSharpness: t < 0.5 ? a.specularSharpness : b.specularSharpness,
        standardOpacityMultiplier: lerpDouble(
            a.standardOpacityMultiplier, b.standardOpacityMultiplier, t)!,
        shadowElevation: lerpDouble(a.shadowElevation, b.shadowElevation, t)!,
        shadow: t < 0.5 ? a.shadow : b.shadow,
        whitenStrength: lerpDouble(a.whitenStrength, b.whitenStrength, t)!,
        whitenGated: t < 0.5 ? a.whitenGated : b.whitenGated,
        edgeAbsorption: lerpDouble(a.edgeAbsorption, b.edgeAbsorption, t)!,
        rimShade: lerpDouble(a.rimShade, b.rimShade, t)!,
        rimShadeEnds: lerpDouble(a.rimShadeEnds, b.rimShadeEnds, t)!,
        rimLight: lerpDouble(a.rimLight, b.rimLight, t)!,
        bodyShade: lerpDouble(a.bodyShade, b.bodyShade, t)!,
        lensModel: t < 0.5 ? a.lensModel : b.lensModel,
        // Lerp the color so the backer fades smoothly (from/to transparent when
        // one side is null), rather than popping at the midpoint.
        backerColor: Color.lerp(a.backerColor, b.backerColor, t),
        platformViewFallbackColor: Color.lerp(
            a.platformViewFallbackColor, b.platformViewFallbackColor, t),
        // A mode is not interpolable: it switches at the midpoint like any
        // other enum in this class.
        platformViewMode: t < 0.5 ? a.platformViewMode : b.platformViewMode,
        bodyMode: t < 0.5 ? a.bodyMode : b.bodyMode,
        // pinchStrength is interaction state — lerp it so transitions are smooth
        // when the indicator fades between active/resting states.
        pinchStrength: lerpDouble(a.pinchStrength, b.pinchStrength, t)!);
  }

  /// Helper for linear interpolation of doubles.
  static double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }

  /// Creates a new [LiquidGlassSettings] with the given settings.
  LiquidGlassSettings copyWith({
    double? visibility,
    Color? glassColor,
    double? thickness,
    double? blur,
    double? frost,
    double? frostOpacity,
    double? frostClamp,
    double? frostWeight,
    double? blurWeight,
    double? chromaticAberration,
    double? blend,
    double? lightAngle,
    double? lightIntensity,
    double? ambientStrength,
    double? ambientRim,
    double? fresnelStrength,
    double? refractiveIndex,
    double? saturation,
    double? glowIntensity,
    GlassSpecularSharpness? specularSharpness,
    double? standardOpacityMultiplier,
    double? shadowElevation,
    List<BoxShadow>? shadow,
    double? whitenStrength,
    bool? whitenGated,
    double? edgeAbsorption,
    double? rimShade,
    double? rimShadeEnds,
    double? rimLight,
    double? bodyShade,
    GlassLensModel? lensModel,
    Color? backerColor,
    Color? platformViewFallbackColor,
    PlatformViewGlassMode? platformViewMode,
    GlassBodyMode? bodyMode,
  }) =>
      LiquidGlassSettings._withPinch(
        visibility: visibility ?? this.visibility,
        glassColor: glassColor ?? this.glassColor,
        thickness: thickness ?? this.thickness,
        blur: blur ?? this.blur,
        frost: frost ?? this.frost,
        frostOpacity: frostOpacity ?? this.frostOpacity,
        frostClamp: frostClamp ?? this.frostClamp,
        frostWeight: frostWeight ?? this.frostWeight,
        blurWeight: blurWeight ?? this.blurWeight,
        chromaticAberration: chromaticAberration ?? this.chromaticAberration,
        lightAngle: lightAngle ?? this.lightAngle,
        lightIntensity: lightIntensity ?? this.lightIntensity,
        ambientStrength: ambientStrength ?? this.ambientStrength,
        ambientRim: ambientRim ?? this.ambientRim,
        fresnelStrength: fresnelStrength ?? this.fresnelStrength,
        refractiveIndex: refractiveIndex ?? this.refractiveIndex,
        saturation: saturation ?? this.saturation,
        glowIntensity: glowIntensity ?? this.glowIntensity,
        specularSharpness: specularSharpness ?? this.specularSharpness,
        standardOpacityMultiplier:
            standardOpacityMultiplier ?? this.standardOpacityMultiplier,
        shadowElevation: shadowElevation ?? this.shadowElevation,
        shadow: shadow ?? this.shadow,
        whitenStrength: whitenStrength ?? this.whitenStrength,
        whitenGated: whitenGated ?? this.whitenGated,
        edgeAbsorption: edgeAbsorption ?? this.edgeAbsorption,
        rimShade: rimShade ?? this.rimShade,
        rimShadeEnds: rimShadeEnds ?? this.rimShadeEnds,
        rimLight: rimLight ?? this.rimLight,
        bodyShade: bodyShade ?? this.bodyShade,
        lensModel: lensModel ?? this.lensModel,
        backerColor: backerColor ?? this.backerColor,
        platformViewFallbackColor:
            platformViewFallbackColor ?? this.platformViewFallbackColor,
        platformViewMode: platformViewMode ?? this.platformViewMode,
        bodyMode: bodyMode ?? this.bodyMode,
        pinchStrength: pinchStrength,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LiquidGlassSettings &&
        other.visibility == visibility &&
        other.glassColor == glassColor &&
        other.thickness == thickness &&
        other.blur == blur &&
        other.frost == frost &&
        other.frostOpacity == frostOpacity &&
        other.frostClamp == frostClamp &&
        other.frostWeight == frostWeight &&
        other.blurWeight == blurWeight &&
        other.chromaticAberration == chromaticAberration &&
        other.lightAngle == lightAngle &&
        other.lightIntensity == lightIntensity &&
        other.ambientStrength == ambientStrength &&
        other.ambientRim == ambientRim &&
        other.fresnelStrength == fresnelStrength &&
        other.refractiveIndex == refractiveIndex &&
        other.saturation == saturation &&
        other.glowIntensity == glowIntensity &&
        other.specularSharpness == specularSharpness &&
        other.standardOpacityMultiplier == standardOpacityMultiplier &&
        other.shadowElevation == shadowElevation &&
        listEquals(other.shadow, shadow) &&
        other.whitenStrength == whitenStrength &&
        other.whitenGated == whitenGated &&
        other.edgeAbsorption == edgeAbsorption &&
        other.rimShade == rimShade &&
        other.rimShadeEnds == rimShadeEnds &&
        other.rimLight == rimLight &&
        other.bodyShade == bodyShade &&
        other.lensModel == lensModel &&
        other.backerColor == backerColor &&
        other.platformViewFallbackColor == platformViewFallbackColor &&
        other.platformViewMode == platformViewMode &&
        other.bodyMode == bodyMode &&
        other.pinchStrength == pinchStrength;
  }

  @override
  int get hashCode => Object.hashAll([
        visibility,
        glassColor,
        thickness,
        blur,
        frost,
        frostOpacity,
        frostClamp,
        frostWeight,
        blurWeight,
        chromaticAberration,
        lightAngle,
        lightIntensity,
        ambientStrength,
        ambientRim,
        fresnelStrength,
        refractiveIndex,
        saturation,
        glowIntensity,
        specularSharpness,
        standardOpacityMultiplier,
        shadowElevation,
        shadow == null ? null : Object.hashAll(shadow!),
        whitenStrength,
        whitenGated,
        edgeAbsorption,
        rimShade,
        rimShadeEnds,
        rimLight,
        bodyShade,
        lensModel,
        backerColor,
        platformViewFallbackColor,
        platformViewMode,
        bodyMode,
        pinchStrength,
      ]);
}
