// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final theme = ThemeData();

  Widget buildApp(Widget child) {
    return MaterialApp(
      theme: theme,
      home: Center(child: child),
    );
  }

  CustomPainter painterOf(WidgetTester tester) {
    return tester
        .widget<CustomPaint>(
          find.descendant(of: find.byType(LoadingIndicator), matching: find.byType(CustomPaint)),
        )
        .painter!;
  }

  /// Returns the rotation of the canvas that the indicator paints its shape
  /// with.
  double paintedRotation(WidgetTester tester) {
    late double rotation;
    expect(
      find.byType(LoadingIndicator),
      paints..something((Symbol methodName, List<dynamic> arguments) {
        if (methodName != #rotate) {
          return false;
        }
        rotation = arguments[0] as double;
        return true;
      }),
    );
    return rotation;
  }

  ShapeDecoration? containerDecorationOf(WidgetTester tester) {
    final Finder finder = find.descendant(
      of: find.byType(LoadingIndicator),
      matching: find.byType(DecoratedBox),
    );
    if (finder.evaluate().isEmpty) {
      return null;
    }
    return tester.widget<DecoratedBox>(finder).decoration as ShapeDecoration;
  }

  testWidgets('LoadingIndicator has the default size', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    expect(tester.getSize(find.byType(LoadingIndicator)), const Size.square(48));

    await tester.pumpWidget(buildApp(const LoadingIndicator.contained()));
    expect(tester.getSize(find.byType(LoadingIndicator)), const Size.square(48));
  });

  testWidgets('LoadingIndicator fills tight constraints', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(const SizedBox(width: 200, height: 100, child: LoadingIndicator.contained())),
    );
    expect(tester.getSize(find.byType(LoadingIndicator)), const Size(200, 100));
  });

  testWidgets('LoadingIndicator does not crash at zero area', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const SizedBox.shrink(child: LoadingIndicator())));
    expect(tester.getSize(find.byType(LoadingIndicator)), Size.zero);

    await tester.pumpWidget(buildApp(const SizedBox.shrink(child: LoadingIndicator.contained())));
    expect(tester.getSize(find.byType(LoadingIndicator)), Size.zero);
  });

  testWidgets('LoadingIndicator has the default colors', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    expect(containerDecorationOf(tester), isNull);
    expect(find.byType(LoadingIndicator), paints..path(color: theme.colorScheme.primary));

    await tester.pumpWidget(buildApp(const LoadingIndicator.contained()));
    final ShapeDecoration decoration = containerDecorationOf(tester)!;
    expect(decoration.color, theme.colorScheme.primaryContainer);
    expect(decoration.shape, const StadiumBorder());
    expect(
      find.byType(LoadingIndicator),
      paints..path(color: theme.colorScheme.onPrimaryContainer),
    );
  });

  testWidgets('LoadingIndicator uses the given colors and shape', (WidgetTester tester) async {
    const color = Color(0xfffffff0);
    const containerColor = Color(0xfffffff1);
    const containerShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    await tester.pumpWidget(buildApp(const LoadingIndicator(color: color)));
    expect(find.byType(LoadingIndicator), paints..path(color: color));

    await tester.pumpWidget(
      buildApp(
        const LoadingIndicator.contained(
          color: color,
          containerColor: containerColor,
          containerShape: containerShape,
        ),
      ),
    );
    final ShapeDecoration decoration = containerDecorationOf(tester)!;
    expect(decoration.color, containerColor);
    expect(decoration.shape, containerShape);
    expect(find.byType(LoadingIndicator), paints..path(color: color));
  });

  testWidgets('Indeterminate LoadingIndicator keeps animating', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    expect(tester.hasRunningAnimations, isTrue);

    // Sample across several morphs to make sure the indicator keeps going
    // after each one completes.
    for (var i = 0; i < 20; i++) {
      final double rotation = paintedRotation(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(paintedRotation(tester), isNot(moreOrLessEquals(rotation)));
    }
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('Indeterminate LoadingIndicator repaints without rebuilding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    final CustomPainter painter = painterOf(tester);
    final double rotation = paintedRotation(tester);

    // The painter listens to the animation directly, so the same painter
    // paints each frame.
    await tester.pump(const Duration(milliseconds: 100));
    expect(painterOf(tester), same(painter));
    expect(paintedRotation(tester), isNot(moreOrLessEquals(rotation)));
  });

  testWidgets('Determinate LoadingIndicator does not animate', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 0.5)));
    expect(tester.hasRunningAnimations, isFalse);

    final CustomPainter painter = painterOf(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(painterOf(tester).shouldRepaint(painter), isFalse);
  });

  testWidgets('Determinate LoadingIndicator repaints when its value changes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 0.25)));
    final CustomPainter painter = painterOf(tester);

    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 0.75)));
    expect(painterOf(tester).shouldRepaint(painter), isTrue);
  });

  testWidgets('LoadingIndicator clamps its value', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 1.0)));
    final CustomPainter painter = painterOf(tester);

    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 2.0)));
    expect(painterOf(tester).shouldRepaint(painter), isFalse);

    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 0.0)));
    final CustomPainter zeroPainter = painterOf(tester);

    await tester.pumpWidget(buildApp(const LoadingIndicator(value: -1.0)));
    expect(painterOf(tester).shouldRepaint(zeroPainter), isFalse);
  });

  testWidgets('A complete determinate LoadingIndicator turns indeterminate without a seam', (
    WidgetTester tester,
  ) async {
    /// Returns the rotation of the canvas and the bounds of the shape that the
    /// indicator paints.
    (double, Rect) paintedShape() {
      late double rotation;
      late Rect bounds;
      expect(
        find.byType(LoadingIndicator),
        paints..everything((Symbol methodName, List<dynamic> arguments) {
          if (methodName == #rotate) {
            rotation = arguments[0] as double;
          } else if (methodName == #drawPath) {
            bounds = (arguments[0] as Path).getBounds();
          }
          return true;
        }),
      );
      return (rotation, bounds);
    }

    await tester.pumpWidget(buildApp(const LoadingIndicator.contained(value: 1.0)));
    final (double determinateRotation, Rect determinateBounds) = paintedShape();

    await tester.pumpWidget(buildApp(const LoadingIndicator.contained()));
    final (double indeterminateRotation, Rect indeterminateBounds) = paintedShape();

    // The bounds include the curves' control points, which differ slightly as
    // the same shape is split into curves differently by each morph.
    expect(indeterminateRotation, moreOrLessEquals(determinateRotation));
    expect(indeterminateBounds.width, moreOrLessEquals(determinateBounds.width, epsilon: 0.5));
    expect(indeterminateBounds.height, moreOrLessEquals(determinateBounds.height, epsilon: 0.5));
  });

  testWidgets('Default determinate and indeterminate shapes are drawn at the same size', (
    WidgetTester tester,
  ) async {
    Rect shapeBounds() {
      late Rect bounds;
      expect(
        find.byType(LoadingIndicator),
        paints..something((Symbol methodName, List<dynamic> arguments) {
          if (methodName != #drawPath) {
            return false;
          }
          bounds = (arguments[0] as Path).getBounds();
          return true;
        }),
      );
      return bounds;
    }

    // Both start from shapes that fill their bounds, a circle and a soft burst.
    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 0.0)));
    final Rect circle = shapeBounds();
    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    final Rect softBurst = shapeBounds();

    expect(circle.width, moreOrLessEquals(softBurst.width, epsilon: 1.0));
    expect(circle.height, moreOrLessEquals(softBurst.height, epsilon: 1.0));
  });

  testWidgets('LoadingIndicator switches between determinate and indeterminate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 0.5)));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('LoadingIndicator keeps its semantics node when switching modes', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 1.0)));
    final int id = tester.getSemantics(find.byType(LoadingIndicator)).id;

    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    expect(tester.getSemantics(find.byType(LoadingIndicator)).id, id);

    await tester.pumpWidget(buildApp(const LoadingIndicator(value: 0.5)));
    expect(tester.getSemantics(find.byType(LoadingIndicator)).id, id);
    handle.dispose();
  });

  testWidgets('Indeterminate LoadingIndicator keeps its rotation when its polygons change', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(const LoadingIndicator()));
    await tester.pump(const Duration(milliseconds: 1000));
    final double rotation = paintedRotation(tester);

    await tester.pumpWidget(
      buildApp(
        LoadingIndicator(polygons: <RoundedPolygon>[MaterialShapes.square, MaterialShapes.heart]),
      ),
    );
    expect(paintedRotation(tester), moreOrLessEquals(rotation));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pump(const Duration(milliseconds: 100));
    expect(paintedRotation(tester), isNot(moreOrLessEquals(rotation)));
  });

  testWidgets('LoadingIndicator morphs between the given polygons', (WidgetTester tester) async {
    final polygons = <RoundedPolygon>[MaterialShapes.square, MaterialShapes.triangle];

    await tester.pumpWidget(buildApp(LoadingIndicator(value: 0.0, polygons: polygons)));
    final CustomPainter startPainter = painterOf(tester);

    await tester.pumpWidget(buildApp(LoadingIndicator(value: 1.0, polygons: polygons)));
    expect(painterOf(tester).shouldRepaint(startPainter), isTrue);

    // Equal polygons, even in a new list, keep the same morphs.
    final CustomPainter endPainter = painterOf(tester);
    await tester.pumpWidget(
      buildApp(LoadingIndicator(value: 1.0, polygons: List<RoundedPolygon>.of(polygons))),
    );
    expect(painterOf(tester).shouldRepaint(endPainter), isFalse);

    await tester.pumpWidget(
      buildApp(
        LoadingIndicator(
          value: 1.0,
          polygons: <RoundedPolygon>[MaterialShapes.square, MaterialShapes.heart],
        ),
      ),
    );
    expect(painterOf(tester).shouldRepaint(endPainter), isTrue);
  });

  testWidgets('LoadingIndicator asserts that it has at least two polygons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(LoadingIndicator(polygons: <RoundedPolygon>[MaterialShapes.circle])),
    );
    expect(
      tester.takeException(),
      isAssertionError.having(
        (AssertionError error) => error.message,
        'message',
        contains('at least two polygons'),
      ),
    );
  });

  test('LoadingIndicator default polygons', () {
    expect(LoadingIndicator.indeterminatePolygons, <RoundedPolygon>[
      MaterialShapes.softBurst,
      MaterialShapes.cookie9Sided,
      MaterialShapes.pentagon,
      MaterialShapes.pill,
      MaterialShapes.sunny,
      MaterialShapes.cookie4Sided,
      MaterialShapes.oval,
    ]);
    expect(LoadingIndicator.determinatePolygons, hasLength(2));
    expect(LoadingIndicator.determinatePolygons.first, isNot(MaterialShapes.circle));
    expect(LoadingIndicator.determinatePolygons.last, MaterialShapes.softBurst);
    expect(
      () => LoadingIndicator.indeterminatePolygons.add(MaterialShapes.circle),
      throwsUnsupportedError,
    );
    expect(
      () => LoadingIndicator.determinatePolygons.add(MaterialShapes.circle),
      throwsUnsupportedError,
    );
  });

  testWidgets('Indeterminate LoadingIndicator semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(buildApp(const LoadingIndicator(semanticsLabel: 'Loading')));

    expect(
      tester.getSemantics(find.byType(LoadingIndicator)),
      matchesSemantics(label: 'Loading', textDirection: TextDirection.ltr),
    );
    expect(tester.getSemantics(find.byType(LoadingIndicator)).role, SemanticsRole.loadingSpinner);
    handle.dispose();
  });

  testWidgets('Determinate LoadingIndicator semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      buildApp(const LoadingIndicator.contained(value: 0.25, semanticsLabel: 'Progress')),
    );

    expect(
      tester.getSemantics(find.byType(LoadingIndicator)),
      matchesSemantics(
        label: 'Progress',
        value: '25',
        minValue: '0',
        maxValue: '100',
        textDirection: TextDirection.ltr,
      ),
    );
    expect(tester.getSemantics(find.byType(LoadingIndicator)).role, SemanticsRole.progressBar);

    await tester.pumpWidget(
      buildApp(
        const LoadingIndicator(value: 0.25, semanticsLabel: 'Progress', semanticsValue: '30'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(LoadingIndicator)),
      matchesSemantics(
        label: 'Progress',
        value: '30',
        minValue: '0',
        maxValue: '100',
        textDirection: TextDirection.ltr,
      ),
    );
    handle.dispose();
  });

  testWidgets('LoadingIndicator stops animating when tickers are disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(const TickerMode(enabled: false, child: LoadingIndicator())));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(buildApp(const TickerMode(enabled: true, child: LoadingIndicator())));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('Default LoadingIndicator debugFillProperties', (WidgetTester tester) async {
    final builder = DiagnosticPropertiesBuilder();
    const LoadingIndicator().debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[]);
  });

  testWidgets('LoadingIndicator implements debugFillProperties', (WidgetTester tester) async {
    final builder = DiagnosticPropertiesBuilder();
    const LoadingIndicator.contained(
      value: 0.5,
      color: Color(0xfffffff0),
      containerColor: Color(0xfffffff1),
      containerShape: CircleBorder(),
      semanticsLabel: 'label',
      semanticsValue: 'value',
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[
      'value: 0.5',
      'color: ${const Color(0xfffffff0)}',
      'containerColor: ${const Color(0xfffffff1)}',
      'containerShape: CircleBorder(BorderSide(width: 0.0, style: none))',
      'semanticsLabel: "label"',
      'semanticsValue: "value"',
      'contained',
    ]);
  });

  for (final value in <double>[0.0, 0.25, 0.5, 0.75, 1.0]) {
    testWidgets('Determinate LoadingIndicator golden at $value', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          RepaintBoundary(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox.square(dimension: 100, child: LoadingIndicator(value: value)),
                SizedBox.square(dimension: 100, child: LoadingIndicator.contained(value: value)),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('loading_indicator.determinate.$value.png'),
      );
    });
  }

  testWidgets('Indeterminate LoadingIndicator golden', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        const RepaintBoundary(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox.square(dimension: 100, child: LoadingIndicator()),
              SizedBox.square(dimension: 100, child: LoadingIndicator.contained()),
            ],
          ),
        ),
      ),
    );

    // Captures the start of a morph, the middle of its spring overshoot, and
    // the hold after it settles, across a few morphs.
    var elapsedMs = 0;
    for (final ms in <int>[0, 150, 500, 650, 800, 1150, 1300, 1450]) {
      await tester.pump(Duration(milliseconds: ms - elapsedMs));
      elapsedMs = ms;
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('loading_indicator.indeterminate.${ms}ms.png'),
      );
    }
  });
}
