// AnimatedGlassIndicator: outer drop shadow on the moving glass jelly.
//
// The shadow paints only when the caller EXPLICITLY sets a non-default
// shadowElevation (or a shadow list) in the indicator settings, only in
// light mode (package-wide shadow convention), and only while the glass
// pass is mounted. Existing indicators must render without it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

/// The outer-shadow layer is a CustomPaint with the (private)
/// _OuterShadowPainter — identified by runtime type name.
Finder _outerShadowPaint() => find.byWidgetPredicate((w) =>
    w is CustomPaint &&
    w.painter.runtimeType.toString() == '_OuterShadowPainter');

Widget _wrap(Widget indicator, {required Brightness brightness}) =>
    createTestApp(
      theme: ThemeData(brightness: brightness),
      child: SizedBox(
        width: 400,
        height: 80,
        child: Stack(children: [indicator]),
      ),
    );

AnimatedGlassIndicator _make({
  LiquidGlassSettings? settings,
  double thickness = 0.5, // > 0.01 → glass pass mounts (mid-morph)
}) =>
    AnimatedGlassIndicator(
      velocity: 0.0,
      itemCount: 3,
      alignment: Alignment.center,
      thickness: thickness,
      quality: GlassQuality.standard,
      indicatorColor: Colors.blue,
      isBackgroundIndicator: false,
      borderRadius: 20.0,
      settings: settings,
      pinchStrength: 0.4,
      expansion: const EdgeInsets.all(8.0),
      paintBackground: true,
      paintGlass: true,
      innerBlur: 0.0,
    );

void main() {
  group('AnimatedGlassIndicator — jelly outer shadow', () {
    testWidgets('explicit shadowElevation paints the shadow in light mode',
        (tester) async {
      await tester.pumpWidget(_wrap(
        _make(settings: const LiquidGlassSettings(shadowElevation: 3.0)),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(_outerShadowPaint(), findsOneWidget);
    });

    testWidgets('explicit shadow list paints the shadow in light mode',
        (tester) async {
      await tester.pumpWidget(_wrap(
        _make(
          settings: const LiquidGlassSettings(shadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ]),
        ),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(_outerShadowPaint(), findsOneWidget);
    });

    testWidgets('default settings paint NO shadow (back-compat)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        _make(settings: const LiquidGlassSettings()),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(_outerShadowPaint(), findsNothing);
    });

    testWidgets('null settings paint NO shadow (back-compat)', (tester) async {
      await tester.pumpWidget(_wrap(
        _make(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(_outerShadowPaint(), findsNothing);
    });

    testWidgets('dark mode paints NO shadow even with explicit elevation',
        (tester) async {
      await tester.pumpWidget(_wrap(
        _make(settings: const LiquidGlassSettings(shadowElevation: 3.0)),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(_outerShadowPaint(), findsNothing);
    });

    testWidgets('no shadow at rest (glass pass unmounted)', (tester) async {
      await tester.pumpWidget(_wrap(
        _make(
          settings: const LiquidGlassSettings(shadowElevation: 3.0),
          thickness: 0.0, // resting — interactive indicator not built
        ),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(_outerShadowPaint(), findsNothing);
    });
  });
}
