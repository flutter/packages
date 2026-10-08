// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/widgets/interactive/glass_slider.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_focus_region.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';
import 'package:liquid_glass_widgets/types/glass_quality.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassSlider', () {
    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSlider(
              value: 0.5,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassSlider), findsOneWidget);
    });

    testWidgets('calls onChanged when dragged', (tester) async {
      var value = 0.5;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSlider(
              value: value,
              onChanged: (newValue) => value = newValue,
            ),
          ),
        ),
      );

      // Start drag at center
      final sliderFinder = find.byType(GlassSlider);
      await tester.drag(sliderFinder, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Value should have changed
      expect(value, isNot(equals(0.5)));
    });

    testWidgets('RTL drag direction is reversed', (tester) async {
      var value = 0.5;

      await tester.pumpWidget(
        createTestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSlider(
                value: value,
                onChanged: (newValue) => value = newValue,
              ),
            ),
          ),
        ),
      );

      // Start drag at center and drag right. In RTL, dragging right moves towards the start of the track (0.0).
      final sliderFinder = find.byType(GlassSlider);
      await tester.drag(sliderFinder, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Value should have DECREASED
      expect(value, lessThan(0.5));
    });

    testWidgets('calls onChangeStart and onChangeEnd', (tester) async {
      var started = false;
      var ended = false;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSlider(
              value: 0.5,
              onChanged: (_) {},
              onChangeStart: (_) => started = true,
              onChangeEnd: (_) => ended = true,
            ),
          ),
        ),
      );

      await tester.drag(find.byType(GlassSlider), const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(started, isTrue);
      expect(ended, isTrue);
    });

    testWidgets('respects min and max values', (tester) async {
      const min = 10.0;
      const max = 100.0;
      var value = 50.0;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSlider(
              value: value,
              min: min,
              max: max,
              onChanged: (newValue) => value = newValue,
            ),
          ),
        ),
      );

      expect(find.byType(GlassSlider), findsOneWidget);
    });

    testWidgets('respects divisions for discrete values', (tester) async {
      var value = 2.0;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSlider(
              value: value,
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (newValue) => value = newValue,
            ),
          ),
        ),
      );

      expect(find.byType(GlassSlider), findsOneWidget);
    });

    testWidgets(
      'discrete slider respects a non-zero minimum while dragging',
      (tester) async {
        double? changedValue;

        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: SizedBox(
                width: 300,
                child: GlassSlider(
                  value: 22,
                  min: 12,
                  max: 32,
                  divisions: 20,
                  onChanged: (value) => changedValue = value,
                ),
              ),
            ),
          ),
        );

        final finder = find.byType(GlassSlider);
        final slider = tester.widget<GlassSlider>(finder);
        final rect = tester.getRect(finder);
        final usableTrackWidth = rect.width - slider.thumbRadius * 2;
        final target = Offset(
          rect.left + slider.thumbRadius + usableTrackWidth * 0.1,
          rect.center.dy,
        );

        final gesture = await tester.startGesture(rect.center);
        await gesture.moveTo(target);
        await tester.pump();

        expect(changedValue, 14);

        await gesture.up();
      },
    );

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSlider(
            value: 0.5,
            onChanged: (_) {},
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
          ),
        ),
      );

      expect(find.byType(GlassSlider), findsOneWidget);
    });

    test('defaults are correct', () {
      final slider = GlassSlider(
        value: 0.5,
        onChanged: (_) {},
      );

      expect(slider.min, equals(0.0));
      expect(slider.max, equals(1.0));
      expect(slider.trackHeight, equals(4.0));
      expect(slider.thumbRadius, equals(15.0));
      expect(slider.useOwnLayer, isFalse);
      expect(slider.quality, isNull);
    });

    testWidgets('drag cancel is handled without crash', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSlider(
              value: 0.5,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Start drag, move, then send a cancel (exercises _handleDragCancel)
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassSlider)),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.cancel();
      await tester.pump();

      expect(find.byType(GlassSlider), findsOneWidget);
    });

    testWidgets('divisions drag across boundary triggers haptic (no crash)',
        (tester) async {
      // The haptic path (line 327: HapticFeedback.selectionClick) fires when
      // _dragValue != newValue across a division boundary.
      double value = 0.0;
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSlider(
              value: value,
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      // Drag far enough to cross at least one division boundary
      await tester.drag(find.byType(GlassSlider), const Offset(120, 0));
      await tester.pumpAndSettle();

      expect(find.byType(GlassSlider), findsOneWidget);
    });

    testWidgets('onChanged=null means semantics still present', (tester) async {
      // Lines 415-422: onIncrease / onDecrease are null when onChanged is null
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassSlider(
              value: 0.5,
              onChanged: null, // read-only slider
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassSlider), findsOneWidget);
    });

    testWidgets('Premium path renders thumb as solid white at rest',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSlider(
            value: 0.5,
            onChanged: (_) {},
            quality: GlassQuality.premium,
          ),
        ),
      );

      // The material Container is wrapped in an Opacity widget.
      // At rest (transition=0), Opacity.opacity = 1.0, Container color = white at full alpha.
      final opacityFinder = find.byWidgetPredicate((widget) {
        if (widget is Opacity && widget.opacity == 1.0) {
          return true;
        }
        return false;
      });
      expect(opacityFinder, findsWidgets); // At least one Opacity at full

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final dec = widget.decoration as BoxDecoration;
          return dec.color == Colors.white;
        }
        return false;
      });

      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final dec = container.decoration as BoxDecoration;
      expect(dec.color, isNotNull);
      expect(dec.color!.a,
          equals(1.0)); // Solid white (Opacity controls visibility)
    });

    testWidgets('Standard path renders thumb as solid white at rest',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSlider(
            value: 0.5,
            onChanged: (_) {},
            quality: GlassQuality.standard,
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final dec = widget.decoration as BoxDecoration;
          return dec.color == Colors.white;
        }
        return false;
      });

      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final dec = container.decoration as BoxDecoration;
      expect(dec.color, isNotNull);
      expect(dec.color!.a,
          equals(1.0)); // Solid white (Opacity controls visibility)
    });

    for (final quality in [GlassQuality.standard, GlassQuality.premium]) {
      for (final brightness in Brightness.values) {
        testWidgets(
            '$quality $brightness keeps the resting shadow outside glass',
            (tester) async {
          var value = 0.5;
          await tester.pumpWidget(createTestApp(
            theme: ThemeData(brightness: brightness),
            child: Center(
              child: SizedBox(
                width: 300,
                child: StatefulBuilder(builder: (context, setState) {
                  return GlassSlider(
                    value: value,
                    quality: quality,
                    onChanged: (next) => setState(() => value = next),
                  );
                }),
              ),
            ),
          ));
          await tester.pumpAndSettle();

          final shadow = find.descendant(
            of: find.byType(GlassSlider),
            matching: find.byWidgetPredicate((widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).boxShadow?.isNotEmpty ==
                    true),
          );
          expect(shadow, findsOneWidget);
          // GlassEffect clips its content to the thumb shape, so an internal
          // BoxShadow loses the pixels that should extend outside the thumb.
          expect(find.ancestor(of: shadow, matching: find.byType(GlassEffect)),
              findsNothing);
          double shadowOpacity() =>
              (tester.widget<DecoratedBox>(shadow).decoration as BoxDecoration)
                  .boxShadow!
                  .single
                  .color
                  .a;
          expect(shadowOpacity(), 0.15);
          final restingCenter = tester.getCenter(shadow);

          final gesture = await tester.startGesture(restingCenter);
          await gesture.moveBy(const Offset(60, 0));
          await tester.pumpAndSettle();
          expect(value, greaterThan(0.5));
          expect(shadowOpacity(), 0);

          await gesture.up();
          await tester.pumpAndSettle();
          expect(shadowOpacity(), 0.15);
          expect(tester.getCenter(shadow).dx, greaterThan(restingCenter.dx));
          final material = find.byWidgetPredicate((widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.white);
          expect(tester.getCenter(shadow), tester.getCenter(material));

          final cancelled = await tester.startGesture(tester.getCenter(shadow));
          await tester.pumpAndSettle();
          expect(shadowOpacity(), 0);
          await cancelled.cancel();
          await tester.pumpAndSettle();
          expect(shadowOpacity(), 0.15);
        });
      }
    }

    for (final quality in [GlassQuality.standard, GlassQuality.premium]) {
      testWidgets('$quality custom shadows preserve geometry and animate alpha',
          (tester) async {
        const customShadows = [
          BoxShadow(
            color: Color.from(alpha: 0.4, red: 0.2, green: 0.3, blue: 0.5),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(2, 4),
            blurStyle: BlurStyle.outer,
          ),
          BoxShadow(
            color: Color.from(alpha: 0.12, red: 0, green: 0, blue: 0),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ];
        await tester.pumpWidget(createTestApp(
          child: Center(
            child: SizedBox(
              width: 300,
              child: GlassSlider(
                value: 0.5,
                quality: quality,
                thumbShadow: customShadows,
                onChanged: (_) {},
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        final shadow = find.descendant(
          of: find.byType(GlassSlider),
          matching: find.byWidgetPredicate((widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).boxShadow?.length == 2),
        );
        List<BoxShadow> renderedShadows() =>
            (tester.widget<DecoratedBox>(shadow).decoration as BoxDecoration)
                .boxShadow!;
        expect(shadow, findsOneWidget);
        expect(find.ancestor(of: shadow, matching: find.byType(GlassEffect)),
            findsNothing);
        expect(renderedShadows(), customShadows);

        final gesture = await tester.startGesture(tester.getCenter(shadow));
        await gesture.moveBy(const Offset(30, 0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75));
        final fading = renderedShadows();
        final fade = fading.first.color.a / customShadows.first.color.a;
        expect(fade, greaterThan(0));
        expect(fade, lessThan(1));
        for (var i = 0; i < customShadows.length; i++) {
          final original = customShadows[i];
          expect(fading[i].color.a, closeTo(original.color.a * fade, 1e-9));
          expect(fading[i].copyWith(color: original.color), original);
        }
        await tester.pumpAndSettle();
        expect(renderedShadows().every((s) => s.color.a == 0), isTrue);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(renderedShadows(), customShadows);

        final cancelled = await tester.startGesture(tester.getCenter(shadow));
        await tester.pumpAndSettle();
        expect(renderedShadows().every((s) => s.color.a == 0), isTrue);
        await cancelled.cancel();
        await tester.pumpAndSettle();
        expect(renderedShadows(), customShadows);
      });
    }

    testWidgets('thumbShadow can disable and restore the default on rebuild',
        (tester) async {
      List<BoxShadow>? shadows = const [];
      late StateSetter update;
      await tester.pumpWidget(createTestApp(
        child: Center(
          child: SizedBox(
            width: 300,
            child: StatefulBuilder(builder: (context, setState) {
              update = setState;
              return GlassSlider(
                value: 0.5,
                thumbShadow: shadows,
                onChanged: (_) {},
              );
            }),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final shadow = find.descendant(
        of: find.byType(GlassSlider),
        matching: find.byWidgetPredicate((widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).boxShadow?.isNotEmpty == true),
      );
      expect(shadow, findsNothing);
      update(() => shadows = null);
      await tester.pumpAndSettle();
      expect(shadow, findsOneWidget);
      final restored =
          (tester.widget<DecoratedBox>(shadow).decoration as BoxDecoration)
              .boxShadow!
              .single;
      expect(restored.color.a, 0.15);
      expect(restored.blurRadius, 8);
      expect(restored.offset, const Offset(0, 2));
      update(() => shadows = const []);
      await tester.pumpAndSettle();
      expect(shadow, findsNothing);
    });

    group('keyboard focus & accessibility', () {
      testWidgets('exposes slider semantics', (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            createTestApp(
              child: GlassSlider(
                value: 0.5,
                onChanged: (_) {},
                label: 'Test Slider',
              ),
            ),
          );

          final node = tester.getSemantics(find.byType(GlassFocusRegion));
          expect(node.label, 'Test Slider');
          expect(node.value, '50%');
          expect(node.increasedValue, '60%');
          expect(node.decreasedValue, '40%');
          // ignore: deprecated_member_use
          expect(node.hasFlag(SemanticsFlag.isSlider), true);
          // ignore: deprecated_member_use
          expect(node.hasFlag(SemanticsFlag.isEnabled), true);
          // ignore: deprecated_member_use
          expect(node.hasFlag(SemanticsFlag.isFocusable), true);
        } finally {
          handle.dispose();
        }
      });

      testWidgets('does not activate on Space key (sliders use arrows)',
          (tester) async {
        double value = 0.5;
        final focusNode = FocusNode();

        await tester.pumpWidget(
          createTestApp(
            child: GlassSlider(
              value: value,
              onChanged: (v) => value = v,
              focusNode: focusNode,
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();

        expect(value, equals(0.5));
      });
    });
  });
}
