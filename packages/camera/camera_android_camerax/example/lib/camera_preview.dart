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

    int qt = _getQuarterTurns();
    print(
        'CAMILLE wrap in rotated box info start--------------------------------------------');
    print('CAMILLE quarter turns: $qt');
    print(
        'CAMILLE wrap in rotated box info end--------------------------------------------');
    return RotatedBox(
      quarterTurns: qt,
      child: child,
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ].contains(_getApplicableOrientation());
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };

    // [WORKS FOR BACK CAMERA] Test for naturally landscape left:
    // final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
    //   DeviceOrientation.portraitUp: 3,
    //   DeviceOrientation.landscapeRight: 2,
    //   DeviceOrientation.portraitDown: 1,
    //   DeviceOrientation.landscapeLeft: 0,
    // };

    // [WORKS FOR FRONT CAMERA] Test for naturally landscape left:
    // TODO(camsim99): do algebra to understand this relationship a bit better.
    // final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
    //   DeviceOrientation.portraitUp: 1,
    //   DeviceOrientation.landscapeRight: 2,
    //   DeviceOrientation.portraitDown: 0,
    //   DeviceOrientation.landscapeLeft: 2,
    // };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
  }
}
