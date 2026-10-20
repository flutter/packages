// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'camerax_library.dart' show DeviceOrientationManager, TransformationInfo;

/// Base class for the widgets that rotate the camera preview to be upright
/// according to the current user interface orientation.
@internal
abstract class RotatedPreview extends StatefulWidget {
  /// Creates a [RotatedPreview] with the inputs shared by all camera preview
  /// rotation implementations.
  const RotatedPreview({
    super.key,
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
}

/// Tracks the current device orientation, Android default display rotation,
/// and [TransformationInfo] of a [RotatedPreview] for its whole lifetime.
@internal
mixin RotatedPreviewStateMixin<T extends RotatedPreview> on State<T> {
  /// The current orientation of the device.
  late DeviceOrientation deviceOrientation;

  /// The current rotation of the Android default display, in terms of a
  /// Surface rotation constant.
  late Future<int> defaultDisplayRotation;

  /// The current [TransformationInfo] of the camera preview, if any has been
  /// received.
  TransformationInfo? transformationInfo;

  late StreamSubscription<DeviceOrientation> _deviceOrientationSubscription;
  late StreamSubscription<TransformationInfo> _transformationInfoSubscription;

  @override
  void initState() {
    super.initState();
    deviceOrientation = widget.initialDeviceOrientation;
    defaultDisplayRotation = Future<int>.value(widget.initialDefaultDisplayRotation);
    transformationInfo = widget.initialTransformationInfo;

    _deviceOrientationSubscription = widget.deviceOrientationStream.listen((
      DeviceOrientation event,
    ) {
      // Ensure that we aren't updating the state if the widget is being destroyed.
      if (!mounted) {
        return;
      }

      setState(() {
        deviceOrientation = event;
        defaultDisplayRotation = widget.deviceOrientationManager.getDefaultDisplayRotation();
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
        transformationInfo = event;
      });
    });
  }

  @override
  void dispose() {
    _deviceOrientationSubscription.cancel();
    _transformationInfoSubscription.cancel();
    super.dispose();
  }

  /// Builds the widget returned by [builder] once the current rotation of the
  /// Android default display (a Surface rotation constant) is known.
  Widget buildWithDefaultDisplayRotation(Widget Function(int defaultDisplayRotation) builder) {
    return FutureBuilder<int>(
      future: defaultDisplayRotation,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder(snapshot.data!);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
