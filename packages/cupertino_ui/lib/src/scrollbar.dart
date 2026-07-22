// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'package:material_ui/material_ui.dart';
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';

// All values eyeballed.
const double _kScrollbarMinLength = 36.0;
const double _kScrollbarMinOverscrollLength = 8.0;
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 1200);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
const Duration _kScrollbarResizeDuration = Duration(milliseconds: 100);

// Extracted from iOS 13.1 beta using Debug View Hierarchy.
const Color _kScrollbarColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x59000000),
  darkColor: Color(0x80FFFFFF),
);

// This is the amount of space from the top of a vertical scrollbar to the
// top edge of the scrollable, measured when the vertical scrollbar overscrolls
// to the top.
// TODO(LongCatIsLooong): fix https://github.com/flutter/flutter/issues/32175
const double _kScrollbarMainAxisMargin = 3.0;
const double _kScrollbarCrossAxisMargin = 3.0;

/// An iOS style scrollbar.
///
/// To add a scrollbar to a [ScrollView], wrap the scroll view widget in
/// a [CupertinoScrollbar] widget.
///
/// A scrollbar thumb indicates which portion of a [ScrollView] is actually
/// visible.
///
/// By default, the thumb will fade in and out as the child scroll view
/// scrolls. When [thumbVisibility] is true, the scrollbar thumb will remain
/// visible without the fade animation. This requires that the [ScrollController]
/// associated with the Scrollable widget is provided to [controller], or that
/// the [PrimaryScrollController] is being used by that Scrollable widget.
///
/// If the scrollbar is wrapped around multiple [ScrollView]s, it only responds to
/// the nearest ScrollView and shows the corresponding scrollbar thumb by default.
/// The [notificationPredicate] allows the ability to customize which
/// [ScrollNotification]s the Scrollbar should listen to.
///
/// If the child [ScrollView] is infinitely long, the [RawScrollbar] will not be
/// painted. In this case, the scrollbar cannot accurately represent the
/// relative location of the visible area, or calculate the accurate delta to
/// apply when dragging on the thumb or tapping on the track.
///
/// ### Interaction
///
/// Scrollbars are interactive and can use the [PrimaryScrollController] if
/// a [controller] is not set. Interactive Scrollbar thumbs can be dragged along
/// the main axis of the [ScrollView] to change the [ScrollPosition]. Tapping
/// along the track exclusive of the thumb will trigger a
/// [ScrollIncrementType.page] based on the relative position to the thumb.
///
/// When using the [PrimaryScrollController], it must not be attached to more
/// than one [ScrollPosition]. [ScrollView]s that have not been provided a
/// [ScrollController] and have a [ScrollView.scrollDirection] of
/// [Axis.vertical] will automatically attach their ScrollPosition to the
/// PrimaryScrollController. Provide a unique ScrollController to each
/// [Scrollable] in this case to prevent having multiple ScrollPositions
/// attached to the PrimaryScrollController.
///
/// ### Automatic Scrollbars on Desktop Platforms
///
/// Scrollbars are added to most [Scrollable] widgets by default on
/// desktop platforms. This is done through
/// [ScrollBehavior.buildScrollbar] as part of an app's
/// [ScrollConfiguration]. Scrollables that do not use the
/// [PrimaryScrollController] or have a [ScrollController] provided to them
/// will receive a unique ScrollController for use with the Scrollbar. In this
/// case, only one Scrollable can be using the PrimaryScrollController, unless
/// [interactive] is false. To prevent [Axis.vertical] Scrollables from using
/// the PrimaryScrollController, set [ScrollView.primary] to false. Scrollable
/// widgets that do not have automatically applied Scrollbars include
///
///   * [EditableText]
///   * [ListWheelScrollView]
///   * [PageView]
///   * [NestedScrollView]
///   * [DropdownButton]
///
/// Default Scrollbars can be disabled for the whole app by setting a
/// [ScrollBehavior] with `scrollbars` set to false.
///
/// When dragging a [CupertinoScrollbar] thumb, the thickness and radius will
/// animate from [thickness] and [radius] to [thicknessWhileDragging] and
/// [radiusWhileDragging], respectively.
///
/// <callout-box>
///
/// This sample shows a [CupertinoScrollbar] that fades in and out of view as scrolling occurs.
/// The scrollbar will fade into view as the user scrolls, and fade out when scrolling stops.
/// The `thickness` of the scrollbar will animate from 6 pixels to the `thicknessWhileDragging` of 10
/// when it is dragged by the user. The `radius` of the scrollbar thumb corners will animate from 34
/// to the `radiusWhileDragging` of 0 when the scrollbar is being dragged by the user.
///
// TODO(framework): Replace the following block with a @dartpad directive
// when it's supported. https://github.com/dart-lang/dartdoc/issues/4123
/// {@macro cupertino_ui.dartpad_guide}
///
/// {@example /example/lib/scrollbar/cupertino_scrollbar.0.dart#body}
///
/// </callout-box>
///
/// <callout-box>
///
/// When [thumbVisibility] is true, the scrollbar thumb will remain visible without the
/// fade animation. This requires that a [ScrollController] is provided to controller,
/// or that the [PrimaryScrollController] is available.
///
// TODO(framework): Replace the following block with a @dartpad directive
// when it's supported. https://github.com/dart-lang/dartdoc/issues/4123
/// {@macro cupertino_ui.dartpad_guide}
///
/// {@example /example/lib/scrollbar/cupertino_scrollbar.1.dart#body}
///
/// </callout-box>
///
/// See also:
///
///  * [ListView], which displays a linear, scrollable list of children.
///  * [GridView], which displays a 2 dimensional, scrollable array of children.
///  * [Scrollbar], a Material Design scrollbar.
///  * [RawScrollbar], a basic scrollbar that fades in and out, extended
///    by this class to add more animations and behaviors.
class CupertinoScrollbar extends RawScrollbar {
  /// Creates an iOS style scrollbar that wraps the given [child].
  ///
  /// The [child] should be a source of [ScrollNotification] notifications,
  /// typically a [Scrollable] widget.
  const CupertinoScrollbar({
    super.key,
    required super.child,
    super.controller,
    bool? thumbVisibility,
    double super.thickness = defaultThickness,
    this.thicknessWhileDragging = defaultThicknessWhileDragging,
    Radius super.radius = defaultRadius,
    this.radiusWhileDragging = defaultRadiusWhileDragging,
    ScrollNotificationPredicate? notificationPredicate,
    super.scrollbarOrientation,
    super.mainAxisMargin = _kScrollbarMainAxisMargin,
  }) : assert(thickness < double.infinity),
       assert(thicknessWhileDragging < double.infinity),
       super(
         thumbVisibility: thumbVisibility ?? false,
         fadeDuration: _kScrollbarFadeDuration,
         timeToFade: _kScrollbarTimeToFade,
         pressDuration: const Duration(milliseconds: 100),
         notificationPredicate: notificationPredicate ?? defaultScrollNotificationPredicate,
       );

