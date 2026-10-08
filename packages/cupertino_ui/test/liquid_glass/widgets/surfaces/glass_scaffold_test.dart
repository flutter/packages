import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassScaffold', () {
    testWidgets('renders with body and bottom bar', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              body: const Text('Body'),
              bottomBar: GlassTabBar.bottom(
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const [
                  GlassTab(
                    label: 'Tab 1',
                    icon: Icon(Icons.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('renders with app bar', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              appBar: GlassAppBar(title: Text('Title')),
              body: Text('Body'),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    // ── Edge fade: top fade height calculation ──────────────────────────────

    testWidgets('top fade excludes appBarHeight when no appBar is provided',
        (tester) async {
      // When topEdgeFade is true but no appBar is set, the fade should
      // only cover the status bar area + extent — NOT include the default
      // 44px appBarHeight. Regression test for the fix that checks
      // `appBar != null` before adding effectiveAppBarHeight.
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              topEdgeFade: true,
              body: SizedBox.expand(),
            ),
          ),
        ),
      );

      // The GlassScrollEdgeEffect should be present (fade is enabled).
      expect(find.byType(GlassScrollEdgeEffect), findsOneWidget);

      // Verify the fade widget exists and the scaffold rendered without error.
      final scrollEdge = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      // Without appBar, topFadeHeight = topPad + 0 + 20 (default extent).
      // The key assertion: it should NOT be topPad + 44 + 20.
      // In test environment, topPad is 0, so topFadeHeight should be 20.
      expect(scrollEdge.topFadeHeight, 20.0);
    });

    testWidgets('top fade includes appBarHeight when appBar is provided',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              appBar: GlassAppBar(title: Text('Title')),
              body: SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.byType(GlassScrollEdgeEffect), findsOneWidget);

      final scrollEdge = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      // With appBar, topFadeHeight = topPad(0) + 44 + 20 = 64.
      expect(scrollEdge.topFadeHeight, 64.0);
    });

    testWidgets(
        'defaults to GlassScrollEdgeStyle.soft and does not render ProgressiveBlur',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              topEdgeFade: true,
              body: SizedBox.expand(),
            ),
          ),
        ),
      );

      final scrollEdge = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      expect(scrollEdge.style, GlassScrollEdgeStyle.soft);
      expect(find.byType(ProgressiveBlur), findsNothing);
    });

    testWidgets(
        'forwards explicit blur edgeStyle to GlassScrollEdgeEffect and renders ProgressiveBlur',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              topEdgeFade: true,
              edgeStyle: GlassScrollEdgeStyle.blur,
              maxSigma: 22,
              body: SizedBox.expand(),
            ),
          ),
        ),
      );

      final scrollEdge = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      expect(scrollEdge.style, GlassScrollEdgeStyle.blur);
      expect(scrollEdge.maxSigma, 22);

      final blur = tester.widget<ProgressiveBlur>(find.byType(ProgressiveBlur));
      expect(blur.maxSigma, 22);
    });

    // ── Isolation scope: bars get premium quality hint ───────────────────────

    testWidgets('wraps bars in GlassIsolationScope with defaultQuality premium',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              appBar: const GlassAppBar(title: Text('Title')),
              body: const Text('Body'),
              bottomBar: GlassTabBar.bottom(
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const [
                  GlassTab(
                    label: 'Tab 1',
                    icon: Icon(Icons.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // GlassIsolationScope should be present (wrapping bars).
      expect(find.byType(GlassIsolationScope), findsWidgets);
    });

    testWidgets('bars use isolated: true for correct Z-order', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              appBar: const GlassAppBar(title: Text('Title')),
              body: const Text('Body'),
              bottomBar: GlassTabBar.bottom(
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const [
                  GlassTab(
                    label: 'Tab 1',
                    icon: Icon(Icons.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify GlassIsolationScope widgets have isolated: true.
      final scopes = tester.widgetList<GlassIsolationScope>(
        find.byType(GlassIsolationScope),
      );
      for (final scope in scopes) {
        if (scope.defaultQuality == GlassQuality.premium) {
          // Bar scopes from GlassScaffold should be isolated.
          expect(scope.isolated, isTrue,
              reason: 'Bar isolation scope should use isolated: true '
                  'for correct Z-order of glass components');
        }
      }
    });
  });

  // ── Header + headerScrollController + headerFadeDistance ────────────────

  group('GlassScaffold.header', () {
    testWidgets('renders header widget when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              header: const Text('Listen Now'),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.text('Listen Now'), findsOneWidget);
    });

    testWidgets('header has ValueKey for stable identity', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              header: const Text('Header'),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('glass_scaffold_header')),
        findsOneWidget,
      );
    });

    testWidgets('header fades on scroll via headerScrollController',
        (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              header: const Text('Fading Header'),
              headerScrollController: controller,
              headerFadeDistance: 100.0,
              body: ListView.builder(
                controller: controller,
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 80, child: Text('$i')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Fading Header'), findsOneWidget);

      controller.jumpTo(150.0);
      await tester.pumpAndSettle();

      expect(find.text('Fading Header'), findsOneWidget);

      final igp = tester.widgetList<IgnorePointer>(
        find.ancestor(
          of: find.text('Fading Header'),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(igp.any((w) => w.ignoring), isTrue,
          reason: 'Fully faded header should be non-interactive');

      controller.dispose();
    });

    testWidgets('header without scroll controller renders directly',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              header: const Text('Static Header'),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.text('Static Header'), findsOneWidget);
    });
  });

  // ── bodyOverlays ────────────────────────────────────────────────────────

  group('GlassScaffold.bodyOverlays', () {
    testWidgets('renders overlay widgets between body and bars',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              body: const Text('Body Content'),
              bodyOverlays: [
                const Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text('Play Bar Pill'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Body Content'), findsOneWidget);
      expect(find.text('Play Bar Pill'), findsOneWidget);
    });

    testWidgets('multiple overlays all render', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              body: const SizedBox.expand(),
              bodyOverlays: const [
                Positioned(bottom: 10, child: Text('Overlay 1')),
                Positioned(bottom: 50, child: Text('Overlay 2')),
                Positioned(bottom: 90, child: Text('Overlay 3')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Overlay 1'), findsOneWidget);
      expect(find.text('Overlay 2'), findsOneWidget);
      expect(find.text('Overlay 3'), findsOneWidget);
    });
  });

  // ── ValueKey stability ──────────────────────────────────────────────────

  group('GlassScaffold ValueKeys', () {
    testWidgets('app bar has stable ValueKey', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              appBar: GlassAppBar(title: Text('Title')),
              body: SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('glass_scaffold_app_bar')),
        findsOneWidget,
      );
    });

    testWidgets('bottom bar has stable ValueKey', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              body: const SizedBox.expand(),
              bottomBar: GlassTabBar.bottom(
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const [
                  GlassTab(label: 'Home', icon: Icon(Icons.home)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('glass_scaffold_bottom_bar')),
        findsOneWidget,
      );
    });

    testWidgets('toggling header preserves bar state', (tester) async {
      late StateSetter rebuildFn;
      bool showHeader = true;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuildFn = setState;
                return GlassScaffold(
                  header: showHeader ? const Text('Header') : null,
                  appBar: const GlassAppBar(title: Text('Title')),
                  body: const SizedBox.expand(),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);

      rebuildFn(() => showHeader = false);
      await tester.pumpAndSettle();

      expect(find.text('Header'), findsNothing);
      expect(find.text('Title'), findsOneWidget);
    });
  });

  // ── contentAwareBrightness ────────────────────────────────────────────────

  group('GlassScaffold.contentAwareBrightness', () {
    testWidgets('installs scope and content wrapper when true', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              contentAwareBrightness: true,
              body: const Text('Body'),
              bottomBar: GlassTabBar.bottom(
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const [
                  GlassTab(label: 'Home', icon: Icon(Icons.home)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassContentAwareScope), findsOneWidget);
      expect(find.byType(GlassContentAwareContent), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('does not install scope when false (default)', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassScaffold(
              body: const Text('Body'),
              bottomBar: GlassTabBar.bottom(
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const [
                  GlassTab(label: 'Home', icon: Icon(Icons.home)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassContentAwareScope), findsNothing);
      expect(find.byType(GlassContentAwareContent), findsNothing);
      expect(find.text('Body'), findsOneWidget);
    });

    // ── Dark-mode gradient flash regression (fix: fadeColor + transparent scaffold) ──

    testWidgets(
        'passes backgroundColor to GlassScrollEdgeEffect.fadeColor '
        'so fallback gradient uses correct colour in dark mode',
        (tester) async {
      // Regression test for: GlassTabBar gradient flickering dark when
      // GlassScaffold(backgroundColor: Colors.white) is used in dark mode.
      // GlassScrollEdgeEffect's async-capture fallback previously defaulted
      // to CupertinoTheme.scaffoldBackgroundColor (near-black in dark mode).
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              backgroundColor: Colors.white,
              topEdgeFade: true,
              bottomEdgeFade: true,
              body: SizedBox.expand(),
            ),
          ),
        ),
      );

      final scrollEdge = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      // fadeColor must be the explicit white, not null/dark theme default.
      expect(scrollEdge.fadeColor, Colors.white);
    });

    testWidgets(
        'GlassScrollEdgeEffect.fadeColor is null when no backgroundColor set',
        (tester) async {
      // When no backgroundColor is provided, fadeColor should be null so
      // GlassScrollEdgeEffect falls back to the theme default (existing behaviour).
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              topEdgeFade: true,
              body: SizedBox.expand(),
            ),
          ),
        ),
      );

      final scrollEdge = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      expect(scrollEdge.fadeColor, isNull);
    });

    testWidgets(
        'inner CupertinoPageScaffold is always transparent '
        'regardless of background or backgroundColor', (tester) async {
      // Regression test: Scaffold.backgroundColor was conditionally null when
      // only backgroundColor (not background widget) was provided, causing the
      // Material dark-mode theme colour to bleed through and corrupt glass
      // bar backdrop captures. Now uses CupertinoPageScaffold.
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              backgroundColor: Colors.white,
              body: Text('Body'),
            ),
          ),
        ),
      );

      // Find the inner CupertinoPageScaffold inside GlassScaffold.
      final scaffold = tester.widget<CupertinoPageScaffold>(
        find.descendant(
          of: find.byType(GlassScaffold),
          matching: find.byType(CupertinoPageScaffold),
        ),
      );
      expect(scaffold.backgroundColor, const Color(0x00000000));
    });

    testWidgets(
        'inner CupertinoPageScaffold uses CupertinoTheme background with no background set',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassScaffold(
              body: Text('Body'),
            ),
          ),
        ),
      );

      final scaffold = tester.widget<CupertinoPageScaffold>(
        find.descendant(
          of: find.byType(GlassScaffold),
          matching: find.byType(CupertinoPageScaffold),
        ),
      );
      // Without a background widget the CupertinoPageScaffold must NOT be
      // forced transparent — null lets it use the CupertinoTheme default (opaque)
      // to prevent the underlying route bleeding through during route transitions
      // (issue #177). Mirrors prior Scaffold(backgroundColor: null) behaviour.
      expect(scaffold.backgroundColor, isNull);
    });
  });
}
