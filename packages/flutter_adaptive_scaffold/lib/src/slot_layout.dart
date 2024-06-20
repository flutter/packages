// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// A Widget that takes a mapping of [SlotLayoutConfig]s to [Breakpoint]s and
/// adds the appropriate Widget based on the current screen size.
///
/// See also:
/// * [AdaptiveLayout], where [SlotLayout]s are assigned to placements on the
///   screen called "slots".
class SlotLayout extends StatefulWidget {
  /// Creates a [SlotLayout] widget.
  const SlotLayout({required this.config, super.key});

  /// Given a context and a config, it returns the [SlotLayoutConfig] that will
  /// be chosen from the config under the context's conditions.
  static SlotLayoutConfig? pickWidget(
      BuildContext context, Map<Breakpoint, SlotLayoutConfig?> config) {
    final Breakpoint? breakpoint =
        Breakpoint.activeBreakpointIn(context, config.keys.toList());
    return breakpoint != null && config.containsKey(breakpoint)
        ? config[breakpoint]
        : null;
  }

  /// Maps [Breakpoint]s to [SlotLayoutConfig]s to determine what Widget to
  /// display on which condition of screens.
  ///
  /// The [SlotLayoutConfig]s in this map are nullable since some breakpoints
  /// apply to more open ranges and the nullability allows one to override the
  /// value at that Breakpoint to be null.
  ///
  /// [SlotLayout] picks the last [SlotLayoutConfig] whose corresponding
  /// [Breakpoint.isActive] returns true.
  ///
  /// If two [Breakpoint]s are active concurrently then the latter one defined
  /// in the map takes priority.
  final Map<Breakpoint, SlotLayoutConfig?> config;

  /// A wrapper for the children passed to [SlotLayout] to provide appropriate
  /// config information.
  ///
  /// Acts as a delegate to the abstract class [SlotLayoutConfig].
  /// It first takes a builder which returns the child Widget that [SlotLayout]
  /// eventually displays with an animation.
  ///
  /// It also takes an inAnimation and outAnimation to describe how the Widget
  /// should be animated as it is switched in or out from [SlotLayout]. These
  /// are both defined as functions that takes a [Widget] and an [Animation] and
  /// return a [Widget]. These functions are passed to the [AnimatedSwitcher]
  /// inside [SlotLayout] and are to be played when the child enters/exits.
  ///
  /// Last, it takes a required key. The key should be kept constant but unique
  /// as this key is what is used to let the [SlotLayout] know that a change has
  /// been made to its child.
  ///
  /// If you define a given animation phase, there may be multiple
  /// widgets being displayed depending on the phases you have chosen to animate.
  /// If you are using GlobalKeys, this may cause issues with the
  /// [AnimatedSwitcher].
  ///
  /// See also:
  ///
  ///  * [AnimatedWidget] and [ImplicitlyAnimatedWidget], which are commonly used
  ///   as the returned widget for the inAnimation and outAnimation functions.
  ///  * [AnimatedSwitcher.defaultTransitionBuilder], which is what takes the
  ///   inAnimation and outAnimation.
  static SlotLayoutConfig from({
    WidgetBuilder? builder,
    Widget Function(Widget, Animation<double>)? inAnimation,
    Widget Function(Widget, Animation<double>)? outAnimation,
    Duration? inDuration,
    Duration? outDuration,
    Curve? inCurve,
    Curve? outCurve,
    required Key key,
  }) =>
      SlotLayoutConfig._(
        builder: builder,
        inAnimation: inAnimation,
        outAnimation: outAnimation,
        inDuration: inDuration,
        outDuration: outDuration,
        inCurve: inCurve,
        outCurve: outCurve,
        key: key,
      );

  @override
  State<SlotLayout> createState() => _SlotLayoutState();
}

class _SlotLayoutState extends State<SlotLayout>
    with SingleTickerProviderStateMixin {
  SlotLayoutConfig? chosenWidget;

  @override
  Widget build(BuildContext context) {
    chosenWidget = SlotLayout.pickWidget(context, widget.config);
    bool hasAnimation = false;
    return AnimatedSwitcher(
        duration:
            chosenWidget?.inDuration ?? const Duration(milliseconds: 1000),
        reverseDuration: chosenWidget?.outDuration,
        switchInCurve: chosenWidget?.inCurve ?? Curves.linear,
        switchOutCurve: chosenWidget?.outCurve ?? Curves.linear,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          final Stack elements = Stack(
            children: <Widget>[
              if (hasAnimation && previousChildren.isNotEmpty)
                previousChildren.first,
              if (currentChild != null) currentChild,
            ],
          );
          return elements;
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final SlotLayoutConfig configChild = child as SlotLayoutConfig;
          if (child.key == chosenWidget?.key) {
            return (configChild.inAnimation != null)
                ? child.inAnimation!(child, animation)
                : child;
          } else {
            if (configChild.outAnimation != null) {
              hasAnimation = true;
            }
            return (configChild.outAnimation != null)
                ? child.outAnimation!(child, ReverseAnimation(animation))
                : child;
          }
        },
        child: chosenWidget ?? SlotLayoutConfig.empty());
  }
}

/// Defines how [SlotLayout] should display under a certain [Breakpoint].
class SlotLayoutConfig extends StatelessWidget {
  /// Creates a new [SlotLayoutConfig].
  ///
  /// Returns the child widget as is but holds properties to be accessed by other
  /// classes.
  const SlotLayoutConfig._({
    super.key,
    required this.builder,
    this.inAnimation,
    this.outAnimation,
    this.inDuration,
    this.outDuration,
    this.inCurve,
    this.outCurve,
  });

  /// The child Widget that [SlotLayout] eventually returns with an animation.
  final WidgetBuilder? builder;

  /// A function that provides the animation to be wrapped around the builder
  /// child as it is being moved in during a switch in [SlotLayout].
  ///
  /// See also:
  ///
  ///  * [AnimatedWidget] and [ImplicitlyAnimatedWidget], which are commonly used
  ///   as the returned widget.
  final Widget Function(Widget, Animation<double>)? inAnimation;

  /// A function that provides the animation to be wrapped around the builder
  /// child as it is being moved in during a switch in [SlotLayout].
  ///
  /// See also:
  ///
  ///  * [AnimatedWidget] and [ImplicitlyAnimatedWidget], which are commonly used
  ///   as the returned widget.
  final Widget Function(Widget, Animation<double>)? outAnimation;

  /// The duration of the transition from the old child to the new one during
  /// a switch in [SlotLayout].
  final Duration? inDuration;

  /// The duration of the transition from the new child to the old one during
  /// a switch in [SlotLayout].
  final Duration? outDuration;

  /// The animation curve to use when transitioning in a new child during a
  /// switch in [SlotLayout].
  final Curve? inCurve;

  /// The animation curve to use when transitioning a previous slot out during
  /// a switch in [SlotLayout].
  final Curve? outCurve;

  /// An empty [SlotLayoutConfig] to be placed in a slot to indicate that the slot
  /// should show nothing.
  static SlotLayoutConfig empty() {
    return const SlotLayoutConfig._(key: Key(''), builder: null);
  }

  @override
  Widget build(BuildContext context) {
    return (builder != null) ? builder!(context) : const SizedBox.shrink();
  }
}
