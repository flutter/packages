// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
                aspectRatio: _isLandscape(context)
                    ? controller.value.aspectRatio
                    : (1 / controller.value.aspectRatio),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[controller.buildPreview(), child ?? Container()],
                ),
              );
            },
            child: child,
          )
        : Container();
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    int deviceTurns = turns[controller.value.deviceOrientation] ?? 0;
    int targetTurns = turns[_getApplicableOrientation()] ?? 0;
    int quarterTurns = (targetTurns - deviceTurns) % 4;
    if (quarterTurns < 0) {
      quarterTurns += 4;
    }
    return quarterTurns;
  }

  bool _isLandscape(BuildContext context) {
    if (controller.value.isRecordingVideo) {
      return <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ].contains(controller.value.recordingOrientation);
    }
    if (controller.value.lockedCaptureOrientation != null) {
      return <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ].contains(controller.value.lockedCaptureOrientation);
    }
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
              controller.value.lockedCaptureOrientation ??
              controller.value.deviceOrientation);
  }
}
