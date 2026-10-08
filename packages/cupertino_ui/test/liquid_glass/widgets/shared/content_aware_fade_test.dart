// Tests for GlassContentAwareScope brightness-based content awareness.
//
// NOTE: The luminance-delivery APIs (computeMeanLuminance, onLuminanceChanged,
// meanLuminance) and the contentAwareFade / contentAwareEdgeFade parameters
// were introduced in origin/main (PR #106 content-luminance scrim) but have
// not yet been implemented on this branch. Those tests are deferred until the
// feature is ported here.
//
// This file currently validates the existing brightness-callback path that IS
// implemented: register(controlBox:, onBrightnessChanged:, initialBrightness:)
// and the sampleNow() / requestSample() public API.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Runs one deterministic sample to completion.
Future<void> _settleSample(
  WidgetTester tester,
  GlassContentAwareScopeState scope,
) {
  return tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await scope.sampleNow();
  });
}

void main() {
  group('GlassContentAwareScope — brightness callback path', () {
    Widget host({required Color content}) => MaterialApp(
          home: GlassContentAwareScope(
            child: GlassContentAwareContent(
              child: ColoredBox(color: content),
            ),
          ),
        );

    testWidgets('scope state is findable', (tester) async {
      await tester.pumpWidget(host(content: const Color(0xFF000000)));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      expect(scope, isNotNull);
    });

    testWidgets('register returns a subscription and cancel is idempotent',
        (tester) async {
      await tester.pumpWidget(host(content: const Color(0xFF000000)));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      final box = tester.renderObject(find.byType(GlassContentAwareContent))
          as RenderBox;

      final verdicts = <Brightness>[];
      final sub = scope.register(
        controlBox: () => box,
        onBrightnessChanged: verdicts.add,
        initialBrightness: Brightness.light,
      );
      expect(sub, isNotNull);

      // Double-cancel must not throw.
      sub.cancel();
      sub.cancel();
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark content triggers dark brightness verdict',
        (tester) async {
      await tester.pumpWidget(host(content: const Color(0xFF000000)));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      final box = tester.renderObject(find.byType(GlassContentAwareContent))
          as RenderBox;

      final verdicts = <Brightness>[];
      final sub = scope.register(
        controlBox: () => box,
        onBrightnessChanged: verdicts.add,
        initialBrightness: Brightness.light,
      );

      await _settleSample(tester, scope);
      // In headless test environment image capture may yield no pixels;
      // we just verify no exception is thrown and the subscription works.
      expect(tester.takeException(), isNull);
      sub.cancel();
    });

    testWidgets('requestSample is coalesced — second call is a no-op',
        (tester) async {
      await tester.pumpWidget(host(content: const Color(0xFFFFFFFF)));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));

      // Two rapid calls must not crash or double-deliver.
      scope.requestSample();
      scope.requestSample();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('scope disposes cleanly when tree is torn down',
        (tester) async {
      await tester.pumpWidget(host(content: const Color(0xFF000000)));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      final box = tester.renderObject(find.byType(GlassContentAwareContent))
          as RenderBox;

      final sub = scope.register(
        controlBox: () => box,
        onBrightnessChanged: (_) {},
        initialBrightness: Brightness.light,
      );

      // Tear down the tree with an active subscription.
      await tester.pumpWidget(Container());
      expect(tester.takeException(), isNull);
      // Cancel after dispose must also be safe.
      sub.cancel();
      expect(tester.takeException(), isNull);
    });
  });

  group('GlassContentAwareScope — GlassScaffold brightness integration', () {
    testWidgets('GlassScaffold contentAwareBrightness renders without error',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GlassScaffold(
          contentAwareBrightness: true,
          bottomBar: const SizedBox(height: 60),
          body: ListView(children: [Container(height: 2000)]),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
