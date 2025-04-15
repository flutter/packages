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
final class ImageReaderRotatedPreview extends StatefulWidget {
  /// Creates [ImageReaderRotatedPreview] that will correct the preview
  /// rotation assuming that the front camera is being used.
  const ImageReaderRotatedPreview.frontFacingCamera(
    this.initialDeviceOrientation,
    this.deviceOrientation, {
    required this.sensorOrientationDegrees,
    required this.child,
    super.key,
  }) : facingSign = 1;

  /// Creates [ImageReaderRotatedPreview] that will correct the preview
  /// rotation assuming that the back camera is being used.
  const ImageReaderRotatedPreview.backFacingCamera(
    this.initialDeviceOrientation,
    this.deviceOrientation, {
    required this.child,
    required this.sensorOrientationDegrees,
    super.key,
  }) : facingSign = -1;

  /// The initial orientation of the device when the camera is created.
  final DeviceOrientation initialDeviceOrientation;

  /// Stream of changes to the device orientation.
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
  State<StatefulWidget> createState() => _ImageReaderRotatedPreviewState();
}

final class _ImageReaderRotatedPreviewState
    extends State<ImageReaderRotatedPreview> {
  late DeviceOrientation deviceOrientation;
  late StreamSubscription<DeviceOrientation> deviceOrientationSubscription;

  @override
  void initState() {
    deviceOrientation = widget.initialDeviceOrientation;
    deviceOrientationSubscription =
        widget.deviceOrientation.listen((DeviceOrientation event) {
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
    // TODO(camsim99): works with emulator back camera, front not working
    // but could this be emulator issue? not sure what else I could be doing wrong
    final double extraRotationDegrees = switch (orientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeRight => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeLeft => 270,
    };

    final double deviceOrientationDegrees = switch (orientation) {
      DeviceOrientation.portraitUp => 270, // TODO ??
      DeviceOrientation.landscapeRight => 180,
      DeviceOrientation.portraitDown => 90, // TODO ??
      DeviceOrientation.landscapeLeft => 0,
    };

    // Rotate the camera preview according to
    // https://developer.android.com/media/camera/camera2/camera-preview#orientation_calculation.
    double rotationDegrees =
        (sensorOrientationDegrees - deviceOrientationDegrees * sign + 360) %
            360;

    // Then, subtract the rotation already applied in the CameraPreview widget
    // (see camera/camera/lib/src/camera_preview.dart).
    rotationDegrees -= extraRotationDegrees;

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
    print(
        'CAMILLE build info start--------------------------------------------------');
    print('CAMILLE device orientation: $deviceOrientation');
    print(
        'CAMILLE sensor orientation degrees: ${widget.sensorOrientationDegrees}');
    print('CAMILLE: camer facing sign: ${widget.facingSign}');
    print('CAMILLE rotation degrees: $rotationDegrees');
    print('CAMILLE rotation degrees mod 90: ${rotationDegrees ~/ 90}');
    print(
        'CAMILLE build info end--------------------------------------------------');

    return RotatedBox(
      quarterTurns: rotationDegrees ~/ 90,
      child: widget.child,
    );
  }
}
