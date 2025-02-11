// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// https://developer.android.com/media/camera/camera2/camera-preview#orientation_calculation.
double computeRotation(
  DeviceOrientation orientation, {
  required double sensorOrientationDegrees,
  required int sign,
}) {
  final double deviceOrientationDegrees = switch (orientation) {
    DeviceOrientation.portraitUp => 0,
    DeviceOrientation.landscapeRight => 90,
    DeviceOrientation.portraitDown => 180,
    DeviceOrientation.landscapeLeft => 270, // FIXME: Should this be -90?
  };
  return (sensorOrientationDegrees - deviceOrientationDegrees * sign + 360) %
      360;
}

final class PreviewRotation extends StatefulWidget {
  /// ...
  PreviewRotation.frontFacingCamera(
    this.deviceOrientation, {
    required this.child,
    required this.sensorOrientationDegrees,
    super.key,
  }) : facingSign = 1;

  /// ...
  PreviewRotation.backFacingCamera(
    this.deviceOrientation, {
    required this.child,
    required this.sensorOrientationDegrees,
    super.key,
  }) : facingSign = -1;

  /// ...
  final Widget child;

  /// ...
  final Stream<DeviceOrientation> deviceOrientation;

  /// ...
  final double sensorOrientationDegrees;

  /// ...
  final int facingSign;

  @override
  State<StatefulWidget> createState() => _PreviewRotationState();
}

final class _PreviewRotationState extends State<PreviewRotation> {
  DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp;

  @override
  void initState() {
    widget.deviceOrientation.listen((DeviceOrientation event) {
      setState(() {
        deviceOrientation = event;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double rotation = computeRotation(
      deviceOrientation,
      sensorOrientationDegrees: widget.sensorOrientationDegrees,
      sign: widget.facingSign,
    );
    // FIXME: This sucks.
    return RotatedBox(
      quarterTurns: rotation ~/ 90,
      child: widget.child,
    );
  }
}
