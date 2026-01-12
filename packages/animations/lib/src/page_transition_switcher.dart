// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An internal representation of a child widget subtree that, now or in the past,
/// was set on the [PageTransitionSwitcher.child] field and is now in the process of
/// transitioning.
///
/// The internal representation includes fields that we don't want to expose to
/// the public API (like the controllers).
class _ChildEntry {
  /// Creates a [_ChildEntry].
  ///
  /// The [primaryController], [secondaryController], [transition] and
  /// [widgetChild] parameters must not be null.
  _ChildEntry({
    required this.primaryController,
    required this.secondaryController,
    required this.transition,
    required this.widgetChild,
  });

  /// The animation controller for the child's transition.
  final AnimationController primaryController;

  /// The (curved) animation being used to drive the transition.
  final AnimationController secondaryController;

  /// The currently built transition for this child.
  Widget transition;

  /// The widget's child at the time this entry was created or updated.
  /// Used to rebuild the transition if necessary.
  Widget widgetChild;

  /// Release the resources used by this object.
  ///
  /// The object is no longer usable after this method is called.
  void dispose() {
    primaryController.dispose();
    secondaryController.dispose();
  }

  @override
  String toString() {
    return 'PageTransitionSwitcherEntry#${shortHash(this)}($widgetChild)';
  }
}

/// Signature for builders used to generate custom layouts for
/// [PageTransitionSwitcher].
///
/// The builder should return a widget which contains the given children, laid
/// out as desired. It must not return null. The builder should be able to
/// handle an empty list of `entries`.
typedef PageTransitionSwitcherLayoutBuilder =
    Widget Function(List<Widget> entries);

/// Signature for builders used to generate custom transitions for
/// [PageTransitionSwitcher].
///
/// The function should return a widget which wraps the given `child`.
///
/// When a [PageTransitionSwitcher]'s `child` is replaced, the new child's
/// `primaryAnimation` runs forward and the value of its `secondaryAnimation` is
/// usually fixed at 0.0. At the same time, the old child's `secondaryAnimation`
/// runs forward, and the value of its primaryAnimation is usually fixed at 1.0.
///
/// The widget returned by the [PageTransitionSwitcherTransitionBuilder] can
/// incorporate both animations. It will use the primary animation to define how
/// its child appears, and the secondary animation to define how its child
/// disappears.
typedef PageTransitionSwitcherTransitionBuilder =
    Widget Function(
      Widget child,
      Animation<double> primaryAnimation,
      Animation<double> secondaryAnimation,
    );

/// A widget that transitions from an old child to a new child whenever [child]
/// changes using an animation specified by [transitionBuilder].
///
/// This is a variation of an [AnimatedSwitcher], but instead of using the
/// same transition for enter and exit, two separate transitions can be
/// specified, similar to how the enter and exit transitions of a [PageRoute]
/// are defined.
///
/// When a new [child] is specified, the [transitionBuilder] is effectively
/// applied twice, once to the old child and once to the new one. When
/// [reverse] is false, the old child's `secondaryAnimation` runs forward, and
/// the value of its `primaryAnimation` is usually fixed at 1.0. The new child's
/// `primaryAnimation` runs forward and the value of its `secondaryAnimation` is
/// usually fixed at 0.0. The widget returned by the [transitionBuilder] can
/// incorporate both animations. It will use the primary animation to define how
/// its child appears, and the secondary animation to define how its child
/// disappears. This is similar to the transition associated with pushing a new
/// [PageRoute] on top of another.
///
/// When [reverse] is true, the old child's `primaryAnimation` runs in reverse
/// and the value of its `secondaryAnimation` is usually fixed at 0.0. The new
/// child's `secondaryAnimation` runs in reverse and the value of its
/// `primaryAnimation` is usually fixed at 1.0. This is similar to popping a
/// [PageRoute] to reveal another [PageRoute] underneath it.
///
/// This process is the same as the one used by [PageRoute.buildTransitions].
///
/// The following example shows a [transitionBuilder] that slides out the
/// old child to the right (driven by the `secondaryAnimation`) while the new
/// child fades in (driven by the `primaryAnimation`):
///
/// ```dart
/// transitionBuilder: (
///   Widget child,
///   Animation<double> primaryAnimation,
///   Animation<double> secondaryAnimation,
/// ) {
///   return SlideTransition(
///     position: Tween<Offset>(
///       begin: Offset.zero,
///       end: const Offset(1.5, 0.0),
///     ).animate(secondaryAnimation),
///     child: FadeTransition(
///       opacity: Tween<double>(
///         begin: 0.0,
///         end: 1.0,
///       ).animate(primaryAnimation),
///       child: child,
///     ),
///   );
/// },
/// ```
///
/// If the children are swapped fast enough (i.e. before [duration] elapses),
/// more than one old child can exist and be transitioning out while the
/// newest one is transitioning in.
///
/// If the *new* child is the same widget type and key as the *old* child,
/// but with different parameters, then [PageTransitionSwitcher] will *not* do a
/// transition between them, since as far as the framework is concerned, they
/// are the same widget and the existing widget can be updated with the new
/// parameters. To force the transition to occur, set a [Key] on each child
/// widget that you wish to be considered unique (typically a [ValueKey] on the
/// widget data that distinguishes this child from the others). For example,
/// changing the child from `SizedBox(width: 10)` to `SizedBox(width: 100)`
/// would not trigger a transition but changing the child from
/// `SizedBox(width: 10)` to `SizedBox(key: Key('foo'), width: 100)` would.
/// Similarly, changing the child to `Container(width: 10)` would trigger a
/// transition.
///
/// The same key can be used for a new child as was used for an already-outgoing
/// child; the two will not be considered related. For example, if a progress
/// indicator with key A is first shown, then an image with key B, then another
/// progress indicator with key A again, all in rapid succession, then the old
/// progress indicator and the image will be fading out while a new progress
/// indicator is fading in.
///
/// PageTransitionSwitcher uses the [layoutBuilder] property to lay out the
/// old and new child widgets. By default, [defaultLayoutBuilder] is used.
/// See the documentation for [layoutBuilder] for suggestions on how to
/// configure the layout of the incoming and outgoing child widgets if
/// [defaultLayoutBuilder] is not your desired layout.
class PageTransitionSwitcher extends StatefulWidget {
  /// Creates a [PageTransitionSwitcher].
  ///
  /// The [duration], [reverse], and [transitionBuilder] parameters
  /// must not be null.
  const PageTransitionSwitcher({
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.reverse = false,
    required this.transitionBuilder,
    this.layoutBuilder = defaultLayoutBuilder,
    this.child,
  });

