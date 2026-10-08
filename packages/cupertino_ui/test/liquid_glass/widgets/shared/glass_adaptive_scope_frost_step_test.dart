// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/renderer/glass_frost_budget.dart';
import 'package:liquid_glass_widgets/utils/glass_quality_adapter.dart';

// GlassAdaptiveScope(frostStep: true) hands the adapter's frost decision to
// its subtree: through GlassAdaptiveScopeData.frostEnabled and the
// GlassFrostBudget the premium layers read.

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
  setUp(() {
    GlassQualityAdapter.warmupFrames = 3;
    GlassQualityAdapter.windowSize = 3;
    GlassQualityAdapter.degradeWindowCount = 2;
    GlassQualityAdapter.upgradeWindowCount = 2;
    GlassQualityAdapter.cooldownDuration = Duration.zero;
    GlassQualityAdapter.skipInitialFrames = 0;
    GlassQualityAdapter.skipStaticProbeForTesting = true;
  });

  tearDown(() {
    GlassQualityAdapter.skipStaticProbeForTesting = false;
    GlassQualityAdapter.skipInitialFrames = 90;
    GlassQualityAdapter.upgradeWindowCount = 10;
    GlassQualityAdapter.clearSessionCache();
  });

  Future<GlassQualityAdapter> pumpScope(
    WidgetTester tester,
    GlobalKey key, {
    required bool frostStep,
    required ValueSetter<(GlassAdaptiveScopeData, bool)> onBuild,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: GlassAdaptiveScope(
        key: key,
        frostStep: frostStep,
        debugLogDiagnostics: true,
        child: Builder(builder: (context) {
          onBuild((
            GlassAdaptiveScopeData.of(context),
            GlassFrostBudget.frostEnabledOf(context),
          ));
          return const SizedBox();
        }),
      ),
    ));
    return (key.currentState! as dynamic).adapter as GlassQualityAdapter;
  }

  testWidgets('frost off and on again reaches the subtree', (tester) async {
    final key = GlobalKey();
    late (GlassAdaptiveScopeData, bool) seen;
    final logs = <String>[];
    final previous = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');

    final adapter = await pumpScope(
      tester,
      key,
      frostStep: true,
      onBuild: (value) => seen = value,
    );
    expect(seen.$1.frostEnabled, isTrue);
    expect(seen.$2, isTrue);

    adapter.simulateFrameTimings(_frames(3, 5000)); // warm-up: premium
    adapter.simulateFrameTimings(_frames(6, 30000)); // two slow windows
    expect(adapter.frostEnabled, isFalse);
    await tester.pump();
    await tester.pump();
    expect(seen.$1.effectiveQuality, GlassQuality.premium);
    expect(seen.$1.frostEnabled, isFalse);
    expect(seen.$2, isFalse);
    expect(logs.any((l) => l.contains('frost off')), isTrue);

    adapter.simulateFrameTimings(_frames(6, 2000)); // two fast windows
    await tester.pump();
    await tester.pump();
    expect(seen.$1.frostEnabled, isTrue);
    expect(seen.$2, isTrue);
    // Restored in the body: the binding checks debugPrint before tear-down.
    debugPrint = previous;
    expect(logs.any((l) => l.contains('frost on')), isTrue);
  });

  testWidgets('changing frostStep starts over with the frost on',
      (tester) async {
    final key = GlobalKey();
    late (GlassAdaptiveScopeData, bool) seen;
    var adapter = await pumpScope(
      tester,
      key,
      frostStep: true,
      onBuild: (value) => seen = value,
    );
    adapter.simulateFrameTimings(_frames(3, 5000));
    adapter.simulateFrameTimings(_frames(6, 30000));
    await tester.pump();
    await tester.pump();
    expect(seen.$1.frostEnabled, isFalse);

    adapter = await pumpScope(
      tester,
      key,
      frostStep: false,
      onBuild: (value) => seen = value,
    );
    expect(adapter.frostStep, isFalse);
    expect(seen.$1.frostEnabled, isTrue);
    expect(seen.$2, isTrue);
  });

  test('scope data equality includes frostEnabled', () {
    const on = GlassAdaptiveScopeData(
      effectiveQuality: GlassQuality.premium,
      phase: AdaptivePhase.runtime,
    );
    const off = GlassAdaptiveScopeData(
      effectiveQuality: GlassQuality.premium,
      phase: AdaptivePhase.runtime,
      frostEnabled: false,
    );
    expect(on == off, isFalse);
    expect(on.hashCode == off.hashCode, isFalse);
    expect(off.toString(), contains('frostEnabled: false'));
  });
}
