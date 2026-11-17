// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'rotated_preview_utils.dart';

/// Shows a native Android `PreviewView` as a platform view.
///
/// The `PreviewView` rotates and scales the camera preview itself, so this
/// widget only cancels the rotation that the `CameraPreview` widget of the
/// `camera` package applies for the device orientation (see
/// camera/camera/lib/src/camera_preview.dart) instead of applying the
/// corrections of `RotatedPreviewDelegate`.
@internal
final class PreviewViewPreview extends StatefulWidget {
  /// Creates a [PreviewViewPreview] that shows the `PreviewView` identified by
  /// [previewViewId] in the `InstanceManager`.
  const PreviewViewPreview({
    super.key,
    required this.previewViewId,
    required this.initialDeviceOrientation,
    required this.deviceOrientationStream,
  });

  /// The view type of the platform view that hosts the `PreviewView`.
  static const String viewType = 'plugins.flutter.io/camera_android_camerax/preview_view';

  /// The `InstanceManager` identifier of the `PreviewView` to show.
  final int previewViewId;

  /// The orientation of the device when the camera was created.
  final DeviceOrientation initialDeviceOrientation;

  /// Stream of changes to the device orientation.
  final Stream<DeviceOrientation> deviceOrientationStream;

  @override
  State<PreviewViewPreview> createState() => _PreviewViewPreviewState();
}

final class _PreviewViewPreviewState extends State<PreviewViewPreview> {
  late StreamSubscription<DeviceOrientation> _deviceOrientationSubscription;
  late int _preappliedQuarterTurns;

  @override
  void initState() {
    super.initState();
    _preappliedQuarterTurns = getPreAppliedQuarterTurnsRotationFromDeviceOrientation(
      widget.initialDeviceOrientation,
    );
    _deviceOrientationSubscription = widget.deviceOrientationStream.listen((
      DeviceOrientation orientation,
    ) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preappliedQuarterTurns = getPreAppliedQuarterTurnsRotationFromDeviceOrientation(
          orientation,
        );
      });
    });
  }

  @override
  void dispose() {
    _deviceOrientationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -_preappliedQuarterTurns,
      // A platform view keeps showing the view it was created with, so a new
      // PreviewView needs a new platform view.
      child: PlatformViewLink(
        key: ValueKey<int>(widget.previewViewId),
        viewType: PreviewViewPreview.viewType,
        surfaceFactory: (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: PreviewViewPreview.viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: widget.previewViewId,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      ),
    );
  }
}
