// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/fade_scale_transition.dart';
import 'package:animations/src/modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FadeScaleTransitionConfiguration builds a new route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModal<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return const _FlutterLogoModal();
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(_FlutterLogoModal), findsOneWidget);
  });

  testWidgets('FadeScaleTransitionConfiguration runs forward', (
    WidgetTester tester,
  ) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModal<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return _FlutterLogoModal(key: key);
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // Opacity duration: First 30% of 150ms, linear transition
    double topFadeTransitionOpacity = _getOpacity(key, tester);
    double topScale = _getScale(key, tester);
    expect(topFadeTransitionOpacity, 0.0);
    expect(topScale, 0.80);

    // 3/10 * 150ms = 45ms (total opacity animation duration)
    // 1/2 * 45ms = ~23ms elapsed for halfway point of opacity
    // animation
    await tester.pump(const Duration(milliseconds: 23));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, closeTo(0.5, 0.05));
    topScale = _getScale(key, tester);
    expect(topScale, greaterThan(0.80));
    expect(topScale, lessThan(1.0));

    // End of opacity animation
    await tester.pump(const Duration(milliseconds: 22));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 1.0);
    topScale = _getScale(key, tester);
    expect(topScale, greaterThan(0.80));
    expect(topScale, lessThan(1.0));

    // 100ms into the animation
    await tester.pump(const Duration(milliseconds: 55));
    topScale = _getScale(key, tester);
    expect(topScale, greaterThan(0.80));
    expect(topScale, lessThan(1.0));

    // Get to the end of the animation
    await tester.pump(const Duration(milliseconds: 50));
    topScale = _getScale(key, tester);
    expect(topScale, 1.0);

    await tester.pump();
    expect(find.byType(_FlutterLogoModal), findsOneWidget);
  });

  testWidgets('FadeScaleTransitionConfiguration runs forward', (
    WidgetTester tester,
  ) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModal<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return _FlutterLogoModal(key: key);
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      ),
    );
    // Show the incoming modal and let it animate in fully.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Tap on modal barrier to start reverse animation.
    await tester.tapAt(Offset.zero);
    await tester.pump();

    // Opacity duration: Linear transition throughout 75ms
    // No scale animations on exit transition.
    double topFadeTransitionOpacity = _getOpacity(key, tester);
    double topScale = _getScale(key, tester);
    expect(topFadeTransitionOpacity, 1.0);
    expect(topScale, 1.0);

    await tester.pump(const Duration(milliseconds: 25));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    topScale = _getScale(key, tester);
    expect(topFadeTransitionOpacity, closeTo(0.66, 0.05));
    expect(topScale, 1.0);

    await tester.pump(const Duration(milliseconds: 25));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    topScale = _getScale(key, tester);
    expect(topFadeTransitionOpacity, closeTo(0.33, 0.05));
    expect(topScale, 1.0);

    // End of opacity animation
    await tester.pump(const Duration(milliseconds: 25));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 0.0);
    topScale = _getScale(key, tester);
    expect(topScale, 1.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(_FlutterLogoModal), findsNothing);
  });

  testWidgets(
    'FadeScaleTransitionConfiguration does not jump when interrupted',
    (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModal<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _FlutterLogoModal(key: key);
                        },
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      // Opacity duration: First 30% of 150ms, linear transition
      double topFadeTransitionOpacity = _getOpacity(key, tester);
      double topScale = _getScale(key, tester);
      expect(topFadeTransitionOpacity, 0.0);
      expect(topScale, 0.80);

      // 3/10 * 150ms = 45ms (total opacity animation duration)
      // End of opacity animation
      await tester.pump(const Duration(milliseconds: 45));
      topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, 1.0);
      topScale = _getScale(key, tester);
      expect(topScale, greaterThan(0.80));
      expect(topScale, lessThan(1.0));

      // 100ms into the animation
      await tester.pump(const Duration(milliseconds: 55));
      topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, 1.0);
      topScale = _getScale(key, tester);
      expect(topScale, greaterThan(0.80));
      expect(topScale, lessThan(1.0));

      // Start the reverse transition by interrupting the forwards
      // transition.
      await tester.tapAt(Offset.zero);
      await tester.pump();
      // Opacity and scale values should remain the same after
      // the reverse animation starts.
      expect(_getOpacity(key, tester), topFadeTransitionOpacity);
      expect(_getScale(key, tester), topScale);

      // Should animate in reverse with 2/3 * 75ms = 50ms
      // using the enter transition's animation pattern
      // instead of the exit animation pattern.

      // Calculation for the time when the linear fade
      // transition should start if running backwards:
      // 3/10 * 75ms = 22.5ms
      // To get the 22.5ms timestamp, run backwards for:
      // 50ms - 22.5ms = ~27.5ms
      await tester.pump(const Duration(milliseconds: 27));
      topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, 1.0);
      topScale = _getScale(key, tester);
      expect(topScale, greaterThan(0.80));
      expect(topScale, lessThan(1.0));

      // Halfway through fade animation
      await tester.pump(const Duration(milliseconds: 12));
      topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, closeTo(0.5, 0.05));
      topScale = _getScale(key, tester);
      expect(topScale, greaterThan(0.80));
      expect(topScale, lessThan(1.0));

      // Complete the rest of the animation
      await tester.pump(const Duration(milliseconds: 11));
      topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, 0.0);
      topScale = _getScale(key, tester);
      expect(topScale, 0.8);

      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(_FlutterLogoModal), findsNothing);
    },
  );

  testWidgets('State is not lost when transitioning', (
    WidgetTester tester,
  ) async {
    final GlobalKey bottomKey = GlobalKey();
    final GlobalKey topKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        showModal<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return _FlutterLogoModal(
                              key: topKey,
                              name: 'top route',
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                    _FlutterLogoModal(key: bottomKey, name: 'bottom route'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    // The bottom route's state should already exist.
    final _FlutterLogoModalState bottomState = tester.state(
      find.byKey(bottomKey),
    );
    expect(bottomState.widget.name, 'bottom route');

    // Start the enter transition of the modal route.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump();

    // The bottom route's state should be retained at the start of the
    // transition.
    expect(tester.state(find.byKey(bottomKey)), bottomState);
    // The top route's state should be created.
    final _FlutterLogoModalState topState = tester.state(find.byKey(topKey));
    expect(topState.widget.name, 'top route');

    // Halfway point of forwards animation.
    await tester.pump(const Duration(milliseconds: 75));
    expect(tester.state(find.byKey(bottomKey)), bottomState);
    expect(tester.state(find.byKey(topKey)), topState);

    // End the transition and see if top and bottom routes'
    // states persist.
    await tester.pumpAndSettle();
    expect(
      tester.state(find.byKey(bottomKey, skipOffstage: false)),
      bottomState,
    );
    expect(tester.state(find.byKey(topKey)), topState);

    // Start the reverse animation. Both top and bottom
    // routes' states should persist.
    await tester.tapAt(Offset.zero);
    await tester.pump();
    expect(tester.state(find.byKey(bottomKey)), bottomState);
    expect(tester.state(find.byKey(topKey)), topState);

    // Halfway point of the exit transition.
    await tester.pump(const Duration(milliseconds: 38));
    expect(tester.state(find.byKey(bottomKey)), bottomState);
    expect(tester.state(find.byKey(topKey)), topState);

    // End the exit transition. The bottom route's state should
    // persist, whereas the top route's state should no longer
    // be present.
    await tester.pumpAndSettle();
    expect(tester.state(find.byKey(bottomKey)), bottomState);
    expect(find.byKey(topKey), findsNothing);
  });

  testWidgets('should preserve state', (WidgetTester tester) async {
    final AnimationController controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FadeScaleTransition(
              animation: controller,
              child: const _FlutterLogoModal(),
            ),
          ),
        ),
      ),
    );

    final State<StatefulWidget> state = tester.state(
      find.byType(_FlutterLogoModal),
    );
    expect(state, isNotNull);

    controller.forward();
    await tester.pump();
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));
    await tester.pumpAndSettle();
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));

    controller.reverse();
    await tester.pump();
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));
    await tester.pumpAndSettle();
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));

    controller.forward();
    await tester.pump();
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));
    await tester.pumpAndSettle();
    expect(state, same(tester.state(find.byType(_FlutterLogoModal))));
  });
}

double _getOpacity(GlobalKey key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(key),
    matching: find.byType(FadeTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final FadeTransition transition = widget as FadeTransition;
    return a * transition.opacity.value;
  });
}

double _getScale(GlobalKey key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(key),
    matching: find.byType(ScaleTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final ScaleTransition transition = widget as ScaleTransition;
    return a * transition.scale.value;
  });
}

class _FlutterLogoModal extends StatefulWidget {
  const _FlutterLogoModal({super.key, this.name});

  final String? name;

  @override
  _FlutterLogoModalState createState() => _FlutterLogoModalState();
}

class _FlutterLogoModalState extends State<_FlutterLogoModal> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Material(child: Center(child: FlutterLogo(size: 250))),
      ),
    );
  }
}
