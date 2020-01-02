// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/shared_z_axis_transition.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets(
    'SharedZAxisPageTransitionsBuilder builds a SharedZAxisTransition',
    (WidgetTester tester) async {
      final AnimationController animation = AnimationController(
        vsync: const TestVSync(),
      );
      final AnimationController secondaryAnimation = AnimationController(
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        const SharedZAxisPageTransitionsBuilder().buildTransitions<void>(
          null,
          null,
          animation,
          secondaryAnimation,
          const Placeholder(),
        ),
      );

      expect(find.byType(SharedZAxisTransition), findsOneWidget);
    },
  );

  testWidgets(
    'SharedZAxisTransition runs forward',
    (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(navigatorKey: navigator),
      );

      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), 1.0);
      expect(_getOpacity(bottomRoute, tester), 1.0);
      expect(find.text(topRoute), findsNothing);

      navigator.currentState.pushNamed(topRoute);
      await tester.pump();
      await tester.pump();

      // Bottom route is full size and fully visible.
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), 1.0);
      expect(_getOpacity(bottomRoute, tester), 1.0);
      // Top route is at 80% of full size and not visible yet.
      expect(find.text(topRoute), findsOneWidget);
      expect(_getScale(topRoute, tester), 0.8);
      expect(_getOpacity(topRoute, tester), 0.0);

      // Jump 3/10ths of the way through the transition, bottom route
      // should be be completely faded out while the top route
      // is also completely faded out.
      // Transition time: 300ms, 3/10 * 300ms = 90ms
      await tester.pump(const Duration(milliseconds: 90));

      // Bottom route is now invisible
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getOpacity(bottomRoute, tester), 0.0);
      // Top route is still invisible, but scaling up.
      expect(find.text(topRoute), findsOneWidget);
      expect(_getOpacity(topRoute, tester), 0.0);
      double topScale = _getScale(topRoute, tester);
      expect(topScale, greaterThan(0.8));
      expect(topScale, lessThan(1.0));

      // Jump to the middle of fading in
      await tester.pump(const Duration(milliseconds: 90));
      // Bottom route is still invisible
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getOpacity(bottomRoute, tester), 0.0);
      // Top route is fading in
      expect(find.text(topRoute), findsOneWidget);
      expect(_getOpacity(topRoute, tester), greaterThan(0));
      expect(_getOpacity(topRoute, tester), lessThan(1.0));
      topScale = _getScale(topRoute, tester);
      expect(topScale, greaterThan(0.8));
      expect(topScale, lessThan(1.0));

      // Jump to the end of the transition
      await tester.pump(const Duration(milliseconds: 120));
      // Bottom route is not visible.
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), 1.1);
      expect(_getOpacity(bottomRoute, tester), 0.0);
      // Top route fully scaled in and visible.
      expect(find.text(topRoute), findsOneWidget);
      expect(_getScale(topRoute, tester), 1.0);
      expect(_getOpacity(topRoute, tester), 1.0);

      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text(bottomRoute), findsNothing);
      expect(find.text(topRoute), findsOneWidget);
    },
  );

  testWidgets(
    'SharedZAxisTransition runs in reverse',
    (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(navigatorKey: navigator),
      );

      navigator.currentState.pushNamed(topRoute);
      await tester.pumpAndSettle();

      expect(find.text(topRoute), findsOneWidget);
      expect(_getScale(topRoute, tester), 1.0);
      expect(_getOpacity(topRoute, tester), 1.0);
      expect(find.text(bottomRoute), findsNothing);

      navigator.currentState.pop();
      await tester.pump();

      // Top route is full size and fully visible.
      expect(find.text(topRoute), findsOneWidget);
      expect(_getScale(topRoute, tester), 1.0);
      expect(_getOpacity(topRoute, tester), 1.0);
      // Bottom route is at 80% of full size and not visible yet.
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), 0.8);
      expect(_getOpacity(bottomRoute, tester), 0.0);

      // Jump 3/10ths of the way through the transition, bottom route
      // should be be completely faded out while the top route
      // is also completely faded out.
      // Transition time: 300ms, 3/10 * 300ms = 90ms
      await tester.pump(const Duration(milliseconds: 90));

      // Bottom route is now invisible
      expect(find.text(topRoute), findsOneWidget);
      expect(_getOpacity(topRoute, tester), 0.0);
      // Top route is still invisible, but scaling up.
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getOpacity(bottomRoute, tester),
          moreOrLessEquals(0, epsilon: 0.005));
      double bottomScale = _getScale(bottomRoute, tester);
      expect(bottomScale, greaterThan(0.8));
      expect(bottomScale, lessThan(1.0));

      // Jump to the middle of fading in
      await tester.pump(const Duration(milliseconds: 90));
      // Top route is still invisible
      expect(find.text(topRoute), findsOneWidget);
      expect(_getOpacity(topRoute, tester), 0.0);
      // Bottom route is fading in
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getOpacity(bottomRoute, tester), greaterThan(0));
      expect(_getOpacity(bottomRoute, tester), lessThan(1.0));
      bottomScale = _getScale(bottomRoute, tester);
      expect(bottomScale, greaterThan(0.8));
      expect(bottomScale, lessThan(1.0));

      // Jump to the end of the transition
      await tester.pump(const Duration(milliseconds: 120));
      // Top route is not visible.
      expect(find.text(topRoute), findsOneWidget);
      expect(_getScale(topRoute, tester), 1.1);
      expect(_getOpacity(topRoute, tester), 0.0);
      // Bottom route fully scaled in and visible.
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), 1.0);
      expect(_getOpacity(bottomRoute, tester), 1.0);

      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text(topRoute), findsNothing);
      expect(find.text(bottomRoute), findsOneWidget);
    },
  );

  testWidgets(
    'SharedZAxisTransition does not jump when interrupted',
    (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
        ),
      );
      expect(find.text(bottomRoute), findsOneWidget);
      expect(find.text(topRoute), findsNothing);

      navigator.currentState.pushNamed(topRoute);
      await tester.pump();

      // Jump to halfway point of transition.
      await tester.pump(const Duration(milliseconds: 150));
      // Bottom route is fully faded out.
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getOpacity(bottomRoute, tester), 0.0);
      final double halfwayBottomScale = _getScale(bottomRoute, tester);
      expect(halfwayBottomScale, greaterThan(1.0));
      expect(halfwayBottomScale, lessThan(1.1));

      // Top route is fading/scaling in.
      expect(find.text(topRoute), findsOneWidget);
      final double halfwayTopScale = _getScale(topRoute, tester);
      final double halfwayTopOpacity = _getOpacity(topRoute, tester);
      expect(halfwayTopScale, greaterThan(0.8));
      expect(halfwayTopScale, lessThan(1.0));
      expect(halfwayTopOpacity, greaterThan(0.0));
      expect(halfwayTopOpacity, lessThan(1.0));

      // Interrupt the transition with a pop.
      navigator.currentState.pop();
      await tester.pump();

      // Nothing should change.
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), halfwayBottomScale);
      expect(_getOpacity(bottomRoute, tester), 0.0);
      expect(find.text(topRoute), findsOneWidget);
      expect(_getScale(topRoute, tester), halfwayTopScale);
      expect(_getOpacity(topRoute, tester), halfwayTopOpacity);

      // Jump to the 1/4 (75 ms) point of transition
      await tester.pump(const Duration(milliseconds: 75));
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), greaterThan(1.0));
      expect(_getScale(bottomRoute, tester), lessThan(1.1));
      expect(_getScale(bottomRoute, tester), lessThan(halfwayBottomScale));
      expect(_getOpacity(bottomRoute, tester), greaterThan(0.0));
      expect(_getOpacity(bottomRoute, tester), lessThan(1.0));

      // Jump to the end.
      await tester.pump(const Duration(milliseconds: 75));
      expect(find.text(bottomRoute), findsOneWidget);
      expect(_getScale(bottomRoute, tester), 1.0);
      expect(_getOpacity(bottomRoute, tester), 1.0);
      expect(find.text(topRoute), findsOneWidget);
      expect(_getScale(topRoute, tester), 0.80);
      expect(_getOpacity(topRoute, tester), 0.0);

      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text(topRoute), findsNothing);
      expect(find.text(bottomRoute), findsOneWidget);
    },
  );

  testWidgets(
    'SharedZAxisTransition properly disposes animation',
    (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
        ),
      );
      expect(find.text(bottomRoute), findsOneWidget);
      expect(find.text(topRoute), findsNothing);

      navigator.currentState.pushNamed(topRoute);
      await tester.pump();

      // Jump to halfway point of transition.
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(SharedZAxisTransition), findsNWidgets(2));

      // Rebuild the app without the transition.
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          home: const Material(
            child: Text('abc'),
          ),
        ),
      );
      await tester.pump();
      // Transitions should have been disposed of.
      expect(find.byType(SharedZAxisTransition), findsNothing);
    },
  );

  testWidgets(
    'State is not lost when transitioning',
    (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
          contentBuilder: (RouteSettings settings) {
            return _StatefulTestWidget(
              key: ValueKey<String>(settings.name),
              name: settings.name,
            );
          },
        ),
      );

      final _StatefulTestWidgetState bottomState = tester.state(
        find.byKey(const ValueKey<String>(bottomRoute)),
      );
      expect(bottomState.widget.name, bottomRoute);

      navigator.currentState.pushNamed(topRoute);
      await tester.pump();
      await tester.pump();

      expect(
        tester.state(find.byKey(const ValueKey<String>(bottomRoute))),
        bottomState,
      );
      final _StatefulTestWidgetState topState = tester.state(
        find.byKey(const ValueKey<String>(topRoute)),
      );
      expect(topState.widget.name, topRoute);

      await tester.pump(const Duration(milliseconds: 150));
      expect(
        tester.state(find.byKey(const ValueKey<String>(bottomRoute))),
        bottomState,
      );
      expect(
        tester.state(find.byKey(const ValueKey<String>(topRoute))),
        topState,
      );

      await tester.pumpAndSettle();
      expect(
        tester.state(find.byKey(
          const ValueKey<String>(bottomRoute),
          skipOffstage: false,
        )),
        bottomState,
      );
      expect(
        tester.state(find.byKey(const ValueKey<String>(topRoute))),
        topState,
      );

      navigator.currentState.pop();
      await tester.pump();

      expect(
        tester.state(find.byKey(const ValueKey<String>(bottomRoute))),
        bottomState,
      );
      expect(
        tester.state(find.byKey(const ValueKey<String>(topRoute))),
        topState,
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(
        tester.state(find.byKey(const ValueKey<String>(bottomRoute))),
        bottomState,
      );
      expect(
        tester.state(find.byKey(const ValueKey<String>(topRoute))),
        topState,
      );

      await tester.pumpAndSettle();
      expect(
        tester.state(find.byKey(const ValueKey<String>(bottomRoute))),
        bottomState,
      );
      expect(find.byKey(const ValueKey<String>(topRoute)), findsNothing);
    },
  );
}

double _getOpacity(String key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(FadeTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final FadeTransition transition = widget;
    return a * transition.opacity.value;
  });
}

double _getScale(String key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(ScaleTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final ScaleTransition transition = widget;
    return a * transition.scale.value;
  });
}

class _TestWidget extends StatelessWidget {
  const _TestWidget({this.navigatorKey, this.contentBuilder});

  final Key navigatorKey;
  final _ContentBuilder contentBuilder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        platform: TargetPlatform.android,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: SharedZAxisPageTransitionsBuilder(),
          },
        ),
      ),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) {
            return contentBuilder != null
                ? contentBuilder(settings)
                : Container(
                    child: Center(
                      key: ValueKey<String>(settings.name),
                      child: Text(settings.name),
                    ),
                  );
          },
        );
      },
    );
  }
}

class _StatefulTestWidget extends StatefulWidget {
  const _StatefulTestWidget({Key key, this.name}) : super(key: key);

  final String name;

  @override
  State<_StatefulTestWidget> createState() => _StatefulTestWidgetState();
}

class _StatefulTestWidgetState extends State<_StatefulTestWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.name);
  }
}

typedef _ContentBuilder = Widget Function(RouteSettings settings);
