// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/loading_indicator/loading_indicator.1.dart'
    as example;

void main() {
  LoadingIndicator currentIndicator(WidgetTester tester) {
    return tester.widget<LoadingIndicator>(find.byType(LoadingIndicator));
  }

  /// The transform of the closest [Transform] around the indicator, which
  /// rotates it further when the list is pulled further than it needs to be
  /// to refresh.
  Matrix4 overPullTransform(WidgetTester tester) {
    return tester
        .widget<Transform>(
          find
              .ancestor(
                of: find.byType(LoadingIndicator),
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform;
  }

  double indicatorOpacity(WidgetTester tester) {
    return tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(LoadingIndicator),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;
  }

  /// The scale of the indicator relative to its full size.
  double indicatorScale(WidgetTester tester) {
    return tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.byType(LoadingIndicator),
            matching: find.byType(Transform),
          ),
        )
        .fold(1.0, (double scale, Transform transform) {
          // The length of the transformed x axis, which a rotation keeps.
          final Matrix4 matrix = transform.transform;
          return scale *
              math.sqrt(
                matrix.entry(0, 0) * matrix.entry(0, 0) +
                    matrix.entry(1, 0) * matrix.entry(1, 0),
              );
        });
  }

  Future<void> drag(TestGesture gesture, WidgetTester tester, double dy) async {
    final double step = dy.sign * 10.0;
    for (var dragged = 0.0; dragged < dy.abs(); dragged += 10.0) {
      await gesture.moveBy(Offset(0.0, step));
      await tester.pump();
    }
  }

  Future<TestGesture> pull(WidgetTester tester, double distance) async {
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await drag(gesture, tester, distance);
    return gesture;
  }

  testWidgets('A short pull shows a determinate indicator and cancels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    expect(find.text('Pull To Refresh Sample'), findsOne);
    expect(currentIndicator(tester).value, 0.0);

    final TestGesture gesture = await pull(tester, 100.0);
    final double? value = currentIndicator(tester).value;
    expect(value, isNotNull);
    expect(value, greaterThan(0.0));
    expect(value, lessThan(1.0));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(currentIndicator(tester).value, 0.0);
    expect(find.text('Item 15'), findsOne);
    expect(find.text('Item 16'), findsNothing);
  });

  testWidgets('A long pull refreshes with an indeterminate indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    final TestGesture gesture = await pull(tester, 300.0);
    expect(currentIndicator(tester).value, greaterThanOrEqualTo(1.0));

    await gesture.up();
    // The release is noticed once the list starts springing back.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(currentIndicator(tester).value, isNull);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(currentIndicator(tester).value, 0.0);
    expect(find.text('Item 20'), findsOne);
  });

  testWidgets(
    'The indicator trails the pull and springs back to where it appeared',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

      final double listTop = tester.getTopLeft(find.byType(ListView)).dy;
      // The indicator rests 8 pixels below the top of the list.
      final double restCenter = listTop + 8.0 + 24.0;
      double indicatorCenter() =>
          tester.getCenter(find.byType(LoadingIndicator)).dy;

      final double restItemTop = tester.getTopLeft(find.text('Item 15')).dy;

      final TestGesture gesture = await pull(tester, 300.0);
      final double pulledItemTop = tester.getTopLeft(find.text('Item 15')).dy;
      final double listPull = pulledItemTop - restItemTop;
      expect(listPull, greaterThan(80.0));
      expect(indicatorCenter(), greaterThan(restCenter));
      // The indicator moves much less than the list does.
      expect(indicatorCenter() - restCenter, lessThan(listPull / 2));

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(currentIndicator(tester).value, isNull);
      expect(indicatorCenter(), moreOrLessEquals(restCenter, epsilon: 0.5));
      expect(
        tester.getTopLeft(find.text('Item 15')).dy,
        moreOrLessEquals(restItemTop, epsilon: 0.5),
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'The indicator fades in from half its size and fades out at full size',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.LoadingIndicatorExampleApp());
      expect(indicatorOpacity(tester), 0.0);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      while (indicatorOpacity(tester) == 0.0) {
        await gesture.moveBy(const Offset(0.0, 2.0));
        await tester.pump();
      }
      expect(indicatorOpacity(tester), lessThan(1.0));
      expect(indicatorScale(tester), greaterThanOrEqualTo(0.5));
      expect(indicatorScale(tester), lessThan(0.6));

      await drag(gesture, tester, 300.0);
      expect(indicatorOpacity(tester), 1.0);
      expect(indicatorScale(tester), moreOrLessEquals(1.0));

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(currentIndicator(tester).value, isNull);
      await tester.pump(const Duration(seconds: 3));

      // The refresh is done, and the indicator is fading out.
      await tester.pump(const Duration(milliseconds: 50));
      expect(indicatorOpacity(tester), greaterThan(0.0));
      expect(indicatorOpacity(tester), lessThan(1.0));
      expect(indicatorScale(tester), moreOrLessEquals(1.0));

      await tester.pumpAndSettle();
      expect(indicatorOpacity(tester), 0.0);
    },
  );

  testWidgets('Pushing back above the refresh distance cancels the refresh', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    final TestGesture gesture = await pull(tester, 300.0);
    expect(currentIndicator(tester).value, greaterThanOrEqualTo(1.0));

    await drag(gesture, tester, -200.0);
    expect(currentIndicator(tester).value, lessThan(1.0));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(currentIndicator(tester).value, 0.0);
    expect(find.text('Item 16'), findsNothing);
  });

  testWidgets('The indicator keeps rotating while the list is pulled further', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    final TestGesture gesture = await pull(tester, 150.0);
    expect(overPullTransform(tester), Matrix4.identity());

    // Pulls further than a half turn of extra rotation.
    await drag(gesture, tester, 300.0);
    expect(currentIndicator(tester).value, greaterThan(2.0));
    final Matrix4 halfTurnTransform = overPullTransform(tester);

    await drag(gesture, tester, 50.0);
    expect(overPullTransform(tester), isNot(halfTurnTransform));

    await gesture.up();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('The app bar keeps its color while the list springs back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    Color? appBarColor() {
      return tester
          .widget<Material>(
            find
                .descendant(
                  of: find.byType(AppBar),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color;
    }

    final Color? restColor = appBarColor();

    final TestGesture gesture = await pull(tester, 300.0);
    await gesture.up();
    // The list springs back a little past its top, which must not count as
    // scrolling content under the app bar.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(appBarColor(), restColor);
    }
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(appBarColor(), restColor);

    // Scrolling the list down still changes the color.
    await tester.drag(find.byType(ListView), const Offset(0.0, -200.0));
    await tester.pumpAndSettle();
    expect(appBarColor(), isNot(restColor));
  });

  testWidgets('The refresh button refreshes the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();
    expect(currentIndicator(tester).value, isNull);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(currentIndicator(tester).value, 0.0);
    expect(find.text('Item 20'), findsOne);
  });
}
