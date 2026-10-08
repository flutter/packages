import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  testWidgets('GlassPopover opens on trigger tap and shows content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: Container(
                width: 50,
                height: 50,
                color: Colors.blue,
                child: const Center(child: Text('Open')),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Popover Content'),
              ),
            ),
          ),
        ),
      ),
    );

    // Initial state: Popover closed
    expect(find.text('Popover Content'), findsNothing);

    // Tap trigger
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Popover content should be present
    expect(find.text('Popover Content'), findsOneWidget);
  });

  testWidgets('GlassPopover closes on barrier tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                width: 50,
                height: 50,
                child: Text('Open'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Content'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open popover
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Content'), findsOneWidget);

    // Tap outside (barrier)
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pumpAndSettle();

    // Popover closed
    expect(find.text('Content'), findsNothing);
  });

  testWidgets('GlassPopover close callback from contentBuilder works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              popoverHeight: 150,
              trigger: const SizedBox(
                width: 50,
                height: 50,
                child: Text('Open'),
              ),
              contentBuilder: (context, close) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Content'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: close,
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Open
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Content'), findsOneWidget);

    // Tap the Done button (uses close callback)
    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Popover closed
    expect(find.text('Content'), findsNothing);
  });

  testWidgets('GlassPopover triggerBuilder provides working toggle callback',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              triggerBuilder: (context, toggle) => GlassButton.custom(
                onTap: toggle,
                useOwnLayer: true,
                child: const Text('Interactive'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Builder Content'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Builder Content'), findsNothing);

    await tester.tap(find.text('Interactive'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Builder Content'), findsOneWidget);
  });

  testWidgets(
      'GlassPopover closes when tapping trigger area (barrier intercepts)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('Toggle'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Toggle Content'),
              ),
            ),
          ),
        ),
      ),
    );

    // First tap — opens
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Toggle Content'), findsOneWidget);

    // Tap outside to close (barrier intercepts)
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Toggle Content'), findsNothing);
  });

  testWidgets('GlassPopover onClose fires when closing',
      (WidgetTester tester) async {
    int closeCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              onClose: () => closeCalls++,
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('Open'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Closeable'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(closeCalls, 0);

    // Close via barrier tap
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(closeCalls, 1);
  });

  testWidgets('GlassPopover onOpen fires when opening',
      (WidgetTester tester) async {
    int openCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              onOpen: () => openCalls++,
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('Open'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Content'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(openCalls, 0);

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(openCalls, 1);
  });

  testWidgets('GlassPopover at bottom of screen flips vertical alignment',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                bottom: 10,
                left: 20,
                child: GlassPopover(
                  trigger: const SizedBox(
                    width: 60,
                    height: 40,
                    child: Text('BottomPopover'),
                  ),
                  contentBuilder: (context, close) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Flipped Content'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('BottomPopover'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Flipped Content'), findsOneWidget);
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('GlassPopover on right side of screen aligns correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                right: 20,
                top: 20,
                child: GlassPopover(
                  trigger: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Text('RightBtn'),
                  ),
                  contentBuilder: (context, close) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Right Content'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('RightBtn'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Right Content'), findsOneWidget);
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('GlassPopover with explicit popoverHeight constrains content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              popoverHeight: 200,
              popoverWidth: 200,
              trigger: const SizedBox(
                width: 50,
                height: 50,
                child: Text('Open'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Constrained'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Constrained'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GlassPopover with explicit alignment',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              alignment: GlassMenuAlignment.bottomCenter,
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('Aligned'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Bottom Center'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Aligned'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Bottom Center'), findsOneWidget);
  });

  testWidgets('GlassPopover autoAdjustToScreen does not crash at screen edge',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: GlassPopover(
              autoAdjustToScreen: true,
              screenPadding: const EdgeInsets.all(12),
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('EdgePopover'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Edge Content'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('EdgePopover'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Edge Content'), findsOneWidget);
    expect(tester.takeException(), isNull);
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('GlassPopover onClose not called when not provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('NoCallback'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('SafeContent'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('NoCallback'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Close — must not throw
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('GlassPopover asserts when neither trigger nor triggerBuilder provided',
      () {
    expect(
      () => GlassPopover(
        contentBuilder: (context, close) => const Text('Test'),
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('GlassPopover default values', () {
    final popover = GlassPopover(
      trigger: const SizedBox(width: 40, height: 40),
      contentBuilder: (context, close) => const Text('Test'),
    );

    expect(popover.popoverWidth, 280);
    expect(popover.popoverHeight, isNull);
    expect(popover.popoverBorderRadius, 24.0);
    expect(popover.alignment, isNull);
    expect(popover.autoAdjustToScreen, isTrue);
    expect(popover.barrierDismissible, isTrue);
    expect(popover.stretch, 0.3);
    expect(popover.interactionScale, 1.02);
    expect(popover.stretchResistance, 0.08);
    expect(popover.enableInteractionGlow, isTrue);
    expect(popover.glowOnTapOnly, isTrue);
    expect(popover.glowRadius, 0.6);
    expect(popover.glowIntensity, 0.0);
    expect(popover.onClose, isNull);
    expect(popover.onOpen, isNull);
  });
  // ── Scale-with-morph animation (aligned with GlassMenu PR #97) ─────────────
  testWidgets(
      'GlassPopover content is wrapped in Transform.scale when fully open',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('ScaleOpen')),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('ScaledContent'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ScaleOpen'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('ScaledContent'), findsOneWidget);

    // A Transform widget wrapping the content should exist in the tree.
    final transformFinder = find.ancestor(
      of: find.text('ScaledContent'),
      matching: find.byType(Transform),
    );
    expect(transformFinder, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GlassPopover content is wrapped in Opacity when fully open',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('FadeOpen')),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('FadedContent'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('FadeOpen'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('FadedContent'), findsOneWidget);

    final opacityFinder = find.ancestor(
      of: find.text('FadedContent'),
      matching: find.byType(Opacity),
    );
    expect(opacityFinder, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GlassPopover content not present immediately after opening (early morph)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('EarlyPopover')),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('EarlyContent'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap to open — pump only one frame (spring is near 0%).
    await tester.tap(find.text('EarlyPopover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    // At this very early stage of the spring, content should not yet be
    // in the tree (clampedValue is well below 0.3).
    expect(find.text('EarlyContent'), findsNothing);

    // Let the animation complete so teardown is clean.
    await tester.pumpAndSettle();
    expect(find.text('EarlyContent'), findsOneWidget);
  });

  testWidgets('GlassPopover renders and opens in minimal quality mode (#214)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              quality: GlassQuality.minimal,
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('OpenPopover'),
              ),
              contentBuilder: (context, close) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('MinimalContent'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OpenPopover'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('MinimalContent'), findsOneWidget);
  });

  // ── Route-aware dismissal tests (#274) ────────────────────────────────────
  testWidgets(
      'GlassPopover dismisses instantly on route navigation without overlapping destination (#274)',
      (tester) async {
    bool closedCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: GlassPopover(
                onClose: () => closedCalled = true,
                trigger: const SizedBox(
                  width: 80,
                  height: 40,
                  child: Text('Open Popover'),
                ),
                contentBuilder: (context, close) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('Page 2')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Navigate From Popover'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Open popover
    await tester.tap(find.text('Open Popover'));
    await tester.pumpAndSettle();
    expect(find.text('Navigate From Popover'), findsOneWidget);
    expect(closedCalled, isFalse);

    // Tap navigate button inside popover
    await tester.tap(find.text('Navigate From Popover'));

    // Advance into route transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Popover must be immediately dismissed during route transition
    expect(find.text('Navigate From Popover'), findsNothing);
    expect(find.text('Page 2'), findsOneWidget);
    expect(closedCalled, isTrue);

    // Settle transition
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('Navigate From Popover'), findsNothing);

    // Pop back to Page 1
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Back on Page 1: trigger is visible and popover is closed
    expect(find.text('Open Popover'), findsOneWidget);
    expect(find.text('Navigate From Popover'), findsNothing);

    // Reopen popover cleanly
    await tester.tap(find.text('Open Popover'));
    await tester.pumpAndSettle();
    expect(find.text('Navigate From Popover'), findsOneWidget);
  });

  testWidgets(
      'GlassPopover dismisses instantly when route is pushed externally while open',
      (tester) async {
    late BuildContext homeContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            homeContext = context;
            return Scaffold(
              body: Center(
                child: GlassPopover(
                  trigger: const Text('Open Popover'),
                  contentBuilder: (context, close) =>
                      const Text('Popover Body'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Popover'));
    await tester.pumpAndSettle();
    expect(find.text('Popover Body'), findsOneWidget);

    // Push an external route
    Navigator.of(homeContext).push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('External Route')),
        ),
      ),
    );

    // Advance into transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Popover Body'), findsNothing);
    expect(find.text('External Route'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassPopover dismisses instantly when route with zero duration is pushed while open',
      (tester) async {
    late BuildContext homeContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            homeContext = context;
            return Scaffold(
              body: Center(
                child: GlassPopover(
                  trigger: const Text('Open Popover'),
                  contentBuilder: (context, close) =>
                      const Text('Popover Body'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Popover'));
    await tester.pumpAndSettle();
    expect(find.text('Popover Body'), findsOneWidget);

    Navigator.of(homeContext).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Zero Duration Route')),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Popover Body'), findsNothing);
    expect(find.text('Zero Duration Route'), findsOneWidget);
  });

  testWidgets(
      'GlassPopover dismisses instantly when containing route is popped while open',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Second Route')),
                      body: Center(
                        child: GlassPopover(
                          trigger: const Text('Open SubPopover'),
                          contentBuilder: (context, close) =>
                              const Text('Sub Popover Content'),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Go to Second'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go to Second'));
    await tester.pumpAndSettle();
    expect(find.text('Second Route'), findsOneWidget);

    // Open popover on second route
    await tester.tap(find.text('Open SubPopover'));
    await tester.pumpAndSettle();
    expect(find.text('Sub Popover Content'), findsOneWidget);

    // Pop the containing route
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();

    // Advance 1 frame of pop
    await tester.pump();
    expect(find.text('Sub Popover Content'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Go to Second'), findsOneWidget);
  });

  testWidgets(
      'GlassPopover dismisses instantly when route is pushed on ancestor Navigator (#274 nested navigator)',
      (tester) async {
    final shellNavigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          key: shellNavigatorKey,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: Center(
                    child: GlassPopover(
                      trigger: const Text('Open Popover'),
                      contentBuilder: (context, close) => ElevatedButton(
                        onPressed: () {
                          shellNavigatorKey.currentState!.push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const Scaffold(
                                body: Center(child: Text('Destination page')),
                              ),
                            ),
                          );
                        },
                        child: const Text('Start Activity'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Popover'));
    await tester.pumpAndSettle();
    expect(find.text('Start Activity'), findsOneWidget);

    await tester.tap(find.text('Start Activity'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Mid-transition into Destination page on the ancestor navigator,
    // the popover should already be dismissed and not lingering in root overlay.
    expect(find.text('Destination page'), findsOneWidget);
    expect(find.text('Start Activity'), findsNothing);

    await tester.pumpAndSettle();
  });

  // ── Trigger soft-detach and landing opacity ───────────────────────────────

  testWidgets('Trigger dissolves cleanly to 0.0 when popover is fully open',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              popoverWidth: 200,
              contentBuilder: (context, close) => const Text('Content'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    // When fully open, the trigger must be cleanly dissolved (opacity 0.0)
    // so there is no ghost button or visual artifact under/behind the popover.
    final opacityWidgets = tester.widgetList<Opacity>(find.byType(Opacity));
    final triggerOpacity = opacityWidgets.first.opacity;
    expect(
      triggerOpacity,
      equals(0.0),
      reason:
          'Trigger should be fully dissolved when popover is open (clean detach)',
    );
  });

  testWidgets('Trigger opacity returns to 1.0 after popover fully closes',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              popoverWidth: 200,
              contentBuilder: (context, close) => const Text('Content'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    // Close via barrier tap
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // When fully closed, the trigger should not have an Opacity widget or it should be 1.0
    final opacityFinder = find.byType(Opacity);
    if (opacityFinder.evaluate().isNotEmpty) {
      final opacity = tester.widget<Opacity>(opacityFinder.first);
      expect(opacity.opacity, equals(1.0));
    }
    expect(find.text('Btn'), findsOneWidget);
  });

  testWidgets(
      'GlassPopover on standard quality renders only single GlassContainer on close (no Blob A ghost)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              quality: GlassQuality.standard,
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              popoverWidth: 200,
              contentBuilder: (context, close) => const Text('Content'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    // Trigger close via barrier tap
    await tester.tapAt(const Offset(10, 10));
    // Pump partially into the close animation (e.g. 50ms)
    await tester.pump(const Duration(milliseconds: 50));

    // Under standard quality, Blob A is suppressed during close to prevent double-button overlap.
    // There should be exactly 1 GlassContainer inside the overlay (Blob B, the collapsing popover body).
    final overlayContainers = find.descendant(
      of: find.byType(LiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(overlayContainers, findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassPopover on minimal quality renders only single GlassContainer on close (no Blob A ghost)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              quality: GlassQuality.minimal,
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              popoverWidth: 200,
              contentBuilder: (context, close) => const Text('Content'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 50));

    final overlayContainers = find.descendant(
      of: find.byType(LiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(overlayContainers, findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassPopover renders Blob A trigger ghost during opening morph (liquid bridge preserved on open)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              quality: GlassQuality.standard,
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              popoverWidth: 200,
              popoverHeight: 100,
              contentBuilder: (context, close) => const Text('Content'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pump(const Duration(milliseconds: 30));

    final overlayContainers = find.descendant(
      of: find.byType(LiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(overlayContainers, findsNWidgets(2));

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassPopover content presents within 150ms with GlassAccessibilityScope(reduceMotion: true)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassAccessibilityScope(
              reduceMotion: true,
              child: GlassPopover(
                popoverHeight: 100,
                trigger: const SizedBox(
                    width: 60, height: 40, child: Text('InstantPopover')),
                contentBuilder: (context, close) =>
                    const Text('InstantPopoverContent'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('InstantPopover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('InstantPopoverContent'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassPopover content presents within 150ms with platform reduceMotion: true',
      (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassPopover(
              popoverHeight: 100,
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('PlatformPopover')),
              contentBuilder: (context, close) =>
                  const Text('PlatformPopoverContent'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('PlatformPopover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('PlatformPopoverContent'), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
