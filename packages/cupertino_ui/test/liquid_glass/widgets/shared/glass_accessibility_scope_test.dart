import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  // -------------------------------------------------------------------------
  // GlassAccessibilityData
  // -------------------------------------------------------------------------

  group('GlassAccessibilityData', () {
    test('defaults has no restrictions', () {
      const data = GlassAccessibilityData.defaults;
      expect(data.reduceMotion, isFalse);
      expect(data.reduceTransparency, isFalse);
    });

    test('equality holds when fields match', () {
      const a =
          GlassAccessibilityData(reduceMotion: true, reduceTransparency: false);
      const b =
          GlassAccessibilityData(reduceMotion: true, reduceTransparency: false);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality fails when fields differ', () {
      const a =
          GlassAccessibilityData(reduceMotion: true, reduceTransparency: false);
      const b = GlassAccessibilityData(
          reduceMotion: false, reduceTransparency: false);
      expect(a, isNot(equals(b)));
    });

    test('toString includes both fields', () {
      const data =
          GlassAccessibilityData(reduceMotion: true, reduceTransparency: false);
      expect(data.toString(), contains('reduceMotion: true'));
      expect(data.toString(), contains('reduceTransparency: false'));
    });
  });

  // -------------------------------------------------------------------------
  // GlassAccessibilityScope — of() / maybeOf()
  // -------------------------------------------------------------------------

  group('GlassAccessibilityScope.of / maybeOf', () {
    testWidgets('of() returns defaults when no scope is in tree',
        (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              captured = GlassAccessibilityData.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, equals(GlassAccessibilityData.defaults));
    });

    testWidgets('maybeOf() returns null when no scope is in tree',
        (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              captured = GlassAccessibilityData.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets('of() returns data when scope is present', (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassAccessibilityScope(
            reduceMotion: true,
            reduceTransparency: true,
            child: Builder(
              builder: (context) {
                captured = GlassAccessibilityData.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured?.reduceMotion, isTrue);
      expect(captured?.reduceTransparency, isTrue);
    });

    testWidgets('maybeOf() returns data when scope is present', (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassAccessibilityScope(
            reduceMotion: false,
            reduceTransparency: true,
            child: Builder(
              builder: (context) {
                captured = GlassAccessibilityData.maybeOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured?.reduceTransparency, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GlassAccessibilityScope — iOS Reduce Motion
  // -------------------------------------------------------------------------

  group('GlassAccessibilityScope — iOS Reduce Motion', () {
    testWidgets('reads platform reduceMotion when disableAnimations is false', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      GlassAccessibilityData? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              captured = GlassAccessibilityData.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured?.reduceMotion, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GlassAccessibilityScope — explicit overrides
  // -------------------------------------------------------------------------

  group('GlassAccessibilityScope — explicit overrides', () {
    testWidgets('explicit reduceMotion=true overrides MediaQuery false',
        (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MediaQuery(
          // System says no disable-animations
          data: const MediaQueryData(disableAnimations: false),
          child: MaterialApp(
            home: GlassAccessibilityScope(
              reduceMotion: true, // explicit override
              child: Builder(
                builder: (context) {
                  captured = GlassAccessibilityData.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(captured?.reduceMotion, isTrue);
    });

    testWidgets('explicit reduceMotion=false overrides MediaQuery true',
        (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: GlassAccessibilityScope(
              reduceMotion: false, // explicit opt-out
              child: Builder(
                builder: (context) {
                  captured = GlassAccessibilityData.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(captured?.reduceMotion, isFalse);
    });

    testWidgets('null reduceMotion delegates to MediaQuery.disableAnimations',
        (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: GlassAccessibilityScope(
              // reduceMotion not provided → reads from MediaQuery
              child: Builder(
                builder: (context) {
                  captured = GlassAccessibilityData.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(captured?.reduceMotion, isTrue);
    });

    testWidgets('null reduceTransparency delegates to MediaQuery.highContrast',
        (tester) async {
      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: MaterialApp(
            home: GlassAccessibilityScope(
              // reduceTransparency not provided → reads from MediaQuery
              child: Builder(
                builder: (context) {
                  captured = GlassAccessibilityData.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(captured?.reduceTransparency, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GlassAccessibilityScope — reactive rebuilds
  // -------------------------------------------------------------------------

  group('GlassAccessibilityScope — reactive rebuilds', () {
    testWidgets('rebuilds dependents when MediaQuery.disableAnimations changes',
        (tester) async {
      final mediaQueryData = ValueNotifier(
        const MediaQueryData(disableAnimations: false),
      );
      addTearDown(mediaQueryData.dispose);

      final captured = <bool>[];

      await tester.pumpWidget(
        ValueListenableBuilder<MediaQueryData>(
          valueListenable: mediaQueryData,
          builder: (_, data, __) => MediaQuery(
            data: data,
            child: MaterialApp(
              home: GlassAccessibilityScope(
                child: Builder(
                  builder: (context) {
                    captured
                        .add(GlassAccessibilityData.of(context).reduceMotion);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Initially false
      expect(captured.last, isFalse);

      // Simulate the user enabling Reduce Motion
      mediaQueryData.value = const MediaQueryData(disableAnimations: true);
      await tester.pump();

      expect(captured.last, isTrue);
    });

    testWidgets('rebuilds dependents when explicit override changes',
        (tester) async {
      final override = ValueNotifier<bool?>(null);
      addTearDown(override.dispose);

      final captured = <bool>[];

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: MaterialApp(
            home: ValueListenableBuilder<bool?>(
              valueListenable: override,
              builder: (_, value, __) => GlassAccessibilityScope(
                reduceMotion: value,
                child: Builder(
                  builder: (context) {
                    captured
                        .add(GlassAccessibilityData.of(context).reduceMotion);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(captured.last, isFalse); // reads MediaQuery (false)

      override.value = true; // force override
      await tester.pump();
      expect(captured.last, isTrue);

      override.value = null; // back to system (false)
      await tester.pump();
      expect(captured.last, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // GlassAccessibilityScope — child passes through
  // -------------------------------------------------------------------------

  testWidgets('GlassAccessibilityScope renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GlassAccessibilityScope(
          child: SizedBox(key: Key('inner'), width: 100, height: 100),
        ),
      ),
    );

    expect(find.byKey(const Key('inner')), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // LiquidGlassWidgets.respectSystemAccessibility global flag
  // -------------------------------------------------------------------------

  group('LiquidGlassWidgets.respectSystemAccessibility global flag', () {
    // Always reset to safe default after each test so state doesn't bleed.
    tearDown(() => LiquidGlassWidgets.respectSystemAccessibility = true);

    testWidgets(
        'when false, of() returns defaults even if MediaQuery has reduce-motion',
        (tester) async {
      LiquidGlassWidgets.respectSystemAccessibility = false;

      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MediaQuery(
          data:
              const MediaQueryData(disableAnimations: true, highContrast: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                captured = GlassAccessibilityData.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured?.reduceMotion, isFalse,
          reason: 'Global flag=false should ignore MediaQuery');
      expect(captured?.reduceTransparency, isFalse,
          reason: 'Global flag=false should ignore MediaQuery');
    });

    testWidgets(
        'when false, an explicit GlassAccessibilityScope still overrides',
        (tester) async {
      LiquidGlassWidgets.respectSystemAccessibility = false;

      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassAccessibilityScope(
            reduceMotion: true, // explicit override
            child: Builder(
              builder: (context) {
                captured = GlassAccessibilityData.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Scope wins regardless of global flag
      expect(captured?.reduceMotion, isTrue);
    });

    testWidgets('can be restored to true after being set to false',
        (tester) async {
      LiquidGlassWidgets.respectSystemAccessibility = false;
      LiquidGlassWidgets.respectSystemAccessibility = true;

      GlassAccessibilityData? captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                captured = GlassAccessibilityData.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured?.reduceMotion, isTrue,
          reason:
              'After restoring to true, MediaQuery should be respected again');
    });
  });
}
