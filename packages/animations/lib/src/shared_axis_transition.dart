// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'composite_animation_widget.dart';
import 'utils/curves.dart';

/// Determines which type of shared axis transition is used.
enum SharedAxisTransitionType {
  /// Creates a shared axis vertical (y-axis) page transition.
  vertical,

  /// Creates a shared axis horizontal (x-axis) page transition.
  horizontal,

  /// Creates a shared axis scaled (z-axis) page transition.
  scaled,
}

/// Used by [PageTransitionsTheme] to define a page route transition animation
/// in which outgoing and incoming elements share a fade transition.
///
/// The shared axis pattern provides the transition animation between UI elements
/// that have a spatial or navigational relationship. For example,
/// transitioning from one page of a sign up page to the next one.
///
/// The following example shows how the SharedAxisPageTransitionsBuilder can
/// be used in a [PageTransitionsTheme] to change the default transitions
/// of [MaterialPageRoute]s.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     pageTransitionsTheme: PageTransitionsTheme(
///       builders: {
///         TargetPlatform.android: SharedAxisPageTransitionsBuilder(
///           transitionType: SharedAxisTransitionType.horizontal,
///         ),
///         TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
///           transitionType: SharedAxisTransitionType.horizontal,
///         ),
///       },
///     ),
///   ),
///   routes: {
///     '/': (BuildContext context) {
///       return Container(
///         color: Colors.red,
///         child: Center(
///           child: RaisedButton(
///             child: Text('Push route'),
///             onPressed: () {
///               Navigator.of(context).pushNamed('/a');
///             },
///           ),
///         ),
///       );
///     },
///     '/a' : (BuildContext context) {
///       return Container(
///         color: Colors.blue,
///         child: Center(
///           child: RaisedButton(
///             child: Text('Pop route'),
///             onPressed: () {
///               Navigator.of(context).pop();
///             },
///           ),
///         ),
///       );
///     },
///   },
/// );
/// ```
class SharedAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Construct a [SharedAxisPageTransitionsBuilder].
  const SharedAxisPageTransitionsBuilder({
    this.transitionType,
    this.fillColor,
  });

  /// Determines which [SharedAxisTransitionType] to build.
  final SharedAxisTransitionType transitionType;

  /// The color to use for the background color during the transition.
  ///
  /// This defaults to the [Theme]'s [ThemeData.canvasColor].
  final Color fillColor;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: transitionType,
      fillColor: fillColor,
      child: child,
    );
  }
}

