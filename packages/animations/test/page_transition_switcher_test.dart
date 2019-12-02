// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('transitions in a new child.', (WidgetTester tester) async {
    final UniqueKey containerOne = UniqueKey();
    final UniqueKey containerTwo = UniqueKey();
    final UniqueKey containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerOne, color: const Color(0x00000000)),
        transitionBuilder: _transitionBuilder,
      ),
    );

    Map<Key, double> _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne], tester);
    Map<Key, double> _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne], tester);
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerTwo, color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne, containerTwo], tester);
    _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne, containerTwo], tester);
    // Secondary is running for outgoing widget.
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.4));
    // Primary is running for incoming widget.
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(0.4));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.0));

    // Container one is at the bottom.
    final Container container = tester.firstWidget(find.byType(Container));
    expect(container.key, containerOne);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerThree, color: const Color(0xffff0000)),
        transitionBuilder: _transitionBuilder,
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    _primaryAnimation = _getPrimaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    _secondaryAnimation = _getSecondaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.6));
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(0.6));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.2));
    expect(_primaryAnimation[containerThree], moreOrLessEquals(0.2));
    expect(_secondaryAnimation[containerThree], moreOrLessEquals(0.0));
    await tester.pumpAndSettle();
  });

  testWidgets('transitions in a new child in reverse.',
      (WidgetTester tester) async {
    final UniqueKey containerOne = UniqueKey();
    final UniqueKey containerTwo = UniqueKey();
    final UniqueKey containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerOne, color: const Color(0x00000000)),
        transitionBuilder: _transitionBuilder,
        reverse: true,
      ),
    );

    Map<Key, double> _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne], tester);
    Map<Key, double> _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne], tester);
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerTwo, color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
        reverse: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne, containerTwo], tester);
    _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne, containerTwo], tester);
    // Primary is running for outgoing widget.
    expect(_primaryAnimation[containerOne], moreOrLessEquals(0.6));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));
    // Secondary is running for incoming widget.
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.6));

    // Container two is at the bottom.
    final Container container = tester.firstWidget(find.byType(Container));
    expect(container.key, containerTwo);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerThree, color: const Color(0xffff0000)),
        transitionBuilder: _transitionBuilder,
        reverse: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    _primaryAnimation = _getPrimaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    _secondaryAnimation = _getSecondaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    expect(_primaryAnimation[containerOne], moreOrLessEquals(0.4));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(0.8));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.4));
    expect(_primaryAnimation[containerThree], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerThree], moreOrLessEquals(0.8));
    await tester.pumpAndSettle();
  });

  testWidgets('switch from forward to reverse', (WidgetTester tester) async {
    final UniqueKey containerOne = UniqueKey();
    final UniqueKey containerTwo = UniqueKey();
    final UniqueKey containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerOne, color: const Color(0x00000000)),
        transitionBuilder: _transitionBuilder,
      ),
    );

    Map<Key, double> _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne], tester);
    Map<Key, double> _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne], tester);
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerTwo, color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne, containerTwo], tester);
    _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne, containerTwo], tester);
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.4));
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.0));
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(0.4));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerThree, color: const Color(0xffff0000)),
        transitionBuilder: _transitionBuilder,
        reverse: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    _primaryAnimation = _getPrimaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    _secondaryAnimation = _getSecondaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.6));
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.0));
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(0.2));
    expect(_secondaryAnimation[containerThree], moreOrLessEquals(0.8));
    expect(_primaryAnimation[containerThree], moreOrLessEquals(1.0));
    await tester.pumpAndSettle();
  });

  testWidgets('switch from reverse to forward.', (WidgetTester tester) async {
    final UniqueKey containerOne = UniqueKey();
    final UniqueKey containerTwo = UniqueKey();
    final UniqueKey containerThree = UniqueKey();
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerOne, color: const Color(0x00000000)),
        transitionBuilder: _transitionBuilder,
        reverse: true,
      ),
    );

    Map<Key, double> _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne], tester);
    Map<Key, double> _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne], tester);
    expect(_primaryAnimation[containerOne], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerTwo, color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
        reverse: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    _primaryAnimation =
        _getPrimaryAnimation(<Key>[containerOne, containerTwo], tester);
    _secondaryAnimation =
        _getSecondaryAnimation(<Key>[containerOne, containerTwo], tester);
    // Primary is running for outgoing widget.
    expect(_primaryAnimation[containerOne], moreOrLessEquals(0.6));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));
    // Secondary is running for incoming widget.
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.6));

    // Container two is at the bottom.
    final Container container = tester.firstWidget(find.byType(Container));
    expect(container.key, containerTwo);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: containerThree, color: const Color(0xffff0000)),
        transitionBuilder: _transitionBuilder,
        reverse: false,
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));

    _primaryAnimation = _getPrimaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    _secondaryAnimation = _getSecondaryAnimation(
        <Key>[containerOne, containerTwo, containerThree], tester);
    expect(_primaryAnimation[containerOne], moreOrLessEquals(0.4));
    expect(_secondaryAnimation[containerOne], moreOrLessEquals(0.0));
    expect(_primaryAnimation[containerTwo], moreOrLessEquals(1.0));
    expect(_secondaryAnimation[containerTwo], moreOrLessEquals(0.8));
    expect(_primaryAnimation[containerThree], moreOrLessEquals(0.2));
    expect(_secondaryAnimation[containerThree], moreOrLessEquals(0.0));
    await tester.pumpAndSettle();
  });

  testWidgets("doesn't transition in a new child of the same type.",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(color: const Color(0x00000000)),
        transitionBuilder: _transitionBuilder,
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
        child: Container(color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
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
        child: null,
        transitionBuilder: _transitionBuilder,
      ),
    );

    expect(find.byType(FadeTransition), findsNothing);
    expect(find.byType(ScaleTransition), findsNothing);

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
      ),
    );

    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(ScaleTransition), findsOneWidget);
    FadeTransition fade = tester.firstWidget(find.byType(FadeTransition));
    ScaleTransition scale = tester.firstWidget(find.byType(ScaleTransition));
    expect(fade.opacity.value, moreOrLessEquals(1.0));
    expect(scale.scale.value, moreOrLessEquals(0.4));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      const PageTransitionSwitcher(
        duration: Duration(milliseconds: 100),
        child: null,
        transitionBuilder: _transitionBuilder,
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(ScaleTransition), findsOneWidget);
    fade = tester.firstWidget(find.byType(FadeTransition));
    scale = tester.firstWidget(find.byType(ScaleTransition));
    expect(fade.opacity.value, moreOrLessEquals(0.5));
    expect(scale.scale.value, moreOrLessEquals(1.0));
    await tester.pumpAndSettle();
  });

  testWidgets("doesn't start any animations after dispose.",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: UniqueKey(), color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
      ),
    );

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: UniqueKey(), color: const Color(0xff000000)),
        transitionBuilder: _transitionBuilder,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(FadeTransition), findsNWidgets(2));
    expect(find.byType(ScaleTransition), findsNWidgets(2));
    final FadeTransition fade = tester.firstWidget(find.byType(FadeTransition));
    final ScaleTransition scale =
        tester.firstWidget(find.byType(ScaleTransition));
    expect(fade.opacity.value, moreOrLessEquals(0.5));
    expect(scale.scale.value, moreOrLessEquals(1.0));

    // Change the widget tree in the middle of the animation.
    await tester.pumpWidget(Container(color: const Color(0xffff0000)));
    expect(await tester.pumpAndSettle(const Duration(milliseconds: 100)),
        equals(1));
  });

  testWidgets("doesn't reset state of the children in transitions.",
      (WidgetTester tester) async {
    final UniqueKey statefulOne = UniqueKey();
    final UniqueKey statefulTwo = UniqueKey();
    final UniqueKey statefulThree = UniqueKey();

    StatefulTestState.generation = 0;

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: StatefulTest(key: statefulOne),
        transitionBuilder: _transitionBuilder,
      ),
    );

    Map<Key, double> _primaryAnimation =
        _getPrimaryAnimation(<Key>[statefulOne], tester);
    Map<Key, double> _secondaryAnimation =
        _getSecondaryAnimation(<Key>[statefulOne], tester);
    expect(_primaryAnimation[statefulOne], equals(1.0));
    expect(_secondaryAnimation[statefulOne], equals(0.0));
    expect(StatefulTestState.generation, equals(1));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: StatefulTest(key: statefulTwo),
        transitionBuilder: _transitionBuilder,
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(FadeTransition), findsNWidgets(2));
    _primaryAnimation =
        _getPrimaryAnimation(<Key>[statefulOne, statefulTwo], tester);
    _secondaryAnimation =
        _getSecondaryAnimation(<Key>[statefulOne, statefulTwo], tester);
    expect(_primaryAnimation[statefulTwo], equals(0.5));
    expect(_secondaryAnimation[statefulTwo], equals(0.0));
    expect(StatefulTestState.generation, equals(2));

    await tester.pumpWidget(
      PageTransitionSwitcher(
        duration: const Duration(milliseconds: 100),
        child: StatefulTest(key: statefulThree),
        transitionBuilder: _transitionBuilder,
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));
    expect(StatefulTestState.generation, equals(3));
    await tester.pumpAndSettle();
    expect(StatefulTestState.generation, equals(3));
  });

  testWidgets('updates widgets without animating if they are isomorphic.',
      (WidgetTester tester) async {
    Future<void> pumpChild(Widget child) async {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 100),
            child: child,
            transitionBuilder: _transitionBuilder,
          ),
        ),
      );
    }

    await pumpChild(const Text('1'));
    await tester.pump(const Duration(milliseconds: 10));
    FadeTransition fade = tester.widget(find.byType(FadeTransition).first);
    ScaleTransition scale = tester.widget(find.byType(ScaleTransition).first);
    expect(fade.opacity.value, equals(1.0));
    expect(scale.scale.value, equals(1.0));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);
    await pumpChild(const Text('2'));
    fade = tester.widget(find.byType(FadeTransition).first);
    scale = tester.widget(find.byType(ScaleTransition).first);
    await tester.pump(const Duration(milliseconds: 20));
    expect(fade.opacity.value, equals(1.0));
    expect(scale.scale.value, equals(1.0));
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
      'updates previous child transitions if the transitionBuilder changes.',
      (WidgetTester tester) async {
    final UniqueKey containerOne = UniqueKey();
    final UniqueKey containerTwo = UniqueKey();
    final UniqueKey containerThree = UniqueKey();

    // Insert three unique children so that we have some previous children.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 100),
          child: Container(key: containerOne, color: const Color(0xFFFF0000)),
          transitionBuilder: _transitionBuilder,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 100),
          child: Container(key: containerTwo, color: const Color(0xFF00FF00)),
          transitionBuilder: _transitionBuilder,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 100),
          child: Container(key: containerThree, color: const Color(0xFF0000FF)),
          transitionBuilder: _transitionBuilder,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byType(FadeTransition), findsNWidgets(3));
    expect(find.byType(ScaleTransition), findsNWidgets(3));
    expect(find.byType(SlideTransition), findsNothing);
    expect(find.byType(SizeTransition), findsNothing);

    Widget newTransitionBuilder(
        Widget child, Animation<double> primary, Animation<double> secondary) {
      return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: const Offset(20, 30))
            .animate(primary),
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
          child: Container(key: containerThree, color: const Color(0x00000000)),
          transitionBuilder: newTransitionBuilder,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byType(FadeTransition), findsNothing);
    expect(find.byType(ScaleTransition), findsNothing);
    expect(find.byType(SlideTransition), findsNWidgets(3));
    expect(find.byType(SizeTransition), findsNWidgets(3));
  });
}

class StatefulTest extends StatefulWidget {
  const StatefulTest({Key key}) : super(key: key);

  @override
  StatefulTestState createState() => StatefulTestState();
}

class StatefulTestState extends State<StatefulTest> {
  StatefulTestState();
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
    Widget child, Animation<double> primary, Animation<double> secondary) {
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
  final Map<Key, double> result = <Key, double>{};
  for (Key key in keys) {
    final FadeTransition transition = tester.firstWidget(
      find.ancestor(
        of: find.byKey(key),
        matching: find.byType(FadeTransition),
      ),
    );
    result[key] = 1.0 - transition.opacity.value;
  }
  return result;
}

Map<Key, double> _getPrimaryAnimation(List<Key> keys, WidgetTester tester) {
  expect(find.byType(ScaleTransition), findsNWidgets(keys.length));
  final Map<Key, double> result = <Key, double>{};
  for (Key key in keys) {
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
