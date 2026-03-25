// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/fade_through_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'FadeThroughPageTransitionsBuilder builds a FadeThroughTransition',
    (WidgetTester tester) async {
      final animation = AnimationController(vsync: const TestVSync());
      final secondaryAnimation = AnimationController(vsync: const TestVSync());

      await tester.pumpWidget(
        const FadeThroughPageTransitionsBuilder().buildTransitions<void>(
          null,
          null,
          animation,
          secondaryAnimation,
          const Placeholder(),
        ),
      );

      expect(find.byType(FadeThroughTransition), findsOneWidget);
    },
  );

  testWidgets('FadeThroughTransition runs forward', (
    WidgetTester tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    const bottomRoute = '/';
    const topRoute = '/a';

    await tester.pumpWidget(_TestWidget(navigatorKey: navigator));
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 1.0);
    expect(find.text(topRoute), findsNothing);

    navigator.currentState!.pushNamed(topRoute);
    await tester.pump();
    await tester.pump();

    // Bottom route is full size and fully visible.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 1.0);
    // top route is at 95% of full size and not visible yet.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 0.92);
    expect(_getOpacity(topRoute, tester), 0.0);

    // Jump to half-way through the fade out (total duration is 300ms, 6/12th of
    // that are fade out, so half-way is 300 * 6/12 / 2 = 45ms.
    await tester.pump(const Duration(milliseconds: 45));
    // Bottom route is fading out.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    final double bottomOpacity = _getOpacity(bottomRoute, tester);
    expect(bottomOpacity, lessThan(1.0));
    expect(bottomOpacity, greaterThan(0.0));
    // Top route is still invisible.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 0.92);
    expect(_getOpacity(topRoute, tester), 0.0);

    // Let's jump to the end of the fade-out.
    await tester.pump(const Duration(milliseconds: 45));
    // Bottom route is completely faded out.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 0.0);
    // Top route is still invisible.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 0.92);
    expect(_getOpacity(topRoute, tester), 0.0);

    // Let's jump to the middle of the fade-in.
    await tester.pump(const Duration(milliseconds: 105));
    // Bottom route is not visible.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 0.0);
    // Top route is fading/scaling in.
    expect(find.text(topRoute), findsOneWidget);
    final double topScale = _getScale(topRoute, tester);
    final double topOpacity = _getOpacity(topRoute, tester);
    expect(topScale, greaterThan(0.92));
    expect(topScale, lessThan(1.0));
    expect(topOpacity, greaterThan(0.0));
    expect(topOpacity, lessThan(1.0));

    // Let's jump to the end of the animation.
    await tester.pump(const Duration(milliseconds: 105));
    // Bottom route is not visible.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 0.0);
    // Top route fully scaled in and visible.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 1.0);
    expect(_getOpacity(topRoute, tester), 1.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text(bottomRoute), findsNothing);
    expect(find.text(topRoute), findsOneWidget);
  });

  testWidgets('FadeThroughTransition runs backwards', (
    WidgetTester tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    const bottomRoute = '/';
    const topRoute = '/a';

    await tester.pumpWidget(_TestWidget(navigatorKey: navigator));
    navigator.currentState!.pushNamed('/a');
    await tester.pumpAndSettle();

    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 1.0);
    expect(_getOpacity(topRoute, tester), 1.0);
    expect(find.text(bottomRoute), findsNothing);

    navigator.currentState!.pop();
    await tester.pump();

    // Top route is full size and fully visible.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 1.0);
    expect(_getOpacity(topRoute, tester), 1.0);
    // Bottom route is at 95% of full size and not visible yet.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 0.92);
    expect(_getOpacity(bottomRoute, tester), 0.0);

    // Jump to half-way through the fade out (total duration is 300ms, 6/12th of
    // that are fade out, so half-way is 300 * 6/12 / 2 = 45ms.
    await tester.pump(const Duration(milliseconds: 45));
    // Bottom route is fading out.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 1.0);
    final double topOpacity = _getOpacity(topRoute, tester);
    expect(topOpacity, lessThan(1.0));
    expect(topOpacity, greaterThan(0.0));
    // Top route is still invisible.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 0.92);
    expect(_getOpacity(bottomRoute, tester), 0.0);

    // Let's jump to the end of the fade-out.
    await tester.pump(const Duration(milliseconds: 45));
    // Bottom route is completely faded out.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 1.0);
    expect(_getOpacity(topRoute, tester), 0.0);
    // Top route is still invisible.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(
      _getScale(bottomRoute, tester),
      moreOrLessEquals(0.92, epsilon: 0.005),
    );
    expect(
      _getOpacity(bottomRoute, tester),
      moreOrLessEquals(0.0, epsilon: 0.005),
    );

    // Let's jump to the middle of the fade-in.
    await tester.pump(const Duration(milliseconds: 105));
    // Bottom route is not visible.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 1.0);
    expect(_getOpacity(topRoute, tester), 0.0);
    // Top route is fading/scaling in.
    expect(find.text(bottomRoute), findsOneWidget);
    final double bottomScale = _getScale(bottomRoute, tester);
    final double bottomOpacity = _getOpacity(bottomRoute, tester);
    expect(bottomScale, greaterThan(0.96));
    expect(bottomScale, lessThan(1.0));
    expect(bottomOpacity, greaterThan(0.1));
    expect(bottomOpacity, lessThan(1.0));

    // Let's jump to the end of the animation.
    await tester.pump(const Duration(milliseconds: 105));
    // Bottom route is not visible.
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 1.0);
    expect(_getOpacity(topRoute, tester), 0.0);
    // Top route fully scaled in and visible.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 1.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text(topRoute), findsNothing);
    expect(find.text(bottomRoute), findsOneWidget);
  });

  testWidgets('FadeThroughTransition does not jump when interrupted', (
    WidgetTester tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    const bottomRoute = '/';
    const topRoute = '/a';

    await tester.pumpWidget(_TestWidget(navigatorKey: navigator));
    expect(find.text(bottomRoute), findsOneWidget);
    expect(find.text(topRoute), findsNothing);

    navigator.currentState!.pushNamed(topRoute);
    await tester.pump();

    // Jump to halfway point of transition.
    await tester.pump(const Duration(milliseconds: 150));
    // Bottom route is fully faded out.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 0.0);
    // Top route is fading/scaling in.
    expect(find.text(topRoute), findsOneWidget);
    final double topScale = _getScale(topRoute, tester);
    final double topOpacity = _getOpacity(topRoute, tester);
    expect(topScale, greaterThan(0.92));
    expect(topScale, lessThan(1.0));
    expect(topOpacity, greaterThan(0.0));
    expect(topOpacity, lessThan(1.0));

    // Interrupt the transition with a pop.
    navigator.currentState!.pop();
    await tester.pump();
    // Noting changed.
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 0.0);
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), topScale);
    expect(_getOpacity(topRoute, tester), topOpacity);

    // Jump to the halfway point.
    await tester.pump(const Duration(milliseconds: 75));
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    final double bottomOpacity = _getOpacity(bottomRoute, tester);
    expect(bottomOpacity, greaterThan(0.0));
    expect(bottomOpacity, lessThan(1.0));
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), lessThan(topScale));
    expect(_getOpacity(topRoute, tester), lessThan(topOpacity));

    // Jump to the end.
    await tester.pump(const Duration(milliseconds: 75));
    expect(find.text(bottomRoute), findsOneWidget);
    expect(_getScale(bottomRoute, tester), 1.0);
    expect(_getOpacity(bottomRoute, tester), 1.0);
    expect(find.text(topRoute), findsOneWidget);
    expect(_getScale(topRoute, tester), 0.92);
    expect(_getOpacity(topRoute, tester), 0.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text(topRoute), findsNothing);
    expect(find.text(bottomRoute), findsOneWidget);
  });

  testWidgets('State is not lost when transitioning', (
    WidgetTester tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    const bottomRoute = '/';
    const topRoute = '/a';

    await tester.pumpWidget(
      _TestWidget(
        navigatorKey: navigator,
        contentBuilder: (RouteSettings settings) {
          return _StatefulTestWidget(
            key: ValueKey<String?>(settings.name),
            name: settings.name,
          );
        },
      ),
    );

    final _StatefulTestWidgetState bottomState = tester.state(
      find.byKey(const ValueKey<String?>(bottomRoute)),
    );
    expect(bottomState.widget.name, bottomRoute);

    navigator.currentState!.pushNamed(topRoute);
    await tester.pump();
    await tester.pump();

    expect(
      tester.state(find.byKey(const ValueKey<String?>(bottomRoute))),
      bottomState,
    );
    final _StatefulTestWidgetState topState = tester.state(
      find.byKey(const ValueKey<String?>(topRoute)),
    );
    expect(topState.widget.name, topRoute);

    await tester.pump(const Duration(milliseconds: 150));
    expect(
      tester.state(find.byKey(const ValueKey<String?>(bottomRoute))),
      bottomState,
    );
    expect(
      tester.state(find.byKey(const ValueKey<String?>(topRoute))),
      topState,
    );

    await tester.pumpAndSettle();
    expect(
      tester.state(
        find.byKey(const ValueKey<String?>(bottomRoute), skipOffstage: false),
      ),
      bottomState,
    );
    expect(
      tester.state(find.byKey(const ValueKey<String?>(topRoute))),
      topState,
    );

    navigator.currentState!.pop();
    await tester.pump();

    expect(
      tester.state(find.byKey(const ValueKey<String?>(bottomRoute))),
      bottomState,
    );
    expect(
      tester.state(find.byKey(const ValueKey<String?>(topRoute))),
      topState,
    );

    await tester.pump(const Duration(milliseconds: 150));
    expect(
      tester.state(find.byKey(const ValueKey<String?>(bottomRoute))),
      bottomState,
    );
    expect(
      tester.state(find.byKey(const ValueKey<String?>(topRoute))),
      topState,
    );

    await tester.pumpAndSettle();
    expect(
      tester.state(find.byKey(const ValueKey<String?>(bottomRoute))),
      bottomState,
    );
    expect(find.byKey(const ValueKey<String?>(topRoute)), findsNothing);
  });

  testWidgets('should keep state', (WidgetTester tester) async {
    final animation = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    );
    final secondaryAnimation = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: const _StatefulTestWidget(name: 'Foo'),
          ),
        ),
      ),
    );
    final State<StatefulWidget> state = tester.state(
      find.byType(_StatefulTestWidget),
    );
    expect(state, isNotNull);

    animation.forward();
    await tester.pump();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pumpAndSettle();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));

    secondaryAnimation.forward();
    await tester.pump();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pumpAndSettle();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));

    secondaryAnimation.reverse();
    await tester.pump();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pumpAndSettle();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));

    animation.reverse();
    await tester.pump();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pump(const Duration(milliseconds: 150));
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
    await tester.pumpAndSettle();
    expect(state, same(tester.state(find.byType(_StatefulTestWidget))));
  });
}

