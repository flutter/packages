// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'messages.g.dart';
import 'type_conversion.dart';
import 'utils.dart';

/// An iOS implementation of [CameraPlatform] based on AVFoundation.
class AVFoundationCamera extends CameraPlatform {
  /// Creates a new AVFoundation-based [CameraPlatform] implementation instance.
  AVFoundationCamera({@visibleForTesting CameraApi? api})
      : _hostApi = api ?? CameraApi();

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AVFoundationCamera();
  }

  /// Interface for calling host-side code.
  final CameraApi _hostApi;

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to camera events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// The handler for device-level messages that should be rebroadcast to
  /// clients as [DeviceEvent]s.
  @visibleForTesting
  late final HostDeviceMessageHandler hostHandler = () {
    // Set up the method handler lazily.
    return HostDeviceMessageHandler();
  }();

  /// The per-camera handlers for messages that should be rebroadcast to
  /// clients as [CameraEvent]s.
  @visibleForTesting
  final Map<int, HostCameraMessageHandler> hostCameraHandlers =
      <int, HostCameraMessageHandler>{};

  // The stream to receive frames from the native code.
  StreamSubscription<dynamic>? _platformImageStreamSubscription;

  // The stream for vending frames to platform interface clients.
  StreamController<CameraImageData>? _frameStreamController;

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      return (await _hostApi.getAvailableCameras())
          .map(cameraDescriptionFromPlatform)
          .toList();
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
      return await _hostApi.create(
          cameraDescription.name,
          PlatformMediaSettings(
            resolutionPreset:
                _pigeonResolutionPreset(mediaSettings?.resolutionPreset),
            framesPerSecond: mediaSettings?.fps,
            videoBitrate: mediaSettings?.videoBitrate,
            audioBitrate: mediaSettings?.audioBitrate,
            enableAudio: mediaSettings?.enableAudio ?? true,
          ));
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

    final Completer<void> completer = Completer<void>();

    unawaited(onCameraInitialized(cameraId)
        .first
        .then((CameraInitializedEvent value) {
      completer.complete();
    }));

    try {
      await _hostApi.initialize(cameraId, _pigeonImageFormat(imageFormatGroup));
    } on PlatformException catch (e, s) {
      completer.completeError(
        CameraException(e.code, e.message),
        s,
      );
    }

    return completer.future;
  }

  @override
  Future<void> dispose(int cameraId) async {
    final HostCameraMessageHandler? handler =
        hostCameraHandlers.remove(cameraId);
    handler?.dispose();

    await _hostApi.dispose(cameraId);
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraResolutionChangedEvent>();
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
    return hostHandler.deviceEventStreamController.stream
        .whereType<DeviceOrientationChangedEvent>();
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    await _hostApi
        .lockCaptureOrientation(serializeDeviceOrientation(orientation));
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    await _hostApi.unlockCaptureOrientation();
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final String path = await _hostApi.takePicture();
    return XFile(path);
  }

  @override
  Future<void> prepareForVideoRecording() async {
    await _hostApi.prepareForVideoRecording();
  }

  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    // Ignore maxVideoDuration, as it is unimplemented and deprecated.
    return startVideoCapturing(VideoCaptureOptions(cameraId));
  }

  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) async {
    // Max video duration is currently not supported.
    await _hostApi.startVideoRecording(options.streamCallback != null);

    if (options.streamCallback != null) {
      _frameStreamController = _createStreamController();
      _frameStreamController!.stream.listen(options.streamCallback);
      _startStreamListener();
    }
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final String path = await _hostApi.stopVideoRecording();
    return XFile(path);
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) async {
    await _hostApi.pauseVideoRecording();
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    await _hostApi.resumeVideoRecording();
  }

  @override
  bool supportsImageStreaming() => true;

  @override
  Stream<CameraImageData> onStreamedFrameAvailable(int cameraId,
      {CameraImageStreamOptions? options}) {
    _frameStreamController =
        _createStreamController(onListen: _onFrameStreamListen);
    return _frameStreamController!.stream;
  }

  StreamController<CameraImageData> _createStreamController(
      {void Function()? onListen}) {
    return StreamController<CameraImageData>(
      onListen: onListen ?? () {},
      onPause: _onFrameStreamPauseResume,
      onResume: _onFrameStreamPauseResume,
      onCancel: _onFrameStreamCancel,
    );
  }

  void _onFrameStreamListen() {
    _startPlatformStream();
  }

  Future<void> _startPlatformStream() async {
    await _hostApi.startImageStream();
    _startStreamListener();
  }

  void _startStreamListener() {
    const EventChannel cameraEventChannel =
        EventChannel('plugins.flutter.io/camera_avfoundation/imageStream');
    _platformImageStreamSubscription =
        cameraEventChannel.receiveBroadcastStream().listen((dynamic imageData) {
      try {
        _hostApi.receivedImageStreamData();
      } on PlatformException catch (e) {
        throw CameraException(e.code, e.message);
      }
      _frameStreamController!
          .add(cameraImageFromPlatformData(imageData as Map<dynamic, dynamic>));
    });
  }

  FutureOr<void> _onFrameStreamCancel() async {
    await _hostApi.stopImageStream();
    await _platformImageStreamSubscription?.cancel();
    _platformImageStreamSubscription = null;
    _frameStreamController = null;
  }

  void _onFrameStreamPauseResume() {
    throw CameraException('InvalidCall',
        'Pause and resume are not supported for onStreamedFrameAvailable');
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    await _hostApi.setFlashMode(_pigeonFlashMode(mode));
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {
    await _hostApi.setExposureMode(_pigeonExposureMode(mode));
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    await _hostApi.setExposurePoint(_pigeonPoint(point));
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    return _hostApi.getMinExposureOffset();
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    return _hostApi.getMaxExposureOffset();
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    // iOS has no step size.
    return 0;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    await _hostApi.setExposureOffset(offset);
    // The platform API allows for implementations that have to adjust the
    // target offset and return the actual offset used, but there is never
    // adjustment in this implementation.
    return offset;
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {
    await _hostApi.setFocusMode(_pigeonFocusMode(mode));
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    await _hostApi.setFocusPoint(_pigeonPoint(point));
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    return _hostApi.getMaxZoomLevel();
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    return _hostApi.getMinZoomLevel();
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    try {
      await _hostApi.setZoomLevel(zoom);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    await _hostApi.pausePreview();
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    await _hostApi.resumePreview();
  }

  @override
  Future<void> setDescriptionWhileRecording(
      CameraDescription description) async {
    await _hostApi.updateDescriptionWhileRecording(description.name);
  }

  @override
  Future<void> setImageFileFormat(int cameraId, ImageFileFormat format) async {
    await _hostApi.setImageFileFormat(_pigeonImageFileFormat(format));
  }

  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }

  /// Returns an [FocusMode]'s Pigeon representation.
  PlatformFocusMode _pigeonFocusMode(FocusMode mode) {
    switch (mode) {
      case FocusMode.locked:
        return PlatformFocusMode.locked;
      case FocusMode.auto:
        return PlatformFocusMode.auto;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return PlatformFocusMode.auto;
  }

  /// Returns an [ExposureMode]'s Pigeon representation.
  PlatformExposureMode _pigeonExposureMode(ExposureMode mode) {
    switch (mode) {
      case ExposureMode.locked:
        return PlatformExposureMode.locked;
      case ExposureMode.auto:
        return PlatformExposureMode.auto;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return PlatformExposureMode.auto;
  }

  /// Returns a [FlashMode]'s Pigeon representation.
  PlatformFlashMode _pigeonFlashMode(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.off:
        return PlatformFlashMode.off;
      case FlashMode.auto:
        return PlatformFlashMode.auto;
      case FlashMode.always:
        return PlatformFlashMode.always;
      case FlashMode.torch:
        return PlatformFlashMode.torch;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return PlatformFlashMode.off;
  }

  /// Returns a [ResolutionPreset]'s Pigeon representation.
  PlatformResolutionPreset _pigeonResolutionPreset(
      ResolutionPreset? resolutionPreset) {
    if (resolutionPreset == null) {
      // Provide a default if one isn't provided, since the native side needs
      // to set something.
      return PlatformResolutionPreset.high;
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

  /// Returns an [ImageFormatGroup]'s Pigeon representation.
  PlatformImageFormatGroup _pigeonImageFormat(ImageFormatGroup format) {
    switch (format) {
      // "unknown" is used to indicate the default.
      case ImageFormatGroup.unknown:
      case ImageFormatGroup.bgra8888:
        return PlatformImageFormatGroup.bgra8888;
      case ImageFormatGroup.yuv420:
        return PlatformImageFormatGroup.yuv420;
      case ImageFormatGroup.jpeg:
      case ImageFormatGroup.nv21:
      // Fall through.
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // TODO(stuartmorgan): Consider throwing an UnsupportedError, instead of
    // doing fallback, when a specific unsupported format is requested. This
    // would require a breaking change at this layer and the app-facing layer.
    return PlatformImageFormatGroup.bgra8888;
  }

  /// Returns an [ImageFileFormat]'s Pigeon representation.
  PlatformImageFileFormat _pigeonImageFileFormat(ImageFileFormat format) {
    switch (format) {
      case ImageFileFormat.heif:
        return PlatformImageFileFormat.heif;
      case ImageFileFormat.jpeg:
        return PlatformImageFileFormat.jpeg;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // TODO(stuartmorgan): Consider throwing an UnsupportedError, instead of
    // doing fallback, when a specific unsupported format is requested. This
    // would require a breaking change at this layer and the app-facing layer.
    // ignore: dead_code
    return PlatformImageFileFormat.jpeg;
  }

  /// Returns a [Point]s Pigeon representation.
  PlatformPoint? _pigeonPoint(Point<double>? point) {
    if (point == null) {
      return null;
    }
    return PlatformPoint(x: point.x, y: point.y);
  }
}

/// Callback handler for device-level events from the platform host.
@visibleForTesting
class HostDeviceMessageHandler implements CameraGlobalEventApi {
  /// Creates a new handler and registers it to listen to its platform channel.
  HostDeviceMessageHandler() {
    CameraGlobalEventApi.setUp(this);
  }

  /// The controller used to broadcast general device events coming from the
  /// host platform.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  final StreamController<DeviceEvent> deviceEventStreamController =
      StreamController<DeviceEvent>.broadcast();

  @override
  void deviceOrientationChanged(PlatformDeviceOrientation orientation) {
    deviceEventStreamController.add(DeviceOrientationChangedEvent(
        deviceOrientationFromPlatform(orientation)));
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
  void initialized(PlatformCameraState initialState) {
    streamController.add(CameraInitializedEvent(
      cameraId,
      initialState.previewSize.width,
      initialState.previewSize.height,
      exposureModeFromPlatform(initialState.exposureMode),
      initialState.exposurePointSupported,
      focusModeFromPlatform(initialState.focusMode),
      initialState.focusPointSupported,
    ));
  }
}
