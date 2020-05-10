// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  AnimationController _controller;

  setUp(() {
    _controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    );
  });

  testWidgets(
    'CompositeAnimationWidget animates child fading in on forward and scaling down on reverse',
    (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompositeAnimationWidget(
                animation: _controller,
                forwardTransitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                reverseTransitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Text(
                  'Hello World',
                  key: key,
                ),
              ),
            ),
          ),
        ),
      );

      double onForwardFade = _getOpacity(key, tester);
      expect(onForwardFade, 0.0,
          reason:
              'forward transition child must not visible when animation is dismissed');

      _controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      onForwardFade = _getOpacity(key, tester);
      double onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 0.5,
          reason:
              'forward transition child must be at mid-point when animating forward');
      expect(onReverseScale, 1.0,
          reason:
              'reverse trasition child must be at visible-point when animating forward');

      await tester.pumpAndSettle();

      onForwardFade = _getOpacity(key, tester);
      onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 1.0,
          reason:
              'forward transition child must be at visible-point when animation is completed from forward');
      expect(onReverseScale, 1.0,
          reason:
              'reverse transition child must be at visible-point when animation is completed from forward');

      _controller.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      onForwardFade = _getOpacity(key, tester);
      onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 1.0,
          reason:
              'forward transition child must be at visible-point when animating reverse from completed');
      expect(onReverseScale, 0.5,
          reason:
              'reverse transition child must be at mid-point when animating reverse from completed');

      await tester.pumpAndSettle();

      onForwardFade = _getOpacity(key, tester);
      // not testing onReverseScale here cause it doesn't matter if this is
      // visible or not as long as the parent forwardTransitionBuilder is not
      // visible.
      expect(onForwardFade, 0.0,
          reason:
              'forward transition child must not visible when animation is dismissed from reverse');
    },
  );

  testWidgets(
    'CompositeAnimationWidget animates child fading out on forward and scaling up on reverse (visibleAtStart is true)',
    (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompositeAnimationWidget(
                animation: _controller,
                // let the widget know that we want to define an animation
                // visible at start (0.0)
                visibleAtStart: true,
                forwardTransitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    // flipping values to make the child visible at start
                    opacity: _flip(animation),
                    child: child,
                  );
                },
                reverseTransitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: _flip(animation),
                    child: child,
                  );
                },
                child: Text(
                  'Hello World',
                  key: key,
                ),
              ),
            ),
          ),
        ),
      );

      double onForwardFade = _getOpacity(key, tester);
      double onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 1.0,
          reason:
              'forward transition child must be at visible-point when animation is dismissed');
      expect(onReverseScale, 1.0,
          reason:
              'reverse transition child must be at visible-point when animation is dismissed');

      _controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      onForwardFade = _getOpacity(key, tester);
      onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 0.5,
          reason:
              'forward transition child must be at mid-point when animating forward');
      expect(onReverseScale, 1.0,
          reason:
              'reverse trasition child must be at visible-point when animating forward');

      await tester.pumpAndSettle();

      onForwardFade = _getOpacity(key, tester);
      onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 0.0,
          reason:
              'forward transition child must not visible when animation is completed from forward');
      expect(onReverseScale, 0.0,
          reason:
              'reverse transition child must not visible when animation is completed from forward');

      _controller.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      onForwardFade = _getOpacity(key, tester);
      onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 1.0,
          reason:
              'forward transition child must be at visible-point when animating reverse from completed');
      expect(onReverseScale, 0.5,
          reason:
              'reverse transition child must be at mid-point when animating reverse from completed');

      await tester.pumpAndSettle();

      onForwardFade = _getOpacity(key, tester);
      onReverseScale = _getScale(key, tester);
      expect(onForwardFade, 1.0,
          reason:
              'forward transition child must be at visible-point when animation is dismissed from reverse');
      expect(onReverseScale, 1.0,
          reason:
              'reverse trasition child must be at visible-point when animation is dismissed from reverse');
    },
  );
  testWidgets(
    'CompositeAnimationWidget preserves child state when transitioning',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompositeAnimationWidget(
                animation: _controller,
                forwardTransitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                reverseTransitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: const _CounterWidget(),
              ),
            ),
          ),
        ),
      );

      // animate in first
      _controller.forward();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Counter 0'), findsOneWidget);
      expect(find.text('Counter 3'), findsNothing);

      // tap three times
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Counter 0'), findsNothing);
      expect(find.text('Counter 3'), findsOneWidget);

      // animate out
      _controller.reverse();
      await tester.pump();
      await tester.pumpAndSettle();

      // ohh counter still 3?
      expect(find.text('Counter 0'), findsNothing);
      // the finder still find the Text widget with no opacity or zero scale.
      expect(find.text('Counter 3'), findsOneWidget);

      // ok lets get it back
      _controller.forward();
      await tester.pump();
      await tester.pumpAndSettle();

      // it is really counter state still 3?
      expect(find.text('Counter 0'), findsNothing);
      expect(find.text('Counter 3'), findsOneWidget);
    },
  );
}

final Tween<double> _flippedTween = Tween<double>(
  begin: 1.0,
  end: 0.0,
);

Animation<double> _flip(Animation<double> animation) {
  return _flippedTween.animate(animation);
}

double _getOpacity(GlobalKey key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(key),
    matching: find.byType(FadeTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final FadeTransition transition = widget;
    return a * transition.opacity.value;
  });
}

double _getScale(GlobalKey key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(key),
    matching: find.byType(ScaleTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final ScaleTransition transition = widget;
    return a * transition.scale.value;
  });
}

class _CounterWidget extends StatefulWidget {
  const _CounterWidget({
    Key key,
  }) : super(key: key);

  @override
  __CounterWidgetState createState() => __CounterWidgetState();
}

class __CounterWidgetState extends State<_CounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Counter $_counter'),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _counter++;
            });
          },
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}