double _getOpacity(String key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(ValueKey<String?>(key)),
    matching: find.byType(FadeTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final transition = widget as FadeTransition;
    return a * transition.opacity.value;
  });
}

double _getScale(String key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(ValueKey<String?>(key)),
    matching: find.byType(ScaleTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final transition = widget as ScaleTransition;
    return a * transition.scale.value;
  });
}

class _TestWidget extends StatelessWidget {
  const _TestWidget({this.navigatorKey, this.contentBuilder});

  final Key? navigatorKey;
  final _ContentBuilder? contentBuilder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey as GlobalKey<NavigatorState>?,
      theme: ThemeData(
        platform: TargetPlatform.android,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          },
        ),
      ),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) {
            return contentBuilder != null
                ? contentBuilder!(settings)
                : Center(
                    key: ValueKey<String?>(settings.name),
                    child: Text(settings.name!),
                  );
          },
        );
      },
    );
  }
}

class _StatefulTestWidget extends StatefulWidget {
  const _StatefulTestWidget({super.key, this.name});

  final String? name;

  @override
  State<_StatefulTestWidget> createState() => _StatefulTestWidgetState();
}

class _StatefulTestWidgetState extends State<_StatefulTestWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.name!);
  }
}

typedef _ContentBuilder = Widget Function(RouteSettings settings);
