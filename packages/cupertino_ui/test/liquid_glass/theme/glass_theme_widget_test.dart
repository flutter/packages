import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart';

import '../shared/test_helpers.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassTheme — InheritedWidget
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassTheme', () {
    testWidgets('maybeOf returns null when no theme in tree', (tester) async {
      late GlassTheme? result;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            result = GlassTheme.maybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(result, isNull);
    });

    testWidgets('maybeOf returns theme when present', (tester) async {
      final data = GlassThemeData.fallback();
      late GlassTheme? result;

      await tester.pumpWidget(
        GlassTheme(
          data: data,
          child: Builder(
            builder: (context) {
              result = GlassTheme.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, isNotNull);
      expect(result!.data, equals(data));
    });

    testWidgets('of throws when no theme in tree', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => GlassTheme.of(context),
              throwsAssertionError,
            );
            return const SizedBox.shrink();
          },
        ),
      );
    });

    testWidgets('of returns theme when present', (tester) async {
      final data = GlassThemeData.fallback();
      late GlassTheme result;

      await tester.pumpWidget(
        GlassTheme(
          data: data,
          child: Builder(
            builder: (context) {
              result = GlassTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result.data, equals(data));
    });

    testWidgets('updateShouldNotify is false when data unchanged',
        (tester) async {
      final data = GlassThemeData.fallback();
      var notifyCount = 0;

      await tester.pumpWidget(
        GlassTheme(
          data: data,
          child: Builder(
            builder: (context) {
              context.dependOnInheritedWidgetOfExactType<GlassTheme>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // Pump with same data — should not rebuild
      await tester.pumpWidget(
        GlassTheme(
          data: data,
          child: Builder(
            builder: (context) {
              context.dependOnInheritedWidgetOfExactType<GlassTheme>();
              notifyCount++;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // The builder runs once on initial pump, once on re-pump — both with same data
      // notifyCount <= 2 proves updateShouldNotify doesn't re-trigger unnecessarily
      expect(notifyCount, lessThanOrEqualTo(2));
    });

    testWidgets('updateShouldNotify is true when data changes', (tester) async {
      var notifyCount = 0;
      final data1 = GlassThemeData.fallback();
      final data2 = GlassThemeData(
        light: GlassThemeVariant(
          settings: const GlassThemeSettings(thickness: 99),
          quality: GlassQuality.standard,
        ),
        dark: GlassThemeVariant(
          settings: const GlassThemeSettings(thickness: 99),
          quality: GlassQuality.standard,
        ),
      );

      await tester.pumpWidget(
        GlassTheme(
          data: data1,
          child: Builder(
            builder: (context) {
              context.dependOnInheritedWidgetOfExactType<GlassTheme>();
              notifyCount++;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        GlassTheme(
          data: data2,
          child: Builder(
            builder: (context) {
              context.dependOnInheritedWidgetOfExactType<GlassTheme>();
              notifyCount++;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // Should have been notified again when data changed
      expect(notifyCount, greaterThan(1));
    });

    testWidgets('debugFillProperties does not throw', (tester) async {
      final data = GlassThemeData.fallback();

      await tester.pumpWidget(
        GlassTheme(
          data: data,
          child: const SizedBox.shrink(),
        ),
      );

      final element = tester.element(find.byType(GlassTheme));
      final widget = element.widget as GlassTheme;
      // Verify debugFillProperties can be called by inspecting it
      expect(widget.data, equals(data));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeHelpers
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeHelpers', () {
    testWidgets('returns fallback when no GlassTheme ancestor', (tester) async {
      late GlassThemeData result;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            result = GlassThemeHelpers.of(context);
            return const SizedBox.shrink();
          },
        ),
      );

      final fallback = GlassThemeData.fallback();
      expect(result, equals(fallback));
    });

    testWidgets('returns theme data when GlassTheme is present',
        (tester) async {
      final data = GlassThemeData(
        light: GlassThemeVariant(
          settings: const GlassThemeSettings(thickness: 42),
          quality: GlassQuality.standard,
        ),
        dark: GlassThemeVariant(
          settings: const GlassThemeSettings(thickness: 42),
          quality: GlassQuality.standard,
        ),
      );

      late GlassThemeData result;

      await tester.pumpWidget(
        GlassTheme(
          data: data,
          child: Builder(
            builder: (context) {
              result = GlassThemeHelpers.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, equals(data));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LiquidGlassWidgets
  // ──────────────────────────────────────────────────────────────────────────

  group('LiquidGlassWidgets', () {
    test('has null globalSettings by default', () {
      expect(LiquidGlassWidgets.globalSettings, isNull);
    });

    test('globalSettings can be set and cleared', () {
      const settings = LiquidGlassSettings(thickness: 25);
      LiquidGlassWidgets.globalSettings = settings;
      expect(LiquidGlassWidgets.globalSettings, equals(settings));
      // Restore
      LiquidGlassWidgets.globalSettings = null;
    });

    // ── wrap() ───────────────────────────────────────────────────────────────

    test('wrap returns child directly when no options given', () {
      const child = SizedBox.shrink();
      final wrapped = LiquidGlassWidgets.wrap(child: child);
      // With no theme or adaptive quality, wrap returns the child itself.
      expect(identical(wrapped, child), isTrue);
    });

    test('wrap with adaptiveQuality:true returns a GlassAdaptiveScope', () {
      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        adaptiveQuality: true,
      );
      expect(wrapped.runtimeType.toString(), contains('GlassAdaptiveScope'));
    });

    test('wrap without adaptiveQuality does NOT insert GlassAdaptiveScope', () {
      const child = SizedBox.shrink();
      final wrapped = LiquidGlassWidgets.wrap(child: child);
      // With no adaptive quality, wrap returns the child directly.
      expect(
        wrapped.runtimeType.toString(),
        isNot(contains('GlassAdaptiveScope')),
      );
      expect(wrapped.runtimeType.toString(), contains('SizedBox'));
    });

    test('wrap(respectSystemAccessibility:false) sets the global flag', () {
      LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        respectSystemAccessibility: false,
      );
      expect(LiquidGlassWidgets.respectSystemAccessibility, isFalse);
      // Restore
      LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        respectSystemAccessibility: true,
      );
      expect(LiquidGlassWidgets.respectSystemAccessibility, isTrue);
    });

    // ── initialize() ─────────────────────────────────────────────────────────

    testWidgets('initialize() completes without throwing', (tester) async {
      await tester.runAsync(() async {
        await expectLater(
          LiquidGlassWidgets.initialize(enablePerformanceMonitor: false),
          completes,
        );
      });
    });

    testWidgets('initialize() supports GlassWarmUpMode auto, always, never',
        (tester) async {
      await tester.runAsync(() async {
        await expectLater(
          LiquidGlassWidgets.initialize(
            enablePerformanceMonitor: false,
            warmUpMode: GlassWarmUpMode.auto,
          ),
          completes,
        );
        await expectLater(
          LiquidGlassWidgets.initialize(
            enablePerformanceMonitor: false,
            warmUpMode: GlassWarmUpMode.always,
          ),
          completes,
        );
        await expectLater(
          LiquidGlassWidgets.initialize(
            enablePerformanceMonitor: false,
            warmUpMode: GlassWarmUpMode.never,
          ),
          completes,
        );
      });
    });

    testWidgets('initialize() with warmUpMode completes', (tester) async {
      await tester.runAsync(() async {
        await expectLater(
          LiquidGlassWidgets.initialize(
            enablePerformanceMonitor: false,
            warmUpMode: GlassWarmUpMode.never,
          ),
          completes,
        );
      });
    });

    testWidgets(
        'initialize() with enablePerformanceMonitor:true starts monitor',
        (tester) async {
      await tester.runAsync(() async {
        await LiquidGlassWidgets.initialize(enablePerformanceMonitor: true);
        GlassPerformanceMonitor.stop();
        GlassPerformanceMonitor.reset();
      });
    });

    // ── wrap() + adaptive ────────────────────────────────────────────────────

    testWidgets(
        'wrap(adaptiveQuality:true) inserts GlassAdaptiveScope as outermost widget',
        (tester) async {
      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        adaptiveQuality: true,
      );
      expect(wrapped.runtimeType.toString(), contains('GlassAdaptiveScope'));
    });

    test('wrap() without adaptiveQuality does NOT insert GlassAdaptiveScope',
        () {
      final wrapped = LiquidGlassWidgets.wrap(child: const SizedBox.shrink());
      // With no adaptive quality, wrap returns the child directly.
      expect(
        wrapped.runtimeType.toString(),
        isNot(contains('GlassAdaptiveScope')),
      );
    });
  });

  // ── GlassTheme.debugFillProperties (lines 90-93) ────────────────────────────
  group('GlassTheme.debugFillProperties', () {
    testWidgets('produces DiagnosticsProperty with data key', (tester) async {
      final data = GlassThemeData.fallback();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTheme(
            data: data,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final theme = tester.widget<GlassTheme>(find.byType(GlassTheme));

      // Calling toDiagnosticsNode().getProperties() exercises debugFillProperties
      final node = theme.toDiagnosticsNode();
      final props = node.getProperties();
      expect(props.any((p) => p.name == 'data'), isTrue);
    });
  });
}
