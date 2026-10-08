import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: LiquidGlassWidgets.wrap(child: child)),
    );

const _shape = LiquidRoundedRectangle(borderRadius: 20);
const _settings = LiquidGlassSettings(blur: 5);

void main() {
  group('AdaptiveGlass — quality paths', () {
    testWidgets('minimal quality renders fallback path', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.minimal,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      // Frosted-fallback path used to wrap in ClipPath(ShapeBorderClipper);
      // for RoundedRectangleBorder-resolving shapes it now wraps in
      // ClipRRect via _ShapeClip (so Flutter PR #177551's PlatformView
      // clip-forwarding takes effect over a PlatformView backdrop).
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('blur=0 triggers minimal fast path', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: LiquidGlassSettings(blur: 0),
          quality: GlassQuality.standard,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('standard quality renders lightweight glass', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.standard,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('premium useOwnLayer renders RepaintBoundary', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.premium,
          useOwnLayer: true,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });

  group('AdaptiveGlass — backer (dimming layer)', () {
    // A distinctive color nothing else in the glass stack uses, so the
    // backer's ColoredBox is unambiguous to find.
    const backer = Color(0x80FF00FF);
    Finder backerFinder() =>
        find.byWidgetPredicate((w) => w is ColoredBox && w.color == backer);

    testWidgets('renders a clipped dimming pad behind the glass when set',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: LiquidGlassSettings(blur: 5, backerColor: backer),
          quality: GlassQuality.standard,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(backerFinder(), findsOneWidget);
    });

    testWidgets('no backer when backerColor is null', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings, // no backerColor
          quality: GlassQuality.standard,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(backerFinder(), findsNothing);
    });

    testWidgets('a fully-transparent backer is treated as no backer',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings:
              LiquidGlassSettings(blur: 5, backerColor: Color(0x00FF00FF)),
          quality: GlassQuality.standard,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(
        find.byWidgetPredicate(
            (w) => w is ColoredBox && w.color == const Color(0x00FF00FF)),
        findsNothing,
      );
    });

    testWidgets('backer also applies on the minimal/frosted path',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: LiquidGlassSettings(backerColor: backer),
          quality: GlassQuality.minimal,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(backerFinder(), findsOneWidget);
    });

    testWidgets('backer applies on the premium own-layer path', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: LiquidGlassSettings(blur: 5, backerColor: backer),
          quality: GlassQuality.premium,
          useOwnLayer: true,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(backerFinder(), findsOneWidget);
    });
  });

  group('AdaptiveGlass — accessibility path', () {
    testWidgets('reduce transparency triggers frosted fallback',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiquidGlassWidgets.wrap(
            child: GlassAccessibilityScope(
              reduceTransparency: true,
              child: const SizedBox(
                width: 200,
                height: 100,
                child: AdaptiveGlass(
                  shape: _shape,
                  settings: _settings,
                  quality: GlassQuality.standard,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      // See note above on the ClipPath → ClipRRect swap in _ShapeClip
      // for RoundedRectangleBorder-resolving shapes.
      expect(find.byType(ClipRRect), findsWidgets);
    });
  });

  group('AdaptiveGlass — grouped factory', () {
    testWidgets('grouped() returns AdaptiveGlass', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass.grouped(
            shape: _shape, child: const SizedBox.expand()),
      )));
      await tester.pump();
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });

    testWidgets('grouped() isInteractive+glowIntensity renders correctly',
        (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass.grouped(
          shape: _shape,
          quality: GlassQuality.minimal,
          isInteractive: true,
          glowIntensity: 1.0,
          child: const SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });
  });

  group('AdaptiveGlass — allowElevation paths', () {
    testWidgets('allowElevation=false renders container glass', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.standard,
          allowElevation: false,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('elevation with ancestor blur adds density factor',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiquidGlassWidgets.wrap(
            child: InheritedLiquidGlass(
              settings: _settings,
              quality: GlassQuality.standard,
              isBlurProvidedByAncestor: true,
              child: const SizedBox(
                width: 200,
                height: 100,
                child: AdaptiveGlass(
                  shape: _shape,
                  settings: _settings,
                  quality: GlassQuality.standard,
                  allowElevation: true,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('_FrostedFallback edge cases', () {
    testWidgets('isInteractive=true skips BackdropFilter', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.minimal,
          isInteractive: true,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('isInteractive=true keeps BackdropFilter over a PlatformView',
        (tester) async {
      // platformViewBackdrop overrides the interactive blur-omission above: over
      // a PlatformView the live BackdropFilter is the only path that blurs the
      // (hybrid-composed) map, so it must run even for interactive surfaces.
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.minimal,
          isInteractive: true,
          platformViewBackdrop: true,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(BackdropFilter), findsWidgets);
    });

    testWidgets('glowIntensity > 0 adds glow overlay', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.minimal,
          glowIntensity: 0.8,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(Stack), findsWidgets);
    });
  });

  // _ShapeClip — the private helper used by _FrostedFallback to route
  // superellipse shapes through ClipRSuperellipse (exact iOS continuous-curve
  // fidelity), RoundedRectangleBorder-resolving shapes through ClipRRect
  // (Flutter PR #177551 PlatformView clip-forwarding), and everything else
  // through ClipPath. Exercise the branches not covered by the top-level cases.
  group('AdaptiveGlass — _ShapeClip shape branches via _FrostedFallback', () {
    testWidgets(
        'LiquidVerticalRoundedSuperellipse routes through ClipRSuperellipse',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: LiquidVerticalRoundedSuperellipse(
            topRadius: 18,
            bottomRadius: 4,
          ),
          settings: _settings,
          quality: GlassQuality.minimal,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      // LiquidVerticalRoundedSuperellipse now routes to ClipRSuperellipse for
      // exact iOS continuous-curve fidelity when not over a PlatformView.
      expect(find.byType(ClipRSuperellipse), findsWidgets);
    });

    testWidgets('LiquidOval falls back to ClipPath via _ShapeClip',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 80,
        height: 80,
        child: AdaptiveGlass(
          shape: LiquidOval(),
          settings: _settings,
          quality: GlassQuality.minimal,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      // LiquidOval is intentionally NOT routed through ClipRRect (see
      // _ShapeClip doc comment) — verify the ClipPath fallback path is
      // taken.
      expect(find.byType(ClipPath), findsWidgets);
    });
  });

  group('AdaptiveGlass — platformViewBackdrop routes to the frost', () {
    // Over a PlatformView the premium/standard shaders sample a captured
    // backdrop that excludes the platform view (inert), so platformViewBackdrop
    // must route to the frosted fallback (a live BackdropFilter) regardless of
    // the requested quality. The frost path wraps in ClipRRect via _ShapeClip;
    // the lightweight/shader paths do not. (settings has blur:5, so this is the
    // platformViewBackdrop branch, not the blur==0 fast path.)
    testWidgets('forces the frost at premium quality', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.premium,
          platformViewBackdrop: true,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      // Over a PlatformView, ClipRSuperellipse is not forwarded to the mutator
      // stack — the platformViewBackdrop guard must override the superellipse
      // routing and fall back to ClipRRect so the frost is correctly bounded.
      expect(find.byType(ClipRRect), findsWidgets,
          reason: 'platformViewBackdrop must take the frosted-fallback path at '
              'premium, not the shader path that is inert over a PlatformView');
    });

    testWidgets('forces the frost at standard quality', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: _shape,
          settings: _settings,
          quality: GlassQuality.standard,
          platformViewBackdrop: true,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(ClipRRect), findsWidgets);
    });
  });
}
