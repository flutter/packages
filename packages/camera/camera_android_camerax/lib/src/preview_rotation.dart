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
  final double preAppliedRotation = deviceOrientationDegrees;
  debugPrint('>>>>> deviceOrientationDegrees: $deviceOrientationDegrees');
  debugPrint('>>>>> preAppliedRotation: $preAppliedRotation');
  return ((sensorOrientationDegrees - deviceOrientationDegrees * sign + 360) %
          360) -
      preAppliedRotation;
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

  /// FIXME: Add an initialDeviceOrientation.
  /// final DeviceOrientation initialDeviceOrientation;

  /// ...
  final double sensorOrientationDegrees;

  /// ...
  final int facingSign;

  @override
  State<StatefulWidget> createState() => _PreviewRotationState();
}

final class _PreviewRotationState extends State<PreviewRotation> {
  // FIXME: Instead of assuming the initial state is portraitUp, we should
  // get that from the widget itself; meaning, when we call 'createCameraWithSettings'
  // we should get the initial device orientation, and then provide that to preview
  // rotation PreviewRotation.frontFacingCamera(initialDeviceOrientation: ...);
  //
  // So this will be come late instead of having an initial value.
  DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp;

  @override
  void initState() {
    // FIXME: Get the initial orientation.
    // deviceOrientation = widget.initialDeviceOrientation;

    // FIXME: Need to store a reference to the stream subscription, and
    // cancel it in the @override dispose() method, which is not yet done here.
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

  @override
  Widget build(BuildContext context) {
    debugPrint('>>>> PreviewRotation build called!');
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
