// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'messages.g.dart';
import 'type_conversion.dart';
import 'utils.dart';

/// The Android implementation of [CameraPlatform] that uses method channels.
class AndroidCamera extends CameraPlatform {
  /// Creates a new [CameraPlatform] instance.
  AndroidCamera({@visibleForTesting CameraApi? hostApi})
      : _hostApi = hostApi ?? CameraApi();

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCamera();
  }

  final CameraApi _hostApi;

  /// The name of the channel that device events from the platform side are
  /// sent on.
  @visibleForTesting
  static const String deviceEventChannelName =
      'plugins.flutter.io/camera_android/fromPlatform';

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

  /// Handler for device-level callbacks from the native side.
  @visibleForTesting
  late final HostDeviceMessageHandler hostHandler = HostDeviceMessageHandler();

  /// Map of camera IDs to camera-level callback handlers listening to their
  /// respective platform channels.
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
      final List<PlatformCameraDescription> cameraDescriptions =
          await _hostApi.getAvailableCameras();
      return cameraDescriptions
          .map((PlatformCameraDescription cameraDescription) {
        return CameraDescription(
            name: cameraDescription.name,
            lensDirection: cameraLensDirectionFromPlatform(
                cameraDescription.lensDirection),
            sensorOrientation: cameraDescription.sensorOrientation);
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
      return await _hostApi.create(
          cameraDescription.name, mediaSettingsToPlatform(mediaSettings));
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
      await _hostApi.initialize(imageFormatGroupToPlatform(imageFormatGroup));
    } on PlatformException catch (e, s) {
      completer.completeError(CameraException(e.code, e.message), s);
    }

    return completer.future;
  }

  @override
  Future<void> dispose(int cameraId) async {
    final HostCameraMessageHandler? handler =
        hostCameraHandlers.remove(cameraId);
    handler?.dispose();

    await _hostApi.dispose();
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
        .lockCaptureOrientation(deviceOrientationToPlatform(orientation));
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

  // This optimization is unnecessary on Android.
  @override
  Future<void> prepareForVideoRecording() async {}

  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    // Ignore maxVideoDuration, as it is unimplemented and deprecated.
    return startVideoCapturing(VideoCaptureOptions(cameraId));
  }

  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) async {
    await _hostApi.startVideoRecording(options.streamCallback != null);

    if (options.streamCallback != null) {
      _installStreamController().stream.listen(options.streamCallback);
      _startStreamListener();
    }
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final String path = await _hostApi.stopVideoRecording();
    return XFile(path);
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) =>
      _hostApi.pauseVideoRecording();

  @override
  Future<void> resumeVideoRecording(int cameraId) =>
      _hostApi.resumeVideoRecording();

  @override
  bool supportsImageStreaming() => true;

  @override
  Stream<CameraImageData> onStreamedFrameAvailable(int cameraId,
      {CameraImageStreamOptions? options}) {
    _installStreamController(onListen: _onFrameStreamListen);
    return _frameStreamController!.stream;
  }

  StreamController<CameraImageData> _installStreamController(
      {void Function()? onListen}) {
    _frameStreamController = StreamController<CameraImageData>(
      onListen: onListen ?? () {},
      onPause: _onFrameStreamPauseResume,
      onResume: _onFrameStreamPauseResume,
      onCancel: _onFrameStreamCancel,
    );
    return _frameStreamController!;
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
        EventChannel('plugins.flutter.io/camera_android/imageStream');
    _platformImageStreamSubscription =
        cameraEventChannel.receiveBroadcastStream().listen((dynamic imageData) {
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
  Future<void> setFlashMode(int cameraId, FlashMode mode) =>
      _hostApi.setFlashMode(flashModeToPlatform(mode));

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) =>
      _hostApi.setExposureMode(exposureModeToPlatform(mode));

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _hostApi.setExposurePoint(pointToPlatform(point));
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
    return _hostApi.getExposureOffsetStepSize();
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    return _hostApi.setExposureOffset(offset);
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) =>
      _hostApi.setFocusMode(focusModeToPlatform(mode));

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _hostApi.setFocusPoint(pointToPlatform(point));
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
    await _hostApi.setDescriptionWhileRecording(description.name);
  }

  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }
}

/// Handles callbacks from the platform host that are not camera-specific.
@visibleForTesting
class HostDeviceMessageHandler implements CameraGlobalEventApi {
  /// Creates a new handler and registers it to listen to the global event platform channel.
  HostDeviceMessageHandler() {
    CameraGlobalEventApi.setUp(this);
  }

  /// The controller that broadcasts device events coming from the host platform.
  final StreamController<DeviceEvent> deviceEventStreamController =
      StreamController<DeviceEvent>.broadcast();
  @override
  void deviceOrientationChanged(PlatformDeviceOrientation orientation) {
    deviceEventStreamController.add(DeviceOrientationChangedEvent(
        deviceOrientationFromPlatform(orientation)));
  }
}

/// Handles camera-specific callbacks from the platform host.
@visibleForTesting
class HostCameraMessageHandler implements CameraEventApi {
  /// Creates a new handler and registers it to listen to its camera's platform channel.
  HostCameraMessageHandler(this.cameraId, this.cameraEventStreamController) {
    CameraEventApi.setUp(this, messageChannelSuffix: '$cameraId');
  }

  /// Removes this handler from its platform channel.
  void dispose() {
    CameraEventApi.setUp(null, messageChannelSuffix: '$cameraId');
  }

  /// The ID of the camera for which this handler listens for events.
  final int cameraId;

  /// The controller which broadcasts camera events from the host platform.
  final StreamController<CameraEvent> cameraEventStreamController;
  @override
  void error(String message) {
    cameraEventStreamController.add(CameraErrorEvent(cameraId, message));
  }

  @override
  void initialized(PlatformCameraState initialState) {
    cameraEventStreamController.add(CameraInitializedEvent(
        cameraId,
        initialState.previewSize.width,
        initialState.previewSize.height,
        exposureModeFromPlatform(initialState.exposureMode),
        initialState.exposurePointSupported,
        focusModeFromPlatform(initialState.focusMode),
        initialState.focusPointSupported));
  }

  @override
  void closed() {
    cameraEventStreamController.add(CameraClosingEvent(cameraId));
  }
}
