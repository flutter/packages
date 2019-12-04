// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Internal representation of a child that, now or in the past, was set on the
// PageTransitionSwitcher.child field, but is now in the process of
// transitioning. The internal representation includes fields that we don't want
// to expose to the public API (like the controllers).
class _ChildEntry {
  _ChildEntry({
    @required this.primaryController,
    @required this.secondaryController,
    @required this.transition,
    @required this.widgetChild,
  })  : assert(primaryController != null),
        assert(secondaryController != null),
        assert(widgetChild != null),
        assert(transition != null);

  final AnimationController primaryController;

  final AnimationController secondaryController;

  // The currently built transition for this child.
  Widget transition;

  // The widget's child at the time this entry was created or updated.
  // Used to rebuild the transition if necessary.
  Widget widgetChild;

  void dispose() {
    primaryController.dispose();
    secondaryController.dispose();
  }

  @override
  String toString() => 'Entry#${shortHash(this)}($widgetChild)';
}

/// Signature for builders used to generate custom transitions for
/// [PageTransitionSwitcher].
///
/// The function should return a widget which wraps the given `child`.
typedef PageTransitionSwitcherTransitionBuilder = Widget Function(
  Widget child,
  Animation<double> primaryAnimation,
  Animation<double> secondaryAnimation,
);

/// A widget that transitions from a previously set child to a newly set child
/// using an animation specified by [transitionBuilder].
///
/// This is a variation of an [AnimatedSwitcher], but instead of using the
/// same transition for enter and exit, two separate transitions can be
/// specified, similar to how the enter and exit transitions of a [PageRoute]
/// are defined.
///
/// The transitions returned by the [transitionBuilder] are driven by two
/// animations: a primary one and a secondary one. When a new child is
/// transitioning in while [reverse] is false, the primary animation of the
/// transition associated with that new child is running forward. At the same
/// time, the secondary animation of the previous child is playing forward to
/// transition that child out. In other words, the primary animation defines
/// how a child enters, and the secondary animation determines how it leaves.
/// This is similar to the transition associated with pushing a new [PageRoute]
/// on top of another.
///
/// When [reverse] is true, then the primary animation of the previous child
/// is playing in reverse to reveal the new child underneath, whose secondary
/// animation is also playing in reverse. This is similar to popping a
/// [PageRoute] to reveal a new [PageRoute] underneath it.
///
/// If the children are swapped fast enough (i.e. before [duration] elapses),
/// more than one previous child can exist and be transitioning out while the
/// newest one is transitioning in.
///
/// If the *new* child is the same widget type and key as the *previous* child,
/// but with different parameters, then [PageTransitionSwitcher] will *not* do a
/// transition between them, since as far as the framework is concerned, they
/// are the same widget and the existing widget can be updated with the new
/// parameters. To force the transition to occur, set a [Key] on each child
/// widget that you wish to be considered unique (typically a [ValueKey] on the
/// widget data that distinguishes this child from the others).
///
/// The same key can be used for a new child as was used for an already-outgoing
/// child; the two will not be considered related. (For example, if a progress
/// indicator with key A is first shown, then an image with key B, then another
/// progress indicator with key A again, all in rapid succession, then the old
/// progress indicator and the image will be fading out while a new progress
/// indicator is fading in.)
class PageTransitionSwitcher extends StatefulWidget {
  /// Creates a [PageTransitionSwitcher].
  ///
  /// The [duration], [reverse], and [transitionBuilder] parameters
  /// must not be null.
  const PageTransitionSwitcher({
    Key key,
    this.duration = const Duration(milliseconds: 300),
    this.reverse = false,
    @required this.transitionBuilder,
    this.child,
  })  : assert(duration != null),
        assert(reverse != null),
        assert(transitionBuilder != null),
        super(key: key);

  /// The current child widget to display.
  ///
  /// If there was a previous child, it will be transitioning out using the
  /// secondary animation of the [transitionBuilder], while the new child
  /// transitions in using the primary animation of the [transitionBuilder].
  ///
  /// If there was no previous child, then this child will transition in using
  /// the primary animation of the [transitionBuilder].
  ///
  /// The child is considered to be "new" if it has a different type or [Key]
  /// (see [Widget.canUpdate]).
  final Widget child;

  /// The duration of the transition from the old [child] value to the new one.
  ///
  /// This duration is applied to the given [child] when that property is set to
  /// a new child. Changing [duration] will not affect the
  /// durations of transitions already in progress.
  final Duration duration;

