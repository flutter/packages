import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart';

void main() {
  // ── GlassThemeHelpers.resolveQuality ────────────────────────────────────────

  group('GlassThemeHelpers.resolveQuality', () {
    testWidgets(
        'explicit widgetQuality wins over theme and inherited (no scope)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = GlassThemeHelpers.resolveQuality(
              context,
              widgetQuality: GlassQuality.minimal,
            );
            return const SizedBox.shrink();
          }),
        ),
      );

      // No adaptive scope present — explicit quality is returned as-is.
      expect(result, GlassQuality.minimal);
    });

    testWidgets(
        'adaptive scope caps explicit widgetQuality when ceiling is lower',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: _FakeAdaptiveScope(
            ceiling: GlassQuality.standard, // scope decided: standard
            child: Builder(builder: (context) {
              // Widget asks for premium, but device can only do standard.
              result = GlassThemeHelpers.resolveQuality(
                context,
                widgetQuality: GlassQuality.premium,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      // Adaptive scope wins — premium capped to standard.
      expect(result, GlassQuality.standard);
    });

    testWidgets(
        'explicit minimal is NOT raised by adaptive scope ceiling at standard',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: _FakeAdaptiveScope(
            ceiling: GlassQuality.standard,
            child: Builder(builder: (context) {
              // Developer explicitly chose minimal (e.g. a list card).
              // Scope ceiling is standard — must NOT raise minimal to standard.
              result = GlassThemeHelpers.resolveQuality(
                context,
                widgetQuality: GlassQuality.minimal,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      // Ceiling only lowers, never raises.
      expect(result, GlassQuality.minimal);
    });

    testWidgets('explicit widgetQuality equal to scope ceiling is unchanged',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: _FakeAdaptiveScope(
            ceiling: GlassQuality.premium,
            child: Builder(builder: (context) {
              result = GlassThemeHelpers.resolveQuality(
                context,
                widgetQuality: GlassQuality.premium,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result, GlassQuality.premium);
    });

    testWidgets('returns ancestor InheritedLiquidGlass quality (priority 2)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            quality: GlassQuality.premium, // ancestor sets premium
            child: Builder(builder: (context) {
              // widgetQuality is null — should fall through to ancestor
              result = GlassThemeHelpers.resolveQuality(
                context,
                widgetQuality: null,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result, GlassQuality.premium);
    });

    testWidgets(
        'returns standard fallback when no ancestor and no theme (priority 4)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            // No InheritedLiquidGlass ancestor, no GlassTheme, no widgetQuality
            result = GlassThemeHelpers.resolveQuality(context);
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result, GlassQuality.standard);
    });

    testWidgets('respects custom fallback (premium for surface widgets)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            // No ancestor, no theme → uses the passed fallback
            result = GlassThemeHelpers.resolveQuality(
              context,
              fallback: GlassQuality.premium,
            );
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result, GlassQuality.premium);
    });

    testWidgets('widgetQuality overrides ancestor quality', (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            quality: GlassQuality.premium,
            child: Builder(builder: (context) {
              // Widget explicitly wants minimal despite premium ancestor.
              result = GlassThemeHelpers.resolveQuality(
                context,
                widgetQuality: GlassQuality.minimal,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result, GlassQuality.minimal);
    });

    // ── Theme-level quality (Level 4) ──────────────────────────────────────

    testWidgets('GlassTheme quality applies when no widget or ancestor quality',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: GlassThemeData(
              light: const GlassThemeVariant(quality: GlassQuality.minimal),
              dark: const GlassThemeVariant(quality: GlassQuality.minimal),
            ),
            child: Builder(builder: (context) {
              // No widgetQuality, no ancestor — falls through to theme.
              result = GlassThemeHelpers.resolveQuality(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result, GlassQuality.minimal);
    });

    testWidgets(
        'widgetQuality wins over GlassTheme quality (explicit beats theme)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: GlassThemeData(
              light: const GlassThemeVariant(quality: GlassQuality.minimal),
              dark: const GlassThemeVariant(quality: GlassQuality.minimal),
            ),
            child: Builder(builder: (context) {
              // Developer explicitly sets premium despite theme saying minimal.
              result = GlassThemeHelpers.resolveQuality(
                context,
                widgetQuality: GlassQuality.premium,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      // No adaptive scope → explicit widget quality is returned as-is.
      expect(result, GlassQuality.premium);
    });

    testWidgets('scope caps theme quality (Level 4 subject to ceiling)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: _FakeAdaptiveScope(
            ceiling: GlassQuality.standard,
            child: GlassTheme(
              data: GlassThemeData(
                light: const GlassThemeVariant(quality: GlassQuality.premium),
                dark: const GlassThemeVariant(quality: GlassQuality.premium),
              ),
              child: Builder(builder: (context) {
                // Theme says premium, scope ceiling is standard.
                result = GlassThemeHelpers.resolveQuality(context);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );

      expect(result, GlassQuality.standard);
    });

    // ── Widget-class default / fallback (Level 5) ─────────────────────────

    testWidgets('surface widget premium fallback applies when no theme set',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            // Simulates e.g. GlassAppBar which passes fallback: premium.
            // No theme, no ancestor, no explicit quality → widget-class default.
            result = GlassThemeHelpers.resolveQuality(
              context,
              fallback: GlassQuality.premium,
            );
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result, GlassQuality.premium);
    });

    testWidgets('scope caps widget-class default (Level 5 subject to ceiling)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: _FakeAdaptiveScope(
            ceiling: GlassQuality.standard,
            child: Builder(builder: (context) {
              // Surface widget default is premium, scope ceiling is standard.
              result = GlassThemeHelpers.resolveQuality(
                context,
                fallback: GlassQuality.premium,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result, GlassQuality.standard);
    });

    testWidgets('scope does NOT raise minimal fallback to higher scope ceiling',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: _FakeAdaptiveScope(
            ceiling: GlassQuality.premium, // high ceiling — should not raise
            child: Builder(builder: (context) {
              result = GlassThemeHelpers.resolveQuality(
                context,
                fallback: GlassQuality.minimal,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      // Scope never raises, only lowers.
      expect(result, GlassQuality.minimal);
    });

    // ── Full 5-level interaction ─────────────────────────────────────────────

    testWidgets(
        'full hierarchy: widget > theme > fallback, all subject to scope ceiling',
        (tester) async {
      // Scope ceiling = standard.
      // Theme = premium (which would normally be applied to no-explicit-quality widgets).
      // Widget A has explicit premium → capped to standard.
      // Widget B has no explicit quality → theme says premium → capped to standard.
      // Widget C has explicit minimal → stays minimal (ceiling never raises).
      late GlassQuality resultA, resultB, resultC;

      await tester.pumpWidget(
        MaterialApp(
          home: _FakeAdaptiveScope(
            ceiling: GlassQuality.standard,
            child: GlassTheme(
              data: GlassThemeData(
                light: const GlassThemeVariant(quality: GlassQuality.premium),
                dark: const GlassThemeVariant(quality: GlassQuality.premium),
              ),
              child: Builder(builder: (context) {
                resultA = GlassThemeHelpers.resolveQuality(context,
                    widgetQuality: GlassQuality.premium); // explicit → capped
                resultB =
                    GlassThemeHelpers.resolveQuality(context); // theme → capped
                resultC = GlassThemeHelpers.resolveQuality(context,
                    widgetQuality:
                        GlassQuality.minimal); // explicit → not raised
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );

      expect(resultA, GlassQuality.standard); // premium explicit → capped
      expect(resultB, GlassQuality.standard); // theme premium → capped
      expect(resultC, GlassQuality.minimal); // minimal explicit → unchanged
    });

    // ── GlassIsolationScope.defaultQuality interaction (bar quality fix) ───

    testWidgets(
        'scopeDefault overrides inherited page-level quality '
        '(GlassScaffold bar pattern)', (tester) async {
      // Regression test: GlassScaffold wraps bars in
      // GlassIsolationScope(isolated: false, defaultQuality: premium).
      // The page-level AdaptiveLiquidGlassLayer provides standard quality
      // via InheritedLiquidGlass. Without the fix, the inherited standard
      // would short-circuit Step 2, making bars render at standard.
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            quality: GlassQuality.standard, // page-level = standard
            child: GlassIsolationScope(
              isolated: false, // NOT isolated (shared layer)
              defaultQuality: GlassQuality.premium, // scope hint = premium
              child: Builder(builder: (context) {
                // Simulates GlassTabBar.bottom which passes fallback: premium.
                result = GlassThemeHelpers.resolveQuality(
                  context,
                  fallback: GlassQuality.premium,
                );
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );

      // scopeDefault premium must win over inherited standard.
      expect(result, GlassQuality.premium);
    });

    testWidgets(
        'without scopeDefault, inherited page-level quality applies normally',
        (tester) async {
      // Verify we didn't break the normal case: when no scope provides
      // a defaultQuality, the inherited quality from the page layer should
      // still apply at Step 2.
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            quality: GlassQuality.premium, // page-level = premium
            child: Builder(builder: (context) {
              // No GlassIsolationScope with defaultQuality → inherited wins.
              result = GlassThemeHelpers.resolveQuality(
                context,
                fallback: GlassQuality.standard, // fallback is lower
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      // Inherited premium from page layer should apply.
      expect(result, GlassQuality.premium);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GlassThemeHelpers.resolveAdaptiveRadius (PR #39 — yukinoaruu)
  //
  // Validates height-based Pro Max detection: top padding alone must NOT
  // trigger the 54.0 radius. Height >= 900 is the single authoritative
  // signal for Pro Max / Plus tier (regression added in PR #39).
  // ─────────────────────────────────────────────────────────────────────────

  group('GlassThemeHelpers.resolveAdaptiveRadius', () {
    Widget buildWithMedia(Widget Function(BuildContext) probe,
        {Size size = const Size(390, 844),
        EdgeInsets viewPadding = const EdgeInsets.only(top: 44, bottom: 34),
        TargetPlatform platform = TargetPlatform.iOS}) {
      return MaterialApp(
        home: Builder(builder: (context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: size,
              viewPadding: viewPadding,
              padding: viewPadding,
            ),
            child: Builder(builder: probe),
          );
        }),
      );
    }

    testWidgets('Pro Max height (>= 900) → 54.0', (tester) async {
      double? result;
      await tester.pumpWidget(
        buildWithMedia(
          (ctx) {
            result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
            return const SizedBox.shrink();
          },
          size: const Size(430, 932), // 15 Pro Max
          viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
        ),
      );
      expect(result, 54.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('Pro height (>= 800, < 900) → 46.0', (tester) async {
      double? result;
      await tester.pumpWidget(
        buildWithMedia(
          (ctx) {
            result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
            return const SizedBox.shrink();
          },
          size: const Size(393, 852), // 15 Pro
          viewPadding: const EdgeInsets.only(top: 54, bottom: 34),
        ),
      );
      expect(result, 46.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets(
        'regression: high top padding on Pro height must NOT return Pro Max radius',
        (tester) async {
      // Before PR #39, top >= 59 triggered 54.0 on any device — including Pro.
      // After the fix, height < 900 always returns 46.0.
      double? result;
      await tester.pumpWidget(
        buildWithMedia(
          (ctx) {
            result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
            return const SizedBox.shrink();
          },
          size: const Size(393, 852), // Pro height, NOT Pro Max
          viewPadding: const EdgeInsets.only(top: 62, bottom: 34),
        ),
      );
      expect(result, 46.0); // must be Pro, NOT Pro Max
      expect(result, isNot(54.0));
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('Android with bottom safe area → 28.0', (tester) async {
      double? result;
      await tester.pumpWidget(
        buildWithMedia(
          (ctx) {
            result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
            return const SizedBox.shrink();
          },
          size: const Size(412, 892),
          viewPadding: const EdgeInsets.only(top: 28, bottom: 24),
        ),
      );
      expect(result, 28.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('device without bottom safe area → 0.0 (home button)',
        (tester) async {
      double? result;
      await tester.pumpWidget(
        buildWithMedia(
          (ctx) {
            result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
            return const SizedBox.shrink();
          },
          size: const Size(375, 667), // iPhone SE (home button)
          viewPadding: const EdgeInsets.only(top: 20, bottom: 0),
        ),
      );
      expect(result, 0.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });

  // ─────────────────────────────────────────────────────────────────────────
  // LiquidVerticalRoundedSuperellipse asymmetric radii (PR #42 — jfhair)
  //
  // Verifies the Dart-side shape API that feeds rawBottomCornerRadius into
  // the premium geometry shader stride-7 pipeline.
  // ─────────────────────────────────────────────────────────────────────────

  group('LiquidVerticalRoundedSuperellipse asymmetric radii', () {
    test('stores distinct top and bottom radii', () {
      const shape =
          LiquidVerticalRoundedSuperellipse(topRadius: 36, bottomRadius: 60);
      expect(shape.topRadius, 36.0);
      expect(shape.bottomRadius, 60.0);
      expect(shape.topRadius, isNot(shape.bottomRadius));
    });

    test('symmetric shape has equal top and bottom radii', () {
      const shape =
          LiquidVerticalRoundedSuperellipse(topRadius: 36, bottomRadius: 36);
      expect(shape.topRadius, shape.bottomRadius);
    });

    test('zero bottom radius is valid (flush bottom edge)', () {
      const shape =
          LiquidVerticalRoundedSuperellipse(topRadius: 24, bottomRadius: 0);
      expect(shape.bottomRadius, 0.0);
    });

    test('scale() reduces both radii proportionally', () {
      const shape =
          LiquidVerticalRoundedSuperellipse(topRadius: 40, bottomRadius: 60);
      final scaled = shape.scale(0.5) as LiquidVerticalRoundedSuperellipse;
      expect(scaled.topRadius, closeTo(20.0, 0.01));
      expect(scaled.bottomRadius, closeTo(30.0, 0.01));
    });

    test('copyWith overrides only the specified radius', () {
      const original =
          LiquidVerticalRoundedSuperellipse(topRadius: 20, bottomRadius: 40);
      final copied = original.copyWith(bottomRadius: 55);
      expect(copied.topRadius, 20.0); // unchanged
      expect(copied.bottomRadius, 55.0); // overridden
    });
  });
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Injects a fake [GlassAdaptiveScopeData] into the widget tree so tests can
/// exercise the adaptive ceiling path without a real [GlassAdaptiveScope]
/// running a benchmark.
class _FakeAdaptiveScope extends StatelessWidget {
  const _FakeAdaptiveScope({required this.ceiling, required this.child});

  final GlassQuality ceiling;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassAdaptiveScope(
      // Lock the scope at the desired ceiling with no adaptation.
      initialQuality: ceiling,
      minQuality: ceiling,
      maxQuality: ceiling,
      child: child,
    );
  }
}
