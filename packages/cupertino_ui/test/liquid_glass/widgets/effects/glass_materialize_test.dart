import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/renderer/glass_materialize_scope.dart';
import 'package:liquid_glass_widgets/widgets/effects/shared/glass_materialize_effect.dart';

/// Resolves the settings a glass surface below [child] would render with.
Future<LiquidGlassSettings> _resolvedSettings(
  WidgetTester tester,
  Widget Function(Widget probe) build,
) async {
  late LiquidGlassSettings resolved;
  await tester.pumpWidget(
    CupertinoApp(
      home: build(
        Builder(
          builder: (context) {
            resolved = GlassMaterializeScope.resolveSettings(
              context,
              const LiquidGlassSettings(blur: 5, thickness: 20),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return resolved;
}

void main() {
  group('settings transform', () {
    const base = LiquidGlassSettings(blur: 5, thickness: 20);

    /// The settings a glass surface actually resolves under a scope at [t].
    Future<LiquidGlassSettings> at(
      WidgetTester tester,
      double t, {
      LiquidGlassSettings settings = base,
    }) async {
      late LiquidGlassSettings resolved;
      await tester.pumpWidget(
        CupertinoApp(
          home: GlassMaterializeScope(
            glassProgress: t,
            contentOpacity: t,
            contentSigma: 0,
            child: Builder(
              builder: (context) {
                resolved =
                    GlassMaterializeScope.resolveSettings(context, settings);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return resolved;
    }

    testWidgets('at rest the very same instance comes back', (tester) async {
      // Identity matters beyond cost: a new instance every frame would defeat
      // the render object's settings equality check and repaint resting glass.
      expect(identical(await at(tester, 1.0), base), isTrue);
    });

    testWidgets('fully dematerialized glass skips its render pass',
        (tester) async {
      final settings = await at(tester, 0.0);
      // The render object early-outs on exactly this condition.
      expect(settings.effectiveThickness, 0.0);
      expect(settings.effectiveBlur, 0.0);
    });

    testWidgets('a dissolving surface stops blurring its backdrop',
        (tester) async {
      // Regression: driving the blur up to keep the shell looking frosty
      // smeared the content behind a surface nobody could see any more — a
      // blurred disc floated over the page after the glass had gone. The
      // backdrop blur has to fall away with the surface.
      final settled = await at(tester, 1.0);
      final half = await at(tester, 0.5);
      final nearly = await at(tester, 0.05);
      expect(half.effectiveBlur, lessThan(settled.effectiveBlur));
      expect(nearly.effectiveBlur, lessThan(half.effectiveBlur));
      expect(nearly.effectiveBlur, lessThan(0.5));
    });

    testWidgets('widget-level decorations fade with the glass', (tester) async {
      // Asserted through the `effective*` getters, which is how every consumer
      // reads them. Regression: the scope scaled these fields by progress as
      // well, and the getters then scaled the result by the visibility the
      // scope had already lowered — the shadow faded as t², so it left about
      // twice as fast as the glass it belonged to.
      const decorated = LiquidGlassSettings(
        blur: 5,
        shadowElevation: 1.0,
        whitenStrength: 0.4,
        backerColor: Color(0x59000000),
      );
      final half = await at(tester, 0.5, settings: decorated);
      expect(half.shadowElevation, decorated.shadowElevation);
      expect(half.effectiveShadowElevation, closeTo(0.5, 1e-9));
      expect(half.effectiveWhitenStrength, closeTo(0.2, 1e-9));
      expect(
        half.effectiveBackerColor!.a,
        closeTo(decorated.backerColor!.a * 0.5, 1e-6),
      );
    });
  });

  group('visibility fades every channel', () {
    // Regression: the uEdgeConfig terms uploaded raw, with no `effective*`
    // getter, so the Fresnel rim kept drawing at full strength however far
    // visibility had fallen. A dissolving surface stranded a bright outline
    // where the glass had been — visible against a fully-gone native one.
    test('the rim terms scale with visibility like every other channel', () {
      const full = LiquidGlassSettings(
        fresnelStrength: 1.0,
        ambientRim: 0.5,
        edgeAbsorption: 0.3,
      );
      final gone = full.copyWith(visibility: 0.0);
      expect(gone.effectiveFresnelStrength, 0.0);
      expect(gone.effectiveAmbientRim, 0.0);
      expect(gone.effectiveEdgeAbsorption, 0.0);

      final half = full.copyWith(visibility: 0.5);
      expect(half.effectiveFresnelStrength, closeTo(0.5, 1e-9));
      expect(half.effectiveAmbientRim, closeTo(0.25, 1e-9));
      expect(half.effectiveEdgeAbsorption, closeTo(0.15, 1e-9));
    });

    test('a surface at full visibility is untouched', () {
      const s = LiquidGlassSettings(
        fresnelStrength: 1.0,
        ambientRim: 0.5,
        edgeAbsorption: 0.3,
      );
      expect(s.effectiveFresnelStrength, s.fresnelStrength);
      expect(s.effectiveAmbientRim, s.ambientRim);
      expect(s.effectiveEdgeAbsorption, s.edgeAbsorption);
    });
  });

  group('scope plumbing', () {
    testWidgets('a running effect scales the visibility a surface sees',
        (tester) async {
      final settings = await _resolvedSettings(
        tester,
        (probe) => GlassMaterializeScope(
          glassProgress: 0.5,
          contentOpacity: 0.5,
          contentSigma: 4,
          child: probe,
        ),
      );
      expect(settings.visibility, closeTo(0.5, 1e-9));
    });

    testWidgets('no scope leaves settings untouched', (tester) async {
      final settings = await _resolvedSettings(tester, (probe) => probe);
      expect(settings.visibility, 1.0);
      expect(settings.blur, 5);
    });
  });

  group('choreography', () {
    testWidgets('an entrance resolves the glass before the content',
        (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: GlassMaterializeEffect(
            progress: 0.35,
            profile: GlassMaterializeProfile.entrance,
            child: SizedBox.shrink(),
          ),
        ),
      );
      final scope = tester.widget<GlassMaterializeScope>(
        find.byType(GlassMaterializeScope),
      );
      expect(scope.glassProgress, greaterThan(scope.contentOpacity));
    });

    testWidgets('an exit empties the content before the glass dissolves',
        (tester) async {
      // Late in the exit axis (low progress) the content must already be gone
      // while the shell is still visible — the briefly empty circle. Sampled
      // between the two: content is out by 0.45, the shell not until 0.3.
      await tester.pumpWidget(
        const CupertinoApp(
          home: GlassMaterializeEffect(
            progress: 0.4,
            profile: GlassMaterializeProfile.exit,
            child: SizedBox.shrink(),
          ),
        ),
      );
      final scope = tester.widget<GlassMaterializeScope>(
        find.byType(GlassMaterializeScope),
      );
      expect(scope.contentOpacity, 0.0);
      expect(scope.glassProgress, greaterThan(0.0));
    });

    test('neither glass channel moves far in any single frame', () {
      // Regression: an ease-out has a slope of 3 at zero, which put the glass
      // a fifth of the way present on the first frame of its window — it read
      // as the surface appearing instantly and then drifting. What matters is
      // that no frame carries a large share of the travel, at either end.
      const frames = 17; // a window at 60fps
      for (final channel in <(String, Interval)>[
        ('entrance', GlassMaterializeChoreography.entranceGlass),
        ('exit', GlassMaterializeChoreography.exitGlass),
      ]) {
        var previous = channel.$2.transform(0.0);
        for (var f = 1; f <= frames; f++) {
          final value = channel.$2.transform(f / frames);
          expect(
            value - previous,
            lessThan(0.15),
            reason: '${channel.$1} jumps at frame $f',
          );
          previous = value;
        }
      }
    });

    test('the exit dissolves from its first frame and reaches nothing', () {
      // The shell must start going as soon as the exit does — a curve that is
      // flat at the top holds it at full strength while the icon leaves — and
      // must land on zero rather than trailing a faint ring behind.
      const exit = GlassMaterializeChoreography.exitGlass;
      expect(exit.transform(1.0), 1.0);
      expect(exit.transform(0.0), 0.0);
      // A fifteenth of the way in, the shell has visibly begun to go.
      expect(1.0 - exit.transform(1.0 - 1 / 15), greaterThan(0.03));
    });

    test('the entrance still finishes', () {
      const entrance = GlassMaterializeChoreography.entranceGlass;
      expect(entrance.transform(0.5), greaterThan(0.2));
      expect(entrance.transform(1.0), 1.0);
    });

    testWidgets('the tree shape is the same at rest as mid-transition',
        (tester) async {
      // A shell that remounts as a transition starts or settles pops its
      // backdrop, so the wrappers must be present at every progress.
      for (final progress in <double>[1.0, 0.5, 0.0]) {
        await tester.pumpWidget(
          CupertinoApp(
            home: GlassMaterializeEffect(
              progress: progress,
              profile: GlassMaterializeProfile.entrance,
              child: const SizedBox.shrink(),
            ),
          ),
        );
        expect(find.byType(GlassMaterializeScope), findsOneWidget);
        expect(find.byType(Transform), findsWidgets);
      }
    });

    testWidgets('at rest the effect is paint-neutral', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: GlassMaterializeEffect(
            progress: 1.0,
            profile: GlassMaterializeProfile.entrance,
            scaleFrom: 0.85,
            child: SizedBox.shrink(),
          ),
        ),
      );
      final scope = tester.widget<GlassMaterializeScope>(
        find.byType(GlassMaterializeScope),
      );
      expect(scope.glassProgress, 1.0);
      expect(scope.contentOpacity, 1.0);
      expect(scope.contentSigma, 0.0);
    });
  });

  group('reduce motion', () {
    testWidgets('collapses to a cross-dissolve with no scale or blur',
        (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: GlassAccessibilityScope(
            reduceMotion: true,
            child: GlassMaterializeEffect(
              progress: 0.4,
              profile: GlassMaterializeProfile.entrance,
              scaleFrom: 0.85,
              contentSigma: 8,
              child: SizedBox.shrink(),
            ),
          ),
        ),
      );
      final scope = tester.widget<GlassMaterializeScope>(
        find.byType(GlassMaterializeScope),
      );
      // Both channels track progress directly — a fade, not motion.
      expect(scope.glassProgress, closeTo(0.4, 1e-9));
      expect(scope.contentOpacity, closeTo(0.4, 1e-9));
      expect(scope.contentSigma, 0.0);
    });
  });

  group('GlassMaterialize', () {
    testWidgets('animates between hidden and shown', (tester) async {
      Widget build(bool visible) => CupertinoApp(
            home: GlassMaterialize(
              visible: visible,
              child: const SizedBox.shrink(),
            ),
          );

      await tester.pumpWidget(build(false));
      var scope = tester.widget<GlassMaterializeScope>(
        find.byType(GlassMaterializeScope),
      );
      expect(scope.glassProgress, 0.0);

      await tester.pumpWidget(build(true));
      await tester.pump(const Duration(milliseconds: 120));
      scope = tester.widget<GlassMaterializeScope>(
        find.byType(GlassMaterializeScope),
      );
      expect(scope.glassProgress, greaterThan(0.0));
      expect(scope.glassProgress, lessThan(1.0));

      await tester.pumpAndSettle();
      expect(find.byType(GlassMaterializeScope), findsOneWidget);
    });

    testWidgets('maintainState: false releases the subtree once hidden',
        (tester) async {
      Widget build(bool visible) => CupertinoApp(
            home: GlassMaterialize(
              visible: visible,
              maintainState: false,
              child: const Text('glass', textDirection: TextDirection.ltr),
            ),
          );

      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(find.text('glass'), findsOneWidget);

      await tester.pumpWidget(build(false));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('glass'), findsOneWidget, reason: 'still dissolving');

      await tester.pumpAndSettle();
      expect(find.text('glass'), findsNothing);
    });

    testWidgets('onEnd fires when a transition settles', (tester) async {
      var ends = 0;
      Widget build(bool visible) => CupertinoApp(
            home: GlassMaterialize(
              visible: visible,
              onEnd: () => ends++,
              child: const SizedBox.shrink(),
            ),
          );

      await tester.pumpWidget(build(false));
      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(ends, 1);
    });
  });

  group('AnimatedSwitcher', () {
    testWidgets('switcherBuilder materializes each child', (tester) async {
      Widget build(String label) => CupertinoApp(
            home: AnimatedSwitcher(
              duration: GlassDefaults.materializeDuration,
              transitionBuilder: GlassMaterializeTransition.switcherBuilder,
              child: Text(label, key: ValueKey(label)),
            ),
          );

      await tester.pumpWidget(build('one'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(build('two'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GlassMaterializeTransition), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('two'), findsOneWidget);
    });
  });
}
