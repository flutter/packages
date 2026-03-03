// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('transitions in a new child.', (WidgetTester tester) async {
    final containerOne = UniqueKey();
    final containerTwo = UniqueKey();
    final containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: containerOne, color: const Color(0x00000000)),
      ),
    );

    Map<Key, double> primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
    ], tester);
    Map<Key, double> secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
    ], tester);
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerOne], equals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: containerTwo, color: const Color(0xff000000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    // Secondary is running for outgoing widget.
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerOne], moreOrLessEquals(0.4));
    // Primary is running for incoming widget.
    expect(primaryAnimation[containerTwo], moreOrLessEquals(0.4));
    expect(secondaryAnimation[containerTwo], equals(0.0));

    // Container one is underneath container two
    final Container container = tester.firstWidget(find.byType(Container));
    expect(container.key, containerOne);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: containerThree, color: const Color(0xffff0000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerOne], equals(0.6));
    expect(primaryAnimation[containerTwo], equals(0.6));
    expect(secondaryAnimation[containerTwo], moreOrLessEquals(0.2));
    expect(primaryAnimation[containerThree], moreOrLessEquals(0.2));
    expect(secondaryAnimation[containerThree], equals(0.0));
    await tester.pumpAndSettle();
  });

  testWidgets('transitions in a new child in reverse.', (
    WidgetTester tester,
  ) async {
    final containerOne = UniqueKey();
    final containerTwo = UniqueKey();
    final containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        reverse: true,
        child: Container(key: containerOne, color: const Color(0x00000000)),
      ),
    );

    Map<Key, double> primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
    ], tester);
    Map<Key, double> secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
    ], tester);
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerOne], equals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        reverse: true,
        child: Container(key: containerTwo, color: const Color(0xff000000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    // Primary is running forward for outgoing widget.
    expect(primaryAnimation[containerOne], moreOrLessEquals(0.6));
    expect(secondaryAnimation[containerOne], equals(0.0));
    // Secondary is running forward for incoming widget.
    expect(primaryAnimation[containerTwo], equals(1.0));
    expect(secondaryAnimation[containerTwo], moreOrLessEquals(0.6));

    // Container two two is underneath container one.
    final Container container = tester.firstWidget(find.byType(Container));
    expect(container.key, containerTwo);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        reverse: true,
        child: Container(key: containerThree, color: const Color(0xffff0000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    expect(primaryAnimation[containerOne], equals(0.4));
    expect(secondaryAnimation[containerOne], equals(0.0));
    expect(primaryAnimation[containerTwo], equals(0.8));
    expect(secondaryAnimation[containerTwo], equals(0.4));
    expect(primaryAnimation[containerThree], equals(1.0));
    expect(secondaryAnimation[containerThree], equals(0.8));
    await tester.pumpAndSettle();
  });

  testWidgets('switch from forward to reverse', (WidgetTester tester) async {
    final containerOne = UniqueKey();
    final containerTwo = UniqueKey();
    final containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: containerOne, color: const Color(0x00000000)),
      ),
    );

    Map<Key, double> primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
    ], tester);
    Map<Key, double> secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
    ], tester);
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerOne], equals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: containerTwo, color: const Color(0xff000000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    expect(secondaryAnimation[containerOne], moreOrLessEquals(0.4));
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerTwo], equals(0.0));
    expect(primaryAnimation[containerTwo], moreOrLessEquals(0.4));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        reverse: true,
        child: Container(key: containerThree, color: const Color(0xffff0000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    expect(secondaryAnimation[containerOne], equals(0.6));
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerTwo], equals(0.0));
    expect(primaryAnimation[containerTwo], moreOrLessEquals(0.2));
    expect(secondaryAnimation[containerThree], equals(0.8));
    expect(primaryAnimation[containerThree], equals(1.0));
    await tester.pumpAndSettle();
  });

  testWidgets('switch from reverse to forward.', (WidgetTester tester) async {
    final containerOne = UniqueKey();
    final containerTwo = UniqueKey();
    final containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        reverse: true,
        child: Container(key: containerOne, color: const Color(0x00000000)),
      ),
    );

    Map<Key, double> primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
    ], tester);
    Map<Key, double> secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
    ], tester);
    expect(primaryAnimation[containerOne], equals(1.0));
    expect(secondaryAnimation[containerOne], equals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        reverse: true,
        child: Container(key: containerTwo, color: const Color(0xff000000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
    ], tester);
    // Primary is running in reverse for outgoing widget.
    expect(primaryAnimation[containerOne], moreOrLessEquals(0.6));
    expect(secondaryAnimation[containerOne], equals(0.0));
    // Secondary is running in reverse for incoming widget.
    expect(primaryAnimation[containerTwo], equals(1.0));
    expect(secondaryAnimation[containerTwo], moreOrLessEquals(0.6));

    // Container two is underneath container one.
    final Container container = tester.firstWidget(find.byType(Container));
    expect(container.key, containerTwo);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: containerThree, color: const Color(0xffff0000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    // Container one is expected to continue running its primary animation in
    // reverse since it is exiting. Container two's secondary animation switches
    // from running its secondary animation in reverse to running forwards since
    // it should now be exiting underneath container three. Container three's
    // primary animation should be running forwards since it is entering above
    // container two.
    primaryAnimation = _getPrimaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      containerOne,
      containerTwo,
      containerThree,
    ], tester);
    expect(primaryAnimation[containerOne], equals(0.4));
    expect(secondaryAnimation[containerOne], equals(0.0));
    expect(primaryAnimation[containerTwo], equals(1.0));
    expect(secondaryAnimation[containerTwo], equals(0.8));
    expect(primaryAnimation[containerThree], moreOrLessEquals(0.2));
    expect(secondaryAnimation[containerThree], equals(0.0));
    await tester.pumpAndSettle();
  });

  testWidgets('using custom layout', (WidgetTester tester) async {
    Widget newLayoutBuilder(List<Widget> activeEntries) {
      return Column(children: activeEntries);
    }

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        layoutBuilder: newLayoutBuilder,
        child: Container(color: const Color(0x00000000)),
      ),
    );

    expect(find.byType(Column), findsOneWidget);
  });

  testWidgets("doesn't transition in a new child of the same type.", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(color: const Color(0x00000000)),
      ),
    );

    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(ScaleTransition), findsOneWidget);
    FadeTransition fade = tester.firstWidget(find.byType(FadeTransition));
    ScaleTransition scale = tester.firstWidget(find.byType(ScaleTransition));
    expect(fade.opacity.value, equals(1.0));
    expect(scale.scale.value, equals(1.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(color: const Color(0xff000000)),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(ScaleTransition), findsOneWidget);
    fade = tester.firstWidget(find.byType(FadeTransition));
    scale = tester.firstWidget(find.byType(ScaleTransition));
    expect(fade.opacity.value, equals(1.0));
    expect(scale.scale.value, equals(1.0));
    await tester.pumpAndSettle();
  });

  testWidgets('handles null children.', (WidgetTester tester) async {
    await tester.pumpWidget(
      const PageTransitionSwitcher(
        duration: Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
      ),
    );

    expect(find.byType(FadeTransition), findsNothing);
    expect(find.byType(ScaleTransition), findsNothing);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(color: const Color(0xff000000)),
      ),
    );

    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(ScaleTransition), findsOneWidget);
    FadeTransition fade = tester.firstWidget(find.byType(FadeTransition));
    ScaleTransition scale = tester.firstWidget(find.byType(ScaleTransition));
    expect(fade.opacity.value, equals(1.0));
    expect(scale.scale.value, moreOrLessEquals(0.4));
    await tester.pumpAndSettle(); // finish transitions.

    await tester.pumpWidget(
      const PageTransitionSwitcher(
        duration: Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(ScaleTransition), findsOneWidget);
    fade = tester.firstWidget(find.byType(FadeTransition));
    scale = tester.firstWidget(find.byType(ScaleTransition));
    expect(fade.opacity.value, equals(0.5));
    expect(scale.scale.value, equals(1.0));
    await tester.pumpAndSettle();
  });

  testWidgets("doesn't start any animations after dispose.", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: UniqueKey(), color: const Color(0xff000000)),
      ),
    );

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: Container(key: UniqueKey(), color: const Color(0xff000000)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(FadeTransition), findsNWidgets(2));
    expect(find.byType(ScaleTransition), findsNWidgets(2));
    final FadeTransition fade = tester.firstWidget(find.byType(FadeTransition));
    final ScaleTransition scale = tester.firstWidget(
      find.byType(ScaleTransition),
    );
    expect(fade.opacity.value, equals(0.5));
    expect(scale.scale.value, equals(1.0));

    // Change the widget tree in the middle of the animation.
    await tester.pumpWidget(Container(color: const Color(0xffff0000)));
    expect(await tester.pumpAndSettle(), equals(1));
  });

  testWidgets("doesn't reset state of the children in transitions.", (
    WidgetTester tester,
  ) async {
    final statefulOne = UniqueKey();
    final statefulTwo = UniqueKey();
    final statefulThree = UniqueKey();

    StatefulTestWidgetState.generation = 0;

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: StatefulTestWidget(key: statefulOne),
      ),
    );

    Map<Key, double> primaryAnimation = _getPrimaryAnimation(<Key>[
      statefulOne,
    ], tester);
    Map<Key, double> secondaryAnimation = _getSecondaryAnimation(<Key>[
      statefulOne,
    ], tester);
    expect(primaryAnimation[statefulOne], equals(1.0));
    expect(secondaryAnimation[statefulOne], equals(0.0));
    expect(StatefulTestWidgetState.generation, equals(1));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: StatefulTestWidget(key: statefulTwo),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(FadeTransition), findsNWidgets(2));
    primaryAnimation = _getPrimaryAnimation(<Key>[
      statefulOne,
      statefulTwo,
    ], tester);
    secondaryAnimation = _getSecondaryAnimation(<Key>[
      statefulOne,
      statefulTwo,
    ], tester);
    expect(primaryAnimation[statefulTwo], equals(0.5));
    expect(secondaryAnimation[statefulTwo], equals(0.0));
    expect(StatefulTestWidgetState.generation, equals(2));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: _transitionBuilder,
        child: StatefulTestWidget(key: statefulThree),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));
    expect(StatefulTestWidgetState.generation, equals(3));
    await tester.pumpAndSettle();
    expect(StatefulTestWidgetState.generation, equals(3));
  });

  testWidgets('updates widgets without animating if they are isomorphic.', (
    WidgetTester tester,
  ) async {
    Future<void> pumpChild(Widget child) async {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: _transitionBuilder,
            child: child,
          ),
        ),
      );
    }

    await pumpChild(const Text('1'));
    await tester.pump(const Duration(milliseconds: 10));
    FadeTransition fade = tester.widget(find.byType(FadeTransition));
    ScaleTransition scale = tester.widget(find.byType(ScaleTransition));
    expect(fade.opacity.value, equals(1.0));
    expect(scale.scale.value, equals(1.0));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);
    await pumpChild(const Text('2'));
    fade = tester.widget(find.byType(FadeTransition));
    scale = tester.widget(find.byType(ScaleTransition));
    await tester.pump(const Duration(milliseconds: 20));
    expect(fade.opacity.value, equals(1.0));
    expect(scale.scale.value, equals(1.0));
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
    'updates previous child transitions if the transitionBuilder changes.',
    (WidgetTester tester) async {
      final containerOne = UniqueKey();
      final containerTwo = UniqueKey();
      final containerThree = UniqueKey();

      // Insert three unique children so that we have some previous children.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: _transitionBuilder,
            child: Container(key: containerOne, color: const Color(0xFFFF0000)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 10));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: _transitionBuilder,
            child: Container(key: containerTwo, color: const Color(0xFF00FF00)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 10));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: _transitionBuilder,
            child: Container(
              key: containerThree,
              color: const Color(0xFF0000FF),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 10));

      expect(find.byType(FadeTransition), findsNWidgets(3));
      expect(find.byType(ScaleTransition), findsNWidgets(3));
      expect(find.byType(SlideTransition), findsNothing);
      expect(find.byType(SizeTransition), findsNothing);

      Widget newTransitionBuilder(
        Widget child,
        Animation<double> primary,
        Animation<double> secondary,
      ) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(20, 30),
          ).animate(primary),
          child: SizeTransition(
            sizeFactor: Tween<double>(begin: 10, end: 0.0).animate(secondary),
            child: child,
          ),
        );
      }

      // Now set a new transition builder and make sure all the previous
      // transitions are replaced.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: newTransitionBuilder,
            child: Container(
              key: containerThree,
              color: const Color(0x00000000),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 10));

      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(ScaleTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNWidgets(3));
      expect(find.byType(SizeTransition), findsNWidgets(3));
    },
  );
}

