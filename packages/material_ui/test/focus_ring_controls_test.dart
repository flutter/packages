// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Whether a canvas call strokes one band of the focus ring in `color`.
bool _isRingBand(Symbol method, List<dynamic> arguments, Color color) {
  if (method != #drawCircle && method != #drawRRect) {
    return false;
  }
  final paint = arguments.last as Paint;
  // Compare ARGB values, since theme colors can be a Color subclass.
  return paint.style == PaintingStyle.stroke &&
      paint.strokeWidth == 3.0 &&
      paint.color.toARGB32() == color.toARGB32();
}

// The default ring: an inner `onSecondary` band, then the `secondary` ring.
PaintPattern _ringBands(ColorScheme scheme) {
  return paints
    ..something(
      (Symbol method, List<dynamic> arguments) =>
          _isRingBand(method, arguments, scheme.onSecondary),
    )
    ..something(
      (Symbol method, List<dynamic> arguments) => _isRingBand(method, arguments, scheme.secondary),
    );
}

void main() {
  setUp(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  });

  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  Widget buildApp({required Widget child, bool visible = true}) {
    return MaterialApp(
      theme: ThemeData(focusRingTheme: FocusRingThemeData(visible: visible)),
      home: Scaffold(body: Center(child: child)),
    );
  }

  ColorScheme schemeOf(WidgetTester tester) {
    return Theme.of(tester.element(find.byType(Scaffold))).colorScheme;
  }

  Future<void> focus(WidgetTester tester, FocusNode focusNode) async {
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
  }

  testWidgets('Checkbox draws the ring 2 pixels outside its reaction circle', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      buildApp(
        child: Checkbox(focusNode: focusNode, value: false, onChanged: (_) {}),
      ),
    );
    await focus(tester, focusNode);

    final ColorScheme scheme = schemeOf(tester);
    // The reaction circle has a radius of 20. The ring covers 22 to 25, so its
    // stroke is centered at 23.5, and the inner band is centered at 20.5.
    expect(
      tester.renderObject(find.byType(Checkbox)),
      paints
        ..something(
          (Symbol method, List<dynamic> arguments) =>
              _isRingBand(method, arguments, scheme.onSecondary) && arguments[1] == 20.5,
        )
        ..something(
          (Symbol method, List<dynamic> arguments) =>
              _isRingBand(method, arguments, scheme.secondary) && arguments[1] == 23.5,
        ),
    );
  });

  testWidgets('Radio draws the ring 2 pixels outside its reaction circle', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      buildApp(
        child: RadioGroup<int>(
          groupValue: 0,
          onChanged: (_) {},
          child: Radio<int>(focusNode: focusNode, value: 1),
        ),
      ),
    );
    await focus(tester, focusNode);

    final ColorScheme scheme = schemeOf(tester);
    expect(
      tester.renderObject(find.byType(Radio<int>)),
      paints
        ..something(
          (Symbol method, List<dynamic> arguments) =>
              _isRingBand(method, arguments, scheme.onSecondary) && arguments[1] == 20.5,
        )
        ..something(
          (Symbol method, List<dynamic> arguments) =>
              _isRingBand(method, arguments, scheme.secondary) && arguments[1] == 23.5,
        ),
    );
  });

  testWidgets('Switch draws the ring 2 pixels outside its track', (WidgetTester tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      buildApp(
        child: Switch(focusNode: focusNode, value: true, onChanged: (_) {}),
      ),
    );
    await focus(tester, focusNode);

    final ColorScheme scheme = schemeOf(tester);
    // The M3 track is 52 by 32. The ring covers 2 to 5 pixels outside it.
    expect(
      tester.renderObject(find.byType(Switch)),
      paints..something((Symbol method, List<dynamic> arguments) {
        if (!_isRingBand(method, arguments, scheme.secondary)) {
          return false;
        }
        final rrect = arguments[0] as RRect;
        return rrect.width == 52 + 7 && rrect.height == 32 + 7;
      }),
    );
  });

  testWidgets('Slider draws the ring around its thumb', (WidgetTester tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      buildApp(
        child: SizedBox(
          width: 300,
          child: Slider(focusNode: focusNode, value: 0.5, onChanged: (_) {}),
        ),
      ),
    );
    await focus(tester, focusNode);

    expect(tester.renderObject(find.byType(Slider)), _ringBands(schemeOf(tester)));
  });

  testWidgets('Controls draw no ring unless the theme makes it visible', (
    WidgetTester tester,
  ) async {
    final checkboxFocus = FocusNode();
    final switchFocus = FocusNode();
    final sliderFocus = FocusNode();
    addTearDown(checkboxFocus.dispose);
    addTearDown(switchFocus.dispose);
    addTearDown(sliderFocus.dispose);
    await tester.pumpWidget(
      buildApp(
        visible: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Checkbox(focusNode: checkboxFocus, value: false, onChanged: (_) {}),
            Switch(focusNode: switchFocus, value: true, onChanged: (_) {}),
            SizedBox(
              width: 300,
              child: Slider(focusNode: sliderFocus, value: 0.5, onChanged: (_) {}),
            ),
          ],
        ),
      ),
    );
    final ColorScheme scheme = schemeOf(tester);

    await focus(tester, checkboxFocus);
    expect(tester.renderObject(find.byType(Checkbox)), isNot(_ringBands(scheme)));
    await focus(tester, switchFocus);
    expect(tester.renderObject(find.byType(Switch)), isNot(_ringBands(scheme)));
    await focus(tester, sliderFocus);
    expect(tester.renderObject(find.byType(Slider)), isNot(_ringBands(scheme)));
  });

  testWidgets('Controls draw no ring in touch highlight mode', (WidgetTester tester) async {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
    final checkboxFocus = FocusNode();
    final sliderFocus = FocusNode();
    addTearDown(checkboxFocus.dispose);
    addTearDown(sliderFocus.dispose);
    await tester.pumpWidget(
      buildApp(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Checkbox(focusNode: checkboxFocus, value: false, onChanged: (_) {}),
            SizedBox(
              width: 300,
              child: Slider(focusNode: sliderFocus, value: 0.5, onChanged: (_) {}),
            ),
          ],
        ),
      ),
    );
    final ColorScheme scheme = schemeOf(tester);

    await focus(tester, checkboxFocus);
    expect(tester.renderObject(find.byType(Checkbox)), isNot(_ringBands(scheme)));
    await focus(tester, sliderFocus);
    expect(tester.renderObject(find.byType(Slider)), isNot(_ringBands(scheme)));
  });
}
