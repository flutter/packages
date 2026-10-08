import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../engine/liquid_glass_settings.dart';

/// Threads a materialize transition's per-frame state to the glass surfaces
/// below it, so they dissolve through the shader's own uniforms instead of
/// layer opacity.
///
/// An ancestor [Opacity] or [ImageFiltered] cannot fade glass: a backdrop
/// pass renders fully or not at all, so the glass pops while its child fades
/// (the same Impeller limitation [ProgressiveBlur] documents for ShaderMask).
/// Every uniform upload already reads the `effective*` getters on
/// [LiquidGlassSettings], which scale by [LiquidGlassSettings.visibility] —
/// at zero the refraction warp lerps to identity and the render object skips
/// the pass entirely. That is the legal fade channel, and this scope is how a
/// transition widget reaches it for every surface in its subtree at once.
///
/// Two channels ride on the scope:
///
/// * **Glass** — [glassProgress] scales `visibility`, the single input every
///   shader uniform and every widget-level decoration reads through its own
///   `effective*` getter. The configured blur is left alone: the shader
///   multiplies it by visibility, so a dissolving surface stops blurring its
///   backdrop as it goes. Driving the blur *up* to keep the surface looking
///   frosty smears whatever is behind a shape nobody can see any more.
/// * **Content** — [contentOpacity] and [contentSigma] fade and gaussian-blur
///   the glass *child*, which is ordinary painted content where those
///   compose fine. Kept separate from the glass channel so the transition can
///   lag one behind the other (glass resolves first, the icon sharpens last).
class GlassMaterializeScope extends InheritedWidget {
  /// Declares the materialize state for the glass surfaces below [child].
  const GlassMaterializeScope({
    required this.glassProgress,
    required this.contentOpacity,
    required this.contentSigma,
    required super.child,
    super.key,
  });

  /// How materialized the glass is: 0.0 = fully dematerialized, 1.0 = at
  /// rest. At 1.0 the scope is inert — [resolveSettings] returns its input
  /// unchanged and [wrapContent] adds nothing.
  final double glassProgress;

  /// Opacity applied to glass children, on top of the visibility fade the
  /// glass channel already applies through [LiquidGlassSettings].
  final double contentOpacity;

  /// Gaussian sigma applied to glass children, in logical pixels.
  final double contentSigma;

  /// The nearest scope above [context], or null when no transition is
  /// running anywhere above.
  static GlassMaterializeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassMaterializeScope>();

  /// Applies the nearest scope's glass channel to [base].
  ///
  /// Returns [base] itself — the same instance — when no scope is present or
  /// the scope is at rest, so resting glass pays nothing beyond the inherited
  /// lookup.
  static LiquidGlassSettings resolveSettings(
    BuildContext context,
    LiquidGlassSettings base,
  ) {
    final scope = maybeOf(context);
    if (scope == null || scope.glassProgress >= 1.0) return base;
    return scope._transform(base);
  }

  /// Applies the nearest scope's content channel around [child].
  ///
  /// Returns [child] untouched when no scope is present or the content
  /// channel is itself at rest. It deliberately does *not* test
  /// [glassProgress]: the two channels are staggered, so the glass reaches
  /// 1.0 while the content is still sharpening. Gating this on the glass
  /// dropped the blur in a single frame at that crossing — the icon snapped
  /// between sharp and soft with the glass shell unchanged around it.
  ///
  /// The opacity and filter widgets are otherwise both always present, even
  /// at a momentary sigma of zero, so the child's element tree keeps one
  /// shape for the whole of a transition.
  static Widget wrapContent(BuildContext context, Widget child) {
    final scope = maybeOf(context);
    if (scope == null ||
        (scope.contentOpacity >= 1.0 && scope.contentSigma <= 0.0)) {
      return child;
    }
    return Opacity(
      opacity: scope.contentOpacity.clamp(0.0, 1.0),
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: scope.contentSigma,
          sigmaY: scope.contentSigma,
        ),
        child: child,
      ),
    );
  }

  /// Scales `visibility`, and nothing else.
  ///
  /// Every channel that has to fade with the glass — the shader uniforms, the
  /// shadow, the whitening veil, the backer pad — reads its own `effective*`
  /// getter, and each of those already multiplies by `visibility`. Scaling any
  /// of them here as well applied the progress twice: the built-in shadow
  /// faded as t², so it left roughly twice as fast as the glass it belonged
  /// to.
  LiquidGlassSettings _transform(LiquidGlassSettings base) => base.copyWith(
      visibility: base.visibility * glassProgress.clamp(0.0, 1.0));

  @override
  bool updateShouldNotify(GlassMaterializeScope oldWidget) =>
      glassProgress != oldWidget.glassProgress ||
      contentOpacity != oldWidget.contentOpacity ||
      contentSigma != oldWidget.contentSigma;
}