/// Defines a transition in which outgoing and incoming elements share a fade
/// transition.
///
/// The shared axis pattern provides the transition animation between UI elements
/// that have a spatial or navigational relationship. For example,
/// transitioning from one page of a sign up page to the next one.
///
/// Consider using [SharedAxisTransition] within a
/// [PageTransitionsTheme] if you want to apply this kind of transition to
/// [MaterialPageRoute] transitions within a Navigator (see
/// [SharedAxisPageTransitionsBuilder] for example code).
///
/// This transition can also be used directly in a
/// [PageTransitionSwitcher.transitionBuilder] to transition
/// from one widget to another as seen in the following example:
///
/// ```dart
/// int _selectedIndex = 0;
///
/// final List<Color> _colors = [Colors.white, Colors.red, Colors.yellow];
///
/// @override
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: AppBar(
///       title: const Text('Page Transition Example'),
///     ),
///     body: PageTransitionSwitcher(
///       // reverse: true, // uncomment to see transition in reverse
///       transitionBuilder: (
///         Widget child,
///         Animation<double> primaryAnimation,
///         Animation<double> secondaryAnimation,
///       ) {
///         return SharedAxisTransition(
///           animation: primaryAnimation,
///           secondaryAnimation: secondaryAnimation,
///           transitionType: SharedAxisTransitionType.horizontal,
///           child: child,
///         );
///       },
///       child: Container(
///         key: ValueKey<int>(_selectedIndex),
///         color: _colors[_selectedIndex],
///         child: Center(
///           child: FlutterLogo(size: 300),
///         )
///       ),
///     ),
///     bottomNavigationBar: BottomNavigationBar(
///       items: const <BottomNavigationBarItem>[
///         BottomNavigationBarItem(
///           icon: Icon(Icons.home),
///           title: Text('White'),
///         ),
///         BottomNavigationBarItem(
///           icon: Icon(Icons.business),
///           title: Text('Red'),
///         ),
///         BottomNavigationBarItem(
///           icon: Icon(Icons.school),
///           title: Text('Yellow'),
///         ),
///       ],
///       currentIndex: _selectedIndex,
///       onTap: (int index) {
///         setState(() {
///           _selectedIndex = index;
///         });
///       },
///     ),
///   );
/// }
/// ```
class SharedAxisTransition extends StatelessWidget {
  /// Creates a [SharedAxisTransition].
  ///
  /// The [animation] and [secondaryAnimation] argument are required and must
  /// not be null.
  const SharedAxisTransition({
    Key key,
    @required this.animation,
    @required this.secondaryAnimation,
    @required this.transitionType,
    this.fillColor,
    this.child,
  })  : assert(transitionType != null),
        super(key: key);

  /// The animation that drives the [child]'s entrance and exit.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.animate], which is the value given to this property
  ///    when it is used as a page transition.
  final Animation<double> animation;

  /// The animation that transitions [child] when new content is pushed on top
  /// of it.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.secondaryAnimation], which is the value given to this
  ///    property when the it is used as a page transition.
  final Animation<double> secondaryAnimation;

  /// Determines which type of shared axis transition is used.
  ///
  /// See also:
  ///
  ///  * [SharedAxisTransitionType], which defines and describes all shared
  ///    axis transition types.
  final SharedAxisTransitionType transitionType;

  /// The color to use for the background color during the transition.
  ///
  /// This defaults to the [Theme]'s [ThemeData.canvasColor].
  final Color fillColor;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget child;

  static final Tween<double> _flippedTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  static Animation<double> _flip(Animation<double> animation) {
    return _flippedTween.animate(animation);
  }

  @override
  Widget build(BuildContext context) {
    return CompositeAnimationWidget(
      animation: animation,
      forwardTransitionBuilder: (Widget child, Animation<double> animation) {
        return _EnterTransition(
          animation: animation,
          transitionType: transitionType,
          child: child,
        );
      },
      reverseTransitionBuilder: (Widget child, Animation<double> animation) {
        return _ExitTransition(
          animation: _flip(animation),
          transitionType: transitionType,
          reverse: true,
          fillColor: fillColor,
          child: child,
        );
      },
      child: CompositeAnimationWidget(
        animation: secondaryAnimation,
        visibleAtStart: true,
        forwardTransitionBuilder: (Widget child, Animation<double> animation) {
          return _ExitTransition(
            animation: animation,
            transitionType: transitionType,
            fillColor: fillColor,
            child: child,
          );
        },
        reverseTransitionBuilder: (Widget child, Animation<double> animation) {
          return _EnterTransition(
            animation: _flip(animation),
            transitionType: transitionType,
            reverse: true,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

class _EnterTransition extends StatelessWidget {
  const _EnterTransition({
    this.animation,
    this.transitionType,
    this.reverse = false,
    this.child,
  });

  final Animation<double> animation;
  final SharedAxisTransitionType transitionType;
  final Widget child;
  final bool reverse;

  static final Animatable<double> _fadeInTransition = CurveTween(
    curve: decelerateEasing,
  ).chain(CurveTween(curve: const Interval(0.3, 1.0)));

  static final Animatable<double> _scaleDownTransition = Tween<double>(
    begin: 1.10,
    end: 1.00,
  ).chain(CurveTween(curve: standardEasing));

  static final Animatable<double> _scaleUpTransition = Tween<double>(
    begin: 0.80,
    end: 1.00,
  ).chain(CurveTween(curve: standardEasing));

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        final Animatable<Offset> slideInTransition = Tween<Offset>(
          begin: Offset(!reverse ? 30.0 : -30.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: standardEasing));

        return FadeTransition(
          opacity: _fadeInTransition.animate(animation),
          child: Transform.translate(
            offset: slideInTransition.evaluate(animation),
            child: child,
          ),
        );
        break;
      case SharedAxisTransitionType.vertical:
        final Animatable<Offset> slideInTransition = Tween<Offset>(
          begin: Offset(0.0, !reverse ? 30.0 : -30.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: standardEasing));

        return FadeTransition(
          opacity: _fadeInTransition.animate(animation),
          child: Transform.translate(
            offset: slideInTransition.evaluate(animation),
            child: child,
          ),
        );
        break;
      case SharedAxisTransitionType.scaled:
        return FadeTransition(
          opacity: _fadeInTransition.animate(animation),
          child: ScaleTransition(
            scale: (!reverse ? _scaleUpTransition : _scaleDownTransition)
                .animate(animation),
            child: child,
          ),
        );
        break;
    }
    return null; // unreachable
  }
}

class _ExitTransition extends StatelessWidget {
  const _ExitTransition({
    this.animation,
    this.transitionType,
    this.reverse = false,
    this.fillColor,
    this.child,
  });

  final Animation<double> animation;
  final SharedAxisTransitionType transitionType;
  final bool reverse;
  final Color fillColor;
  final Widget child;

  static final Animatable<double> _fadeOutTransition = FlippedCurveTween(
    curve: accelerateEasing,
  ).chain(CurveTween(curve: const Interval(0.0, 0.3)));

  static final Animatable<double> _scaleUpTransition = Tween<double>(
    begin: 1.00,
    end: 1.10,
  ).chain(CurveTween(curve: standardEasing));

  static final Animatable<double> _scaleDownTransition = Tween<double>(
    begin: 1.00,
    end: 0.80,
  ).chain(CurveTween(curve: standardEasing));

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        final Animatable<Offset> slideOutTransition = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(!reverse ? -30.0 : 30.0, 0.0),
        ).chain(CurveTween(curve: standardEasing));

        return FadeTransition(
          opacity: _fadeOutTransition.animate(animation),
          child: Container(
            color: fillColor ?? Theme.of(context).canvasColor,
            child: Transform.translate(
              offset: slideOutTransition.evaluate(animation),
              child: child,
            ),
          ),
        );
        break;
      case SharedAxisTransitionType.vertical:
        final Animatable<Offset> slideOutTransition = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(0.0, !reverse ? -30.0 : 30.0),
        ).chain(CurveTween(curve: standardEasing));

        return FadeTransition(
          opacity: _fadeOutTransition.animate(animation),
          child: Container(
            color: fillColor ?? Theme.of(context).canvasColor,
            child: Transform.translate(
              offset: slideOutTransition.evaluate(animation),
              child: child,
            ),
          ),
        );
        break;
      case SharedAxisTransitionType.scaled:
        return FadeTransition(
          opacity: _fadeOutTransition.animate(animation),
          child: Container(
            color: fillColor ?? Theme.of(context).canvasColor,
            child: ScaleTransition(
              scale: (!reverse ? _scaleUpTransition : _scaleDownTransition)
                  .animate(animation),
              child: child,
            ),
          ),
        );
        break;
    }
    return null; // unreachable
  }
}