  /// Default value for [thickness] if it's not specified in [CupertinoScrollbar].
  static const double defaultThickness = 3;

  /// Default value for [thicknessWhileDragging] if it's not specified in
  /// [CupertinoScrollbar].
  static const double defaultThicknessWhileDragging = 8.0;

  /// Default value for [radius] if it's not specified in [CupertinoScrollbar].
  static const Radius defaultRadius = Radius.circular(1.5);

  /// Default value for [radiusWhileDragging] if it's not specified in
  /// [CupertinoScrollbar].
  static const Radius defaultRadiusWhileDragging = Radius.circular(4.0);

  /// The thickness of the scrollbar when it's being dragged by the user.
  ///
  /// When the user starts dragging the scrollbar, the thickness will animate
  /// from [thickness] to this value, then animate back when the user stops
  /// dragging the scrollbar.
  final double thicknessWhileDragging;

  /// The radius of the scrollbar edges when the scrollbar is being dragged by
  /// the user.
  ///
  /// When the user starts dragging the scrollbar, the radius will animate
  /// from [radius] to this value, then animate back when the user stops
  /// dragging the scrollbar.
  final Radius radiusWhileDragging;

  @override
  RawScrollbarState<CupertinoScrollbar> createState() => _CupertinoScrollbarState();
}

class _CupertinoScrollbarState extends RawScrollbarState<CupertinoScrollbar> {
  late AnimationController _thicknessAnimationController;

  double get _thickness {
    return widget.thickness! +
        _thicknessAnimationController.value * (widget.thicknessWhileDragging - widget.thickness!);
  }

  Radius get _radius {
    return Radius.lerp(
      widget.radius,
      widget.radiusWhileDragging,
      _thicknessAnimationController.value,
    )!;
  }

  @override
  void initState() {
    super.initState();
    _thicknessAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarResizeDuration,
    );
    _thicknessAnimationController.addListener(() {
      updateScrollbarPainter();
    });
  }

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = CupertinoDynamicColor.resolve(_kScrollbarColor, context)
      ..textDirection = Directionality.of(context)
      ..thickness = _thickness
      ..mainAxisMargin = widget.mainAxisMargin
      ..crossAxisMargin = _kScrollbarCrossAxisMargin
      ..radius = _radius
      ..padding = MediaQuery.paddingOf(context)
      ..minLength = _kScrollbarMinLength
      ..minOverscrollLength = _kScrollbarMinOverscrollLength
      ..scrollbarOrientation = widget.scrollbarOrientation;
  }

  double _pressStartAxisPosition = 0.0;

  // Long press event callbacks handle the gesture where the user long presses
  // on the scrollbar thumb and then drags the scrollbar without releasing.

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    final Axis? direction = getScrollbarDirection();
    if (direction == null) {
      return;
    }
    _pressStartAxisPosition = switch (direction) {
      Axis.vertical => localPosition.dy,
      Axis.horizontal => localPosition.dx,
    };
  }

  @override
  void handleThumbPress() {
    if (getScrollbarDirection() == null) {
      return;
    }
    super.handleThumbPress();
    _thicknessAnimationController.forward().then<void>((_) => HapticFeedback.mediumImpact());
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    final Axis? direction = getScrollbarDirection();
    if (direction == null) {
      return;
    }
    _thicknessAnimationController.reverse();
    super.handleThumbPressEnd(localPosition, velocity);
    final (double axisPosition, double axisVelocity) = switch (direction) {
      Axis.horizontal => (localPosition.dx, velocity.pixelsPerSecond.dx),
      Axis.vertical => (localPosition.dy, velocity.pixelsPerSecond.dy),
    };
    if (axisPosition != _pressStartAxisPosition && axisVelocity.abs() < 10) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void handleTrackTapDown(TapDownDetails details) {
    // On iOS, tapping the track does not page towards the position of the tap.
    if (ScrollConfiguration.of(context).getPlatform(context) != TargetPlatform.iOS) {
      super.handleTrackTapDown(details);
    }
  }

  @override
  void dispose() {
    _thicknessAnimationController.dispose();
    super.dispose();
  }
}