  /// The current child widget to display.
  ///
  /// If there was an old child, it will be transitioned out using the
  /// secondary animation of the [transitionBuilder], while the new child
  /// transitions in using the primary animation of the [transitionBuilder].
  ///
  /// If there was no old child, then this child will transition in using
  /// the primary animation of the [transitionBuilder].
  ///
  /// The child is considered to be "new" if it has a different type or [Key]
  /// (see [Widget.canUpdate]).
  final Widget? child;

  /// The duration of the transition from the old [child] value to the new one.
  ///
  /// This duration is applied to the given [child] when that property is set to
  /// a new child. Changing [duration] will not affect the durations of
  /// transitions already in progress.
  final Duration duration;

  /// Indicates whether the new [child] will visually appear on top of or
  /// underneath the old child.
  ///
  /// When this is false, the new child will transition in on top of the
  /// old child while its primary animation and the secondary
  /// animation of the old child are running forward. This is similar to
  /// the transition associated with pushing a new [PageRoute] on top of
  /// another.
  ///
  /// When this is true, the new child will transition in below the
  /// old child while its secondary animation and the primary
  /// animation of the old child are running in reverse. This is similar to
  /// the transition associated with popping a [PageRoute] to reveal a new
  /// [PageRoute] below it.
  final bool reverse;

  /// A function that wraps a new [child] with a primary and secondary animation
  /// set define how the child appears and disappears.
  ///
  /// This is only called when a new [child] is set (not for each build), or
  /// when a new [transitionBuilder] is set. If a new [transitionBuilder] is
  /// set, then the transition is rebuilt for the current child and all old
  /// children using the new [transitionBuilder]. The function must not return
  /// null.
  ///
  /// The child provided to the transitionBuilder may be null.
  final PageTransitionSwitcherTransitionBuilder transitionBuilder;

  /// A function that wraps all of the children that are transitioning out, and
  /// the [child] that's transitioning in, with a widget that lays all of them
  /// out. This is called every time this widget is built. The function must not
  /// return null.
  ///
  /// The default [PageTransitionSwitcherLayoutBuilder] used is
  /// [defaultLayoutBuilder].
  ///
  /// The following example shows a [layoutBuilder] that places all entries in a
  /// [Stack] that sizes itself to match the largest of the active entries.
  /// All children are aligned on the top left corner of the [Stack].
  ///
  /// ```dart
  /// PageTransitionSwitcher(
  ///   duration: const Duration(milliseconds: 100),
  ///   child: Container(color: Colors.red),
  ///   layoutBuilder: (
  ///     List<Widget> entries,
  ///   ) {
  ///     return Stack(
  ///       children: entries,
  ///       alignment: Alignment.topLeft,
  ///     );
  ///   },
  /// ),
  /// ```
  /// See [PageTransitionSwitcherLayoutBuilder] for more information about
  /// how a layout builder should function.
  final PageTransitionSwitcherLayoutBuilder layoutBuilder;

