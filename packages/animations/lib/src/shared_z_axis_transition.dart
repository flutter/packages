// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'utils/curves.dart';

/// Used by [PageTransitionsTheme] to define a page route transition animation
/// in which outgoing and incoming elements share a scale transition.
///
/// The shared axis pattern provides the transition animation between UI elements
/// that have a spatial or navigational relationship. For example,
/// transitioning from one page of a sign up page to the next one.
///
///
/// The following example shows how the SharedZAxisPageTransitionsBuilder can
/// be used in a [PageTransitionsTheme] to change the default transitions
/// of [MaterialPageRoute]s.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     pageTransitionsTheme: PageTransitionsTheme(
///       builders: {
///         TargetPlatform.android: SharedZAxisPageTransitionsBuilder(),
///         TargetPlatform.iOS: SharedZAxisPageTransitionsBuilder(),
///       },
///     ),
///   ),
///   routes: {
///     '/': (BuildContext context) {
///       return Container(
///         color: Colors.red,
///         child: Center(
///           child: MaterialButton(
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
///           child: MaterialButton(
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
class SharedZAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Construct a [SharedZAxisPageTransitionsBuilder].
  const SharedZAxisPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedZAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Defines a transition in which outgoing and incoming elements share a scale
/// transition.
///
/// The shared axis pattern provides the transition animation between UI elements
/// that have a spatial or navigational relationship. For example,
/// transitioning from one page of a sign up page to the next one.
///
/// Consider using [SharedZAxisTransition] within a
/// [PageTransitionsTheme] if you want to apply this kind of transition to
/// [MaterialPageRoute] transitions within a Navigator (see
/// [SharedZAxisPageTransitionsBuilder] for some example code).
///
/// This transition can also be used directly in a
/// [PageTransitionSwitcher.transitionBuilder] to transition
/// from one widget to another as seen in the following example:
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
///         return SharedZAxisTransition(
///           animation: primaryAnimation,
///           secondaryAnimation: secondaryAnimation,
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
class SharedZAxisTransition extends StatefulWidget {
  /// Creates a [SharedZAxisTransition].
  ///
  /// The [animation] and [secondaryAnimation] argument are required and must
  /// not be null.
  const SharedZAxisTransition({
    Key key,
    @required this.animation,
    @required this.secondaryAnimation,
    this.child,
  }) : super(key: key);

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

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget child;

  @override
  _SharedZAxisTransitionState createState() => _SharedZAxisTransitionState();
}

class _SharedZAxisTransitionState extends State<SharedZAxisTransition> {
  @override
  Widget build(BuildContext context) {
    // Scale Transitions
    final Animation<double> _forwardEndScreenScaleTransition = widget.animation.drive(
      Tween<double>(begin: 0.80, end: 1.00)
        .chain(standardEasing));

    final Animation<double> _forwardStartScreenScaleTransition = widget.secondaryAnimation.drive(
      Tween<double>(begin: 1.00, end: 1.10)
        .chain(standardEasing));

    // Fade Transitions
    final Animation<double> _forwardStartScreenFadeTransition = flipTween(widget.secondaryAnimation).drive(
      accelerateEasing
        .chain(CurveTween(curve: const Interval(0.0, 0.3))));

    final Animation<double> _forwardEndScreenFadeTransition = widget.animation.drive(
      decelerateEasing
        .chain(CurveTween(curve: const Interval(0.3, 1.0))));

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: _forwardEndScreenFadeTransition,
          child: ScaleTransition(
            scale: _forwardEndScreenScaleTransition,
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: widget.secondaryAnimation,
        builder: (BuildContext context, Widget child) {
          return Container(
            color: Theme.of(context).canvasColor,
            child: FadeTransition(
              opacity: _forwardStartScreenFadeTransition,
              child: ScaleTransition(
                scale: _forwardStartScreenScaleTransition,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}