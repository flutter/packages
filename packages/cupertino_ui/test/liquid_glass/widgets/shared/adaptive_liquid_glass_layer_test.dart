import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/renderer/liquid_glass_renderer.dart';
import 'package:liquid_glass_widgets/types/glass_quality.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';
import 'package:liquid_glass_widgets/widgets/shared/inherited_liquid_glass.dart';

void main() {
  testWidgets('AdaptiveLiquidGlassLayer provides settings to descendants',
      (WidgetTester tester) async {
    const double expectedBlur = 25.0;
    const double expectedThickness = 50.0;

    LiquidGlassSettings? receivedSettings;

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveLiquidGlassLayer(
          settings: const LiquidGlassSettings(
            blur: expectedBlur,
            thickness: expectedThickness,
          ),
          shape: const LiquidRoundedSuperellipse(borderRadius: 0),
          child: Builder(
            builder: (context) {
              // Capture the settings available in the context
              receivedSettings = InheritedLiquidGlass.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(receivedSettings, isNotNull);
    expect(receivedSettings!.blur, equals(expectedBlur));
    expect(receivedSettings!.thickness, equals(expectedThickness));
  });

  testWidgets('AdaptiveLiquidGlassLayer fallback works with ofOrDefault',
      (WidgetTester tester) async {
    const double expectedBlur = 15.0;

    late LiquidGlassSettings settings;

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveLiquidGlassLayer(
          settings: const LiquidGlassSettings(blur: expectedBlur),
          shape: const LiquidRoundedSuperellipse(borderRadius: 0),
          child: Builder(
            builder: (context) {
              // This is what LightweightLiquidGlass uses
              settings = InheritedLiquidGlass.ofOrDefault(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(settings.blur, equals(expectedBlur));
  });

  testWidgets('AdaptiveLiquidGlassLayer works without shape parameter',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveLiquidGlassLayer(
          child: SizedBox(),
        ),
      ),
    );

    expect(find.byType(AdaptiveLiquidGlassLayer), findsOneWidget);
  });

  // Regression: the selected-indicator morph must survive a platformViewBackdrop
  // toggle. Toggling the flag flips `useFullRenderer`, which adds/removes a
  // LiquidGlassBlendGroup wrapper around the child. Without a stable key the
  // child subtree remounts on that toggle — re-seeding any animation controllers
  // inside it (e.g. a bottom bar's selected-indicator springs), so the indicator
  // snaps instead of morphing. The layer wraps its child in a KeyedSubtree with a
  // State-held GlobalKey so Flutter reparents the subtree instead of rebuilding
  // it. (The wrapper only physically toggles under Impeller; on the headless
  // Skia runner this asserts the stable keying that makes the reparent possible,
  // which is the actual fix.)
  KeyedSubtree probeWrapper(WidgetTester tester) =>
      tester.widgetList<KeyedSubtree>(find.byType(KeyedSubtree)).firstWhere(
            (w) => w.child is _MorphProbe,
            orElse: () => throw StateError(
              'child is not wrapped in a KeyedSubtree — the morph-preservation '
              'fix is missing',
            ),
          );

  testWidgets(
      'keeps a stable-keyed child wrapper across a platformViewBackdrop toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveLiquidGlassLayer(
          quality: GlassQuality.premium,
          child: _MorphProbe(),
        ),
      ),
    );
    final keyBefore = probeWrapper(tester).key;
    final elementBefore = tester.element(find.byType(_MorphProbe));
    expect(keyBefore, isA<GlobalKey>());

    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveLiquidGlassLayer(
          quality: GlassQuality.premium,
          platformViewBackdrop: true,
          child: _MorphProbe(),
        ),
      ),
    );
    final keyAfter = probeWrapper(tester).key;
    final elementAfter = tester.element(find.byType(_MorphProbe));

    // Same GlobalKey instance → the wrapper is stable, so Flutter reparents the
    // subtree rather than remounting it, and the child element is preserved.
    expect(keyAfter, same(keyBefore));
    expect(elementAfter, same(elementBefore));
  });

  testWidgets('wraps its child in a keyed subtree on the minimal path too',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveLiquidGlassLayer(
          quality: GlassQuality.minimal,
          child: _MorphProbe(),
        ),
      ),
    );
    expect(probeWrapper(tester).key, isA<GlobalKey>());
  });
}

/// A findable marker widget used to locate the layer's keyed child wrapper.
class _MorphProbe extends StatelessWidget {
  const _MorphProbe();

  @override
  Widget build(BuildContext context) => const SizedBox(width: 10, height: 10);
}
