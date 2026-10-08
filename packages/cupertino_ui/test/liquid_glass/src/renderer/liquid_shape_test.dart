import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// Since we are mocking painting and path generation, we just ensure no exceptions are thrown.

void main() {
  group('LiquidShape', () {
    const rect = Rect.fromLTWH(0, 0, 100, 100);

    test('LiquidRoundedSuperellipse works correctly', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 20);

      // Test equality and hashCode
      expect(shape, equals(const LiquidRoundedSuperellipse(borderRadius: 20)));
      expect(shape.hashCode,
          equals(const LiquidRoundedSuperellipse(borderRadius: 20).hashCode));
      expect(shape,
          isNot(equals(const LiquidRoundedSuperellipse(borderRadius: 25))));

      // Test copyWith
      final copied = shape.copyWith(borderRadius: 30);
      expect(copied.borderRadius, 30);

      // Test scale
      final scaled = shape.scale(2.0) as LiquidRoundedSuperellipse;
      expect(scaled.borderRadius, 40);

      // Test path generation
      final inner = shape.getInnerPath(rect);
      final outer = shape.getOuterPath(rect);
      expect(inner, isNotNull);
      expect(outer, isNotNull);
    });

    test('LiquidOval works correctly', () {
      const shape = LiquidOval();

      // Test equality and hashCode
      expect(shape, equals(const LiquidOval()));
      expect(shape.hashCode, equals(const LiquidOval().hashCode));

      // Test copyWith
      final copied = shape.copyWith(side: const BorderSide(width: 2));
      expect(copied.side.width, 2);

      // Test scale
      final scaled = shape.scale(2.0) as LiquidOval;
      expect(scaled, isNotNull);

      // Test path generation
      final inner = shape.getInnerPath(rect);
      final outer = shape.getOuterPath(rect);
      expect(inner, isNotNull);
      expect(outer, isNotNull);
    });

    test('LiquidRoundedRectangle works correctly', () {
      const shape = LiquidRoundedRectangle(borderRadius: 15);

      // Test equality and hashCode
      expect(shape, equals(const LiquidRoundedRectangle(borderRadius: 15)));
      expect(shape.hashCode,
          equals(const LiquidRoundedRectangle(borderRadius: 15).hashCode));
      expect(
          shape, isNot(equals(const LiquidRoundedRectangle(borderRadius: 20))));

      // Test copyWith
      final copied = shape.copyWith(borderRadius: 25);
      expect(copied.borderRadius, 25);

      // Test scale
      final scaled = shape.scale(2.0) as LiquidRoundedRectangle;
      expect(scaled.borderRadius, 30);

      // Test path generation
      final inner = shape.getInnerPath(rect);
      final outer = shape.getOuterPath(rect);
      expect(inner, isNotNull);
      expect(outer, isNotNull);
    });

    test('LiquidVerticalRoundedRectangle works correctly', () {
      const shape =
          LiquidVerticalRoundedRectangle(topRadius: 10, bottomRadius: 20);

      // Test equality and hashCode
      expect(
          shape,
          equals(const LiquidVerticalRoundedRectangle(
              topRadius: 10, bottomRadius: 20)));
      expect(
          shape.hashCode,
          equals(const LiquidVerticalRoundedRectangle(
                  topRadius: 10, bottomRadius: 20)
              .hashCode));
      expect(
          shape,
          isNot(equals(const LiquidVerticalRoundedRectangle(
              topRadius: 15, bottomRadius: 20))));

      // Test copyWith
      final copied = shape.copyWith(topRadius: 15);
      expect(copied.topRadius, 15);
      expect(copied.bottomRadius, 20);

      // Test scale
      final scaled = shape.scale(2.0) as LiquidVerticalRoundedRectangle;
      expect(scaled.topRadius, 20);
      expect(scaled.bottomRadius, 40);

      // Test path generation
      final inner = shape.getInnerPath(rect);
      final outer = shape.getOuterPath(rect);
      expect(inner, isNotNull);
      expect(outer, isNotNull);
    });

    test('LiquidVerticalRoundedSuperellipse works correctly', () {
      const shape =
          LiquidVerticalRoundedSuperellipse(topRadius: 5, bottomRadius: 15);

      // Test equality and hashCode
      expect(
          shape,
          equals(const LiquidVerticalRoundedSuperellipse(
              topRadius: 5, bottomRadius: 15)));
      expect(
          shape.hashCode,
          equals(const LiquidVerticalRoundedSuperellipse(
                  topRadius: 5, bottomRadius: 15)
              .hashCode));
      expect(
          shape,
          isNot(equals(const LiquidVerticalRoundedSuperellipse(
              topRadius: 10, bottomRadius: 15))));

      // Test copyWith
      final copied = shape.copyWith(bottomRadius: 25);
      expect(copied.topRadius, 5);
      expect(copied.bottomRadius, 25);

      // Test scale
      final scaled = shape.scale(2.0) as LiquidVerticalRoundedSuperellipse;
      expect(scaled.topRadius, 10);
      expect(scaled.bottomRadius, 30);

      // Test path generation
      final inner = shape.getInnerPath(rect);
      final outer = shape.getOuterPath(rect);
      expect(inner, isNotNull);
      expect(outer, isNotNull);
    });
  });
}