  /// The default layout builder for [PageTransitionSwitcher].
  ///
  /// This function is the default way for how the new and old child widgets are placed
  /// during the transition between the two widgets. All children are placed in a
  /// [Stack] that sizes itself to match the largest of the child or a previous child.
  /// The children are centered on each other.
  ///
  /// See [PageTransitionSwitcherTransitionBuilder] for more information on the function
  /// signature.
  static Widget defaultLayoutBuilder(List<Widget> entries) {
    return Stack(alignment: Alignment.center, children: entries);
  }

  @override
  State<PageTransitionSwitcher> createState() => _PageTransitionSwitcherState();
}

class _PageTransitionSwitcherState extends State<PageTransitionSwitcher>
    with TickerProviderStateMixin {
  final List<_ChildEntry> _activeEntries = <_ChildEntry>[];
  _ChildEntry? _currentEntry;
  int _childNumber = 0;

  @override
  void initState() {
    super.initState();
    _addEntryForNewChild(shouldAnimate: false);
  }

  @override
  void didUpdateWidget(PageTransitionSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the transition builder changed, then update all of the old
    // transitions.
    if (widget.transitionBuilder != oldWidget.transitionBuilder) {
      _activeEntries.forEach(_updateTransitionForEntry);
    }

    final bool hasNewChild = widget.child != null;
    final bool hasOldChild = _currentEntry != null;
    if (hasNewChild != hasOldChild ||
        hasNewChild &&
            !Widget.canUpdate(widget.child!, _currentEntry!.widgetChild)) {
      // Child has changed, fade current entry out and add new entry.
      _childNumber += 1;
      _addEntryForNewChild(shouldAnimate: true);
    } else if (_currentEntry != null) {
      assert(hasOldChild && hasNewChild);
      assert(Widget.canUpdate(widget.child!, _currentEntry!.widgetChild));
      // Child has been updated. Make sure we update the child widget and
      // transition in _currentEntry even though we're not going to start a new
      // animation, but keep the key from the old transition so that we
      // update the transition instead of replacing it.
      _currentEntry!.widgetChild = widget.child!;
      _updateTransitionForEntry(_currentEntry!); // uses entry.widgetChild
    }
  }

  void _addEntryForNewChild({required bool shouldAnimate}) {
    assert(shouldAnimate || _currentEntry == null);
    if (_currentEntry != null) {
      assert(shouldAnimate);
      if (widget.reverse) {
        _currentEntry!.primaryController.reverse();
      } else {
        _currentEntry!.secondaryController.forward();
      }
      _currentEntry = null;
    }
    if (widget.child == null) {
      return;
    }
    final AnimationController primaryController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    final AnimationController secondaryController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    if (shouldAnimate) {
      if (widget.reverse) {
        primaryController.value = 1.0;
        secondaryController.value = 1.0;
        secondaryController.reverse();
      } else {
        primaryController.forward();
      }
    } else {
      assert(_activeEntries.isEmpty);
      primaryController.value = 1.0;
    }
    _currentEntry = _newEntry(
      child: widget.child!,
      primaryController: primaryController,
      secondaryController: secondaryController,
      builder: widget.transitionBuilder,
    );
    if (widget.reverse && _activeEntries.isNotEmpty) {
      // Add below old child.
      _activeEntries.insert(_activeEntries.length - 1, _currentEntry!);
    } else {
      // Add on top of old child.
      _activeEntries.add(_currentEntry!);
    }
  }

  _ChildEntry _newEntry({
    required Widget child,
    required PageTransitionSwitcherTransitionBuilder builder,
    required AnimationController primaryController,
    required AnimationController secondaryController,
  }) {
    final Widget transition = builder(
      child,
      primaryController,
      secondaryController,
    );
    final _ChildEntry entry = _ChildEntry(
      widgetChild: child,
      transition: KeyedSubtree.wrap(transition, _childNumber),
      primaryController: primaryController,
      secondaryController: secondaryController,
    );
    secondaryController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        assert(mounted);
        assert(_activeEntries.contains(entry));
        setState(() {
          _activeEntries.remove(entry);
          entry.dispose();
        });
      }
    });
    primaryController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        assert(mounted);
        assert(_activeEntries.contains(entry));
        setState(() {
          _activeEntries.remove(entry);
          entry.dispose();
        });
      }
    });
    return entry;
  }

  void _updateTransitionForEntry(_ChildEntry entry) {
    final Widget transition = widget.transitionBuilder(
      entry.widgetChild,
      entry.primaryController,
      entry.secondaryController,
    );
    entry.transition = KeyedSubtree(
      key: entry.transition.key,
      child: transition,
    );
  }

  @override
  void dispose() {
    for (final _ChildEntry entry in _activeEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.layoutBuilder(
      _activeEntries
          .map<Widget>((_ChildEntry entry) => entry.transition)
          .toList(),
    );
  }
}
