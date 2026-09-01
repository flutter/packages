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
    print('CAMILLE_DEBUG: CameraPreview.build() isInitialized: ${controller.value.isInitialized}');
    return controller.value.isInitialized
        ? ValueListenableBuilder<CameraValue>(
            valueListenable: controller,
            builder: (BuildContext context, Object? value, Widget? child) {
              final bool isLandscape = _isLandscape(context);
              final double baseAspectRatio = controller.value.aspectRatio;
              final double landscapeRatio = baseAspectRatio < 1.0 ? (1.0 / baseAspectRatio) : baseAspectRatio;
              final double finalAspectRatio = isLandscape ? landscapeRatio : (1.0 / landscapeRatio);
              
              print('CAMILLE_DEBUG: [CameraPreview] _isLandscape(): $isLandscape');
              print('CAMILLE_DEBUG: [CameraPreview] controller.value.aspectRatio: $baseAspectRatio');
              print('CAMILLE_DEBUG: [CameraPreview] Final applied aspectRatio: $finalAspectRatio');
              print('CAMILLE_DEBUG: [CameraPreview] MediaQuery.orientation: ${MediaQuery.of(context).orientation}');
              
              return AspectRatio(
                aspectRatio: finalAspectRatio,
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          print(
                            'CAMILLE_DEBUG: [CameraPreview Constraints] ${constraints.maxWidth} x ${constraints.maxHeight}',
                          );
                          return controller.buildPreview();
                        },
                      ),
                      child ?? Container(),
                    ],
                  ),
                ),
              );
            },
            child: child,
          )
        : Container();
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
}
