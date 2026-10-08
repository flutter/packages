import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme.dart';
import '../../theme/glass_theme_data.dart';
import '../../theme/glass_theme_settings.dart';

/// Drives the glass specular highlight angle from a stream of radians.
///
/// Wraps its subtree with an updated [GlassTheme] that overrides
/// `lightAngle` whenever a new value arrives on [lightAngle].
///
/// Typical use — hook up to `sensors_plus` gyroscope data or any animation:
///
/// ```dart
/// GlassMotionScope(
///   lightAngle: gyroscopeEvents.map((e) => e.y * 0.5),
///   child: child,
/// )
/// ```
///
/// When [lightAngle] is null the widget is a transparent pass-through.
class GlassMotionScope extends StatefulWidget {
  /// Creates a [GlassMotionScope].
  ///
  /// [lightAngle] is a stream of angles **in radians**. Each emitted value
  /// replaces the `lightAngle` in the [GlassTheme] for this subtree.
  const GlassMotionScope({
    required this.child,
    this.lightAngle,
    super.key,
  });

  /// Stream of light angles in radians.
  ///
  /// Overrides [LiquidGlassSettings.lightAngle] for all glass widgets in this
  /// subtree. If null, no override is applied.
  final Stream<double>? lightAngle;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<GlassMotionScope> createState() => _GlassMotionScopeState();
}

class _GlassMotionScopeState extends State<GlassMotionScope> {
  StreamSubscription<double>? _subscription;
  double? _currentAngle;

  @override
  void initState() {
    super.initState();
    _subscribe(widget.lightAngle);
  }

  @override
  void didUpdateWidget(GlassMotionScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lightAngle != widget.lightAngle) {
      _subscription?.cancel();
      _currentAngle = null;
      _subscribe(widget.lightAngle);
    }
  }

  void _subscribe(Stream<double>? stream) {
    if (stream == null) return;
    _subscription = stream.listen((angle) {
      if (mounted) setState(() => _currentAngle = angle);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle = _currentAngle;
    if (angle == null) return widget.child;

    final parent = GlassThemeData.of(context);

    GlassThemeVariant applyAngle(GlassThemeVariant variant) {
      return variant.copyWith(
        settings: (variant.settings ?? const GlassThemeSettings())
            .copyWith(lightAngle: angle),
      );
    }

    return GlassTheme(
      data: parent.copyWith(
        light: applyAngle(parent.light),
        dark: applyAngle(parent.dark),
      ),
      child: widget.child,
    );
  }
}
