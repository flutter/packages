// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'src/messages.g.dart';

/// An implementation of [CameraPlatform] for Windows.
class CameraWindows extends CameraPlatform {
  /// Creates a new Windows [CameraPlatform] implementation instance.
  CameraWindows({@visibleForTesting CameraApi? api})
      : _hostApi = api ?? CameraApi();

  /// Registers the Windows implementation of CameraPlatform.
  static void registerWith() {
    CameraPlatform.instance = CameraWindows();
  }

  /// Interface for calling host-side code.
  final CameraApi _hostApi;

  /// The per-camera handlers for messages that should be rebroadcast to
  /// clients as [CameraEvent]s.
  @visibleForTesting
  final Map<int, HostCameraMessageHandler> hostCameraHandlers =
      <int, HostCameraMessageHandler>{};

  /// The controller that broadcasts events coming from handleCameraMethodCall
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// Returns a stream of camera events for the given [cameraId].
  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final List<String?> cameras = await _hostApi.getAvailableCameras();

      return cameras.map((String? cameraName) {
        return CameraDescription(
          // This type is only nullable due to Pigeon limitations, see
          // https://github.com/flutter/flutter/issues/97848. The native code
          // will never return null.
          name: cameraName!,
          // TODO(stuartmorgan): Implement these; see
          // https://github.com/flutter/flutter/issues/97540.
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );
      }).toList();
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) =>
      createCameraWithSettings(
          cameraDescription,
          MediaSettings(
            resolutionPreset: resolutionPreset,
            enableAudio: enableAudio,
          ));

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings? mediaSettings,
  ) async {
    try {
      // If resolutionPreset is not specified, plugin selects the highest resolution possible.
      return await _hostApi.create(
          cameraDescription.name, _pigeonMediaSettings(mediaSettings));
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    hostCameraHandlers.putIfAbsent(cameraId,
        () => HostCameraMessageHandler(cameraId, cameraEventStreamController));

    final PlatformSize reply;
    try {
      reply = await _hostApi.initialize(cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }

    cameraEventStreamController.add(
      CameraInitializedEvent(
        cameraId,
        reply.width,
        reply.height,
        ExposureMode.auto,
        false,
        FocusMode.auto,
        false,
      ),
    );
  }

  @override
  Future<void> dispose(int cameraId) async {
    await _hostApi.dispose(cameraId);

    // Destroy method channel after camera is disposed to be able to handle last messages.
    hostCameraHandlers.remove(cameraId)?.dispose();
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    /// Windows API does not automatically change the camera's resolution
    /// during capture so these events are never send from the platform.
    /// Support for changing resolution should be implemented, if support for
    /// requesting resolution change is added to camera platform interface.
    return const Stream<CameraResolutionChangedEvent>.empty();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraClosingEvent>();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraErrorEvent>();
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    return _cameraEvents(cameraId).whereType<VideoRecordedEvent>();
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    // TODO(jokerttu): Implement device orientation detection, https://github.com/flutter/flutter/issues/97540.
    // Force device orientation to landscape as by default camera plugin uses portraitUp orientation.
    return Stream<DeviceOrientationChangedEvent>.value(
      const DeviceOrientationChangedEvent(DeviceOrientation.landscapeRight),
    );
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    // TODO(jokerttu): Implement lock capture orientation feature, https://github.com/flutter/flutter/issues/97540.
    throw UnimplementedError('lockCaptureOrientation() is not implemented.');
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    // TODO(jokerttu): Implement unlock capture orientation feature, https://github.com/flutter/flutter/issues/97540.
    throw UnimplementedError('unlockCaptureOrientation() is not implemented.');
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final String path = await _hostApi.takePicture(cameraId);

    return XFile(path);
  }

  @override
  Future<void> prepareForVideoRecording() async {
    // No-op.
  }

  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    // Ignore maxVideoDuration, as it is unimplemented and deprecated.
    return startVideoCapturing(VideoCaptureOptions(cameraId));
  }

  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) async {
    if (options.streamCallback != null || options.streamOptions != null) {
      throw UnimplementedError(
          'Streaming is not currently supported on Windows');
    }

    // Currently none of `options` is supported on Windows, so it's not passed.
    await _hostApi.startVideoRecording(options.cameraId);
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final String path = await _hostApi.stopVideoRecording(cameraId);

    return XFile(path);
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) async {
    throw UnsupportedError(
        'pauseVideoRecording() is not supported due to Win32 API limitations.');
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    throw UnsupportedError(
        'resumeVideoRecording() is not supported due to Win32 API limitations.');
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    // TODO(jokerttu): Implement flash mode support, https://github.com/flutter/flutter/issues/97537.
    throw UnimplementedError('setFlashMode() is not implemented.');
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {
    // TODO(jokerttu): Implement explosure mode support, https://github.com/flutter/flutter/issues/97537.
    throw UnimplementedError('setExposureMode() is not implemented.');
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    throw UnsupportedError(
        'setExposurePoint() is not supported due to Win32 API limitations.');
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    // TODO(jokerttu): Implement exposure control support, https://github.com/flutter/flutter/issues/97537.
    // Value is returned to support existing implementations.
    return 0.0;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    // TODO(jokerttu): Implement exposure control support, https://github.com/flutter/flutter/issues/97537.
    // Value is returned to support existing implementations.
    return 0.0;
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    // TODO(jokerttu): Implement exposure control support, https://github.com/flutter/flutter/issues/97537.
    // Value is returned to support existing implementations.
    return 1.0;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    // TODO(jokerttu): Implement exposure control support, https://github.com/flutter/flutter/issues/97537.
    throw UnimplementedError('setExposureOffset() is not implemented.');
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {
    // TODO(jokerttu): Implement focus mode support, https://github.com/flutter/flutter/issues/97537.
    throw UnimplementedError('setFocusMode() is not implemented.');
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    throw UnsupportedError(
        'setFocusPoint() is not supported due to Win32 API limitations.');
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    // TODO(jokerttu): Implement zoom level support, https://github.com/flutter/flutter/issues/97537.
    // Value is returned to support existing implementations.
    return 1.0;
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    // TODO(jokerttu): Implement zoom level support, https://github.com/flutter/flutter/issues/97537.
    // Value is returned to support existing implementations.
    return 1.0;
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    // TODO(jokerttu): Implement zoom level support, https://github.com/flutter/flutter/issues/97537.
    throw UnimplementedError('setZoomLevel() is not implemented.');
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    await _hostApi.pausePreview(cameraId);
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    await _hostApi.resumePreview(cameraId);
  }

  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }

  /// Returns a [MediaSettings]'s Pigeon representation.
  PlatformMediaSettings _pigeonMediaSettings(MediaSettings? settings) {
    return PlatformMediaSettings(
      resolutionPreset: _pigeonResolutionPreset(settings?.resolutionPreset),
      enableAudio: settings?.enableAudio ?? true,
      framesPerSecond: settings?.fps,
      videoBitrate: settings?.videoBitrate,
      audioBitrate: settings?.audioBitrate,
    );
  }

  /// Returns a [ResolutionPreset]'s Pigeon representation.
  PlatformResolutionPreset _pigeonResolutionPreset(
      ResolutionPreset? resolutionPreset) {
    if (resolutionPreset == null) {
      // Provide a default if one isn't provided, since the native side needs
      // to set something.
      return PlatformResolutionPreset.max;
    }
    switch (resolutionPreset) {
      case ResolutionPreset.max:
        return PlatformResolutionPreset.max;
      case ResolutionPreset.ultraHigh:
        return PlatformResolutionPreset.ultraHigh;
      case ResolutionPreset.veryHigh:
        return PlatformResolutionPreset.veryHigh;
      case ResolutionPreset.high:
        return PlatformResolutionPreset.high;
      case ResolutionPreset.medium:
        return PlatformResolutionPreset.medium;
      case ResolutionPreset.low:
        return PlatformResolutionPreset.low;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return PlatformResolutionPreset.max;
  }
}

/// Callback handler for camera-level events from the platform host.
@visibleForTesting
class HostCameraMessageHandler implements CameraEventApi {
  /// Creates a new handler that listens for events from camera [cameraId], and
  /// broadcasts them to [streamController].
  HostCameraMessageHandler(this.cameraId, this.streamController) {
    CameraEventApi.setUp(this, messageChannelSuffix: cameraId.toString());
  }

  /// Removes the handler for native messages.
  void dispose() {
    CameraEventApi.setUp(null, messageChannelSuffix: cameraId.toString());
  }

  /// The camera ID this handler listens for events from.
  final int cameraId;

  /// The controller used to broadcast camera events coming from the
  /// host platform.
  final StreamController<CameraEvent> streamController;

  @override
  void error(String message) {
    streamController.add(CameraErrorEvent(cameraId, message));
  }

  @override
  void cameraClosing() {
    streamController.add(CameraClosingEvent(cameraId));
  }
}
