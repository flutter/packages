import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_scaffold/src/breakpoints.dart';
import 'package:flutter_adaptive_scaffold/src/slot_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'SlotLayout displays correct widget based on screen width',
    (WidgetTester tester) async {
      MediaQuery slot(double width) {
        return MediaQuery(
          data: MediaQueryData(size: Size(width, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                TestBreakpoint0(): SlotLayout.from(
                    key: const Key('0'), builder: (_) => const Text('Small')),
                TestBreakpoint400(): SlotLayout.from(
                    key: const Key('400'),
                    builder: (_) => const Text('Medium')),
                TestBreakpoint800(): SlotLayout.from(
                    key: const Key('800'), builder: (_) => const Text('Large')),
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(slot(300));
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Large'), findsNothing);

      await tester.pumpWidget(slot(500));
      expect(find.text('Small'), findsNothing);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsNothing);

      await tester.pumpWidget(slot(1000));
      expect(find.text('Small'), findsNothing);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Large'), findsOneWidget);
    },
  );

  testWidgets(
    'SlotLayout applies custom animations and durations correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(500, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                TestBreakpoint0(): SlotLayout.from(
                  key: const Key('0'),
                  builder: (_) => const SizedBox(width: 100, height: 100),
                  inAnimation: (Widget widget, Animation<double> animation) =>
                      ScaleTransition(
                    scale: animation,
                    child: widget,
                  ),
                  outAnimation: (Widget widget, Animation<double> animation) =>
                      FadeTransition(
                    opacity: animation,
                    child: widget,
                  ),
                  inDuration: const Duration(seconds: 1),
                  outDuration: const Duration(seconds: 2),
                  inCurve: Curves.easeIn,
                  outCurve: Curves.easeOut,
                ),
              },
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      // Verify that the animations are applied
      final ScaleTransition scaleTransition =
          tester.widget(find.byType(ScaleTransition));

      // TODO: Fix this test
      // final FadeTransition fadeTransition =
      //    tester.widget(find.byType(FadeTransition));

      expect(scaleTransition.scale.value, equals(1.0));
      //expect(fadeTransition.opacity.value, equals(1.0));
    },
  );

  testWidgets(
    'SlotLayout handles null configurations gracefully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(tester.view)
              .copyWith(size: const Size(500, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig?>{
                TestBreakpoint0(): SlotLayout.from(
                  key: const Key('0'),
                  builder: (BuildContext context) => Container(),
                ),
                TestBreakpoint400(): null,
                TestBreakpoint800(): SlotLayout.from(
                  key: const Key('800'),
                  builder: (BuildContext context) => Container(),
                ),
              },
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('0')), findsOneWidget);
      expect(find.byKey(const Key('400')), findsNothing);
      expect(find.byKey(const Key('800')), findsNothing);
    },
  );

  testWidgets(
    'SlotLayout builder generates widgets correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(500, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                TestBreakpoint0(): SlotLayout.from(
                    key: const Key('0'),
                    builder: (_) => const Text('Builder Test')),
              },
            ),
          ),
        ),
      );

      expect(find.text('Builder Test'), findsOneWidget);
    },
  );
}

class TestBreakpoint0 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 0;
  }
}

class TestBreakpoint400 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width > 400;
  }
}

class TestBreakpoint800 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }
}
