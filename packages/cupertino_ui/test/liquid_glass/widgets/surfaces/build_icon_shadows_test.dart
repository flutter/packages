import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Direct relative import for the internal @visibleForTesting function
// ignore: implementation_imports
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_bottom_internal.dart';

void main() {
  // ── buildIconShadows ────────────────────────────────────────────────────────

  group('buildIconShadows', () {
    const red = Colors.red;

    test('returns null when thickness is null', () {
      final result = buildIconShadows(
        iconColor: red,
        thickness: null,
        selected: false,
        activeIcon: null,
      );
      expect(result, isNull);
    });

    test('returns null when selected=true and activeIcon is non-null', () {
      // When the tab has a distinct active icon the outline shadow is suppressed
      final result = buildIconShadows(
        iconColor: red,
        thickness: 1.0,
        selected: true,
        activeIcon: const Icon(Icons.star), // non-null active icon
      );
      expect(result, isNull);
    });

    test('returns 8 shadows when thickness set and selected=false', () {
      final result = buildIconShadows(
        iconColor: red,
        thickness: 1.5,
        selected: false,
        activeIcon: null,
      );
      expect(result, isNotNull);
      // 8 directions: 0, π/4, π/2, … 7π/4
      expect(result!.length, 8);
    });

    test('returns 8 shadows when selected=true but activeIcon is null', () {
      // selected but no distinct active icon → shadow still applied
      final result = buildIconShadows(
        iconColor: red,
        thickness: 2.0,
        selected: true,
        activeIcon: null,
      );
      expect(result, isNotNull);
      expect(result!.length, 8);
    });

    test('shadow offsets are evenly spaced at 45° increments', () {
      const thickness = 2.0;
      final result = buildIconShadows(
        iconColor: red,
        thickness: thickness,
        selected: false,
        activeIcon: null,
      )!;

      for (int i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final expected = Offset.fromDirection(angle, thickness);
        expect(result[i].offset.dx, closeTo(expected.dx, 1e-10));
        expect(result[i].offset.dy, closeTo(expected.dy, 1e-10));
      }
    });

    test('each shadow uses the provided iconColor', () {
      const color = Color(0xFF1E90FF);
      final result = buildIconShadows(
        iconColor: color,
        thickness: 1.0,
        selected: false,
        activeIcon: null,
      )!;

      for (final shadow in result) {
        expect(shadow.color, color);
      }
    });
  });
}
