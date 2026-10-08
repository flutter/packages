import 'package:flutter/widgets.dart';

/// Marks a subtree whose ancestor scale is applied to the glass alone, and not
/// to the backdrop that glass samples.
///
/// [RenderLiquidGlassLayer] freezes its shader UV coordinates when it sees a
/// uniform scale-down above it, because the case that motivated it — the
/// CupertinoSheet push-back (#192) — scales the glass *and* the page it samples
/// together, leaving the sampled texture in unscaled coordinates.
///
/// A surface that scales itself is the opposite arrangement: the backdrop
/// behind it holds still, so the live transform is the correct one and freezing
/// strands the shader's shape at the size and position the surface had when the
/// scale began. The two are indistinguishable from the matrix, so the widget
/// applying the scale says which it is.
///
/// ## Consumer contract — ORing ancestor declarations
///
/// [of] resolves only the *nearest* scope in the tree. If you are adding a
/// new scope in a widget that may itself sit inside another scope (e.g.
/// [LiquidStretch] inside a swiped sheet), you **must** carry the ancestor's
/// value through by ORing it into your own `selfScaled`:
///
/// ```dart
/// LiquidGlassSelfScaleScope(
///   selfScaled: LiquidGlassSelfScaleScope.of(context) || myOwnCondition,
///   child: ...,
/// )
/// ```
///
/// Failing to do this shadows the ancestor's declaration — any glass widget
/// below will lose its exemption while the ancestor is self-scaling, and the
/// premium refraction will freeze during that window. Widgets that are
/// guaranteed to be the outermost scope (e.g. [GlassMaterializeEffect] and
/// the sheet morph presenter) may set `selfScaled` directly without ORing,
/// since they are never nested inside another scope.
class LiquidGlassSelfScaleScope extends InheritedWidget {
  /// Declares that an ancestor scale over [child] does not move its backdrop.
  const LiquidGlassSelfScaleScope({
    required this.selfScaled,
    required super.child,
    super.key,
  });

  /// Whether such a scale is currently in effect.
  ///
  /// Held false while the surface sits at its natural size, so an ordinary
  /// push-back over a resting surface still freezes as it should.
  final bool selfScaled;

  /// The scale below which [RenderLiquidGlassLayer] freezes, so a caller can
  /// declare itself on exactly the same boundary rather than an invented one.
  static const double freezeScaleThreshold = 0.9999;

  /// Whether [context] sits under a scope that is currently self-scaling.
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LiquidGlassSelfScaleScope>()
          ?.selfScaled ??
      false;

  @override
  bool updateShouldNotify(LiquidGlassSelfScaleScope oldWidget) =>
      selfScaled != oldWidget.selfScaled;
}
