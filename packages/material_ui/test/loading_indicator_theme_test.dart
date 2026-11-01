// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('LoadingIndicatorThemeData copyWith, ==, hashCode', () {
    expect(const LoadingIndicatorThemeData(), const LoadingIndicatorThemeData().copyWith());
    expect(
      const LoadingIndicatorThemeData().hashCode,
      const LoadingIndicatorThemeData().copyWith().hashCode,
    );

    const data = LoadingIndicatorThemeData(
      color: Color(0xFFFFFFF0),
      containedColor: Color(0xFFFFFFF3),
      containerColor: Color(0xFFFFFFF1),
      containerShape: CircleBorder(),
    );
    expect(data.copyWith(), data);
    expect(
      data.copyWith(color: const Color(0xFFFFFFF2)),
      const LoadingIndicatorThemeData(
        color: Color(0xFFFFFFF2),
        containedColor: Color(0xFFFFFFF3),
        containerColor: Color(0xFFFFFFF1),
        containerShape: CircleBorder(),
      ),
    );
    expect(
      data.copyWith(containedColor: const Color(0xFFFFFFF4)),
      const LoadingIndicatorThemeData(
        color: Color(0xFFFFFFF0),
        containedColor: Color(0xFFFFFFF4),
        containerColor: Color(0xFFFFFFF1),
        containerShape: CircleBorder(),
      ),
    );
    expect(data, isNot(data.copyWith(containedColor: const Color(0xFFFFFFF4))));
  });

  test('LoadingIndicatorThemeData lerp special cases', () {
    expect(LoadingIndicatorThemeData.lerp(null, null, 0), null);
    const data = LoadingIndicatorThemeData();
    expect(identical(LoadingIndicatorThemeData.lerp(data, data, 0.5), data), true);
  });

  test('LoadingIndicatorThemeData lerp', () {
    const a = LoadingIndicatorThemeData(
      color: Color(0xFF000000),
      containedColor: Color(0xFF000000),
      containerColor: Color(0xFF000000),
      containerShape: RoundedRectangleBorder(),
    );
    const b = LoadingIndicatorThemeData(
      color: Color(0xFFFFFFFF),
      containedColor: Color(0xFFFFFFFF),
      containerColor: Color(0xFFFFFFFF),
      containerShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    );

    final LoadingIndicatorThemeData lerped = LoadingIndicatorThemeData.lerp(a, b, 0.5)!;
    expect(lerped.color, isSameColorAs(const Color(0xFF7F7F7F)));
    expect(lerped.containedColor, isSameColorAs(const Color(0xFF7F7F7F)));
    expect(lerped.containerColor, isSameColorAs(const Color(0xFF7F7F7F)));
    expect(
      lerped.containerShape,
      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
    );
  });

  test('LoadingIndicatorThemeData defaults', () {
    const themeData = LoadingIndicatorThemeData();
    expect(themeData.color, null);
    expect(themeData.containedColor, null);
    expect(themeData.containerColor, null);
    expect(themeData.containerShape, null);

    expect(ThemeData().loadingIndicatorTheme, themeData);
  });

  testWidgets('Default LoadingIndicatorThemeData debugFillProperties', (WidgetTester tester) async {
    final builder = DiagnosticPropertiesBuilder();
    const LoadingIndicatorThemeData().debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[]);
  });

  testWidgets('LoadingIndicatorThemeData implements debugFillProperties', (
    WidgetTester tester,
  ) async {
    final builder = DiagnosticPropertiesBuilder();
    const LoadingIndicatorThemeData(
      color: Color(0xFFFFFFF0),
      containedColor: Color(0xFFFFFFF2),
      containerColor: Color(0xFFFFFFF1),
      containerShape: CircleBorder(),
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[
      'color: ${const Color(0xFFFFFFF0)}',
      'containedColor: ${const Color(0xFFFFFFF2)}',
      'containerColor: ${const Color(0xFFFFFFF1)}',
      'containerShape: CircleBorder(BorderSide(width: 0.0, style: none))',
    ]);
  });

  testWidgets('LoadingIndicatorTheme.of falls back to ThemeData.loadingIndicatorTheme', (
    WidgetTester tester,
  ) async {
    const themeData = LoadingIndicatorThemeData(color: Color(0xFFFFFFF0));
    const localThemeData = LoadingIndicatorThemeData(color: Color(0xFFFFFFF1));

    late LoadingIndicatorThemeData globalTheme;
    late LoadingIndicatorThemeData localTheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(loadingIndicatorTheme: themeData),
        home: Column(
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                globalTheme = LoadingIndicatorTheme.of(context);
                return const SizedBox();
              },
            ),
            LoadingIndicatorTheme(
              data: localThemeData,
              child: Builder(
                builder: (BuildContext context) {
                  localTheme = LoadingIndicatorTheme.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );

    expect(globalTheme, themeData);
    expect(localTheme, localThemeData);
  });

  testWidgets('LoadingIndicatorTheme overrides the default colors and shape', (
    WidgetTester tester,
  ) async {
    const color = Color(0xFFFFFFF0);
    const containedColor = Color(0xFFFFFFF2);
    const containerColor = Color(0xFFFFFFF1);
    const containerShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          loadingIndicatorTheme: const LoadingIndicatorThemeData(
            color: color,
            containedColor: containedColor,
            containerColor: containerColor,
            containerShape: containerShape,
          ),
        ),
        home: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LoadingIndicator(value: 0.5),
              LoadingIndicator.contained(value: 0.5),
            ],
          ),
        ),
      ),
    );

    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration as ShapeDecoration;
    expect(decoration.color, containerColor);
    expect(decoration.shape, containerShape);
    expect(find.byType(LoadingIndicator).first, paints..path(color: color));
    expect(find.byType(LoadingIndicator).last, paints..path(color: containedColor));
  });

  testWidgets('Local LoadingIndicatorTheme takes precedence over ThemeData', (
    WidgetTester tester,
  ) async {
    const globalColor = Color(0xFFFFFFF0);
    const localColor = Color(0xFFFFFFF1);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          loadingIndicatorTheme: const LoadingIndicatorThemeData(color: globalColor),
        ),
        home: const Center(
          child: LoadingIndicatorTheme(
            data: LoadingIndicatorThemeData(color: localColor),
            child: LoadingIndicator(value: 0.5),
          ),
        ),
      ),
    );

    expect(find.byType(LoadingIndicator), paints..path(color: localColor));
  });

  testWidgets('LoadingIndicator properties take precedence over the theme', (
    WidgetTester tester,
  ) async {
    const color = Color(0xFFFFFFF2);
    const containerColor = Color(0xFFFFFFF3);
    const containerShape = CircleBorder();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          loadingIndicatorTheme: const LoadingIndicatorThemeData(
            color: Color(0xFFFFFFF0),
            containerColor: Color(0xFFFFFFF1),
            containerShape: RoundedRectangleBorder(),
          ),
        ),
        home: const Center(
          child: LoadingIndicator.contained(
            value: 0.5,
            color: color,
            containerColor: containerColor,
            containerShape: containerShape,
          ),
        ),
      ),
    );

    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration as ShapeDecoration;
    expect(decoration.color, containerColor);
    expect(decoration.shape, containerShape);
    expect(find.byType(LoadingIndicator), paints..path(color: color));
  });
}
