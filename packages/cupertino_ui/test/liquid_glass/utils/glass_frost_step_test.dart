// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/renderer/glass_frost_budget.dart';
import 'package:liquid_glass_widgets/utils/glass_quality_adapter.dart';

// With frostStep, the adaptive scope steps premium → premium without frost →
// standard, and back up the same way, so a device that can't afford the iOS 27
// frost keeps the premium lens and rim instead of losing the whole look.

List<FrameTiming> _frames(int count, int rasterUs) => List.generate(
      count,
      (_) => FrameTiming(
        vsyncStart: 0,
        buildStart: 0,
        buildFinish: 0,
        rasterStart: 0,
        rasterFinish: rasterUs,
        rasterFinishWallTime: rasterUs,
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GlassQualityAdapter.warmupFrames = 10;
    GlassQualityAdapter.windowSize = 5;
    GlassQualityAdapter.degradeWindowCount = 2;
    GlassQualityAdapter.upgradeWindowCount = 3;
    GlassQualityAdapter.cooldownDuration = Duration.zero;
    GlassQualityAdapter.skipInitialFrames = 0;
    GlassQualityAdapter.skipStaticProbeForTesting = true;
  });

  tearDown(() {
    GlassQualityAdapter.skipStaticProbeForTesting = false;
    GlassQualityAdapter.skipInitialFrames = 90;
    GlassQualityAdapter.degradeWindowCount = 2;
    GlassQualityAdapter.upgradeWindowCount = 10;
    GlassQualityAdapter.clearSessionCache();
  });

  GlassQualityAdapter adapter({
    required bool frostStep,
    List<Object>? events,
  }) {
    final a = GlassQualityAdapter(
      minQuality: GlassQuality.minimal,
      maxQuality: GlassQuality.premium,
      targetFrameMs: 16,
      allowStepUp: true,
      frostStep: frostStep,
      onQualityChanged: (from, to) => events?.add(to),
      onFrostChanged: (enabled) => events?.add(enabled ? 'frost' : 'no frost'),
    );
    a.simulateFrameTimings(_frames(GlassQualityAdapter.warmupFrames, 5000));
    return a;
  }

  void overBudget(GlassQualityAdapter a) {
    for (var i = 0; i < 2; i++) {
      a.simulateFrameTimings(_frames(5, 30000));
    }
  }

  void underBudget(GlassQualityAdapter a) {
    for (var i = 0; i < 3; i++) {
      a.simulateFrameTimings(_frames(5, 2000));
    }
  }

  group('GlassQualityAdapter.frostStep', () {
    test('off: premium steps straight to standard', () {
      final events = <Object>[];
      final a = adapter(frostStep: false, events: events);
      overBudget(a);
      expect(a.currentQuality, GlassQuality.standard);
      expect(a.frostEnabled, isTrue);
      expect(events, [GlassQuality.standard]);
    });

    test('on: premium drops the frost first, then goes to standard', () {
      final events = <Object>[];
      final a = adapter(frostStep: true, events: events);

      overBudget(a);
      expect(a.currentQuality, GlassQuality.premium);
      expect(a.frostEnabled, isFalse);

      overBudget(a);
      expect(a.currentQuality, GlassQuality.standard);

      overBudget(a);
      expect(a.currentQuality, GlassQuality.minimal);
      expect(events, [
        'no frost',
        GlassQuality.standard,
        GlassQuality.minimal,
      ]);
    });

    test('on: recovery takes the same steps back', () {
      final events = <Object>[];
      final a = adapter(frostStep: true, events: events);
      overBudget(a);
      overBudget(a);
      expect(a.currentQuality, GlassQuality.standard);
      events.clear();

      underBudget(a);
      expect(a.currentQuality, GlassQuality.premium);
      expect(a.frostEnabled, isFalse, reason: 'premium without frost first');

      underBudget(a);
      expect(a.currentQuality, GlassQuality.premium);
      expect(a.frostEnabled, isTrue);
      expect(events, [GlassQuality.premium, 'frost']);
    });
  });

  group('GlassFrostBudget.apply', () {
    const frosted = LiquidGlassSettings(frost: 14, blur: 0.6, rimLight: 1);

    Future<LiquidGlassSettings> applied(
      WidgetTester tester, {
      required bool enabled,
      required LiquidGlassSettings settings,
    }) async {
      late LiquidGlassSettings result;
      await tester.pumpWidget(GlassFrostBudget(
        frostEnabled: enabled,
        child: Builder(builder: (context) {
          result = GlassFrostBudget.apply(context, settings);
          return const SizedBox();
        }),
      ));
      return result;
    }

    testWidgets('leaves settings alone while the frost is allowed',
        (tester) async {
      expect(
        await applied(tester, enabled: true, settings: frosted),
        same(frosted),
      );
    });

    testWidgets('stands a regular blur in for a switched-off frost',
        (tester) async {
      final s = await applied(tester, enabled: false, settings: frosted);
      expect(s.frost, 0);
      expect(s.blur, 14 * GlassFrostBudget.blurPerFrost);
      // Everything else of the material stays.
      expect(s.rimLight, 1);
    });

    testWidgets('keeps a blur that is already wider', (tester) async {
      final s = await applied(
        tester,
        enabled: false,
        settings: frosted.copyWith(blur: 8),
      );
      expect(s.blur, 8);
    });

    testWidgets('glass without frost is not affected', (tester) async {
      const plain = LiquidGlassSettings(blur: 2);
      expect(
        await applied(tester, enabled: false, settings: plain),
        same(plain),
      );
    });

    testWidgets('GlassAdaptiveScope provides the budget', (tester) async {
      late bool enabled;
      await tester.pumpWidget(GlassAdaptiveScope(
        frostStep: true,
        child: Builder(builder: (context) {
          enabled = GlassFrostBudget.frostEnabledOf(context);
          return const SizedBox();
        }),
      ));
      expect(enabled, isTrue);
      expect(
        tester
            .widget<GlassAdaptiveScope>(find.byType(GlassAdaptiveScope))
            .frostStep,
        isTrue,
      );
    });
  });
}
