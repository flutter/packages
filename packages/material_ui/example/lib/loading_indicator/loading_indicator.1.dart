// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'dart:math' as math;
import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for a [LoadingIndicator] used for pull to refresh.

void main() => runApp(const LoadingIndicatorExampleApp());

class LoadingIndicatorExampleApp extends StatelessWidget {
  const LoadingIndicatorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Lets the list be pulled with a mouse as well, for desktop and web.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      home: const LoadingIndicatorExample(),
    );
  }
}

class LoadingIndicatorExample extends StatefulWidget {
  const LoadingIndicatorExample({super.key});

  @override
  State<LoadingIndicatorExample> createState() =>
      _LoadingIndicatorExampleState();
}

class _LoadingIndicatorExampleState extends State<LoadingIndicatorExample> {
  /// How far the list is pulled down past its top, which is negative while
  /// it bounces back up past its top after being released.
  ///
  /// It changes on every frame of a pull, so only the indicator listens to
  /// it, instead of the whole screen rebuilding.
  final ValueNotifier<double> _pullDistance = ValueNotifier<double>(0.0);

  _RefreshStatus _status = _RefreshStatus.idle;

  /// How far the list was pulled at the last drag update, or null while the
  /// list is not being dragged.
  double? _draggedPullDistance;

  /// Whether the list is springing back after being pulled down past its top.
  ///
  /// The spring carries the list a little past its top, which would make the
  /// app bar flash its scrolled under color, so the app bar ignores the list
  /// while this is true.
  bool _isSpringingBack = false;

  /// How far the list was pulled when it was released, which the indicator
  /// keeps showing while refreshing.
  double _releasedPullDistance = 0.0;

  int _itemCount = 15;

  @override
  void dispose() {
    _pullDistance.dispose();
    super.dispose();
  }

  Future<void> _refresh({double pullDistance = 0.0}) async {
    if (_status != _RefreshStatus.idle) {
      return;
    }
    setState(() {
      _status = _RefreshStatus.refreshing;
      _releasedPullDistance = pullDistance;
    });

    // Replace this delay with the code that fetches new data.
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) {
      return;
    }

    setState(() {
      _itemCount += 5;
      _status = _RefreshStatus.finishing;
    });
  }

  void _handleIndicatorFadedOut() {
    if (_status == _RefreshStatus.finishing) {
      setState(() {
        _status = _RefreshStatus.idle;
      });
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Ignores notifications from scrollables inside the list's items.
    if (notification.depth != 0) {
      return false;
    }
    final ScrollMetrics metrics = notification.metrics;
    _pullDistance.value = metrics.minScrollExtent - metrics.pixels;

    // Scroll updates caused by a drag carry its details. Other notifications,
    // such as overscrolls, keep the list's dragging state as it was.
    final bool isDragging = switch (notification) {
      ScrollUpdateNotification(:final DragUpdateDetails? dragDetails) =>
        dragDetails != null,
      ScrollEndNotification() => false,
      _ => _draggedPullDistance != null,
    };

    if (isDragging || notification is ScrollEndNotification) {
      _isSpringingBack = false;
    } else if (metrics.pixels < metrics.minScrollExtent) {
      _isSpringingBack = true;
    }

    if (_status != _RefreshStatus.idle) {
      return false;
    }

    if (isDragging) {
      _draggedPullDistance = _pullDistance.value;
    } else if (_draggedPullDistance case final double releasedPullDistance) {
      // The list was let go of. Pushing it back up above the refresh distance
      // before letting go cancels the refresh.
      _draggedPullDistance = null;
      if (releasedPullDistance >= _PullToRefreshIndicator.refreshDistance) {
        _refresh(pullDistance: releasedPullDistance);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pull To Refresh Sample'),
        notificationPredicate: (ScrollNotification notification) {
          return !_isSpringingBack &&
              defaultScrollNotificationPredicate(notification);
        },
        actions: <Widget>[
          // Provides an accessible alternative to pulling the list.
          IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ListView.builder(
              physics: const _PullToRefreshScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: _itemCount,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(title: Text('Item ${_itemCount - index}'));
              },
            ),
          ),
          ValueListenableBuilder<double>(
            valueListenable: _pullDistance,
            builder:
                (BuildContext context, double pullDistance, Widget? child) {
                  return _PullToRefreshIndicator(
                    status: _status,
                    pullDistance: pullDistance,
                    releasedPullDistance: _releasedPullDistance,
                    onFadedOut: _handleIndicatorFadedOut,
                  );
                },
          ),
        ],
      ),
    );
  }
}

