import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsAction;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  for (final fromTrigger in [false, true]) {
    for (final cancel in [false, true]) {
      testWidgets(
          'active ${fromTrigger ? 'trigger' : 'menu'} pointer can '
          '${cancel ? 'cancel' : 'end'} after menu unmounts', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassMenu(
                enableContinuousSwipe: fromTrigger,
                trigger:
                    const SizedBox(width: 60, height: 40, child: Text('Open')),
                items: [GlassMenuItem(title: 'Action', onTap: () {})],
              ),
            ),
          ),
        );
        if (!fromTrigger) {
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
        }

        final gesture = await tester.startGesture(
          tester.getCenter(find.text(fromTrigger ? 'Open' : 'Action')),
        );
        await tester.pump();
        await tester.pumpWidget(const SizedBox.shrink());
        await gesture.moveBy(const Offset(0, 5));
        if (cancel) {
          await gesture.cancel();
        } else {
          await gesture.up();
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('GlassMenu toggles and renders items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: Container(
                width: 50,
                height: 50,
                color: Colors.blue,
                child: const Center(child: Text('Open Menu')),
              ),
              items: [
                GlassMenuItem(
                  title: 'Option 1',
                  onTap: () {},
                ),
                GlassMenuItem(
                  title: 'Option 2',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Initial state: Menu closed
    expect(find.text('Option 1'), findsNothing);

    // Tap trigger
    await tester.tap(find.text('Open Menu'));
    await tester.pump(); // Start animation
    await tester
        .pumpAndSettle(); // Wait for animation to complete (content appears at 65%+)

    // Menu should be present (portal shown)
    expect(find.text('Option 1'), findsOneWidget);

    // Close menu (tap outside)
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Menu closed
    expect(find.text('Option 1'), findsNothing);
  });

  testWidgets('GlassMenu works with triggerBuilder (interactive trigger)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              triggerBuilder: (context, toggle) => GlassButton.custom(
                onTap: toggle,
                useOwnLayer: true,
                child: const Text('Interactive Menu'),
              ),
              items: [
                GlassMenuItem(
                  title: 'Action',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Action'), findsNothing);

    await tester.tap(find.text('Interactive Menu'));
    await tester.pump();
    await tester.pumpAndSettle(); // Wait for animation to complete

    expect(find.text('Action'), findsOneWidget);
  });

  testWidgets('GlassMenu aligns correctly when on right side of screen',
      (WidgetTester tester) async {
    // Set a wide screen
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
                child: GlassMenu(
                  trigger: const SizedBox(
                      width: 50, height: 50, child: Text('RightBtn')),
                  items: [
                    GlassMenuItem(title: 'RightItem', onTap: () {}),
                  ],
                  menuWidth: 200,
                ),
              )
            ],
          ),
        ),
      ),
    );

    // Open menu
    await tester.tap(find.text('RightBtn'));
    await tester.pump();
    await tester.pumpAndSettle(); // Wait for animation to complete

    // Verify 'RightItem' is visible
    expect(find.text('RightItem'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });

  // ── GlassMenuItem tap-cancel (line 77) ──────────────────────────────────────
  testWidgets('GlassMenuItem onTapCancel resets pressed state (line 77)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassMenu(
            trigger: const SizedBox(
              width: 60,
              height: 40,
              child: Text('Open'),
            ),
            items: [
              GlassMenuItem(
                title: 'Action',
                icon: Icon(Icons.star),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // Open the menu to make item visible
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Action'), findsOneWidget);

    // Tap-down then cancel — exercises onTapDown (line 75) and onTapCancel (line 77)
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Action')),
    );
    await tester.pump();
    await gesture.cancel();
    await tester.pump();

    // Item still present — state reset silently
    expect(find.text('Action'), findsOneWidget);
  });

  // ── _toggleMenu close path (line 186) ───────────────────────────────────────
  testWidgets('GlassMenu second tap closes menu via _toggleMenu (line 186)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: const SizedBox(
                width: 60,
                height: 40,
                child: Text('Toggle'),
              ),
              items: [
                GlassMenuItem(title: 'Close Test', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    // First tap — opens menu
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Close Test'), findsOneWidget);

    // Second tap — closes menu via _toggleMenu (line 186: _closeMenu)
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Close Test'), findsNothing);
  });

  // ── shouldFlipVertical bottom-of-screen path (line 228) ─────────────────────
  testWidgets(
      'GlassMenu at bottom of screen flips vertical alignment (line 228)',
      (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                bottom: 10, // Near bottom — triggers shouldFlipVertical
                left: 20,
                child: GlassMenu(
                  trigger: const SizedBox(
                      width: 60, height: 40, child: Text('BottomMenu')),
                  items: [
                    GlassMenuItem(title: 'FlipItem', onTap: () {}),
                  ],
                  menuWidth: 150,
                ),
              )
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('BottomMenu'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('FlipItem'), findsOneWidget);
    addTearDown(tester.view.resetPhysicalSize);
  });

  // ── GlassMenuAlignment enum (PR #55) ─────────────────────────────────────────
  test('GlassMenuAlignment enum has all expected values', () {
    const values = GlassMenuAlignment.values;
    expect(values, contains(GlassMenuAlignment.none));
    expect(values, contains(GlassMenuAlignment.topLeft));
    expect(values, contains(GlassMenuAlignment.topCenter));
    expect(values, contains(GlassMenuAlignment.topRight));
    expect(values, contains(GlassMenuAlignment.centerLeft));
    expect(values, contains(GlassMenuAlignment.center));
    expect(values, contains(GlassMenuAlignment.centerRight));
    expect(values, contains(GlassMenuAlignment.bottomLeft));
    expect(values, contains(GlassMenuAlignment.bottomCenter));
    expect(values, contains(GlassMenuAlignment.bottomRight));
    expect(values.length, 10);
  });

  testWidgets('GlassMenu opens with explicit menuAlignment.topRight',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              menuAlignment: GlassMenuAlignment.topRight,
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('AlignMenu')),
              items: [
                GlassMenuItem(title: 'AlignedItem', onTap: () {}),
              ],
              menuWidth: 180,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('AlignMenu'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('AlignedItem'), findsOneWidget);
  });

  testWidgets('GlassMenu autoAdjustToScreen with menuPadding does not crash',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: GlassMenu(
              autoAdjustToScreen: true,
              menuPadding: const EdgeInsets.all(12),
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('PaddedMenu')),
              items: [
                GlassMenuItem(title: 'PaddedItem', onTap: () {}),
              ],
              menuWidth: 200,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('PaddedMenu'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('PaddedItem'), findsOneWidget);
    expect(tester.takeException(), isNull);
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('GlassMenu respects itemBorderRadius parameter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              itemBorderRadius: 8.0,
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Open')),
              items: [
                GlassMenuItem(title: 'RoundedItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('RoundedItem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // ── onClose callback (PR #67) ────────────────────────────────────────────────
  test('GlassMenu.onClose defaults to null', () {
    const menu = GlassMenu(
      trigger: SizedBox(width: 40, height: 40),
      items: [],
    );
    expect(menu.onClose, isNull);
  });

  testWidgets('GlassMenu onClose fires when tapping outside the barrier',
      (tester) async {
    // Regression: onClose must fire on the barrier tap-to-close path
    // (GestureDetector Positioned.fill, glass_menu_internal.dart line 369).
    int closeCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              onClose: () => closeCalls++,
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Open')),
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    // Open the menu.
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Item'), findsOneWidget);
    expect(closeCalls, 0); // Opening must NOT call onClose.

    // Tap outside (top-left corner — well outside the menu body).
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(closeCalls, 1);
  });

  testWidgets('GlassMenu onClose fires when closed via trigger re-tap',
      (tester) async {
    // Regression: onClose must fire on the _toggleMenu → _closeMenu path
    // (glass_menu_internal.dart line 188).
    int closeCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              onClose: () => closeCalls++,
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Toggle2')),
              items: [
                GlassMenuItem(title: 'Item2', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    // Open.
    await tester.tap(find.text('Toggle2'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(closeCalls, 0);

    // Re-tap trigger to close. The trigger widget is behind the overlay at this
    // point (opacity=0, IgnorePointer when menu open), so warnIfMissed is
    // suppressed — _toggleMenu is still invoked via the GestureDetector.
    await tester.tap(find.text('Toggle2'), warnIfMissed: false);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(closeCalls, 1);
  });

  testWidgets('GlassMenu onClose not called when not provided', (tester) async {
    // Safety: widget with no onClose must not throw when menu closes.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              // onClose intentionally omitted.
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('NoCallback')),
              items: [
                GlassMenuItem(title: 'SafeItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('NoCallback'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Close via outside tap — must not throw.
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  // ── morphFromZero (point bloom) ───────────────────────────────────────────
  test('GlassMenu.morphFromZero defaults to false', () {
    final menu = GlassMenu(
      trigger: const SizedBox(width: 8, height: 8),
      items: [GlassMenuItem(title: 'Item', onTap: () {})],
    );
    expect(menu.morphFromZero, isFalse);
  });

  testWidgets('GlassMenu morphFromZero opens and closes without crashing',
      (tester) async {
    // morphFromZero lerps Blob B's size from 0 → full and suppresses Blob A,
    // exercising the radius-0 / 0-area degenerate path the default-false tests
    // never hit. The zero-size render guard must keep this from throwing.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              morphFromZero: true,
              trigger: const SizedBox(width: 8, height: 8, child: Text('Zero')),
              items: [
                GlassMenuItem(title: 'ZeroItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Zero'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('ZeroItem'), findsOneWidget);

    // Close via outside tap — the collapse-to-point tail must not throw.
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('ZeroItem'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // ── GlassMenuController (PR #88 / #89) ──────────────────────────────────────
  test('GlassMenuController defaults to detached (isOpen is false)', () {
    final controller = GlassMenuController();
    expect(controller.isOpen, isFalse);
  });

  testWidgets('GlassMenuController.open() opens the menu imperatively',
      (tester) async {
    final controller = GlassMenuController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              controller: controller,
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Ctrl')),
              items: [
                GlassMenuItem(title: 'CtrlItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    expect(controller.isOpen, isFalse);
    expect(find.text('CtrlItem'), findsNothing);

    // Open via controller (not via trigger tap)
    controller.open();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(controller.isOpen, isTrue);
    expect(find.text('CtrlItem'), findsOneWidget);
  });

  testWidgets('GlassMenuController.close() closes the menu imperatively',
      (tester) async {
    final controller = GlassMenuController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              controller: controller,
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Ctrl2')),
              items: [
                GlassMenuItem(title: 'CtrlItem2', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    // Open via controller
    controller.open();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('CtrlItem2'), findsOneWidget);

    // Close via controller
    controller.close();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(controller.isOpen, isFalse);
    expect(find.text('CtrlItem2'), findsNothing);
  });

  // ── showDismissBarrier (PR #88 / #89) ───────────────────────────────────────
  test('GlassMenu.showDismissBarrier defaults to true', () {
    final menu = GlassMenu(
      trigger: const SizedBox(width: 40, height: 40),
      items: [GlassMenuItem(title: 'Item', onTap: () {})],
    );
    expect(menu.showDismissBarrier, isTrue);
  });

  testWidgets(
      'GlassMenu showDismissBarrier=false renders without barrier crash',
      (tester) async {
    final controller = GlassMenuController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              controller: controller,
              showDismissBarrier: false,
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('NoBarrier')),
              items: [
                GlassMenuItem(title: 'BarrierItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    controller.open();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('BarrierItem'), findsOneWidget);

    // Close via controller since there's no barrier to tap
    controller.close();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('BarrierItem'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // ── setFollowOffset (PR #89) ────────────────────────────────────────────────
  testWidgets('GlassMenuController.setFollowOffset does not crash',
      (tester) async {
    final controller = GlassMenuController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              controller: controller,
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Follow')),
              items: [
                GlassMenuItem(title: 'FollowItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    controller.open();
    await tester.pump();
    await tester.pumpAndSettle();

    // Nudge the menu position — must not crash
    controller.setFollowOffset(const Offset(10, 5));
    await tester.pump();

    expect(find.text('FollowItem'), findsOneWidget);

    // Reset offset
    controller.setFollowOffset(Offset.zero);
    await tester.pump();

    expect(tester.takeException(), isNull);

    controller.close();
    await tester.pump();
    await tester.pumpAndSettle();
  });

  // ── GlassIconButton quality null pass-through (PR #90) ──────────────────────
  testWidgets('GlassIconButton passes null quality to let theme chain resolve',
      (tester) async {
    // Exercises the fix: quality must NOT be coerced to GlassQuality.standard
    // before reaching GlassButton.custom(), so the theme chain can resolve it.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassIconButton(
              icon: const Icon(Icons.star),
              onPressed: () {},
              // quality intentionally omitted — must resolve through theme
            ),
          ),
        ),
      ),
    );

    expect(find.byType(GlassIconButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  // ── Scale-with-morph animation (PR #97) ────────────────────────────────────
  testWidgets('GlassMenu items are wrapped in Transform.scale when fully open',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Scale')),
              items: [
                GlassMenuItem(title: 'ScaleItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    // Open the menu and let the spring fully settle.
    await tester.tap(find.text('Scale'));
    await tester.pump();
    await tester.pumpAndSettle();

    // The item text must be visible.
    expect(find.text('ScaleItem'), findsOneWidget);

    // A Transform widget wrapping items should exist in the tree.
    // At rest (clampedValue ≈ 1.0) the scale should be ≈ 1.0.
    final transformFinder = find.ancestor(
      of: find.text('ScaleItem'),
      matching: find.byType(Transform),
    );
    expect(transformFinder, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GlassMenu items are wrapped in Opacity when fully open',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger:
                  const SizedBox(width: 60, height: 40, child: Text('Fade')),
              items: [
                GlassMenuItem(title: 'FadeItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Fade'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('FadeItem'), findsOneWidget);

    // An Opacity widget wrapping items should exist in the tree.
    final opacityFinder = find.ancestor(
      of: find.text('FadeItem'),
      matching: find.byType(Opacity),
    );
    expect(opacityFinder, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GlassMenu items not present immediately after opening (early morph)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('EarlyMorph')),
              items: [
                GlassMenuItem(title: 'EarlyItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    // Tap to open — pump only one frame (spring is near 0%).
    await tester.tap(find.text('EarlyMorph'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    // At this very early stage of the spring, items should not yet be in
    // the tree (clampedValue is well below 0.3).
    expect(find.text('EarlyItem'), findsNothing);

    // Let the animation complete so teardown is clean.
    await tester.pumpAndSettle();
    expect(find.text('EarlyItem'), findsOneWidget);
  });

  testWidgets(
      'GlassMenu items present immediately with GlassAccessibilityScope(reduceMotion: true)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassAccessibilityScope(
              reduceMotion: true,
              child: GlassMenu(
                trigger: const SizedBox(
                    width: 60, height: 40, child: Text('InstantMenu')),
                items: [
                  GlassMenuItem(title: 'InstantItem', onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Tap to open — with reduceMotion (instant spring stiffness 500), the morph settles
    // well within 150ms, whereas normal spring (~375ms) is still travelling.
    await tester.tap(find.text('InstantMenu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('InstantItem'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassMenu items present within 150ms with platform reduceMotion: true',
      (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: const SizedBox(
                  width: 60, height: 40, child: Text('PlatformInstantMenu')),
              items: [
                GlassMenuItem(title: 'PlatformInstantItem', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('PlatformInstantMenu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('PlatformInstantItem'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  // ── Route-aware dismissal tests (#274) ────────────────────────────────────
  testWidgets(
      'GlassMenu dismisses instantly on route navigation without overlapping destination (#274)',
      (tester) async {
    bool closedCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: GlassMenu(
                onClose: () => closedCalled = true,
                trigger: const SizedBox(
                  width: 80,
                  height: 40,
                  child: Text('Open Menu'),
                ),
                items: [
                  GlassMenuItem(
                    title: 'Navigate Item',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const Scaffold(
                            body: Center(child: Text('Page 2')),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Open the menu
    await tester.tap(find.text('Open Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Navigate Item'), findsOneWidget);
    expect(closedCalled, isFalse);

    // Tap navigate item
    await tester.tap(find.text('Navigate Item'));

    // Advance into the route transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Mid-transition into the new route, the menu must already be dismissed.
    // It should not linger in the root overlay over the incoming page.
    expect(find.text('Navigate Item'), findsNothing);
    expect(find.text('Page 2'), findsOneWidget);
    expect(closedCalled, isTrue);

    // Complete the transition
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('Navigate Item'), findsNothing);

    // Pop back to Page 1
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Back on Page 1: trigger is visible and menu is closed
    expect(find.text('Open Menu'), findsOneWidget);
    expect(find.text('Navigate Item'), findsNothing);

    // Menu can be reopened cleanly
    await tester.tap(find.text('Open Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Navigate Item'), findsOneWidget);
  });

  testWidgets(
      'GlassMenu dismisses instantly when route is pushed externally while open',
      (tester) async {
    late BuildContext homeContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            homeContext = context;
            return Scaffold(
              body: Center(
                child: GlassMenu(
                  trigger: const Text('Open Menu'),
                  items: [
                    GlassMenuItem(
                      title: 'Option',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Option'), findsOneWidget);

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
    expect(find.text('Option'), findsNothing);
    expect(find.text('External Route'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassMenu dismisses instantly when route with zero duration is pushed while open',
      (tester) async {
    late BuildContext homeContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            homeContext = context;
            return Scaffold(
              body: Center(
                child: GlassMenu(
                  trigger: const Text('Open Menu'),
                  items: [
                    GlassMenuItem(
                      title: 'Option',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Option'), findsOneWidget);

    Navigator.of(homeContext).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Zero Duration Route')),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Option'), findsNothing);
    expect(find.text('Zero Duration Route'), findsOneWidget);
  });

  testWidgets(
      'GlassMenu dismisses instantly when containing route is popped while open',
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
                        child: GlassMenu(
                          trigger: const Text('Open SubMenu'),
                          items: [
                            GlassMenuItem(
                              title: 'Sub Option',
                              onTap: () {},
                            ),
                          ],
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

    // Open menu on second route
    await tester.tap(find.text('Open SubMenu'));
    await tester.pumpAndSettle();
    expect(find.text('Sub Option'), findsOneWidget);

    // Pop the containing route
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();

    // First frame of pop
    await tester.pump();
    expect(find.text('Sub Option'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Go to Second'), findsOneWidget);
  });

  testWidgets(
      'GlassMenu dismisses instantly when route is pushed on ancestor Navigator (#274 nested navigator)',
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
                    child: GlassMenu(
                      trigger: const Text('Open Menu'),
                      items: [
                        GlassMenuItem(
                          title: 'Start Activity',
                          onTap: () {
                            shellNavigatorKey.currentState!.push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => const Scaffold(
                                  body: Center(child: Text('Destination page')),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
    await tester.tap(find.text('Open Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Start Activity'), findsOneWidget);

    await tester.tap(find.text('Start Activity'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Mid-transition into Destination page on the ancestor navigator,
    // the menu should already be dismissed and not lingering in root overlay.
    expect(find.text('Destination page'), findsOneWidget);
    expect(find.text('Start Activity'), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassMenuItem does not throw RenderFlex overflow when constrained to narrow width',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 59.9,
              child: GlassMenuItem(
                icon: const Icon(Icons.share),
                title: 'Share',
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(GlassMenuItem), findsOneWidget);
  });

  testWidgets(
      'GlassMenu opening morph with icons and default menuWidth does not overflow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Open'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(
                  icon: const Icon(Icons.share),
                  title: 'Option A',
                  onTap: () {},
                ),
                GlassMenuItem(
                  icon: const Icon(Icons.edit),
                  title: 'Option B',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    // Pump through morph animation frame by frame
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(find.text('Option A'), findsOneWidget);
    expect(find.text('Option B'), findsOneWidget);
  });

  // ── Trigger soft-detach opacity ───────────────────────────────────────────

  testWidgets('Trigger opacity is 1.0 before menu opens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // Before tapping: the trigger must be fully opaque.
    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, equals(1.0));
  });

  testWidgets('Trigger dissolves cleanly to 0.0 when menu is fully open',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    // When fully open, the trigger must be cleanly dissolved (opacity 0.0)
    // so there is no ghost button or visual artifact under/behind the menu.
    final opacityWidgets = tester.widgetList<Opacity>(find.byType(Opacity));
    final triggerOpacity = opacityWidgets.first.opacity;
    expect(
      triggerOpacity,
      equals(0.0),
      reason:
          'Trigger should be fully dissolved when menu is open (clean detach)',
    );
  });

  testWidgets('Trigger opacity returns to 1.0 after menu fully closes',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();
    // Close by tapping again.
    await tester.tap(find.text('Btn'), warnIfMissed: false);
    await tester.pumpAndSettle();

    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, equals(1.0));
  });

  testWidgets(
      'GlassMenu on standard quality renders only single GlassContainer on close (no Blob A ghost)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              quality: GlassQuality.standard,
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    // Trigger close
    await tester.tap(find.text('Item'));
    // Pump partially into the close animation (e.g. 50ms)
    await tester.pump(const Duration(milliseconds: 50));

    // Under standard quality, Blob A is suppressed during close to prevent double-button overlap.
    // There should be exactly 1 GlassContainer inside the overlay (Blob B, the collapsing menu body).
    final overlayContainers = find.descendant(
      of: find.byType(AdaptiveLiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(overlayContainers, findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassMenu on minimal quality renders only single GlassContainer on close (no Blob A ghost)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              quality: GlassQuality.minimal,
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Item'));
    await tester.pump(const Duration(milliseconds: 50));

    final overlayContainers = find.descendant(
      of: find.byType(AdaptiveLiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(overlayContainers, findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassMenu with platformViewBackdrop: true suppresses Blob A on close even with premium quality',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              quality: GlassQuality.premium,
              platformViewBackdrop: true,
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Item'));
    await tester.pump(const Duration(milliseconds: 50));

    final overlayContainers = find.descendant(
      of: find.byType(AdaptiveLiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(overlayContainers, findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassMenu renders Blob A trigger ghost during opening morph (liquid bridge preserved on open)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              quality: GlassQuality.standard,
              trigger: const SizedBox(
                width: 44,
                height: 44,
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    // Pump partially into the opening animation where anchorScale > 0
    await tester.pump(const Duration(milliseconds: 30));

    // On open, both Blob A (trigger ghost) and Blob B (menu body) must be present
    final overlayContainers = find.descendant(
      of: find.byType(AdaptiveLiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(overlayContainers, findsNWidgets(2));

    await tester.pumpAndSettle();
  });

  testWidgets(
      'GlassMenu on standard quality lerps border radius toward trigger border radius during close',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              quality: GlassQuality.standard,
              menuBorderRadius: 24.0,
              trigger: const SizedBox(
                width: 40,
                height: 20, // trigger shortest side / 2 = 10.0
                child: Text('Btn'),
              ),
              menuWidth: 200,
              items: [
                GlassMenuItem(title: 'Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Btn'));
    await tester.pumpAndSettle();

    // Start close
    await tester.tap(find.text('Item'));
    // Pump into close travel
    await tester.pump(const Duration(milliseconds: 100));

    final containerFinder = find.descendant(
      of: find.byType(AdaptiveLiquidGlassLayer),
      matching: find.byType(GlassContainer),
    );
    expect(containerFinder, findsOneWidget);

    final container = tester.widget<GlassContainer>(containerFinder);
    final shape = container.shape as LiquidRoundedRectangle;
    // On standard quality, border radius lerps between trigger radius (10.0) and menuBorderRadius (24.0)
    // rather than locking to full capsule rounding (which would be min(width, height)/2 >= 40.0)
    expect(shape.borderRadius, lessThanOrEqualTo(24.0));
    expect(shape.borderRadius, greaterThanOrEqualTo(10.0));

    await tester.pumpAndSettle();
  });

  group('non-scrollable menu row activation', () {
    Future<(GlassMenuController, List<String>)> openMenu(
        WidgetTester tester) async {
      final controller = GlassMenuController();
      final tapped = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 40,
                  top: 80,
                  child: GlassMenu(
                    controller: controller,
                    menuAlignment: GlassMenuAlignment.topLeft,
                    trigger: const SizedBox(width: 8, height: 8),
                    items: [
                      GlassMenuItem(
                          title: 'Copy', onTap: () => tapped.add('Copy')),
                      GlassMenuItem(
                          title: 'Cut', onTap: () => tapped.add('Cut')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();
      return (controller, tapped);
    }

    testWidgets('a screen-reader tap activates the row', (tester) async {
      final semantics = tester.ensureSemantics();
      final (controller, tapped) = await openMenu(tester);

      final node = tester.getSemantics(find.bySemanticsLabel('Copy').first);
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pumpAndSettle();

      expect(tapped, ['Copy']);
      expect(controller.isOpen, isFalse);
      semantics.dispose();
    });

    testWidgets('Enter on a focused row activates it', (tester) async {
      final (controller, tapped) = await openMenu(tester);

      Focus.of(tester.element(find.text('Copy'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(tapped, ['Copy']);
      expect(controller.isOpen, isFalse);
    });

    testWidgets('a touch tap still activates the row exactly once',
        (tester) async {
      final (_, tapped) = await openMenu(tester);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(tapped, ['Copy']);
    });
  });

  testWidgets(
      'a slide-to-select released over the gap between two rows activates a '
      'row', (tester) async {
    final controller = GlassMenuController();
    final tapped = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                left: 40,
                top: 80,
                child: GlassMenu(
                  controller: controller,
                  menuAlignment: GlassMenuAlignment.topLeft,
                  trigger: const SizedBox(width: 8, height: 8),
                  items: [
                    GlassMenuItem(
                        title: 'Copy', onTap: () => tapped.add('Copy')),
                    GlassMenuItem(title: 'Cut', onTap: () => tapped.add('Cut')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    controller.open();
    await tester.pumpAndSettle();

    // Rows are separated by a 2px gap; just below the midpoint between the
    // two row centres lies inside it.
    final copy = tester.getCenter(find.text('Copy'));
    final cut = tester.getCenter(find.text('Cut'));
    final gesture = await tester.startGesture(copy);
    await tester.pump();
    await gesture.moveTo(cut);
    await tester.pump();
    await gesture.moveTo(Offset(copy.dx, (copy.dy + cut.dy) / 2 + 0.5));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tapped, hasLength(1));
    expect(controller.isOpen, isFalse);
  });
}
