// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/third_party/liquid_glass_renderer/ATTRIBUTION.md for provenance and modification history.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import 'liquid_glass_settings.dart';
import 'liquid_shape.dart';

// ---------------------------------------------------------------------------
// SpecularRimPainter — light-angle specular rim stroke
//
// Ported from FakeGlass._paintSpecular() (whynotmake.it, MIT).
// Pure Canvas drawing: two gradient strokes with BlendMode.hardLight and
// BlendMode.overlay. Zero GPU shader cost on any platform.
// ---------------------------------------------------------------------------
class SpecularRimPainter extends CustomPainter {
  const SpecularRimPainter({
    required this.shape,
    required this.settings,
  });

  final LiquidShape shape;
  final LiquidGlassSettings settings;

  @override
  void paint(Canvas canvas, Size size) {
    final lightIntensity = settings.effectiveLightIntensity.clamp(0.0, 1.0);
    if (lightIntensity == 0) return;

    final ambientStrength = settings.effectiveAmbientStrength.clamp(0.0, 1.0);
    final alpha = Curves.easeOut.transform(lightIntensity);
    final white = CupertinoColors.white.withValues(alpha: alpha);

    final rad = settings.lightAngle;
    final x = math.cos(rad);
    // Invert Y to match the GLSL fragment shader coordinate space (up is positive).
    final y = -math.sin(rad);

    // Expand to a square so the gradient angle matches the light angle exactly:
    // a squashed gradient rect distorts the effective direction.
    final bounds = Offset.zero & size;
    final squareBounds = Rect.fromCircle(
      center: bounds.center,
      radius: bounds.size.longestSide / 2,
    );

    // How far the light covers the glass (gradient stop spread).
    final lightCoverage = ui.lerpDouble(.3, .5, lightIntensity)!;

    // Adjust gradient scale for non-square aspect ratios.
    final aspectRatio = size.width / size.height.clamp(0.001, double.infinity);
    final alignmentWithShortestSide = (aspectRatio < 1 ? y : x).abs();
    final aspectAdjustment = 1 - 1 / aspectRatio.clamp(0.001, double.infinity);
    final gradientScale = aspectAdjustment * (1 - alignmentWithShortestSide);

    final inset = ui.lerpDouble(0, .5, gradientScale.clamp(0, 1))!;
    final secondInset =
        ui.lerpDouble(lightCoverage, .5, gradientScale.clamp(0, 1))!;

    final gradient = LinearGradient(
      colors: [
        white,
        white.withValues(alpha: ambientStrength),
        white.withValues(alpha: ambientStrength),
        white,
      ],
      stops: [inset, secondInset, 1 - secondInset, 1 - inset],
      begin: Alignment(x, y),
      end: Alignment(-x, -y),
    ).createShader(squareBounds);

    // Visible inner stroke widths:
    // Pass 1: soft base stroke (visible width 0.5 to 1.0 px)
    final w1 = ui.lerpDouble(0.5, 1.0, lightIntensity)!;
    // Pass 2: sharp inner rim (visible width 0.25 to 1.0 px)
    final w2 = (settings.effectiveThickness / 40).clamp(0.25, 1.0);

    // Draw strokes along deflated paths so the stroke outer edge coincides
    // with the shape boundary and stays strictly inside bounds. This eliminates
    // coincident-edge anti-aliasing conflict with _ShapeClip during scaling/transforms.
    final path1 = shape.getOuterPath(
      bounds.width > w1 * 2 && bounds.height > w1 * 2
          ? bounds.deflate(w1 / 2)
          : bounds,
    );
    canvas.drawPath(
      path1,
      Paint()
        ..shader = gradient
        ..color = white.withValues(alpha: white.a * 0.4)
        ..blendMode = BlendMode.overlay
        ..style = PaintingStyle.stroke
        ..strokeWidth = w1,
    );

    final path2 = shape.getOuterPath(
      bounds.width > w2 * 2 && bounds.height > w2 * 2
          ? bounds.deflate(w2 / 2)
          : bounds,
    );
    canvas.drawPath(
      path2,
      Paint()
        ..shader = gradient
        ..color = white.withValues(alpha: white.a * 0.6)
        ..blendMode = BlendMode.overlay
        ..style = PaintingStyle.stroke
        ..strokeWidth = w2,
    );
  }

  @override
  bool shouldRepaint(SpecularRimPainter old) =>
      old.settings != settings || old.shape != shape;
}
