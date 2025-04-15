// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'camerax_proxy.dart';
import 'surface.dart';

/// Widget that rotates the camera preview to be upright according to the
/// current user interface orientation when the preview is backed by a
/// native Android `SurfaceTexture`.
@internal
final class SurfaceTextureRotatedPreview extends StatefulWidget {
  /// Creates [SurfaceTextureRotatedPreview] that will rotate camera preview
  /// according to the rotation of the Android default display.
  const SurfaceTextureRotatedPreview(
      this.initialDeviceOrientation,
      this.initialDefaultDisplayRotation,
      this.cameraXProxy,
      this.deviceOrientation,
      {required this.child,
      super.key});

  /// The initial orientation of the device when the camera is created.
  final DeviceOrientation initialDeviceOrientation;

  /// The initial rotation of the Android default display when the camera is created.
  final int initialDefaultDisplayRotation;

  /// Proxy for calling into CameraX library on the native Android side of the plugin.
  ///
  /// Instance required to check the current rotation of the default Android display.
  final CameraXProxy cameraXProxy;

  /// Stream of changes to the device orientation.
  final Stream<DeviceOrientation> deviceOrientation;

  /// The camera preview [Widget] to rotate.
  final Widget child;

  @override
  State<StatefulWidget> createState() => _SurfaceTextureRotatedPreviewState();
}

final class _SurfaceTextureRotatedPreviewState
    extends State<SurfaceTextureRotatedPreview> {
  late StreamSubscription<DeviceOrientation> deviceOrientationSubscription;
  late int preappliedRotationQuarterTurns;
  late Future<int> defaultDisplayRotation;

  int _getPreAppliedRotationFromDeviceOrientation(
      DeviceOrientation orientation) {
    return switch (orientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeRight => 1,
      DeviceOrientation.portraitDown => 2,
      DeviceOrientation.landscapeLeft => 3,
    };
  }

  int _getGraphicsRotationFromDefaultDisplayRotation(
      int defaultDisplayRotation) {
    return switch (defaultDisplayRotation) {
      Surface.rotation0 => 0,
      Surface.rotation90 => 3,
      Surface.rotation180 => 2,
      Surface.rotation270 => 1,
      // TODO(camsim99): Handle this case.
      int() => throw UnimplementedError(),
    };
  }

  @override
  void initState() {
    preappliedRotationQuarterTurns =
        _getPreAppliedRotationFromDeviceOrientation(
            widget.initialDeviceOrientation);
    defaultDisplayRotation =
        Future<int>.value(widget.initialDefaultDisplayRotation);
    deviceOrientationSubscription =
        widget.deviceOrientation.listen((DeviceOrientation event) {
      // Ensure that we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }

      setState(() {
        preappliedRotationQuarterTurns =
            _getPreAppliedRotationFromDeviceOrientation(event);
        defaultDisplayRotation =
            widget.cameraXProxy.getDefaultDisplayRotation();

        print(
            'CAMILLE set state info start)))))))))))))))))))))))))))))))))))))))))))))))');
        print('preappliedRotationQuarterTurns $preappliedRotationQuarterTurns');
        print('defaultDisplayRotation $defaultDisplayRotation');
        print(
            'CAMILLE set state info end)))))))))))))))))))))))))))))))))))))))))))))))');
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    deviceOrientationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     'CAMILLE build info start--------------------------------------------------');
    // print('CAMILLE device orientation: $deviceOrientation');
    // print(
    //     'CAMILLE sensor orientation degrees: ${widget.sensorOrientationDegrees}');
    // print('CAMILLE: camer facing sign: ${widget.facingSign}');
    // print('CAMILLE rotation degrees: $rotationDegrees');
    // print('CAMILLE rotation degrees mod 90: ${rotationDegrees ~/ 90}');
    // print(
    //     'CAMILLE build info end--------------------------------------------------');

    return FutureBuilder<int>(
        future: defaultDisplayRotation,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final int currentDefaultDisplayRotation2 = snapshot.data!;
            final int currentDefaultDisplayRotation =
                _getGraphicsRotationFromDefaultDisplayRotation(
                    currentDefaultDisplayRotation2);
            final int rotationCorrection =
                currentDefaultDisplayRotation - preappliedRotationQuarterTurns;
            print(
                'CAMILLE snapshot done info start ::::::::::::::::::::::::::::::::::::::::::::::::::::::');
            print(
                'currentDefaultDisplayRotation $currentDefaultDisplayRotation');
            print(
                'currentDefaultDisplayRotation: $currentDefaultDisplayRotation');
            print(
                'preappliedRotationQuarterTurns: $preappliedRotationQuarterTurns');
            print('rotationCorrection $rotationCorrection');
            print(
                'CAMILLE snapshot done info end ::::::::::::::::::::::::::::::::::::::::::::::::::::::');

            return RotatedBox(
                quarterTurns: rotationCorrection, child: widget.child);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
