import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// A controller-driven menu whose trigger sits near the top-left, so the menu
/// (anchored top-left) opens down and to the right, fully on screen.
Widget _host(GlassMenuController controller, List<Widget> items) {
  return MaterialApp(
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
              items: items,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester, GlassMenuController controller) async {
  controller.open();
  await tester.pumpAndSettle();
}

/// Counts selection-click haptics sent to the platform.
int Function() _countSelectionClicks(WidgetTester tester) {
  var clicks = 0;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate' &&
          call.arguments == 'HapticFeedbackType.selectionClick') {
        clicks++;
      }
      return null;
    },
  );
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));
  return () => clicks;
}

void main() {
  group('GlassMenuController glide', () {
    testWidgets(
        'glideTo + endGlide activates exactly the item under the pointer '
        'and closes the menu', (tester) async {
      final controller = GlassMenuController();
      final tapped = <String>[];
      await tester.pumpWidget(_host(controller, [
        GlassMenuItem(title: 'Copy', onTap: () => tapped.add('Copy')),
        GlassMenuItem(title: 'Cut', onTap: () => tapped.add('Cut')),
      ]));
      await _open(tester, controller);

      expect(controller.glideTo(tester.getCenter(find.text('Copy'))), isTrue);
      expect(controller.glideTo(tester.getCenter(find.text('Cut'))), isTrue);
      await tester.pump();
      expect(controller.endGlide(), isTrue);
      await tester.pumpAndSettle();

      expect(tapped, ['Cut']);
      expect(controller.isOpen, isFalse);
    });

    testWidgets('a selection haptic plays each time the highlight moves',
        (tester) async {
      final controller = GlassMenuController();
      await tester.pumpWidget(_host(controller, [
        GlassMenuItem(title: 'Copy', onTap: () {}),
        GlassMenuItem(title: 'Cut', onTap: () {}),
      ]));
      await _open(tester, controller);
      final clicks = _countSelectionClicks(tester);

      final copy = tester.getCenter(find.text('Copy'));
      controller.glideTo(copy);
      controller.glideTo(copy + const Offset(0, 4)); // same item
      expect(clicks(), 1);

      controller.glideTo(tester.getCenter(find.text('Cut')));
      expect(clicks(), 2);
      controller.cancelGlide();
    });

    testWidgets(
        'leaving the menu returns false and drops the highlight, so '
        'endGlide keeps the menu open', (tester) async {
      final controller = GlassMenuController();
      var tapped = false;
      await tester.pumpWidget(_host(controller, [
        GlassMenuItem(title: 'Copy', onTap: () => tapped = true),
      ]));
      await _open(tester, controller);

      expect(controller.glideTo(tester.getCenter(find.text('Copy'))), isTrue);
      expect(controller.glideTo(const Offset(700, 560)), isFalse);
      expect(controller.endGlide(), isFalse);
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
      expect(controller.isOpen, isTrue);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('cancelGlide clears the highlight so endGlide does nothing',
        (tester) async {
      final controller = GlassMenuController();
      var tapped = false;
      await tester.pumpWidget(_host(controller, [
        GlassMenuItem(title: 'Copy', onTap: () => tapped = true),
      ]));
      await _open(tester, controller);

      controller.glideTo(tester.getCenter(find.text('Copy')));
      controller.cancelGlide();
      expect(controller.endGlide(), isFalse);
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
      expect(controller.isOpen, isTrue);
    });

    testWidgets('a disabled item is not activated', (tester) async {
      final controller = GlassMenuController();
      var tapped = false;
      await tester.pumpWidget(_host(controller, [
        GlassMenuItem(
            title: 'Copy', enabled: false, onTap: () => tapped = true),
      ]));
      await _open(tester, controller);

      controller.glideTo(tester.getCenter(find.text('Copy')));
      expect(controller.endGlide(), isFalse);
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
      expect(controller.isOpen, isTrue);
    });

    testWidgets('glide calls are no-ops while the menu is closed',
        (tester) async {
      final controller = GlassMenuController();
      var tapped = false;
      await tester.pumpWidget(_host(controller, [
        GlassMenuItem(title: 'Copy', onTap: () => tapped = true),
      ]));

      expect(controller.glideTo(const Offset(60, 100)), isFalse);
      expect(controller.endGlide(), isFalse);
      controller.cancelGlide();
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
      expect(controller.isOpen, isFalse);
    });

    testWidgets(
        'a long-press outside the menu opens it and slides to an item in '
        'one gesture', (tester) async {
      final controller = GlassMenuController();
      final tapped = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 40,
                  top: 300,
                  child: GestureDetector(
                    onLongPressStart: (_) => controller.open(),
                    onLongPressMoveUpdate: (d) =>
                        controller.glideTo(d.globalPosition),
                    onLongPressEnd: (_) => controller.endGlide(),
                    onLongPressCancel: controller.cancelGlide,
                    child: const SizedBox(
                      width: 120,
                      height: 60,
                      child: Text('Card'),
                    ),
                  ),
                ),
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

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Card')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);

      // The menu never hit-tested this finger; the long-press owns it.
      await gesture.moveTo(tester.getCenter(find.text('Copy')));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.text('Cut')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, ['Cut']);
      expect(controller.isOpen, isFalse);
    });
  });
}
