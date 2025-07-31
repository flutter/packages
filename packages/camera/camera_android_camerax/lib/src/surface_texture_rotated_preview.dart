// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'camerax_library.dart' show DeviceOrientationManager;
import 'rotated_preview_utils.dart';

/// Widget that rotates the camera preview to be upright according to the
/// current user interface orientation when the preview is backed by a
/// native Android `SurfaceTexture`, which does handle the crop and rotation
/// of the camera preview automatically.
@internal
final class SurfaceTextureRotatedPreview extends StatefulWidget {
  /// Creates [SurfaceTextureRotatedPreview] that will rotate camera preview
  /// according to the rotation of the Android default display.
  const SurfaceTextureRotatedPreview(
    this.initialDeviceOrientation,
    this.initialDefaultDisplayRotation,
    this.deviceOrientationStream,
    this.deviceOrientationManager, {
    required this.child,
    super.key,
  });

  /// The initial orientation of the device when the camera is created.
  final DeviceOrientation initialDeviceOrientation;

  /// The initial rotation of the Android default display when the camera is created
  /// in terms of a Surface rotation constant.
  final int initialDefaultDisplayRotation;

  /// Stream of changes to the device orientation.
  final Stream<DeviceOrientation> deviceOrientationStream;

  /// The camera's device orientation manager.
  ///
  /// Instance required to check the current rotation of the default Android display.
  final DeviceOrientationManager deviceOrientationManager;

  /// The camera preview [Widget] to rotate.
  final Widget child;

  @override
  State<StatefulWidget> createState() => _SurfaceTextureRotatedPreviewState();
}

final class _SurfaceTextureRotatedPreviewState
    extends State<SurfaceTextureRotatedPreview> {
  late StreamSubscription<DeviceOrientation> deviceOrientationSubscription;
  late int preappliedRotationQuarterTurns;
  late Future<int> defaultDisplayRotationQuarterTurns;

  Future<int> _getCurrentDefaultDisplayRotationQuarterTurns() async {
    final int currentDefaultDisplayRotationQuarterTurns = await widget
        .deviceOrientationManager
        .getDefaultDisplayRotation();
    return getQuarterTurnsFromSurfaceRotationConstant(
      currentDefaultDisplayRotationQuarterTurns,
    );
  }

  @override
  void initState() {
    preappliedRotationQuarterTurns =
        getPreAppliedQuarterTurnsRotationFromDeviceOrientation(
          widget.initialDeviceOrientation,
        );
    defaultDisplayRotationQuarterTurns = Future<int>.value(
      getQuarterTurnsFromSurfaceRotationConstant(
        widget.initialDefaultDisplayRotation,
      ),
    );
    deviceOrientationSubscription = widget.deviceOrientationStream.listen((
      DeviceOrientation event,
    ) {
      // Ensure that we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }

      setState(() {
        preappliedRotationQuarterTurns =
            getPreAppliedQuarterTurnsRotationFromDeviceOrientation(event);
        defaultDisplayRotationQuarterTurns =
            _getCurrentDefaultDisplayRotationQuarterTurns();
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
    return FutureBuilder<int>(
      future: defaultDisplayRotationQuarterTurns,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Rotated preview according to current default display rotation,
          // but subtract out rotation applied by the CameraPreview widget
          // (see camera/camera/lib/src/camera_preview.dart) that is not
          // correct for this plugin.
          final int currentDefaultDisplayRotation = snapshot.data!;
          final int rotationCorrection =
              currentDefaultDisplayRotation - preappliedRotationQuarterTurns;

          return RotatedBox(
            quarterTurns: rotationCorrection,
            child: widget.child,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