  /// Indicates the direction of the animation when a new [child] is set.
  ///
  /// When this is false, the new child will transition in on top of the
  /// previously set child while its primary animation and the secondary
  /// animation of the previous child are running forward. This is similar to
  /// the transition associated with pushing a new [PageRoute] on top of
  /// another.
  ///
  /// When this is true, the new child will transition in below the
  /// previously set child while its secondary animation and the primary
  /// animation of the previous child are running in reverse. This is similar to
  /// the transition associated with popping a [PageRoute] to reveal a new
  /// [PageRoute] below it.
  final bool reverse;

  /// A function that wraps a new [child] with a primary and secondary animation
  /// to transition between the previously set child and the new child.
  ///
  /// This is only called when a new [child] is set (not for each build), or
  /// when a new [transitionBuilder] is set. If a new [transitionBuilder] is
  /// set, then the transition is rebuilt for the current child and all previous
  /// children using the new [transitionBuilder]. The function must not return
  /// null.
  final PageTransitionSwitcherTransitionBuilder transitionBuilder;

  @override
  _PageTransitionSwitcherState createState() => _PageTransitionSwitcherState();
}

class _PageTransitionSwitcherState extends State<PageTransitionSwitcher>
    with TickerProviderStateMixin {
  final List<_ChildEntry> _activeEntries = <_ChildEntry>[];
  _ChildEntry _currentEntry;
  int _childNumber = 0;

  @override
  void initState() {
    super.initState();
    _addEntryForNewChild(animate: false);
  }

  @override
  void didUpdateWidget(PageTransitionSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the transition builder changed, then update all of the previous
    // transitions.
    if (widget.transitionBuilder != oldWidget.transitionBuilder) {
      _activeEntries.forEach(_updateTransitionForEntry);
    }

    final bool hasNewChild = widget.child != null;
    final bool hasOldChild = _currentEntry != null;
    if (hasNewChild != hasOldChild ||
        hasNewChild &&
            !Widget.canUpdate(widget.child, _currentEntry.widgetChild)) {
      // Child has changed, fade current entry out and add new entry.
      _childNumber += 1;
      _addEntryForNewChild(animate: true);
    } else if (_currentEntry != null) {
      assert(hasOldChild && hasNewChild);
      assert(Widget.canUpdate(widget.child, _currentEntry.widgetChild));
      // Child has been updated. Make sure we update the child widget and
      // transition in _currentEntry even though we're not going to start a new
      // animation, but keep the key from the previous transition so that we
      // update the transition instead of replacing it.
      _currentEntry.widgetChild = widget.child;
      _updateTransitionForEntry(_currentEntry); // uses entry.widgetChild
    }
  }

  void _addEntryForNewChild({@required bool animate}) {
    assert(animate || _currentEntry == null);
    if (_currentEntry != null) {
      assert(animate);
      if (widget.reverse) {
        _currentEntry.primaryController.reverse();
      } else {
        _currentEntry.secondaryController.forward();
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
    if (animate) {
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
      child: widget.child,
      primaryController: primaryController,
      secondaryController: secondaryController,
      builder: widget.transitionBuilder,
    );
    if (widget.reverse && _activeEntries.isNotEmpty) {
      // Add below previous child.
      _activeEntries.insert(_activeEntries.length - 1, _currentEntry);
    } else {
      // Add on top of previous child.
      _activeEntries.add(_currentEntry);
    }
  }

  _ChildEntry _newEntry({
    @required Widget child,
    @required PageTransitionSwitcherTransitionBuilder builder,
    @required AnimationController primaryController,
    @required AnimationController secondaryController,
  }) {
    final _ChildEntry entry = _ChildEntry(
      widgetChild: child,
      transition: KeyedSubtree.wrap(
        builder(child, primaryController, secondaryController),
        _childNumber,
      ),
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
    entry.transition = KeyedSubtree(
      key: entry.transition.key,
      child: widget.transitionBuilder(
        entry.widgetChild,
        entry.primaryController,
        entry.secondaryController,
      ),
    );
  }

  @override
  void dispose() {
    for (_ChildEntry entry in _activeEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _activeEntries
          .map<Widget>((_ChildEntry entry) => entry.transition)
          .toList(),
      alignment: Alignment.center,
    );
  }
}
