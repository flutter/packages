// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Widget that rotates the camera preview to be upright according to the
/// current user interface orientation.
@internal
final class RotatedPreview extends StatefulWidget {
  /// Creates [RotatedPreview] that will correct the preview
  /// rotation assuming that the front camera is being used.
  const RotatedPreview.frontFacingCamera(
    this.initialDeviceOrientation,
    this.deviceOrientation, {
    required this.sensorOrientationDegrees,
    required this.child,
    super.key,
  }) : facingSign = 1;

  /// Creates [RotatedPreview] that will correct the preview
  /// rotation assuming that the back camera is being used.
  const RotatedPreview.backFacingCamera(
    this.initialDeviceOrientation,
    this.deviceOrientation, {
    required this.child,
    required this.sensorOrientationDegrees,
    super.key,
  }) : facingSign = -1;

  /// The initial orientation of the device when the camera is created.
  final DeviceOrientation initialDeviceOrientation;

  /// The orientation of the device using the camera.
  final Stream<DeviceOrientation> deviceOrientation;

  /// The orienation of the camera sensor in degrees.
  final double sensorOrientationDegrees;

  /// The camera preview [Widget] to rotate.
  final Widget child;

  /// Value used to calculate the correct preview rotation.
  ///
  /// 1 if the camera is front facing; -1 if the camera is back facing.
  final int facingSign;

  @override
  State<StatefulWidget> createState() => _RotatedPreviewState();
}

final class _RotatedPreviewState extends State<RotatedPreview> {
  late DeviceOrientation deviceOrientation;
  late StreamSubscription<DeviceOrientation> deviceOrientationSubscription;

  @override
  void initState() {
    deviceOrientation = widget.initialDeviceOrientation;
    deviceOrientationSubscription = widget.deviceOrientation.listen((
      DeviceOrientation event,
    ) {
      // Ensure that we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }
      setState(() {
        deviceOrientation = event;
      });
    });
    super.initState();
  }

  double _computeRotationDegrees(
    DeviceOrientation orientation, {
    required double sensorOrientationDegrees,
    required int sign,
  }) {
    final double deviceOrientationDegrees = switch (orientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeRight => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeLeft => 270,
    };

    // Rotate the camera preview according to
    // https://developer.android.com/media/camera/camera2/camera-preview#orientation_calculation.
    double rotationDegrees =
        (sensorOrientationDegrees - deviceOrientationDegrees * sign + 360) %
        360;

    // Then, subtract the rotation already applied in the CameraPreview widget
    // (see camera/camera/lib/src/camera_preview.dart).
    rotationDegrees -= deviceOrientationDegrees;

    return rotationDegrees;
  }

  @override
  void dispose() {
    deviceOrientationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double rotationDegrees = _computeRotationDegrees(
      deviceOrientation,
      sensorOrientationDegrees: widget.sensorOrientationDegrees,
      sign: widget.facingSign,
    );
    return RotatedBox(quarterTurns: rotationDegrees ~/ 90, child: widget.child);
  }
}
