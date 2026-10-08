import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: child,
      ),
    ),
  );
}

void main() {
  group('GlassMenu Continuous Swipe-to-Select (#331)', () {
    testWidgets(
        'Continuous swipe selects item 0 on drag and release without lifting finger',
        (tester) async {
      bool item0Tapped = false;
      bool item1Tapped = false;

      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            enableContinuousSwipe: true,
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Open Menu'),
            ),
            items: [
              GlassMenuItem(
                title: 'First Item',
                onTap: () => item0Tapped = true,
              ),
              GlassMenuItem(
                title: 'Second Item',
                onTap: () => item1Tapped = true,
              ),
            ],
          ),
        ),
      );

      // Press down on the trigger button.
      final triggerCenter = tester.getCenter(find.text('Open Menu'));
      final gesture = await tester.startGesture(triggerCenter);

      // Morph animation blooms.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('First Item'), findsOneWidget);

      // Slide finger down across into First Item.
      final item0Center = tester.getCenter(find.text('First Item'));
      await gesture.moveTo(item0Center);
      await tester.pump();

      // Release finger over First Item.
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify item 0 was activated and menu closed.
      expect(item0Tapped, isTrue);
      expect(item1Tapped, isFalse);
      expect(find.text('First Item'), findsNothing);
    });

    testWidgets('Continuous swipe selects item 1 when dragged further down',
        (tester) async {
      bool item0Tapped = false;
      bool item1Tapped = false;

      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            enableContinuousSwipe: true,
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Open Menu'),
            ),
            items: [
              GlassMenuItem(
                title: 'First Item',
                onTap: () => item0Tapped = true,
              ),
              GlassMenuItem(
                title: 'Second Item',
                onTap: () => item1Tapped = true,
              ),
            ],
          ),
        ),
      );

      final triggerCenter = tester.getCenter(find.text('Open Menu'));
      final gesture = await tester.startGesture(triggerCenter);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final item1Center = tester.getCenter(find.text('Second Item'));
      await gesture.moveTo(item1Center);
      await tester.pump();

      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(item0Tapped, isFalse);
      expect(item1Tapped, isTrue);
      expect(find.text('Second Item'), findsNothing);
    });

    testWidgets(
        'Deadband tap mode: releasing within continuousSwipeSlop leaves menu open',
        (tester) async {
      bool item0Tapped = false;

      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            enableContinuousSwipe: true,
            continuousSwipeSlop: 10.0,
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Open Menu'),
            ),
            items: [
              GlassMenuItem(
                title: 'First Item',
                onTap: () => item0Tapped = true,
              ),
            ],
          ),
        ),
      );

      final triggerCenter = tester.getCenter(find.text('Open Menu'));
      final gesture = await tester.startGesture(triggerCenter);

      // Only move by 4 pixels (within 10px slop).
      await gesture.moveBy(const Offset(0, 4));
      await tester.pump();

      // Release finger within deadband.
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      // Menu must remain open, item must not be tapped.
      expect(item0Tapped, isFalse);
      expect(find.text('First Item'), findsOneWidget);
    });

    testWidgets(
        'Continuous swipe dragging far outside dismisses menu without selecting',
        (tester) async {
      bool item0Tapped = false;
      int closeCalls = 0;

      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            enableContinuousSwipe: true,
            onClose: () => closeCalls++,
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Open Menu'),
            ),
            items: [
              GlassMenuItem(
                title: 'First Item',
                onTap: () => item0Tapped = true,
              ),
            ],
          ),
        ),
      );

      final triggerCenter = tester.getCenter(find.text('Open Menu'));
      final gesture = await tester.startGesture(triggerCenter);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag 300px far away to the right.
      await gesture.moveTo(triggerCenter + const Offset(300, 0));
      await tester.pump();

      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(item0Tapped, isFalse);
      expect(closeCalls, 1);
      expect(find.text('First Item'), findsNothing);
    });

    testWidgets(
        'Continuous swipe over disabled item does not activate and dismisses',
        (tester) async {
      bool itemTapped = false;

      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            enableContinuousSwipe: true,
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Open Menu'),
            ),
            items: [
              GlassMenuItem(
                title: 'Disabled Item',
                enabled: false,
                onTap: () => itemTapped = true,
              ),
            ],
          ),
        ),
      );

      final triggerCenter = tester.getCenter(find.text('Open Menu'));
      final gesture = await tester.startGesture(triggerCenter);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final itemCenter = tester.getCenter(find.text('Disabled Item'));
      await gesture.moveTo(itemCenter);
      await tester.pump();

      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(itemTapped, isFalse);
      expect(find.text('Disabled Item'), findsNothing);
    });

    testWidgets('Continuous swipe pointer cancel dismisses menu cleanly',
        (tester) async {
      bool itemTapped = false;
      int closeCalls = 0;

      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            enableContinuousSwipe: true,
            onClose: () => closeCalls++,
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Open Menu'),
            ),
            items: [
              GlassMenuItem(
                title: 'Item',
                onTap: () => itemTapped = true,
              ),
            ],
          ),
        ),
      );

      final triggerCenter = tester.getCenter(find.text('Open Menu'));
      final gesture = await tester.startGesture(triggerCenter);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      await gesture.cancel();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(itemTapped, isFalse);
      expect(closeCalls, 1);
      expect(find.text('Item'), findsNothing);
    });

    testWidgets(
        'GlassPullDownButton defaults to enableContinuousSwipe=true and triggers onSelected',
        (tester) async {
      bool itemTapped = false;
      String? selectedTitle;

      await tester.pumpWidget(
        _wrap(
          GlassPullDownButton(
            onSelected: (title) => selectedTitle = title,
            items: [
              GlassMenuItem(
                title: 'Option A',
                onTap: () => itemTapped = true,
              ),
            ],
          ),
        ),
      );

      final buttonCenter = tester.getCenter(find.byType(GlassPullDownButton));
      final gesture = await tester.startGesture(buttonCenter);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Option A'), findsOneWidget);

      final optionCenter = tester.getCenter(find.text('Option A'));
      await gesture.moveTo(optionCenter);
      await tester.pump();

      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(itemTapped, isTrue);
      expect(selectedTitle, 'Option A');
      expect(find.text('Option A'), findsNothing);
    });

    testWidgets(
        'Default GlassMenu (enableContinuousSwipe=false) does not open on pointer-down',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Tap Only'),
            ),
            items: [
              GlassMenuItem(
                title: 'Item',
                onTap: () {},
              ),
            ],
          ),
        ),
      );

      final triggerCenter = tester.getCenter(find.text('Tap Only'));
      final gesture = await tester.startGesture(triggerCenter);

      // Pointer is down, but menu should NOT be open yet since enableContinuousSwipe is false.
      await tester.pump();
      expect(find.text('Item'), findsNothing);

      // On tap up, menu opens.
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);
    });

    testWidgets(
        'Scrollable menu + enableContinuousSwipe: swipe does not arm, menu stays open on release',
        (tester) async {
      bool itemTapped = false;

      // menuHeight: 60 with 5 items forces a scrollable menu.
      await tester.pumpWidget(
        _wrap(
          GlassMenu(
            enableContinuousSwipe: true,
            menuHeight: 60,
            trigger: const SizedBox(
              width: 100,
              height: 44,
              child: Text('Scrollable Menu'),
            ),
            items: List.generate(
              5,
              (i) => GlassMenuItem(
                title: 'Item $i',
                onTap: () => itemTapped = true,
              ),
            ),
          ),
        ),
      );

      final triggerCenter = tester.getCenter(find.text('Scrollable Menu'));
      final gesture = await tester.startGesture(triggerCenter);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Swipe far beyond the slop — should NOT arm on a scrollable menu.
      await gesture.moveBy(const Offset(0, 80));
      await tester.pump();

      // Release: menu must still be open, no item activated.
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(itemTapped, isFalse);
      // Menu stays open (deadband release path because _swipeArmed was never set).
      expect(find.text('Item 0'), findsOneWidget);
    });
  });
}
