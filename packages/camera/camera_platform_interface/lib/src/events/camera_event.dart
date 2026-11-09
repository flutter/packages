// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import '../../camera_platform_interface.dart';

/// Generic Event coming from the native side of Camera,
/// related to a specific camera module.
///
/// All [CameraEvent]s contain the `cameraId` that originated the event. This
/// should never be `null`.
///
/// This class is used as a base class for all the events that might be
/// triggered from a Camera, but it is never used directly as an event type.
///
/// Do NOT instantiate new events like `CameraEvent(cameraId)` directly,
/// use a specific class instead:
///
/// Do `class NewEvent extend CameraEvent` when creating your own events.
/// See below for examples: `CameraClosingEvent`, `CameraErrorEvent`...
/// These events are more semantic and more pleasant to use than raw generics.
/// They can be (and in fact, are) filtered by the `instanceof`-operator.
@immutable
abstract class CameraEvent {
  /// Build a Camera Event, that relates a `cameraId`.
  ///
  /// The `cameraId` is the ID of the camera that triggered the event.
  const CameraEvent(this.cameraId);

  /// The ID of the Camera this event is associated to.
  final int cameraId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraEvent && runtimeType == other.runtimeType && cameraId == other.cameraId;

  @override
  int get hashCode => cameraId.hashCode;
}

/// An event fired when the camera has finished initializing.
class CameraInitializedEvent extends CameraEvent {
  /// Build a CameraInitialized event triggered from the camera represented by
  /// `cameraId`.
  ///
  /// The `previewWidth` represents the width of the generated preview in pixels.
  /// The `previewHeight` represents the height of the generated preview in pixels.
  const CameraInitializedEvent(
    super.cameraId,
    this.previewWidth,
    this.previewHeight,
    this.exposureMode,
    this.exposurePointSupported,
    this.focusMode,
    this.focusPointSupported,
  );

  /// The width of the preview in pixels.
  final double previewWidth;

  /// The height of the preview in pixels.
  final double previewHeight;

  /// The default exposure mode
  final ExposureMode exposureMode;

  /// The default focus mode
  final FocusMode focusMode;

  /// Whether setting exposure points is supported.
  final bool exposurePointSupported;

  /// Whether setting focus points is supported.
  final bool focusPointSupported;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CameraInitializedEvent &&
          runtimeType == other.runtimeType &&
          previewWidth == other.previewWidth &&
          previewHeight == other.previewHeight &&
          exposureMode == other.exposureMode &&
          exposurePointSupported == other.exposurePointSupported &&
          focusMode == other.focusMode &&
          focusPointSupported == other.focusPointSupported;

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    previewWidth,
    previewHeight,
    exposureMode,
    exposurePointSupported,
    focusMode,
    focusPointSupported,
  );
}

/// An event fired when the resolution preset of the camera has changed.
class CameraResolutionChangedEvent extends CameraEvent {
  /// Build a CameraResolutionChanged event triggered from the camera
  /// represented by `cameraId`.
  ///
  /// The `captureWidth` represents the width of the resulting image in pixels.
  /// The `captureHeight` represents the height of the resulting image in pixels.
  const CameraResolutionChangedEvent(super.cameraId, this.captureWidth, this.captureHeight);

  /// The capture width in pixels.
  final double captureWidth;

  /// The capture height in pixels.
  final double captureHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraResolutionChangedEvent &&
          super == other &&
          runtimeType == other.runtimeType &&
          captureWidth == other.captureWidth &&
          captureHeight == other.captureHeight;

  @override
  int get hashCode => Object.hash(super.hashCode, captureWidth, captureHeight);
}

/// An event fired when the camera is going to close.
class CameraClosingEvent extends CameraEvent {
  /// Build a CameraClosing event triggered from the camera represented by
  /// `cameraId`.
  const CameraClosingEvent(super.cameraId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is CameraClosingEvent && runtimeType == other.runtimeType;

  @override
  // This is here even though it just calls super to make it less likely that
  // operator== would be changed without changing `hashCode`.
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}

/// An event fired when an error occured while operating the camera.
class CameraErrorEvent extends CameraEvent {
  /// Build a CameraError event triggered from the camera represented by
  /// `cameraId`.
  ///
  /// The `description` represents the error occured on the camera.
  const CameraErrorEvent(super.cameraId, this.description);

  /// Description of the error.
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CameraErrorEvent &&
          runtimeType == other.runtimeType &&
          description == other.description;

  @override
  int get hashCode => Object.hash(super.hashCode, description);
}

/// An event fired when a video has finished recording.
class VideoRecordedEvent extends CameraEvent {
  /// Build a VideoRecordedEvent triggered from the camera with the `cameraId`.
  ///
  /// The `file` represents the file of the video.
  /// The `maxVideoDuration` shows if a maxVideoDuration shows if a maximum
  /// video duration was set.
  const VideoRecordedEvent(super.cameraId, this.file, this.maxVideoDuration);

  /// XFile of the recorded video.
  final XFile file;

  /// Maximum duration of the recorded video.
  final Duration? maxVideoDuration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is VideoRecordedEvent &&
          runtimeType == other.runtimeType &&
          maxVideoDuration == other.maxVideoDuration;

  @override
  int get hashCode => Object.hash(super.hashCode, file, maxVideoDuration);
}