enum _RefreshStatus {
  /// The list is at rest, or being pulled.
  idle,

  /// The list was released or refreshed with the button, and is refreshing.
  refreshing,

  /// The list has refreshed, and the indicator is fading out.
  finishing,
}

/// The loading indicator above the list, which follows the pull and shows
/// the refresh.
class _PullToRefreshIndicator extends StatelessWidget {
  const _PullToRefreshIndicator({
    required this.status,
    required this.pullDistance,
    required this.releasedPullDistance,
    required this.onFadedOut,
  });

  /// How far the list has to be pulled down for a release to refresh it.
  static const double refreshDistance = 80.0;

  final _RefreshStatus status;

  final double pullDistance;

  final double releasedPullDistance;

  /// Called when the indicator has faded out after a refresh.
  final VoidCallback onFadedOut;

  @override
  Widget build(BuildContext context) {
    final bool isPulling = status == _RefreshStatus.idle;
    // Goes from 0.0 to 1.0 as the list is pulled down to the refresh
    // distance, and keeps growing if it is pulled further.
    final double pullProgress = math.max(pullDistance, 0.0) / refreshDistance;
    final double releasedPullProgress = releasedPullDistance / refreshDistance;

    // The indicator rests 8 pixels below the top of the list, and moves a
    // third as far as the list does. Following the list a little past its
    // top lets the indicator bounce with it.
    final double offset = 8.0 + math.max(pullDistance, -8.0) / 3;

    final double opacity = switch (status) {
      // Fades in over the first tenth of the pull.
      _RefreshStatus.idle => math.min(pullProgress * 10, 1.0),
      _RefreshStatus.refreshing => 1.0,
      _RefreshStatus.finishing => 0.0,
    };

    // Grows from half its size over the first half of the pull, and keeps
    // its full size once refreshing.
    final double scale = isPulling
        ? lerpDouble(
            0.5,
            1.0,
            Curves.linearToEaseOut.transform(math.min(pullProgress * 2, 1.0)),
          )!
        : 1.0;

    // A determinate indicator stops at a value of 1.0, so pulling further
    // keeps it rotating to show that the pull is still being tracked.
    final double overPull = math.max(
      (isPulling ? pullProgress : releasedPullProgress) - 1.0,
      0.0,
    );

    return Transform.translate(
      offset: Offset(0.0, offset),
      child: AnimatedOpacity(
        opacity: opacity,
        // Follows the pull right away, but fades in and out when refreshing
        // with the button and when the refresh is done.
        duration: isPulling ? Duration.zero : Durations.short2,
        onEnd: onFadedOut,
        child: Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: -overPull * math.pi,
            // When released, the indicator turns indeterminate. Its last
            // determinate shape is the first indeterminate one, and it keeps
            // its rotation, so it carries on without a seam.
            child: LoadingIndicator.contained(
              value: isPulling ? pullProgress : null,
              semanticsLabel: isPulling ? 'Pull to refresh' : 'Refreshing',
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets the list be pulled down past its top on every platform, and springs
/// it back with a little bounce when it is released.
class _PullToRefreshScrollPhysics extends BouncingScrollPhysics {
  const _PullToRefreshScrollPhysics({super.parent});

  @override
  _PullToRefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _PullToRefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: 500, ratio: 0.6);
}
// #endregion body
