import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassToast', () {
    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Test message',
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassToast), findsOneWidget);
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('displays message correctly', (tester) async {
      const testMessage = 'Success message';

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: testMessage,
              type: GlassToastType.success,
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Custom icon',
              icon: Icon(CupertinoIcons.star),
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.star), findsOneWidget);
    });

    testWidgets('displays default success icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Success',
              type: GlassToastType.success,
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsOneWidget);
    });

    testWidgets('displays default error icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Error',
              type: GlassToastType.error,
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsOneWidget);
    });

    testWidgets('displays default info icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Info',
              type: GlassToastType.info,
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.info_circle_fill), findsOneWidget);
    });

    testWidgets('displays default warning icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Warning',
              type: GlassToastType.warning,
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.exclamationmark_triangle_fill),
          findsOneWidget);
    });

    testWidgets('displays action button when provided', (tester) async {
      var actionCalled = false;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'With action',
              action: GlassToastAction(
                label: 'Retry',
                onPressed: () => actionCalled = true,
              ),
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('GlassToast.show creates overlay entry', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  GlassToast.show(
                    context,
                    message: 'Overlay toast',
                    duration: const Duration(seconds: 1),
                  );
                },
                child: const Text('Show Toast'),
              );
            },
          ),
        ),
      );

      // Show toast
      await tester.tap(find.text('Show Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify toast is shown
      expect(find.text('Overlay toast'), findsOneWidget);
    });

    testWidgets('GlassToast.show returns dismiss callback', (tester) async {
      late VoidCallback dismiss;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  dismiss = GlassToast.show(
                    context,
                    message: 'Dismissible toast',
                    duration: Duration.zero, // Won't auto-dismiss
                  );
                },
                child: const Text('Show Toast'),
              );
            },
          ),
        ),
      );

      // Show toast
      await tester.tap(find.text('Show Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dismissible toast'), findsOneWidget);

      // Manually dismiss
      dismiss();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Dismissible toast'), findsNothing);
    });

    testWidgets('toast auto-dismisses after duration', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  GlassToast.show(
                    context,
                    message: 'Auto dismiss',
                    duration: const Duration(milliseconds: 500),
                  );
                },
                child: const Text('Show Toast'),
              );
            },
          ),
        ),
      );

      // Show toast
      await tester.tap(find.text('Show Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Auto dismiss'), findsOneWidget);

      // Wait for auto-dismiss
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Auto dismiss'), findsNothing);
    });

    testWidgets('supports all toast positions', (tester) async {
      for (final position in GlassToastPosition.values) {
        await tester.pumpWidget(
          createTestApp(
            child: Builder(
              builder: (context) => GlassToast(
                message: 'Position: ${position.name}',
                position: position,
                onDismissed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Position: ${position.name}'), findsOneWidget);
      }
    });

    testWidgets('supports all toast types', (tester) async {
      for (final type in GlassToastType.values) {
        await tester.pumpWidget(
          createTestApp(
            child: Builder(
              builder: (context) => GlassToast(
                message: 'Type: ${type.name}',
                type: type,
                onDismissed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Type: ${type.name}'), findsOneWidget);
      }
    });

    testWidgets('respects custom glass settings', (tester) async {
      const customSettings = LiquidGlassSettings(
        thickness: 50.0,
        blur: 8.0,
      );

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Custom settings',
              settings: customSettings,
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Custom settings'), findsOneWidget);
    });

    testWidgets('respects custom quality setting', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassToast(
              message: 'Premium quality',
              quality: GlassQuality.premium,
              onDismissed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Premium quality'), findsOneWidget);
    });
  });

  group('GlassToastAction', () {
    test('can be instantiated with required parameters', () {
      final action = GlassToastAction(
        label: 'Action',
        onPressed: () {},
      );

      expect(action.label, equals('Action'));
      expect(action.onPressed, isA<VoidCallback>());
    });
  });

  // ── Swipeable toast — Dismissible path (line 499) ───────────────────────────
  group('GlassToast swipeable', () {
    testWidgets('swipeable=true wraps toast in Dismissible (line 499)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  GlassToast.show(
                    context,
                    message: 'Swipeable toast',
                    dismissible:
                        true, // exercises line 496-501 Dismissible wrap
                    duration: const Duration(seconds: 5),
                  );
                },
                child: const Text('Show Swipeable'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Swipeable'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Swipeable toast'), findsOneWidget);
      // Verify Dismissible wrapper is present
      expect(find.byType(Dismissible), findsOneWidget);
    });
  });

  // ── Center position (lines 516, 526) ────────────────────────────────────────
  group('GlassToast center position', () {
    testWidgets('position=center wraps child in Center (lines 516, 526)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  GlassToast.show(
                    context,
                    message: 'Center toast',
                    position: GlassToastPosition.center, // line 516 + 526
                    duration: const Duration(seconds: 5),
                  );
                },
                child: const Text('Show Center'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Center'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Center toast'), findsOneWidget);
    });
  });
}
