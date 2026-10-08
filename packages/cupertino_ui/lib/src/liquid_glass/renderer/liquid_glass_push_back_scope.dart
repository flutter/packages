import 'package:flutter/widgets.dart';

/// Package-internal scope that marks a CupertinoSheet push-back transition.
///
/// Emitted by [GlassPage] when the route it sits on is being pushed back by a
/// presented sheet (`secondaryAnimation > 0`). **Not exported from the public
/// barrel** — this is an internal engine primitive.
///
/// [RenderLiquidGlassLayer] reads this as a positive gate: UV freezing only
/// activates when BOTH a uniform scale is detected AND this scope is active.
///
/// Without this scope in the tree [RenderLiquidGlassLayer._hasScale] always
/// returns `false`, so a persistent app-level scale applied by
/// `responsive_framework`, [FittedBox], or [InteractiveViewer] never triggers
/// the UV freeze that caused jitter (#292).
class LiquidGlassPushBackScope extends InheritedWidget {
  /// Creates a scope that signals whether a CupertinoSheet push-back is active.
  const LiquidGlassPushBackScope({
    super.key,
    required this.active,
    required super.child,
  });

  /// Whether a CupertinoSheet push-back is currently in progress above this
  /// point in the widget tree.
  final bool active;

  /// Returns `true` if [context] sits inside an active push-back transition.
  ///
  /// Defaults to `false` — no push-back, so UV freezing is disabled — when
  /// no [LiquidGlassPushBackScope] ancestor exists (e.g. the app does not
  /// use [GlassPage] at all, or the page is at rest).
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LiquidGlassPushBackScope>()
          ?.active ??
      false;

  @override
  bool updateShouldNotify(LiquidGlassPushBackScope old) => active != old.active;
}
