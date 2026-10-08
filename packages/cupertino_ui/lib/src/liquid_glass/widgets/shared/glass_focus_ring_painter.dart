// Internal shared painter for the iOS 26-style keyboard focus ring.
//
// NOT part of the public API — do not export from liquid_glass_widgets.dart.
library;

import 'package:flutter/cupertino.dart';

/// Paints an iOS 26-style keyboard focus ring around a [ShapeBorder].
///
/// Used by [GlassFocusRegion] in both interactive and observe modes.
///
/// Renders as a soft luminous glow — wide diffuse outer halo + crisp inner
/// stroke — so the ring reads as a light emission from the glass rather than
/// a flat overlay border. Zero GPU cost for unfocused widgets: the painter is
/// only mounted inside a [ValueListenableBuilder] when focus is active.
class GlassFocusRingPainter extends CustomPainter {
  /// Creates a new [GlassFocusRingPainter].
  GlassFocusRingPainter({
    required this.shape,
    required this.color,
  });

  /// The shape of the focus ring.
  final ShapeBorder shape;

  /// The color of the focus ring.
  final Color color;

  static const double _outset = 3.0;
  static const double _ringWidth = 1.5;
  static const double _glowWidth = 8.0;
  static const double _outerGlowWidth = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Expand the rect so the ring sits outside the shape boundary.
    final ringRect = Rect.fromLTWH(
      -_outset,
      -_outset,
      size.width + _outset * 2,
      size.height + _outset * 2,
    );
    final path = shape.getOuterPath(ringRect);

    // Outermost diffuse halo — very wide, very faint. Creates the "glow from
    // inside the glass" feel rather than a flat CSS-style border.
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _outerGlowWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // Mid glow — moderate width, low opacity.
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _glowWidth
        ..strokeCap = StrokeCap.round,
    );

    // Inner ring — crisp, full-opacity. This is the sharp definition edge.
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(GlassFocusRingPainter oldDelegate) =>
      color != oldDelegate.color || shape != oldDelegate.shape;
}
