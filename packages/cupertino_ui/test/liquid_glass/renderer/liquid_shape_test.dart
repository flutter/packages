import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass.dart';
import 'package:liquid_glass_widgets/src/engine/render_liquid_glass_geometry.dart';

class _FakeRenderLiquidGlass extends Fake implements RenderLiquidGlass {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      '_FakeRenderLiquidGlass';
}

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // LiquidShape base class
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassDefaults safeRadius methods', () {
    test('safeRadius preserves finite values', () {
      expect(GlassDefaults.safeRadius(16.0), equals(16.0));
      expect(GlassDefaults.safeRadius(0.0), equals(0.0));
    });

    test('safeRadius clamps negative values to 0.0', () {
      expect(GlassDefaults.safeRadius(-5.0), equals(0.0));
    });

    test('safeRadius maps double.infinity and non-finite to maxSafeRadius', () {
      expect(GlassDefaults.safeRadius(double.infinity),
          equals(GlassDefaults.maxSafeRadius));
      expect(GlassDefaults.safeRadius(double.negativeInfinity),
          equals(GlassDefaults.maxSafeRadius));
      expect(GlassDefaults.safeRadius(double.nan),
          equals(GlassDefaults.maxSafeRadius));
    });

    test('safeBorderRadius converts correctly', () {
      final br = GlassDefaults.safeBorderRadius(double.infinity);
      expect(br.topLeft.x, equals(GlassDefaults.maxSafeRadius));
      expect(br.topRight.x, equals(GlassDefaults.maxSafeRadius));
      expect(br.bottomLeft.x, equals(GlassDefaults.maxSafeRadius));
      expect(br.bottomRight.x, equals(GlassDefaults.maxSafeRadius));
    });

    test('safeVerticalBorderRadius converts correctly', () {
      final br = GlassDefaults.safeVerticalBorderRadius(double.infinity, 12.0);
      expect(br.topLeft.x, equals(GlassDefaults.maxSafeRadius));
      expect(br.bottomLeft.x, equals(12.0));
    });
  });

  group('LiquidShape', () {
    test('toBorderRadius and isSuperellipse on subclasses', () {
      const oval = LiquidOval();
      expect(oval.toBorderRadius(), isNull);
      expect(oval.isSuperellipse, isFalse);

      const rect = LiquidRoundedRectangle(borderRadius: 16);
      expect(rect.toBorderRadius(), equals(BorderRadius.circular(16)));
      expect(rect.isSuperellipse, isFalse);

      const superellipse = LiquidRoundedSuperellipse(borderRadius: 20);
      expect(superellipse.toBorderRadius(), equals(BorderRadius.circular(20)));
      expect(superellipse.isSuperellipse, isTrue);

      const vertRect = LiquidVerticalRoundedRectangle(
        topRadius: 10,
        bottomRadius: 30,
      );
      expect(
        vertRect.toBorderRadius(),
        equals(const BorderRadius.vertical(
          top: Radius.circular(10),
          bottom: Radius.circular(30),
        )),
      );
      expect(vertRect.isSuperellipse, isFalse);

      const vertSuper = LiquidVerticalRoundedSuperellipse(
        topRadius: 15,
        bottomRadius: 25,
      );
      expect(
        vertSuper.toBorderRadius(),
        equals(const BorderRadius.vertical(
          top: Radius.circular(15),
          bottom: Radius.circular(25),
        )),
      );
      expect(vertSuper.isSuperellipse, isTrue);
    });

    test('LiquidOval equality and hashCode', () {
      const shape = LiquidOval();
      expect(shape.hashCode, equals(const LiquidOval().hashCode));
    });

    test('LiquidOval equality', () {
      const a = LiquidOval();
      const b = LiquidOval();
      expect(a, equals(b));
    });

    test('LiquidOval with side inequality', () {
      const a = LiquidOval();
      const b = LiquidOval(side: BorderSide(color: Colors.red));
      expect(a, isNot(equals(b)));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LiquidOval
  // ──────────────────────────────────────────────────────────────────────────

  group('LiquidOval', () {
    test('can be instantiated', () {
      const shape = LiquidOval();
      expect(shape, isA<LiquidOval>());
      expect(shape.side, BorderSide.none);
    });

    test('copyWith returns correct type', () {
      const shape = LiquidOval();
      final copy = shape.copyWith(side: const BorderSide(color: Colors.blue));
      expect(copy, isA<LiquidOval>());
    });

    test('copyWith preserves null side', () {
      const shape = LiquidOval();
      final copy = shape.copyWith();
      expect(copy.side, BorderSide.none);
    });

    test('scale returns LiquidOval', () {
      const shape = LiquidOval();
      final scaled = shape.scale(0.5);
      expect(scaled, isA<LiquidOval>());
    });

    test('getOuterPath returns a Path', () {
      const shape = LiquidOval();
      final path = shape.getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path, isA<Path>());
    });

    test('getInnerPath returns a Path', () {
      const shape = LiquidOval();
      final path = shape.getInnerPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path, isA<Path>());
    });

    test('paint does not throw', () {
      const shape = LiquidOval();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      shape.paint(canvas, const Rect.fromLTWH(0, 0, 100, 100));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LiquidRoundedSuperellipse
  // ──────────────────────────────────────────────────────────────────────────

  group('LiquidRoundedSuperellipse', () {
    test('stores borderRadius', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 20);
      expect(shape.borderRadius, 20);
    });

    test('equality holds for same values', () {
      const a = LiquidRoundedSuperellipse(borderRadius: 20);
      const b = LiquidRoundedSuperellipse(borderRadius: 20);
      expect(a, equals(b));
    });

    test('inequality for different borderRadius', () {
      const a = LiquidRoundedSuperellipse(borderRadius: 10);
      const b = LiquidRoundedSuperellipse(borderRadius: 20);
      expect(a, isNot(equals(b)));
    });

    test('hashCode holds for same values', () {
      const a = LiquidRoundedSuperellipse(borderRadius: 15);
      const b = LiquidRoundedSuperellipse(borderRadius: 15);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith creates new instance with updated borderRadius', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 10);
      final copy = shape.copyWith(borderRadius: 30);
      expect(copy.borderRadius, 30);
    });

    test('copyWith preserves existing values when null passed', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 10);
      final copy = shape.copyWith();
      expect(copy.borderRadius, 10);
      expect(copy.side, BorderSide.none);
    });

    test('copyWith with side override', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 10);
      final copy =
          shape.copyWith(side: const BorderSide(color: Colors.red, width: 2));
      expect(copy.side.color, Colors.red);
    });

    test('scale multiplies borderRadius', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 20);
      final scaled = shape.scale(2.0);
      expect((scaled as LiquidRoundedSuperellipse).borderRadius,
          closeTo(40.0, 1e-10));
    });

    test('getOuterPath returns a Path', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 10);
      final path = shape.getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path, isA<Path>());
    });

    test('getInnerPath returns a Path', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 10);
      final path = shape.getInnerPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path, isA<Path>());
    });

    test('paint does not throw', () {
      const shape = LiquidRoundedSuperellipse(borderRadius: 10);
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      shape.paint(canvas, const Rect.fromLTWH(0, 0, 100, 100));
    });

    test(
        'infinite borderRadius getOuterPath produces rounded path without collapsing',
        () {
      const shape = LiquidRoundedSuperellipse(borderRadius: double.infinity);
      final path = shape.getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path.contains(const Offset(1, 1)), isFalse);
      expect(path.contains(const Offset(50, 50)), isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LiquidRoundedRectangle
  // ──────────────────────────────────────────────────────────────────────────

  group('LiquidRoundedRectangle', () {
    test('stores borderRadius', () {
      const shape = LiquidRoundedRectangle(borderRadius: 8);
      expect(shape.borderRadius, 8);
    });

    test('equality holds for same values', () {
      const a = LiquidRoundedRectangle(borderRadius: 8);
      const b = LiquidRoundedRectangle(borderRadius: 8);
      expect(a, equals(b));
    });

    test('inequality for different borderRadius', () {
      const a = LiquidRoundedRectangle(borderRadius: 4);
      const b = LiquidRoundedRectangle(borderRadius: 8);
      expect(a, isNot(equals(b)));
    });

    test('hashCode holds for same values', () {
      const a = LiquidRoundedRectangle(borderRadius: 12);
      const b = LiquidRoundedRectangle(borderRadius: 12);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith updates borderRadius', () {
      const shape = LiquidRoundedRectangle(borderRadius: 8);
      final copy = shape.copyWith(borderRadius: 16);
      expect(copy.borderRadius, 16);
    });

    test('copyWith preserves values when null passed', () {
      const shape = LiquidRoundedRectangle(borderRadius: 8);
      final copy = shape.copyWith();
      expect(copy.borderRadius, 8);
    });

    test('copyWith updates side', () {
      const shape = LiquidRoundedRectangle(borderRadius: 8);
      final copy = shape.copyWith(side: const BorderSide(color: Colors.blue));
      expect(copy.side.color, Colors.blue);
    });

    test('scale multiplies borderRadius', () {
      const shape = LiquidRoundedRectangle(borderRadius: 10);
      final scaled = shape.scale(0.5);
      expect(
          (scaled as LiquidRoundedRectangle).borderRadius, closeTo(5.0, 1e-10));
    });

    test('getOuterPath returns a Path', () {
      const shape = LiquidRoundedRectangle(borderRadius: 8);
      final path = shape.getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path, isA<Path>());
    });

    test('getInnerPath returns a Path', () {
      const shape = LiquidRoundedRectangle(borderRadius: 8);
      final path = shape.getInnerPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path, isA<Path>());
    });

    test('paint does not throw', () {
      const shape = LiquidRoundedRectangle(borderRadius: 8);
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      shape.paint(canvas, const Rect.fromLTWH(0, 0, 100, 100));
    });

    test(
        'infinite borderRadius guards against 0.0 collapse and renders capsule path',
        () {
      const shape = LiquidRoundedRectangle(borderRadius: double.infinity);
      final path = shape.getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      // For a 100x100 box, infinite radius must scale to a circle of radius 50.
      // Corner (1, 1) should be outside the circle.
      expect(path.contains(const Offset(1, 1)), isFalse);
      // Center (50, 50) and edges should be inside.
      expect(path.contains(const Offset(50, 50)), isTrue);
      expect(path.contains(const Offset(50, 5)), isTrue);
      expect(path.contains(const Offset(5, 50)), isTrue);
    });

    test('infinite borderRadius getInnerPath produces capsule path', () {
      const shape = LiquidRoundedRectangle(borderRadius: double.infinity);
      final path = shape.getInnerPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path.contains(const Offset(1, 1)), isFalse);
      expect(path.contains(const Offset(50, 50)), isTrue);
    });

    test('infinite borderRadius paint does not throw', () {
      const shape = LiquidRoundedRectangle(borderRadius: double.infinity);
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      shape.paint(canvas, const Rect.fromLTWH(0, 0, 100, 100));
    });
  });

  group('LiquidVerticalRoundedRectangle infinite radii', () {
    test('infinite topRadius and bottomRadius produce rounded path', () {
      const shape = LiquidVerticalRoundedRectangle(
        topRadius: double.infinity,
        bottomRadius: double.infinity,
      );
      final path = shape.getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path.contains(const Offset(1, 1)), isFalse);
      expect(path.contains(const Offset(50, 50)), isTrue);
    });
  });

  group('LiquidVerticalRoundedSuperellipse infinite radii', () {
    test('infinite topRadius and bottomRadius produce rounded path', () {
      const shape = LiquidVerticalRoundedSuperellipse(
        topRadius: double.infinity,
        bottomRadius: double.infinity,
      );
      final path = shape.getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path.contains(const Offset(1, 1)), isFalse);
      expect(path.contains(const Offset(50, 50)), isTrue);
    });
  });

  group('ShapeGeometry safe radius handling for shader uniforms', () {
    final fakeRender = _FakeRenderLiquidGlass();

    test('LiquidRoundedSuperellipse extracts safe finite corner radii', () {
      final geom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidRoundedSuperellipse(borderRadius: 16),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(geom.rawCornerRadius, equals(16.0));
      expect(geom.rawBottomCornerRadius, equals(16.0));

      final infGeom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidRoundedSuperellipse(borderRadius: double.infinity),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(infGeom.rawCornerRadius, equals(GlassDefaults.maxSafeRadius));
      expect(
          infGeom.rawBottomCornerRadius, equals(GlassDefaults.maxSafeRadius));
    });

    test('LiquidRoundedRectangle extracts safe finite corner radii', () {
      final geom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidRoundedRectangle(borderRadius: 20),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(geom.rawCornerRadius, equals(20.0));
      expect(geom.rawBottomCornerRadius, equals(20.0));

      final infGeom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidRoundedRectangle(borderRadius: double.infinity),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(infGeom.rawCornerRadius, equals(GlassDefaults.maxSafeRadius));
      expect(
          infGeom.rawBottomCornerRadius, equals(GlassDefaults.maxSafeRadius));
    });

    test('LiquidVerticalRoundedRectangle extracts safe finite corner radii',
        () {
      final geom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidVerticalRoundedRectangle(
          topRadius: 10,
          bottomRadius: 30,
        ),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(geom.rawCornerRadius, equals(10.0));
      expect(geom.rawBottomCornerRadius, equals(30.0));

      final infGeom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidVerticalRoundedRectangle(
          topRadius: double.infinity,
          bottomRadius: double.infinity,
        ),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(infGeom.rawCornerRadius, equals(GlassDefaults.maxSafeRadius));
      expect(
          infGeom.rawBottomCornerRadius, equals(GlassDefaults.maxSafeRadius));
    });

    test('LiquidVerticalRoundedSuperellipse extracts safe finite corner radii',
        () {
      final geom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidVerticalRoundedSuperellipse(
          topRadius: 12,
          bottomRadius: 24,
        ),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(geom.rawCornerRadius, equals(12.0));
      expect(geom.rawBottomCornerRadius, equals(24.0));

      final infGeom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidVerticalRoundedSuperellipse(
          topRadius: double.infinity,
          bottomRadius: double.infinity,
        ),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(infGeom.rawCornerRadius, equals(GlassDefaults.maxSafeRadius));
      expect(
          infGeom.rawBottomCornerRadius, equals(GlassDefaults.maxSafeRadius));
    });

    test('LiquidOval extracts 0.0 corner radii', () {
      final geom = ShapeGeometry(
        renderObject: fakeRender,
        shape: const LiquidOval(),
        glassContainsChild: false,
        shapeBounds: const Rect.fromLTWH(0, 0, 100, 50),
      );
      expect(geom.rawCornerRadius, equals(0.0));
      expect(geom.rawBottomCornerRadius, equals(0.0));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LiquidGlass factory constructors
  // ──────────────────────────────────────────────────────────────────────────

  group('LiquidGlass widget constructors', () {
    test('LiquidGlass default constructor creates widget', () {
      const widget = LiquidGlass(
        shape: LiquidOval(),
        child: SizedBox.square(dimension: 100),
      );
      expect(widget, isA<Widget>());
    });

    test('LiquidGlass.grouped creates widget', () {
      const widget = LiquidGlass.grouped(
        shape: LiquidRoundedSuperellipse(borderRadius: 20),
        child: SizedBox.square(dimension: 100),
      );
      expect(widget, isA<Widget>());
    });

    test('LiquidGlass.withOwnLayer creates widget', () {
      final widget = LiquidGlass.withOwnLayer(
        shape: const LiquidRoundedRectangle(borderRadius: 12),
        settings: const LiquidGlassSettings(thickness: 20),
        child: const SizedBox.square(dimension: 100),
      );
      expect(widget, isA<Widget>());
    });

    test('LiquidGlass stores glassContainsChild', () {
      const widget = LiquidGlass(
        shape: LiquidOval(),
        glassContainsChild: true,
        child: SizedBox.square(dimension: 50),
      );
      expect(widget.glassContainsChild, isTrue);
    });

    test('LiquidGlass has defaults', () {
      const widget = LiquidGlass(
        shape: LiquidOval(),
        child: SizedBox.square(dimension: 50),
      );
      expect(widget.glassContainsChild, isFalse);
    });
  });
}
