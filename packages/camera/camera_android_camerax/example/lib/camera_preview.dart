// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_controller.dart';

/// A widget showing a live camera preview.
class CameraPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  const CameraPreview(this.controller, {super.key, this.child});

  /// The controller for the camera that the preview is shown for.
  final CameraController controller;

  /// A widget to overlay on top of the camera preview
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    print('CAMILLE: ${_getCorrectRotation()}');
    return controller.value.isInitialized
        ? ValueListenableBuilder<CameraValue>(
            valueListenable: controller,
            builder: (BuildContext context, Object? value, Widget? child) {
              return AspectRatio(
                aspectRatio: _isLandscape()
                    ? controller.value.aspectRatio
                    : (1 / controller.value.aspectRatio),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    controller.buildPreview(),
                    _wrapInRotatedBox(child: controller.buildPreview()),
                    child ?? Container(),
                  ],
                ),
              );
            },
            child: child,
          )
        : Container();
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ].contains(_getApplicableOrientation());
  }

  // int _getQuarterTurns() {
  //   final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
  //     DeviceOrientation.portraitUp: 0,
  //     DeviceOrientation.landscapeRight: 1,
  //     DeviceOrientation.portraitDown: 2,
  //     DeviceOrientation.landscapeLeft: 3,
  //   };
  //   return turns[_getApplicableOrientation()]!;
  // }

  int _getQuarterTurns() {
    double correctRotation = _getCorrectRotation();
    int turns = (correctRotation / 90).toInt();

    print('CAMILLE: $turns');

    return turns;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
  }

  double _getCorrectRotation() {
    DeviceOrientation deviceOrientationConstant = _getApplicableOrientation();
    final Map<DeviceOrientation, int> deg = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeLeft: 270,
    };
    int deviceOrientation = deg[deviceOrientationConstant]!;

    int sensorOrientation = controller.value.sensorOrientationDegrees!;
    int sign = controller.value.sign!;
    return (sensorOrientation - deviceOrientation * sign + 360) % 360;
  }
}
