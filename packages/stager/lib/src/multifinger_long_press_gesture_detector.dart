// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

/// Detects long press gestures with a configurable [numberOfTouches].
class MultiTouchLongPressGestureDetector extends StatefulWidget {
  /// Creates a [MultiTouchLongPressGestureDetector] with the given
  /// [longPressDelay]. If no [longPressDelay] is specified, it defaults to 1
  /// second.
  const MultiTouchLongPressGestureDetector({
    super.key,
    this.longPressDelay = const Duration(seconds: 1),
    required this.numberOfTouches,
    required this.onGestureDetected,
    required this.child,
  }) : assert(
            numberOfTouches > 1,
            'numberOfTouches must be greater than 1. Use '
            'LongPressGestureRecognizer to recognize a single-touch long '
            'press.');

  /// How long the user must hold down before the gesture is detected.
  ///
  /// Defaults to 1 second;
  final Duration longPressDelay;

  /// How many fingers are required to trigger this gesture
  final int numberOfTouches;

  /// Executed when the multi-touch long press gesture has been recognized.
  final VoidCallback onGestureDetected;

  /// The Widget that will respond to gestures.
  final Widget child;

  @override
  State<MultiTouchLongPressGestureDetector> createState() =>
      _MultiTouchLongPressGestureDetectorState();
}

class _MultiTouchLongPressGestureDetectorState
    extends State<MultiTouchLongPressGestureDetector> {
  Completer<bool>? _gestureHoldCompleter;

  Future<void> _tryToRecognizeGesture() async {
    _gestureHoldCompleter = Completer<bool>();
    await Future<void>.delayed(widget.longPressDelay);
    if (_gestureHoldCompleter != null && !_gestureHoldCompleter!.isCompleted) {
      widget.onGestureDetected();
      _gestureHoldCompleter?.complete(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Scaling callbacks are used as a way to retrieve the number of fingers
      // the user is using.
      onScaleStart: (ScaleStartDetails details) {
        if (details.pointerCount != widget.numberOfTouches) {
          return;
        }

        _tryToRecognizeGesture();
      },
      onScaleEnd: (_) {
        _gestureHoldCompleter = null;
      },
      child: widget.child,
    );
  }
}
