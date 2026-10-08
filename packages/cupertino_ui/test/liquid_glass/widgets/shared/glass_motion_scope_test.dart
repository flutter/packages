import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  testWidgets('GlassMotionScope passes through child when stream is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GlassMotionScope(
          child: SizedBox(key: Key('child'), width: 100, height: 100),
        ),
      ),
    );

    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  testWidgets(
      'GlassMotionScope overrides lightAngle in GlassTheme on stream event',
      (WidgetTester tester) async {
    final controller = StreamController<double>();
    addTearDown(controller.close);

    const parentAngle = 1.0;
    double? capturedAngle;

    await tester.pumpWidget(
      MaterialApp(
        home: GlassTheme(
          data: GlassThemeData(
            light: GlassThemeVariant(
              settings: const GlassThemeSettings(lightAngle: parentAngle),
            ),
          ),
          child: GlassMotionScope(
            lightAngle: controller.stream,
            child: Builder(
              builder: (context) {
                capturedAngle =
                    GlassThemeData.of(context).light.settings?.lightAngle;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    // Before any event — no override, theme angle is used.
    expect(capturedAngle, equals(parentAngle));

    // Emit a new angle.
    const newAngle = pi / 4;
    controller.add(newAngle);
    await tester.pump();

    expect(capturedAngle, equals(newAngle));
  });

  testWidgets(
      'GlassMotionScope reverts to pass-through when stream replaced with null',
      (WidgetTester tester) async {
    final controller = StreamController<double>();
    addTearDown(controller.close);

    const parentAngle = 0.5;
    double? capturedAngle;

    final streamNotifier = ValueNotifier<Stream<double>?>(controller.stream);

    await tester.pumpWidget(
      MaterialApp(
        home: GlassTheme(
          data: GlassThemeData(
            light: GlassThemeVariant(
              settings: const GlassThemeSettings(lightAngle: parentAngle),
            ),
          ),
          child: ValueListenableBuilder<Stream<double>?>(
            valueListenable: streamNotifier,
            builder: (context, stream, _) => GlassMotionScope(
              lightAngle: stream,
              child: Builder(
                builder: (context) {
                  capturedAngle =
                      GlassThemeData.of(context).light.settings?.lightAngle;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Emit an angle override.
    controller.add(pi);
    await tester.pump();
    expect(capturedAngle, equals(pi));

    // Replace stream with null — should revert to parent theme angle.
    streamNotifier.value = null;
    await tester.pump();
    expect(capturedAngle, equals(parentAngle));
  });
}
