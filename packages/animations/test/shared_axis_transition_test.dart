// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/shared_axis_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

void main() {
  group('SharedAxisTransitionType.horizontal', () {
    testWidgets(
      'SharedAxisPageTransitionsBuilder builds a SharedAxisTransition',
      (WidgetTester tester) async {
        final AnimationController animation = AnimationController(
          vsync: const TestVSync(),
        );
        final AnimationController secondaryAnimation = AnimationController(
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal,
          ).buildTransitions<void>(
            null,
            null,
            animation,
            secondaryAnimation,
            const Placeholder(),
          ),
        );

        expect(find.byType(SharedAxisTransition), findsOneWidget);
      },
    );

    testWidgets(
      'SharedAxisTransition runs forward',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        );

        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);
        expect(find.text(topRoute), findsNothing);

        navigator.currentState!.pushNamed(topRoute);
        await tester.pump();
        await tester.pump();

        // Bottom route is not offset and fully visible.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);
        // Top route is offset to the right by 30.0 pixels
        // and not visible yet.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          30.0,
        );
        expect(_getOpacity(topRoute, tester), 0.0);

        // Jump 3/10ths of the way through the transition, bottom route
        // should be be completely faded out while the top route
        // is also completely faded out.
        // Transition time: 300ms, 3/10 * 300ms = 90ms
        await tester.pump(const Duration(milliseconds: 90));

        // Bottom route is now invisible
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), 0.0);
        // Top route is still invisible, but moving towards the left.
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), 0.0);
        double? topOffset = _getTranslationOffset(
          topRoute,
          tester,
          SharedAxisTransitionType.horizontal,
        );
        expect(topOffset, lessThan(30.0));
        expect(topOffset, greaterThan(0.0));

        // Jump to the middle of fading in
        await tester.pump(const Duration(milliseconds: 90));
        // Bottom route is still invisible
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), 0.0);
        // Top route is fading in
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), greaterThan(0));
        expect(_getOpacity(topRoute, tester), lessThan(1.0));
        topOffset = _getTranslationOffset(
          topRoute,
          tester,
          SharedAxisTransitionType.horizontal,
        );
        expect(topOffset, greaterThan(0.0));
        expect(topOffset, lessThan(30.0));

        // Jump to the end of the transition
        await tester.pump(const Duration(milliseconds: 120));
        // Bottom route is not visible.
        expect(find.text(bottomRoute), findsOneWidget);

        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          -30.0,
        );
        expect(_getOpacity(bottomRoute, tester), 0.0);
        // Top route has no offset and is visible.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          0.0,
        );
        expect(_getOpacity(topRoute, tester), 1.0);

        await tester.pump(const Duration(milliseconds: 1));
        expect(find.text(bottomRoute), findsNothing);
        expect(find.text(topRoute), findsOneWidget);
      },
    );

    testWidgets(
      'SharedAxisTransition runs in reverse',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        );

        navigator.currentState!.pushNamed('/a');
        await tester.pumpAndSettle();

        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          0.0,
        );
        expect(_getOpacity(topRoute, tester), 1.0);
        expect(find.text(bottomRoute), findsNothing);

        navigator.currentState!.pop();
        await tester.pump();

        // Top route is is not offset and fully visible.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          0.0,
        );
        expect(_getOpacity(topRoute, tester), 1.0);
        // Bottom route is offset to the left and is not visible yet.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          -30.0,
        );
        expect(_getOpacity(bottomRoute, tester), 0.0);

        // Jump 3/10ths of the way through the transition, bottom route
        // should be be completely faded out while the top route
        // is also completely faded out.
        // Transition time: 300ms, 3/10 * 300ms = 90ms
        await tester.pump(const Duration(milliseconds: 90));

        // Top route is now invisible
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), 0.0);
        // Bottom route is still invisible, but moving towards the right.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester),
            moreOrLessEquals(0, epsilon: 0.005));
        double? bottomOffset = _getTranslationOffset(
          bottomRoute,
          tester,
          SharedAxisTransitionType.horizontal,
        );
        expect(bottomOffset, lessThan(0.0));
        expect(bottomOffset, greaterThan(-30.0));

        // Jump to the middle of fading in
        await tester.pump(const Duration(milliseconds: 90));
        // Top route is still invisible
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), 0.0);
        // Bottom route is fading in
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), greaterThan(0));
        expect(_getOpacity(bottomRoute, tester), lessThan(1.0));
        bottomOffset = _getTranslationOffset(
          bottomRoute,
          tester,
          SharedAxisTransitionType.horizontal,
        );
        expect(bottomOffset, lessThan(0.0));
        expect(bottomOffset, greaterThan(-30.0));

        // Jump to the end of the transition
        await tester.pump(const Duration(milliseconds: 120));
        // Top route is not visible and is offset to the right.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          30.0,
        );
        expect(_getOpacity(topRoute, tester), 0.0);
        // Bottom route is not offset and is visible.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);

        await tester.pump(const Duration(milliseconds: 1));
        expect(find.text(topRoute), findsNothing);
        expect(find.text(bottomRoute), findsOneWidget);
      },
    );

    testWidgets(
      'SharedAxisTransition does not jump when interrupted',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        );
        expect(find.text(bottomRoute), findsOneWidget);
        expect(find.text(topRoute), findsNothing);

        navigator.currentState!.pushNamed(topRoute);
        await tester.pump();

        // Jump to halfway point of transition.
        await tester.pump(const Duration(milliseconds: 150));
        // Bottom route is fully faded out.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), 0.0);
        final double halfwayBottomOffset = _getTranslationOffset(
          bottomRoute,
          tester,
          SharedAxisTransitionType.horizontal,
        );
        expect(halfwayBottomOffset, lessThan(0.0));
        expect(halfwayBottomOffset, greaterThan(-30.0));

        // Top route is fading/coming in.
        expect(find.text(topRoute), findsOneWidget);
        final double halfwayTopOffset = _getTranslationOffset(
          topRoute,
          tester,
          SharedAxisTransitionType.horizontal,
        );
        final double halfwayTopOpacity = _getOpacity(topRoute, tester);
        expect(halfwayTopOffset, greaterThan(0.0));
        expect(halfwayTopOffset, lessThan(30.0));
        expect(halfwayTopOpacity, greaterThan(0.0));
        expect(halfwayTopOpacity, lessThan(1.0));

        // Interrupt the transition with a pop.
        navigator.currentState!.pop();
        await tester.pump();

        // Nothing should change.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          halfwayBottomOffset,
        );
        expect(_getOpacity(bottomRoute, tester), 0.0);
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          halfwayTopOffset,
        );
        expect(_getOpacity(topRoute, tester), halfwayTopOpacity);

        // Jump to the 1/4 (75 ms) point of transition
        await tester.pump(const Duration(milliseconds: 75));
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          lessThan(0.0),
        );
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          greaterThan(-30.0),
        );
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          greaterThan(halfwayBottomOffset),
        );
        expect(_getOpacity(bottomRoute, tester), greaterThan(0.0));
        expect(_getOpacity(bottomRoute, tester), lessThan(1.0));

        // Jump to the end.
        await tester.pump(const Duration(milliseconds: 75));
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.horizontal,
          ),
          30.0,
        );
        expect(_getOpacity(topRoute, tester), 0.0);

        await tester.pump(const Duration(milliseconds: 1));
        expect(find.text(topRoute), findsNothing);
        expect(find.text(bottomRoute), findsOneWidget);
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
                key: ValueKey<String?>(settings.name),
                name: settings.name!,
              );
            },
            transitionType: SharedAxisTransitionType.horizontal,
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
          tester.state(find.byKey(
            const ValueKey<String?>(bottomRoute),
            skipOffstage: false,
          )),
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
      },
    );

    testWidgets('default fill color', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      // The default fill color should be derived from ThemeData.canvasColor.
      final Color defaultFillColor = ThemeData().canvasColor;

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      );

      expect(find.text(bottomRoute), findsOneWidget);
      Finder fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(tester.widget<ColoredBox>(fillContainerFinder).color,
          defaultFillColor);

      navigator.currentState!.pushNamed(topRoute);
      await tester.pump();
      await tester.pumpAndSettle();

      fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/a')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(tester.widget<ColoredBox>(fillContainerFinder).color,
          defaultFillColor);
    });

    testWidgets('custom fill color', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
          fillColor: Colors.green,
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      );

      expect(find.text(bottomRoute), findsOneWidget);
      Finder fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(
          tester.widget<ColoredBox>(fillContainerFinder).color, Colors.green);

      navigator.currentState!.pushNamed(topRoute);
      await tester.pump();
      await tester.pumpAndSettle();

      fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/a')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(
          tester.widget<ColoredBox>(fillContainerFinder).color, Colors.green);
    });

    testWidgets('should keep state', (WidgetTester tester) async {
      final AnimationController animation = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      final AnimationController secondaryAnimation = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SharedAxisTransition(
            transitionType: SharedAxisTransitionType.horizontal,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: const _StatefulTestWidget(name: 'Foo'),
          ),
        ),
      ));
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
  });

  group('SharedAxisTransitionType.vertical', () {
    testWidgets(
      'SharedAxisPageTransitionsBuilder builds a SharedAxisTransition',
      (WidgetTester tester) async {
        final AnimationController animation = AnimationController(
          vsync: const TestVSync(),
        );
        final AnimationController secondaryAnimation = AnimationController(
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.vertical,
          ).buildTransitions<void>(
            null,
            null,
            animation,
            secondaryAnimation,
            const Placeholder(),
          ),
        );

        expect(find.byType(SharedAxisTransition), findsOneWidget);
      },
    );

    testWidgets(
      'SharedAxisTransition runs forward',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.vertical,
          ),
        );

        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);
        expect(find.text(topRoute), findsNothing);

        navigator.currentState!.pushNamed(topRoute);
        await tester.pump();
        await tester.pump();

        // Bottom route is not offset and fully visible.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);
        // Top route is offset down by 30.0 pixels
        // and not visible yet.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          30.0,
        );
        expect(_getOpacity(topRoute, tester), 0.0);

        // Jump 3/10ths of the way through the transition, bottom route
        // should be be completely faded out while the top route
        // is also completely faded out.
        // Transition time: 300ms, 3/10 * 300ms = 90ms
        await tester.pump(const Duration(milliseconds: 90));

        // Bottom route is now invisible
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), 0.0);
        // Top route is still invisible, but moving up.
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), 0.0);
        double? topOffset = _getTranslationOffset(
          topRoute,
          tester,
          SharedAxisTransitionType.vertical,
        );
        expect(topOffset, lessThan(30.0));
        expect(topOffset, greaterThan(0.0));

        // Jump to the middle of fading in
        await tester.pump(const Duration(milliseconds: 90));
        // Bottom route is still invisible
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), 0.0);
        // Top route is fading in
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), greaterThan(0));
        expect(_getOpacity(topRoute, tester), lessThan(1.0));
        topOffset = _getTranslationOffset(
          topRoute,
          tester,
          SharedAxisTransitionType.vertical,
        );
        expect(topOffset, greaterThan(0.0));
        expect(topOffset, lessThan(30.0));

        // Jump to the end of the transition
        await tester.pump(const Duration(milliseconds: 120));
        // Bottom route is not visible.
        expect(find.text(bottomRoute), findsOneWidget);

        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          -30.0,
        );
        expect(_getOpacity(bottomRoute, tester), 0.0);
        // Top route has no offset and is visible.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          0.0,
        );
        expect(_getOpacity(topRoute, tester), 1.0);

        await tester.pump(const Duration(milliseconds: 1));
        expect(find.text(bottomRoute), findsNothing);
        expect(find.text(topRoute), findsOneWidget);
      },
    );

    testWidgets(
      'SharedAxisTransition runs in reverse',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.vertical,
          ),
        );

        navigator.currentState!.pushNamed('/a');
        await tester.pumpAndSettle();

        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          0.0,
        );
        expect(_getOpacity(topRoute, tester), 1.0);
        expect(find.text(bottomRoute), findsNothing);

        navigator.currentState!.pop();
        await tester.pump();

        // Top route is is not offset and fully visible.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          0.0,
        );
        expect(_getOpacity(topRoute, tester), 1.0);
        // Bottom route is offset up and is not visible yet.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          -30.0,
        );
        expect(_getOpacity(bottomRoute, tester), 0.0);

        // Jump 3/10ths of the way through the transition, bottom route
        // should be be completely faded out while the top route
        // is also completely faded out.
        // Transition time: 300ms, 3/10 * 300ms = 90ms
        await tester.pump(const Duration(milliseconds: 90));

        // Top route is now invisible
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), 0.0);
        // Bottom route is still invisible, but moving down.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getOpacity(bottomRoute, tester),
          moreOrLessEquals(0, epsilon: 0.005),
        );
        double? bottomOffset = _getTranslationOffset(
          bottomRoute,
          tester,
          SharedAxisTransitionType.vertical,
        );
        expect(bottomOffset, lessThan(0.0));
        expect(bottomOffset, greaterThan(-30.0));

        // Jump to the middle of fading in
        await tester.pump(const Duration(milliseconds: 90));
        // Top route is still invisible
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), 0.0);
        // Bottom route is fading in
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), greaterThan(0));
        expect(_getOpacity(bottomRoute, tester), lessThan(1.0));
        bottomOffset = _getTranslationOffset(
          bottomRoute,
          tester,
          SharedAxisTransitionType.vertical,
        );
        expect(bottomOffset, lessThan(0.0));
        expect(bottomOffset, greaterThan(-30.0));

        // Jump to the end of the transition
        await tester.pump(const Duration(milliseconds: 120));
        // Top route is not visible and is offset down.
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          30.0,
        );
        expect(_getOpacity(topRoute, tester), 0.0);
        // Bottom route is not offset and is visible.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);

        await tester.pump(const Duration(milliseconds: 1));
        expect(find.text(topRoute), findsNothing);
        expect(find.text(bottomRoute), findsOneWidget);
      },
    );

    testWidgets(
      'SharedAxisTransition does not jump when interrupted',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.vertical,
          ),
        );
        expect(find.text(bottomRoute), findsOneWidget);
        expect(find.text(topRoute), findsNothing);

        navigator.currentState!.pushNamed(topRoute);
        await tester.pump();

        // Jump to halfway point of transition.
        await tester.pump(const Duration(milliseconds: 150));
        // Bottom route is fully faded out.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getOpacity(bottomRoute, tester), 0.0);
        final double halfwayBottomOffset = _getTranslationOffset(
          bottomRoute,
          tester,
          SharedAxisTransitionType.vertical,
        );
        expect(halfwayBottomOffset, lessThan(0.0));
        expect(halfwayBottomOffset, greaterThan(-30.0));

        // Top route is fading/coming in.
        expect(find.text(topRoute), findsOneWidget);
        final double halfwayTopOffset = _getTranslationOffset(
          topRoute,
          tester,
          SharedAxisTransitionType.vertical,
        );
        final double halfwayTopOpacity = _getOpacity(topRoute, tester);
        expect(halfwayTopOffset, greaterThan(0.0));
        expect(halfwayTopOffset, lessThan(30.0));
        expect(halfwayTopOpacity, greaterThan(0.0));
        expect(halfwayTopOpacity, lessThan(1.0));

        // Interrupt the transition with a pop.
        navigator.currentState!.pop();
        await tester.pump();

        // Nothing should change.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          halfwayBottomOffset,
        );
        expect(_getOpacity(bottomRoute, tester), 0.0);
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          halfwayTopOffset,
        );
        expect(_getOpacity(topRoute, tester), halfwayTopOpacity);

        // Jump to the 1/4 (75 ms) point of transition
        await tester.pump(const Duration(milliseconds: 75));
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          lessThan(0.0),
        );
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          greaterThan(-30.0),
        );
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          greaterThan(halfwayBottomOffset),
        );
        expect(_getOpacity(bottomRoute, tester), greaterThan(0.0));
        expect(_getOpacity(bottomRoute, tester), lessThan(1.0));

        // Jump to the end.
        await tester.pump(const Duration(milliseconds: 75));
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            bottomRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          0.0,
        );
        expect(_getOpacity(bottomRoute, tester), 1.0);
        expect(find.text(topRoute), findsOneWidget);
        expect(
          _getTranslationOffset(
            topRoute,
            tester,
            SharedAxisTransitionType.vertical,
          ),
          30.0,
        );
        expect(_getOpacity(topRoute, tester), 0.0);

        await tester.pump(const Duration(milliseconds: 1));
        expect(find.text(topRoute), findsNothing);
        expect(find.text(bottomRoute), findsOneWidget);
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
                key: ValueKey<String?>(settings.name),
                name: settings.name!,
              );
            },
            transitionType: SharedAxisTransitionType.vertical,
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
          tester.state(find.byKey(
            const ValueKey<String?>(bottomRoute),
            skipOffstage: false,
          )),
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
      },
    );

    testWidgets('default fill color', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      // The default fill color should be derived from ThemeData.canvasColor.
      final Color defaultFillColor = ThemeData().canvasColor;

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
          transitionType: SharedAxisTransitionType.vertical,
        ),
      );

      expect(find.text(bottomRoute), findsOneWidget);
      Finder fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(tester.widget<ColoredBox>(fillContainerFinder).color,
          defaultFillColor);

      navigator.currentState!.pushNamed(topRoute);
      await tester.pump();
      await tester.pumpAndSettle();

      fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/a')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(tester.widget<ColoredBox>(fillContainerFinder).color,
          defaultFillColor);
    });

    testWidgets('custom fill color', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
          fillColor: Colors.green,
          transitionType: SharedAxisTransitionType.vertical,
        ),
      );

      expect(find.text(bottomRoute), findsOneWidget);
      Finder fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(
          tester.widget<ColoredBox>(fillContainerFinder).color, Colors.green);

      navigator.currentState!.pushNamed(topRoute);
      await tester.pump();
      await tester.pumpAndSettle();

      fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/a')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(
          tester.widget<ColoredBox>(fillContainerFinder).color, Colors.green);
    });

    testWidgets('should keep state', (WidgetTester tester) async {
      final AnimationController animation = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      final AnimationController secondaryAnimation = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SharedAxisTransition(
            transitionType: SharedAxisTransitionType.vertical,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: const _StatefulTestWidget(name: 'Foo'),
          ),
        ),
      ));
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
  });

  group('SharedAxisTransitionType.scaled', () {
    testWidgets(
      'SharedAxisPageTransitionsBuilder builds a SharedAxisTransition',
      (WidgetTester tester) async {
        final AnimationController animation = AnimationController(
          vsync: const TestVSync(),
        );
        final AnimationController secondaryAnimation = AnimationController(
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ).buildTransitions<void>(
            null,
            null,
            animation,
            secondaryAnimation,
            const Placeholder(),
          ),
        );

        expect(find.byType(SharedAxisTransition), findsOneWidget);
      },
    );

    testWidgets(
      'SharedAxisTransition runs forward',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.scaled,
          ),
        );

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
      'SharedAxisTransition runs in reverse',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.scaled,
          ),
        );

        navigator.currentState!.pushNamed(topRoute);
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
        // Bottom route is at 110% of full size and not visible yet.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(_getScale(bottomRoute, tester), 1.1);
        expect(_getOpacity(bottomRoute, tester), 0.0);

        // Jump 3/10ths of the way through the transition, bottom route
        // should be be completely faded out while the top route
        // is also completely faded out.
        // Transition time: 300ms, 3/10 * 300ms = 90ms
        await tester.pump(const Duration(milliseconds: 90));

        // Bottom route is now invisible
        expect(find.text(topRoute), findsOneWidget);
        expect(_getOpacity(topRoute, tester), 0.0);
        // Top route is still invisible, but scaling down.
        expect(find.text(bottomRoute), findsOneWidget);
        expect(
          _getOpacity(bottomRoute, tester),
          moreOrLessEquals(0, epsilon: 0.005),
        );
        double bottomScale = _getScale(bottomRoute, tester);
        expect(bottomScale, greaterThan(1.0));
        expect(bottomScale, lessThan(1.1));

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
        expect(bottomScale, greaterThan(1.0));
        expect(bottomScale, lessThan(1.1));

        // Jump to the end of the transition
        await tester.pump(const Duration(milliseconds: 120));
        // Top route is not visible.
        expect(find.text(topRoute), findsOneWidget);
        expect(_getScale(topRoute, tester), 0.8);
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
      'SharedAxisTransition does not jump when interrupted',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.scaled,
          ),
        );
        expect(find.text(bottomRoute), findsOneWidget);
        expect(find.text(topRoute), findsNothing);

        navigator.currentState!.pushNamed(topRoute);
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
        navigator.currentState!.pop();
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
      'SharedAxisTransition properly disposes animation',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
        const String bottomRoute = '/';
        const String topRoute = '/a';

        await tester.pumpWidget(
          _TestWidget(
            navigatorKey: navigator,
            transitionType: SharedAxisTransitionType.scaled,
          ),
        );
        expect(find.text(bottomRoute), findsOneWidget);
        expect(find.text(topRoute), findsNothing);

        navigator.currentState!.pushNamed(topRoute);
        await tester.pump();

        // Jump to halfway point of transition.
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(SharedAxisTransition), findsNWidgets(2));

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
        expect(find.byType(SharedAxisTransition), findsNothing);
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
            transitionType: SharedAxisTransitionType.scaled,
            contentBuilder: (RouteSettings settings) {
              return _StatefulTestWidget(
                key: ValueKey<String?>(settings.name),
                name: settings.name!,
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
          tester.state(find.byKey(
            const ValueKey<String?>(bottomRoute),
            skipOffstage: false,
          )),
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
      },
    );

    testWidgets('default fill color', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      // The default fill color should be derived from ThemeData.canvasColor.
      final Color defaultFillColor = ThemeData().canvasColor;

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
          transitionType: SharedAxisTransitionType.scaled,
        ),
      );

      expect(find.text(bottomRoute), findsOneWidget);
      Finder fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(tester.widget<ColoredBox>(fillContainerFinder).color,
          defaultFillColor);

      navigator.currentState!.pushNamed(topRoute);
      await tester.pump();
      await tester.pumpAndSettle();

      fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/a')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(tester.widget<ColoredBox>(fillContainerFinder).color,
          defaultFillColor);
    });

    testWidgets('custom fill color', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
      const String bottomRoute = '/';
      const String topRoute = '/a';

      await tester.pumpWidget(
        _TestWidget(
          navigatorKey: navigator,
          fillColor: Colors.green,
          transitionType: SharedAxisTransitionType.scaled,
        ),
      );

      expect(find.text(bottomRoute), findsOneWidget);
      Finder fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(
          tester.widget<ColoredBox>(fillContainerFinder).color, Colors.green);

      navigator.currentState!.pushNamed(topRoute);
      await tester.pump();
      await tester.pumpAndSettle();

      fillContainerFinder = find
          .ancestor(
            matching: find.byType(ColoredBox),
            of: find.byKey(const ValueKey<String?>('/a')),
          )
          .last;
      expect(fillContainerFinder, findsOneWidget);
      expect(
          tester.widget<ColoredBox>(fillContainerFinder).color, Colors.green);
    });

    testWidgets('should keep state', (WidgetTester tester) async {
      final AnimationController animation = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      final AnimationController secondaryAnimation = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SharedAxisTransition(
            transitionType: SharedAxisTransitionType.scaled,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: const _StatefulTestWidget(name: 'Foo'),
          ),
        ),
      ));
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
  });
}

