// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../camera.dart';

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

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  bool _isLandscape() {
    switch (_getApplicableOrientation()) {
      case DeviceOrientation.landscapeLeft:
      case DeviceOrientation.landscapeRight:
        return true;
      case DeviceOrientation.portraitUp:
      case DeviceOrientation.portraitDown:
        return false;
    }
  }

  int _getQuarterTurns() {
    switch (_getApplicableOrientation()) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeRight:
        return 1;
      case DeviceOrientation.portraitDown:
        return 2;
      case DeviceOrientation.landscapeLeft:
        return 3;
    }
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.recordingOrientation ??
        controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
        controller.value.deviceOrientation;
  }
}
