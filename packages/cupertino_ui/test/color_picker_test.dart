// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CupertinoColorPicker renders its label and can be disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: CupertinoColorPicker(
              color: Color(0xFF007AFF),
              onChanged: null,
              label: Text('Accent Color'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Accent Color'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('cupertino-color-picker-trigger')), findsOneWidget);
    expect(find.text('Colors'), findsNothing);
  });

  testWidgets('CupertinoColorPicker opens the editor and reports changes', (
    WidgetTester tester,
  ) async {
    var color = const Color(0x80007AFF);
    var changeCount = 0;
    var wasDismissed = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return CupertinoColorPicker(
                  color: color,
                  label: const Text('Accent Color'),
                  onChanged: (Color value) {
                    changeCount += 1;
                    setState(() {
                      color = value;
                    });
                  },
                  onPickerDismissed: () {
                    wasDismissed = true;
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('cupertino-color-picker-trigger')));
    await tester.pumpAndSettle();

    expect(find.text('Colors'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Spectrum'), findsOneWidget);
    expect(find.text('Sliders'), findsOneWidget);
    expect(find.text('Opacity'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Color #FFFFFF'));
    await tester.pump();

    expect(changeCount, 1);
    expect(color, const Color(0x80FFFFFF));
    expect(find.bySemanticsLabel('Color #FFFFFF'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Colors'), findsNothing);
    expect(wasDismissed, isTrue);
  });

  testWidgets('slider changes are returned when the editor closes', (WidgetTester tester) async {
    Color? result;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: Builder(
              builder: (BuildContext context) {
                return CupertinoButton(
                  onPressed: () async {
                    result = await showCupertinoColorPicker(
                      context: context,
                      initialColor: const Color(0xFF000000),
                    );
                  },
                  child: const Text('Select color'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Select color'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sliders'));
    await tester.pumpAndSettle();

    final Finder redSlider = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Semantics &&
          widget.properties.label == 'Red' &&
          (widget.properties.slider ?? false),
    );
    expect(redSlider, findsOneWidget);
    final Rect sliderBounds = tester.getRect(redSlider);
    await tester.tapAt(
      Offset(sliderBounds.left + sliderBounds.width * 0.75, sliderBounds.center.dy),
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.r, closeTo(0.75, 0.02));
  });

  testWidgets('color editor exposes grid, spectrum, and sliders modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: CupertinoColorPicker(
              color: const Color(0xFF007AFF),
              onChanged: (Color color) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('cupertino-color-picker-trigger')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spectrum'));
    await tester.pumpAndSettle();

    expect(find.text('Hue'), findsWidgets);
    expect(find.text('Saturation'), findsNothing);
    expect(find.text('#007AFF'), findsOneWidget);

    await tester.tap(find.text('Sliders'));
    await tester.pumpAndSettle();

    expect(find.text('RGB'), findsOneWidget);
    expect(find.text('HSB'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    expect(find.text('Blue'), findsOneWidget);
  });

  testWidgets('color editor scrolls on a compact screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: CupertinoColorPicker(
              color: const Color(0xFF007AFF),
              onChanged: (Color color) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('cupertino-color-picker-trigger')));
    await tester.pumpAndSettle();

    expect(find.text('Colors'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('showCupertinoColorPicker returns an opaque color', (WidgetTester tester) async {
    Color? result;
    const settings = RouteSettings(name: 'color-picker-sheet');

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: Builder(
              builder: (BuildContext context) {
                return CupertinoButton(
                  onPressed: () async {
                    result = await showCupertinoColorPicker(
                      context: context,
                      initialColor: const Color(0x80007AFF),
                      supportsOpacity: false,
                      settings: settings,
                    );
                  },
                  child: const Text('Select color'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Select color'));
    await tester.pumpAndSettle();

    expect(find.text('Colors'), findsOneWidget);
    expect(find.text('Opacity'), findsNothing);

    await tester.tap(find.text('Sliders'));
    await tester.pumpAndSettle();
    expect(find.text('#007AFF'), findsOneWidget);
    expect(ModalRoute.of(tester.element(find.text('Colors')))?.settings, settings);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();

    expect(result, const Color(0xFF007AFF));
  });
}
