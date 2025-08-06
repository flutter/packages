// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'camerax_library.dart';
import 'rotated_preview_utils.dart';

/// Widget that rotates the camera preview to be upright according to the
/// current user interface orientation for devices using the `ImageReader`
/// Impeller backend, which does not automatically handle the crop and
/// rotation of the camera preview correctly.
@internal
final class ImageReaderRotatedPreview extends StatefulWidget {
  /// Creates [ImageReaderRotatedPreview] that will correct the preview
  /// rotation assuming that the front camera is being used.
  const ImageReaderRotatedPreview.frontFacingCamera(
    this.initialDeviceOrientation,
    this.initialDefaultDisplayRotation,
    this.deviceOrientation,
    this.sensorOrientationDegrees,
    this.deviceOrientationManager, {
    required this.child,
    super.key,
  }) : facingSign = 1;

  /// Creates [ImageReaderRotatedPreview] that will correct the preview
  /// rotation assuming that the back camera is being used.
  const ImageReaderRotatedPreview.backFacingCamera(
    this.initialDeviceOrientation,
    this.initialDefaultDisplayRotation,
    this.deviceOrientation,
    this.sensorOrientationDegrees,
    this.deviceOrientationManager, {
    required this.child,
    super.key,
  }) : facingSign = -1;

  /// The initial orientation of the device when the camera is created.
  final DeviceOrientation initialDeviceOrientation;

  /// The initial rotation of the Android default display when the camera is created
  /// in terms of a Surface rotation constant.
  final int initialDefaultDisplayRotation;

  /// Stream of changes to the device orientation.
  final Stream<DeviceOrientation> deviceOrientation;

  /// The orientation of the camera sensor in degrees.
  final double sensorOrientationDegrees;

  /// The camera's device orientation manager.
  ///
  /// Instance required to check the current rotation of the default Android display.
  final DeviceOrientationManager deviceOrientationManager;

  /// Value used to calculate the correct preview rotation.
  ///
  /// 1 if the camera is front facing; -1 if the camera is back facing.
  final int facingSign;

  /// The camera preview [Widget] to rotate.
  final Widget child;

  @override
  State<StatefulWidget> createState() => _ImageReaderRotatedPreviewState();
}

final class _ImageReaderRotatedPreviewState
    extends State<ImageReaderRotatedPreview> {
  late DeviceOrientation deviceOrientation;
  late Future<int> defaultDisplayRotationDegrees;
  late StreamSubscription<DeviceOrientation> deviceOrientationSubscription;

  Future<int> _getCurrentDefaultDisplayRotationDegrees() async {
    final int currentDefaultDisplayRotationQuarterTurns = await widget
        .deviceOrientationManager
        .getDefaultDisplayRotation();
    return getQuarterTurnsFromSurfaceRotationConstant(
          currentDefaultDisplayRotationQuarterTurns,
        ) *
        90;
  }

  @override
  void initState() {
    deviceOrientation = widget.initialDeviceOrientation;
    defaultDisplayRotationDegrees = Future<int>.value(
      getQuarterTurnsFromSurfaceRotationConstant(
            widget.initialDefaultDisplayRotation,
          ) *
          90,
    );
    deviceOrientationSubscription = widget.deviceOrientation.listen((
      DeviceOrientation event,
    ) {
      // Ensure that we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }

      setState(() {
        deviceOrientation = event;
        defaultDisplayRotationDegrees =
            _getCurrentDefaultDisplayRotationDegrees();
      });
    });
    super.initState();
  }

  double _computeRotationDegrees(
    DeviceOrientation orientation,
    int currentDefaultDisplayRotationDegrees, {
    required double sensorOrientationDegrees,
    required int sign,
  }) {
    // Rotate the camera preview according to
    // https://developer.android.com/media/camera/camera2/camera-preview#orientation_calculation.
    double rotationDegrees =
        (sensorOrientationDegrees -
            currentDefaultDisplayRotationDegrees * sign +
            360) %
        360;

    // Then, subtract the rotation already applied in the CameraPreview widget
    // (see camera/camera/lib/src/camera_preview.dart) that is not correct
    // for this plugin.
    final double extraRotationDegrees =
        getPreAppliedQuarterTurnsRotationFromDeviceOrientation(orientation) *
        90;
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
    return FutureBuilder<int>(
      future: defaultDisplayRotationDegrees,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final int currentDefaultDisplayRotation = snapshot.data!;
          final double rotationDegrees = _computeRotationDegrees(
            deviceOrientation,
            currentDefaultDisplayRotation,
            sensorOrientationDegrees: widget.sensorOrientationDegrees,
            sign: widget.facingSign,
          );

          // If the camera is front facing (widget.facingSign is 1 for front
          // cameras, -1 for back cameras), mirror the camera preview
          // according to the current device orientation.
          Widget cameraPreview = widget.child;
          if (widget.facingSign == 1) {
            if (deviceOrientation == DeviceOrientation.portraitDown ||
                deviceOrientation == DeviceOrientation.portraitUp) {
              cameraPreview = Transform.scale(scaleY: -1, child: cameraPreview);
            } else {
              cameraPreview = Transform.scale(scaleX: -1, child: cameraPreview);
            }
          }

          return RotatedBox(
            quarterTurns: rotationDegrees ~/ 90,
            child: cameraPreview,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