class StatefulTestWidget extends StatefulWidget {
  const StatefulTestWidget({super.key});

  @override
  StatefulTestWidgetState createState() => StatefulTestWidgetState();
}

class StatefulTestWidgetState extends State<StatefulTestWidget> {
  StatefulTestWidgetState();
  static int generation = 0;

  @override
  void initState() {
    super.initState();
    generation++;
  }

  @override
  Widget build(BuildContext context) => Container();
}

Widget _transitionBuilder(
  Widget child,
  Animation<double> primary,
  Animation<double> secondary,
) {
  return ScaleTransition(
    scale: Tween<double>(begin: 0.0, end: 1.0).animate(primary),
    child: FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(secondary),
      child: child,
    ),
  );
}

Map<Key, double> _getSecondaryAnimation(List<Key> keys, WidgetTester tester) {
  expect(find.byType(FadeTransition), findsNWidgets(keys.length));
  final result = <Key, double>{};
  for (final key in keys) {
    final FadeTransition transition = tester.firstWidget(
      find.ancestor(of: find.byKey(key), matching: find.byType(FadeTransition)),
    );
    result[key] = 1.0 - transition.opacity.value;
  }
  return result;
}

Map<Key, double> _getPrimaryAnimation(List<Key> keys, WidgetTester tester) {
  expect(find.byType(ScaleTransition), findsNWidgets(keys.length));
  final result = <Key, double>{};
  for (final key in keys) {
    final ScaleTransition transition = tester.firstWidget(
      find.ancestor(
        of: find.byKey(key),
        matching: find.byType(ScaleTransition),
      ),
    );
    result[key] = transition.scale.value;
  }
  return result;
}
