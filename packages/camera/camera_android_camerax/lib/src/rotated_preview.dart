// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'camerax_library.dart' show DeviceOrientationManager, TransformationInfo;
import 'rotated_preview_utils.dart';

/// Widget that rotates, and mirrors if needed, the camera preview to be
/// upright according to the current user interface orientation.
///
/// The correction depends on whether the camera transform (the sensor
/// rotation and, for front cameras, mirroring) has been applied to the
/// preview buffer:
///
///  * A `SurfaceTexture` ([handlesCropAndRotation] is true) applies it when its
///    surface is connected to the camera directly, so only the display rotation
///    needs to be corrected.
///  * An `ImageReader` ([handlesCropAndRotation] is false) never applies it, and
///    neither surface has it when CameraX copies the camera stream with OpenGL
///    (like for stream sharing), so the preview needs to be fully corrected
///    (see [buildUntransformedPreview]).
@internal
final class RotatedPreview extends StatefulWidget {
  /// Creates a [RotatedPreview] that corrects the rotation of [child].
  const RotatedPreview({
    super.key,
    required this.handlesCropAndRotation,
    required this.initialDeviceOrientation,
    required this.initialDefaultDisplayRotation,
    required this.deviceOrientationStream,
    required this.deviceOrientationManager,
    required this.initialTransformationInfo,
    required this.transformationInfoStream,
    required this.previewTargetRotation,
    required this.sensorOrientationDegrees,
    required this.cameraIsFrontFacing,
    required this.child,
  });

  /// Whether or not the Android surface producer of the camera preview is
  /// backed by a `SurfaceTexture`, which applies the camera transform, rather
  /// than an `ImageReader`.
  ///
  /// This is determined when the camera is created and does not change.
  final bool handlesCropAndRotation;

  /// The initial orientation of the device when the camera is created.
  final DeviceOrientation initialDeviceOrientation;

  /// The initial rotation of the Android default display when the camera is
  /// created, in terms of a Surface rotation constant.
  final int initialDefaultDisplayRotation;

  /// Stream of changes to the device orientation.
  final Stream<DeviceOrientation> deviceOrientationStream;

  /// The camera's device orientation manager.
  ///
  /// Instance required to check the current rotation of the default Android display.
  final DeviceOrientationManager deviceOrientationManager;

  /// The most recent [TransformationInfo] of the camera preview when this
  /// widget is created, if any.
  final TransformationInfo? initialTransformationInfo;

  /// Stream of updates to the [TransformationInfo] of the camera preview.
  final Stream<TransformationInfo> transformationInfoStream;

  /// The target rotation of the camera preview `Preview`, in terms of a Surface
  /// rotation constant.
  ///
  /// [TransformationInfo.rotationDegrees] is relative to this rotation.
  final int previewTargetRotation;

  /// The orientation of the camera sensor in degrees.
  final double sensorOrientationDegrees;

  /// Whether or not the camera is front facing.
  final bool cameraIsFrontFacing;

  /// The camera preview [Widget] to rotate.
  final Widget child;

  @override
  State<RotatedPreview> createState() => _RotatedPreviewState();
}

final class _RotatedPreviewState extends State<RotatedPreview> {
  /// The current orientation of the device.
  late DeviceOrientation _deviceOrientation;

  /// The current rotation of the Android default display, in terms of a
  /// Surface rotation constant.
  late Future<int> _defaultDisplayRotation;

  /// The current [TransformationInfo] of the camera preview, if any has been
  /// received.
  TransformationInfo? _transformationInfo;

  late StreamSubscription<DeviceOrientation> _deviceOrientationSubscription;
  late StreamSubscription<TransformationInfo> _transformationInfoSubscription;

  @override
  void initState() {
    super.initState();
    _deviceOrientation = widget.initialDeviceOrientation;
    _defaultDisplayRotation = Future<int>.value(widget.initialDefaultDisplayRotation);
    _transformationInfo = widget.initialTransformationInfo;

    // These streams are only subscribed to here, so the streams of a new
    // widget with the same key are ignored. That is fine because
    // AndroidCameraCameraX.buildPreview always passes streams of the same
    // broadcast stream controllers; if that changes, didUpdateWidget needs to
    // resubscribe to them.
    _deviceOrientationSubscription = widget.deviceOrientationStream.listen((
      DeviceOrientation event,
    ) {
      // Ensure that we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }

      setState(() {
        _deviceOrientation = event;
        _defaultDisplayRotation = widget.deviceOrientationManager.getDefaultDisplayRotation();
      });
    });

    _transformationInfoSubscription = widget.transformationInfoStream.listen((
      TransformationInfo event,
    ) {
      // Ensure that we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }

      setState(() {
        _transformationInfo = event;
      });
    });
  }

  @override
  void dispose() {
    _deviceOrientationSubscription.cancel();
    _transformationInfoSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _defaultDisplayRotation,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        return _buildRotatedPreview(snapshot.data!);
      },
    );
  }

  Widget _buildRotatedPreview(int defaultDisplayRotation) {
    final TransformationInfo? info = _transformationInfo;
    if (widget.handlesCropAndRotation && (info == null || info.hasCameraTransform)) {
      // The SurfaceTexture applies the camera transform (the sensor rotation and,
      // with CameraX's default mirror mode, front camera mirroring), so only the
      // display rotation remains to be corrected, minus the rotation applied by
      // the CameraPreview widget (see camera/camera/lib/src/camera_preview.dart)
      // that is not correct for this plugin.
      final int rotationCorrection =
          getQuarterTurnsFromSurfaceRotationConstant(defaultDisplayRotation) -
          getPreAppliedQuarterTurnsRotationFromDeviceOrientation(_deviceOrientation);

      return RotatedBox(quarterTurns: rotationCorrection, child: widget.child);
    }

    return buildUntransformedPreview(
      child: widget.child,
      transformationInfo: info,
      cameraIsFrontFacing: widget.cameraIsFrontFacing,
      sensorOrientationDegrees: widget.sensorOrientationDegrees.toInt(),
      displayRotation: defaultDisplayRotation,
      previewTargetRotation: widget.previewTargetRotation,
      // The Preview of an ImageReader backed surface is created with CameraX
      // mirroring turned off (see PreviewProxyApi.java).
      previewMirroringDisabled: !widget.handlesCropAndRotation,
      deviceOrientation: _deviceOrientation,
    );
  }
}
