import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassScrollEdgeEffect', () {
    testWidgets(
        'renders children and DecoratedBox overlays by default (soft style)',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 500,
              width: 300,
              child: GlassScrollEdgeEffect(
                topFadeHeight: 100,
                bottomFadeHeight: 60,
                child: const SizedBox(key: Key('child')),
              ),
            ),
          ),
        ),
      );

      // Verify child is rendered
      expect(find.byKey(const Key('child')), findsOneWidget);

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.descendant(of: effectFinder, matching: find.byType(DecoratedBox)),
      );
      expect(decoratedBoxes.length, 2);

      // Verify positioning
      final positionedWidgets = tester.widgetList<Positioned>(
        find.descendant(of: effectFinder, matching: find.byType(Positioned)),
      );
      expect(positionedWidgets.length, 2);

      final topOverlay = positionedWidgets.firstWhere((p) => p.top == 0);
      final bottomOverlay = positionedWidgets.firstWhere((p) => p.bottom == 0);

      expect(topOverlay.height, 100);
      expect(bottomOverlay.height, 60);
    });

    testWidgets('renders ProgressiveBlur overlays when using blur style',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 500,
              width: 300,
              child: GlassScrollEdgeEffect(
                topFadeHeight: 100,
                bottomFadeHeight: 60,
                style: GlassScrollEdgeStyle.blur,
                maxSigma: 24,
                child: const SizedBox(key: Key('child')),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final blurs = tester.widgetList<ProgressiveBlur>(
        find.descendant(
            of: effectFinder, matching: find.byType(ProgressiveBlur)),
      );
      expect(blurs.length, 2);

      final topBlur = blurs.firstWhere(
        (b) => b.direction == ProgressiveBlurDirection.topToBottom,
      );
      final bottomBlur = blurs.firstWhere(
        (b) => b.direction == ProgressiveBlurDirection.bottomToTop,
      );

      expect(topBlur.maxSigma, 24);
      expect(bottomBlur.maxSigma, 24);
      expect(topBlur.falloff, 2.0);
      expect(bottomBlur.falloff, 2.0);
    });

    testWidgets('respects fadeTop and fadeBottom flags', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 500,
              width: 300,
              child: GlassScrollEdgeEffect(
                topFadeHeight: 100,
                bottomFadeHeight: 60,
                fadeTop: false,
                fadeBottom: false,
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      );

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      expect(
        find.descendant(of: effectFinder, matching: find.byType(Positioned)),
        findsNothing,
      );
    });

    testWidgets('clamps overlay height to 40% of screen height',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScrollEdgeEffect(
            topFadeHeight: 500, // greater than 600 * 0.4 (240)
            bottomFadeHeight: 500,
            child: const SizedBox(),
          ),
        ),
      );

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final positionedWidgets = tester.widgetList<Positioned>(
        find.descendant(of: effectFinder, matching: find.byType(Positioned)),
      );
      final topOverlay = positionedWidgets.firstWhere((p) => p.top == 0);

      expect(topOverlay.height, 240); // 600 * 0.4
    });

    testWidgets('applies hard style height adjustment (0.5x)', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScrollEdgeEffect(
            topFadeHeight: 100,
            style: GlassScrollEdgeStyle.hard,
            fadeBottom: false,
            child: const SizedBox(),
          ),
        ),
      );

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final positionedWidgets = tester.widgetList<Positioned>(
        find.descendant(of: effectFinder, matching: find.byType(Positioned)),
      );
      final topOverlay = positionedWidgets.firstWhere((p) => p.top == 0);

      // 100 * 0.5 = 50
      expect(topOverlay.height, 50);
    });

    testWidgets('uses provided fadeColor for soft style', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScrollEdgeEffect(
            style: GlassScrollEdgeStyle.soft,
            fadeColor: const Color(0xFFFF0000),
            child: const SizedBox(),
          ),
        ),
      );

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final decoratedBox = tester.firstWidget<DecoratedBox>(
        find.descendant(of: effectFinder, matching: find.byType(DecoratedBox)),
      );
      final gradient = decoratedBox.decoration as BoxDecoration;
      final linearGradient = gradient.gradient as LinearGradient;

      expect(linearGradient.colors.first.r, 1.0);
      expect(linearGradient.colors.first.g, 0.0);
      expect(linearGradient.colors.first.b, 0.0);
    });

    testWidgets(
        'attempts background capture within LiquidGlassScope when using soft style',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Scaffold(
            body: LiquidGlassScope(
              child: Stack(
                children: [
                  GlassBackgroundSource(
                    child: SizedBox(
                        width: 800,
                        height: 600,
                        child: ColoredBox(color: Colors.red)),
                  ),
                  GlassScrollEdgeEffect(
                    style: GlassScrollEdgeStyle.soft,
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for post-frame callbacks to execute
      await tester.pumpAndSettle();

      expect(find.byType(GlassScrollEdgeEffect), findsOneWidget);

      // Verify that texture capture succeeded and CustomPaint was installed
      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final customPaints = tester.widgetList<CustomPaint>(
        find.descendant(of: effectFinder, matching: find.byType(CustomPaint)),
      );
      expect(customPaints.length, 2);
    });

    testWidgets('recaptures background texture when fadeColor changes',
        (tester) async {
      Widget buildTree(Color color) {
        return CupertinoApp(
          home: Scaffold(
            body: LiquidGlassScope(
              child: Stack(
                children: [
                  GlassBackgroundSource(
                    child: SizedBox(
                      width: 800,
                      height: 600,
                      child: ColoredBox(color: color),
                    ),
                  ),
                  GlassScrollEdgeEffect(
                    fadeColor: color,
                    style: GlassScrollEdgeStyle.soft,
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildTree(const Color(0xFF08111F)));
      await tester.pumpAndSettle();

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final initialPaints = tester.widgetList<CustomPaint>(
        find.descendant(of: effectFinder, matching: find.byType(CustomPaint)),
      );
      expect(initialPaints.length, 2);
      final dynamic initialPainter = initialPaints.first.painter;
      final initialImage = initialPainter.image;
      expect(initialImage, isNotNull);

      // Update with new fadeColor
      await tester.pumpWidget(buildTree(const Color(0xFFFCFCFA)));

      // On the update frame, stale image is cleared and DecoratedBox fallback is shown
      final interimDecoratedBoxes = tester.widgetList<DecoratedBox>(
        find.descendant(of: effectFinder, matching: find.byType(DecoratedBox)),
      );
      expect(interimDecoratedBoxes.length, 2);

      // Settle to complete the new async capture
      await tester.pumpAndSettle();

      final updatedPaints = tester.widgetList<CustomPaint>(
        find.descendant(of: effectFinder, matching: find.byType(CustomPaint)),
      );
      expect(updatedPaints.length, 2);
      final dynamic updatedPainter = updatedPaints.first.painter;
      final updatedImage = updatedPainter.image;
      expect(updatedImage, isNotNull);
      expect(updatedImage != initialImage, isTrue);
    });

    testWidgets(
        'recaptures background and clears stale texture on theme mode change',
        (tester) async {
      final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return MaterialApp(
              themeMode: mode,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFFCFCFA),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF08111F),
              ),
              home: Builder(
                builder: (context) {
                  final background = Theme.of(context).scaffoldBackgroundColor;
                  return GlassScaffold(
                    backgroundColor: background,
                    background: ColoredBox(color: background),
                    bottomBar: GlassTabBar.bottom(
                      tabs: const [
                        GlassTab(icon: Icon(Icons.home), label: 'Home'),
                      ],
                      selectedIndex: 0,
                      onTabSelected: (_) {},
                    ),
                    body: const Center(child: Text('Content')),
                  );
                },
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final initialPaints = tester.widgetList<CustomPaint>(
        find.descendant(of: effectFinder, matching: find.byType(CustomPaint)),
      );
      expect(initialPaints.length,
          1); // bottomEdgeFade only by default without appBar
      final dynamic initialPainter = initialPaints.first.painter;
      final initialImage = initialPainter.image;
      expect(initialImage, isNotNull);

      // Switch theme to light
      themeNotifier.value = ThemeMode.light;
      await tester.pumpAndSettle();

      final updatedPaints = tester.widgetList<CustomPaint>(
        find.descendant(of: effectFinder, matching: find.byType(CustomPaint)),
      );
      expect(updatedPaints.length, 1);
      final dynamic updatedPainter = updatedPaints.first.painter;
      final updatedImage = updatedPainter.image;
      expect(updatedImage, isNotNull);
      expect(updatedImage != initialImage, isTrue);
    });

    testWidgets(
        'recaptures background on theme change even when fadeColor is null',
        (tester) async {
      final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return MaterialApp(
              themeMode: mode,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFFCFCFA),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF08111F),
              ),
              home: Builder(
                builder: (context) {
                  final background = Theme.of(context).scaffoldBackgroundColor;
                  // Explicitly omit backgroundColor so fadeColor remains null
                  return GlassScaffold(
                    background: ColoredBox(color: background),
                    bottomBar: GlassTabBar.bottom(
                      tabs: const [
                        GlassTab(icon: Icon(Icons.home), label: 'Home'),
                      ],
                      selectedIndex: 0,
                      onTabSelected: (_) {},
                    ),
                    body: const Center(child: Text('Content')),
                  );
                },
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      final effectFinder = find.byType(GlassScrollEdgeEffect);
      final initialPaint = tester.widget<CustomPaint>(
        find.descendant(of: effectFinder, matching: find.byType(CustomPaint)),
      );
      final dynamic initialPainter = initialPaint.painter;
      final initialImage = initialPainter.image;
      expect(initialImage, isNotNull);

      // Switch theme to light
      themeNotifier.value = ThemeMode.light;
      await tester.pumpAndSettle();

      final updatedPaint = tester.widget<CustomPaint>(
        find.descendant(of: effectFinder, matching: find.byType(CustomPaint)),
      );
      final dynamic updatedPainter = updatedPaint.painter;
      final updatedImage = updatedPainter.image;
      expect(updatedImage, isNotNull);
      expect(updatedImage != initialImage, isTrue);
    });
  });
}