double _getOpacity(String key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(ValueKey<String?>(key)),
    matching: find.byType(FadeTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final FadeTransition transition = widget as FadeTransition;
    return a * transition.opacity.value;
  });
}

double _getTranslationOffset(
  String key,
  WidgetTester tester,
  SharedAxisTransitionType transitionType,
) {
  final Finder finder = find.ancestor(
    of: find.byKey(ValueKey<String?>(key)),
    matching: find.byType(Transform),
  );

  switch (transitionType) {
    case SharedAxisTransitionType.horizontal:
      return tester.widgetList<Transform>(finder).fold<double>(0.0,
          (double a, Widget widget) {
        final Transform transition = widget as Transform;
        final Vector3 translation = transition.transform.getTranslation();
        return a + translation.x;
      });
    case SharedAxisTransitionType.vertical:
      return tester.widgetList<Transform>(finder).fold<double>(0.0,
          (double a, Widget widget) {
        final Transform transition = widget as Transform;
        final Vector3 translation = transition.transform.getTranslation();
        return a + translation.y;
      });
    case SharedAxisTransitionType.scaled:
      assert(
        false,
        'SharedAxisTransitionType.scaled does not have a translation offset',
      );
      return 0.0;
  }
}

double _getScale(String key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(ValueKey<String?>(key)),
    matching: find.byType(ScaleTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final ScaleTransition transition = widget as ScaleTransition;
    return a * transition.scale.value;
  });
}

class _TestWidget extends StatelessWidget {
  const _TestWidget({
    required this.navigatorKey,
    this.contentBuilder,
    required this.transitionType,
    this.fillColor,
  });

  final Key navigatorKey;
  final _ContentBuilder? contentBuilder;
  final SharedAxisTransitionType transitionType;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey as GlobalKey<NavigatorState>?,
      theme: ThemeData(
        platform: TargetPlatform.android,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: SharedAxisPageTransitionsBuilder(
              fillColor: fillColor,
              transitionType: transitionType,
            ),
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
  const _StatefulTestWidget({super.key, required this.name});

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
