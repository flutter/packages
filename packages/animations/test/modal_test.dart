// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:animations/src/modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'showModal builds a new route with specified barrier properties',
    (WidgetTester tester) async {
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
                        configuration: _TestModalConfiguration(),
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

      // New route containing _FlutterLogoModal is present.
      expect(find.byType(_FlutterLogoModal), findsOneWidget);
      final ModalBarrier topModalBarrier = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).at(1),
      );

      // Verify new route's modal barrier properties are correct.
      expect(topModalBarrier.color, Colors.green);
      expect(topModalBarrier.barrierSemanticsDismissible, true);
      expect(topModalBarrier.semanticsLabel, 'customLabel');
    },
  );

  testWidgets('showModal forwards animation', (WidgetTester tester) async {
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
                      configuration: _TestModalConfiguration(),
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

    // Start forwards animation
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Opacity duration: Linear transition throughout 300ms
    double topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 0.0);

    // Halfway through forwards animation.
    await tester.pump(const Duration(milliseconds: 150));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 0.5);

    // The end of the transition.
    await tester.pump(const Duration(milliseconds: 150));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 1.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(_FlutterLogoModal), findsOneWidget);
  });

  testWidgets('showModal reverse animation', (WidgetTester tester) async {
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
                      configuration: _TestModalConfiguration(),
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

    // Start forwards animation
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(_FlutterLogoModal), findsOneWidget);

    await tester.tapAt(Offset.zero);
    await tester.pump();

    // Opacity duration: Linear transition throughout 200ms
    double topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 1.0);

    // Halfway through forwards animation.
    await tester.pump(const Duration(milliseconds: 100));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 0.5);

    // The end of the transition.
    await tester.pump(const Duration(milliseconds: 100));
    topFadeTransitionOpacity = _getOpacity(key, tester);
    expect(topFadeTransitionOpacity, 0.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(_FlutterLogoModal), findsNothing);
  });

  testWidgets('showModal builds a new route with specified barrier properties '
      'with default configuration(FadeScaleTransitionConfiguration)', (
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

    // New route containing _FlutterLogoModal is present.
    expect(find.byType(_FlutterLogoModal), findsOneWidget);
    final ModalBarrier topModalBarrier = tester.widget<ModalBarrier>(
      find.byType(ModalBarrier).at(1),
    );

    // Verify new route's modal barrier properties are correct.
    expect(topModalBarrier.color, Colors.black54);
    expect(topModalBarrier.barrierSemanticsDismissible, true);
    expect(topModalBarrier.semanticsLabel, 'Dismiss');
  });

  testWidgets('showModal forwards animation '
      'with default configuration(FadeScaleTransitionConfiguration)', (
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

    // Start forwards animation
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

    // End of opacity animation.
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

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(_FlutterLogoModal), findsOneWidget);
  });

  testWidgets('showModal reverse animation '
      'with default configuration(FadeScaleTransitionConfiguration)', (
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

    // Start forwards animation
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(_FlutterLogoModal), findsOneWidget);

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
                          configuration: _TestModalConfiguration(),
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
    await tester.pump(const Duration(milliseconds: 150));
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
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.state(find.byKey(bottomKey)), bottomState);
    expect(tester.state(find.byKey(topKey)), topState);

    // End the exit transition. The bottom route's state should
    // persist, whereas the top route's state should no longer
    // be present.
    await tester.pumpAndSettle();
    expect(tester.state(find.byKey(bottomKey)), bottomState);
    expect(find.byKey(topKey), findsNothing);
  });

  testWidgets('showModal builds a new route with specified route settings', (
    WidgetTester tester,
  ) async {
    const RouteSettings routeSettings = RouteSettings(
      name: 'route-name',
      arguments: 'arguments',
    );

    final Widget button = Builder(
      builder: (BuildContext context) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              showModal<void>(
                context: context,
                configuration: _TestModalConfiguration(),
                routeSettings: routeSettings,
                builder: (BuildContext context) {
                  return const _FlutterLogoModal();
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );

    await tester.pumpWidget(_boilerplate(button));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // New route containing _FlutterLogoModal is present.
    expect(find.byType(_FlutterLogoModal), findsOneWidget);

    // Expect the last route pushed to the navigator to contain RouteSettings
    // equal to the RouteSettings passed to showModal
    final ModalRoute<dynamic> modalRoute =
        ModalRoute.of(tester.element(find.byType(_FlutterLogoModal)))!;
    expect(modalRoute.settings, routeSettings);
  });

  testWidgets('showModal builds a new route with specified image filter', (
    WidgetTester tester,
  ) async {
    final ui.ImageFilter filter = ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1);

    final Widget button = Builder(
      builder: (BuildContext context) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              showModal<void>(
                context: context,
                configuration: _TestModalConfiguration(),
                filter: filter,
                builder: (BuildContext context) {
                  return const _FlutterLogoModal();
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );

    await tester.pumpWidget(_boilerplate(button));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // New route containing _FlutterLogoModal is present.
    expect(find.byType(_FlutterLogoModal), findsOneWidget);
    final BackdropFilter backdropFilter = tester.widget<BackdropFilter>(
      find.byType(BackdropFilter),
    );

    // Verify new route's backdrop filter has been applied
    expect(backdropFilter.filter, filter);
  });
}

Widget _boilerplate(Widget child) => MaterialApp(home: Scaffold(body: child));

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

class _TestModalConfiguration extends ModalConfiguration {
  _TestModalConfiguration()
    : super(
        barrierColor: Colors.green,
        barrierDismissible: true,
        barrierLabel: 'customLabel',
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      );

  @override
  Widget transitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
