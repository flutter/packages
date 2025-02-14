// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

final class PreviewRotation extends StatefulWidget {
  /// Creates [PreviewRotation] that will correct the preview
  /// rotation assuming the front camera is being used.
  PreviewRotation.frontFacingCamera(
    this.initialDeviceOrientation,
    this.deviceOrientation, {
    required this.child,
    required this.sensorOrientationDegrees,
    super.key,
  }) : facingSign = 1;

  /// Creates [PreviewRotation] that will correct the preview
  /// rotation assuming the back camera is being used.
  PreviewRotation.backFacingCamera(
    this.initialDeviceOrientation,
    this.deviceOrientation, {
    required this.child,
    required this.sensorOrientationDegrees,
    super.key,
  }) : facingSign = -1;

  /// The preview [Widget] to rotate.
  final Widget child;

  /// The initial orientation of the device when the camera is created.
  final DeviceOrientation initialDeviceOrientation;

  /// The orientation of the device using the camera.
  final Stream<DeviceOrientation> deviceOrientation;

  /// The orienation of the camera sensor.
  final double sensorOrientationDegrees;

  /// Value used to calculate the correct preview rotation.
  ///
  /// 1 if the camera is front facing; -1 if the camerea is back facing.
  final int facingSign;

  @override
  State<StatefulWidget> createState() => _PreviewRotationState();
}

final class _PreviewRotationState extends State<PreviewRotation> {
  late DeviceOrientation deviceOrientation;
  late StreamSubscription<DeviceOrientation> deviceOrientationSubscription;

  @override
  void initState() {
    deviceOrientation = widget.initialDeviceOrientation;
    deviceOrientationSubscription =
        widget.deviceOrientation.listen((DeviceOrientation event) {
      // Make sure we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }
      setState(() {
        debugPrint('>>>> deviceOrientation changed to: $event');
        deviceOrientation = event;
      });
    });
    super.initState();
  }

  double _computeRotation(
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

    // We rotate the camera preview according to
    // https://developer.android.com/media/camera/camera2/camera-preview#orientation_calculation
    // and then subtract the rotation applied in the CameraPreview widget
    // (see camera/camera/lib/src/camera_preview.dart).
    return ((sensorOrientationDegrees - deviceOrientationDegrees * sign + 360) %
            360) -
        deviceOrientationDegrees;
  }

  @override
  void dispose() {
    deviceOrientationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('>>>> PreviewRotation build called!');
    final double rotation = _computeRotation(
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
