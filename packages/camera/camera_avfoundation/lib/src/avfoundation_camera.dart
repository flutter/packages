// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'messages.g.dart';
import 'type_conversion.dart';
import 'utils.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/camera_avfoundation');

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
          // See comment in messages.dart for why this is safe.
          .map((PlatformCameraDescription? c) => c!)
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
      final Map<String, dynamic>? reply = await _channel
          .invokeMapMethod<String, dynamic>('create', <String, dynamic>{
        'cameraName': cameraDescription.name,
        'resolutionPreset': null != mediaSettings?.resolutionPreset
            ? _serializeResolutionPreset(mediaSettings!.resolutionPreset!)
            : null,
        'fps': mediaSettings?.fps,
        'videoBitrate': mediaSettings?.videoBitrate,
        'audioBitrate': mediaSettings?.audioBitrate,
        'enableAudio': mediaSettings?.enableAudio ?? true,
      });

      return reply!['cameraId']! as int;
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) {
    hostCameraHandlers.putIfAbsent(cameraId,
        () => HostCameraMessageHandler(cameraId, cameraEventStreamController));

    final Completer<void> completer = Completer<void>();

    onCameraInitialized(cameraId).first.then((CameraInitializedEvent value) {
      completer.complete();
    });

    _channel.invokeMapMethod<String, dynamic>(
      'initialize',
      <String, dynamic>{
        'cameraId': cameraId,
        'imageFormatGroup': imageFormatGroup.name(),
      },
    ).catchError(
      // TODO(srawlins): This should return a value of the future's type. This
      // will fail upcoming analysis checks with
      // https://github.com/flutter/flutter/issues/105750.
      // ignore: body_might_complete_normally_catch_error
      (Object error, StackTrace stackTrace) {
        if (error is! PlatformException) {
          // ignore: only_throw_errors
          throw error;
        }
        completer.completeError(
          CameraException(error.code, error.message),
          stackTrace,
        );
      },
    );

    return completer.future;
  }

  @override
  Future<void> dispose(int cameraId) async {
    final HostCameraMessageHandler? handler =
        hostCameraHandlers.remove(cameraId);
    handler?.dispose();

    await _channel.invokeMethod<void>(
      'dispose',
      <String, dynamic>{'cameraId': cameraId},
    );
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
    await _channel.invokeMethod<String>(
      'lockCaptureOrientation',
      <String, dynamic>{
        'cameraId': cameraId,
        'orientation': serializeDeviceOrientation(orientation)
      },
    );
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    await _channel.invokeMethod<String>(
      'unlockCaptureOrientation',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final String? path = await _channel.invokeMethod<String>(
      'takePicture',
      <String, dynamic>{'cameraId': cameraId},
    );

    if (path == null) {
      throw CameraException(
        'INVALID_PATH',
        'The platform "$defaultTargetPlatform" did not return a path while reporting success. The platform should always return a valid path or report an error.',
      );
    }

    return XFile(path);
  }

  @override
  Future<void> prepareForVideoRecording() =>
      _channel.invokeMethod<void>('prepareForVideoRecording');

  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    return startVideoCapturing(
        VideoCaptureOptions(cameraId, maxDuration: maxVideoDuration));
  }

  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) async {
    await _channel.invokeMethod<void>(
      'startVideoRecording',
      <String, dynamic>{
        'cameraId': options.cameraId,
        'maxVideoDuration': options.maxDuration?.inMilliseconds,
        'enableStream': options.streamCallback != null,
      },
    );

    if (options.streamCallback != null) {
      _frameStreamController = _createStreamController();
      _frameStreamController!.stream.listen(options.streamCallback);
      _startStreamListener();
    }
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final String? path = await _channel.invokeMethod<String>(
      'stopVideoRecording',
      <String, dynamic>{'cameraId': cameraId},
    );

    if (path == null) {
      throw CameraException(
        'INVALID_PATH',
        'The platform "$defaultTargetPlatform" did not return a path while reporting success. The platform should always return a valid path or report an error.',
      );
    }

    return XFile(path);
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) => _channel.invokeMethod<void>(
        'pauseVideoRecording',
        <String, dynamic>{'cameraId': cameraId},
      );

  @override
  Future<void> resumeVideoRecording(int cameraId) =>
      _channel.invokeMethod<void>(
        'resumeVideoRecording',
        <String, dynamic>{'cameraId': cameraId},
      );

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
    await _channel.invokeMethod<void>('startImageStream');
    _startStreamListener();
  }

  void _startStreamListener() {
    const EventChannel cameraEventChannel =
        EventChannel('plugins.flutter.io/camera_avfoundation/imageStream');
    _platformImageStreamSubscription =
        cameraEventChannel.receiveBroadcastStream().listen((dynamic imageData) {
      try {
        _channel.invokeMethod<void>('receivedImageStreamData');
      } on PlatformException catch (e) {
        throw CameraException(e.code, e.message);
      }
      _frameStreamController!
          .add(cameraImageFromPlatformData(imageData as Map<dynamic, dynamic>));
    });
  }

  FutureOr<void> _onFrameStreamCancel() async {
    await _channel.invokeMethod<void>('stopImageStream');
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
      _channel.invokeMethod<void>(
        'setFlashMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': _serializeFlashMode(mode),
        },
      );

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) =>
      _channel.invokeMethod<void>(
        'setExposureMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': _serializeExposureMode(mode),
        },
      );

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _channel.invokeMethod<void>(
      'setExposurePoint',
      <String, dynamic>{
        'cameraId': cameraId,
        'reset': point == null,
        'x': point?.x,
        'y': point?.y,
      },
    );
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    final double? minExposureOffset = await _channel.invokeMethod<double>(
      'getMinExposureOffset',
      <String, dynamic>{'cameraId': cameraId},
    );

    return minExposureOffset!;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    final double? maxExposureOffset = await _channel.invokeMethod<double>(
      'getMaxExposureOffset',
      <String, dynamic>{'cameraId': cameraId},
    );

    return maxExposureOffset!;
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    final double? stepSize = await _channel.invokeMethod<double>(
      'getExposureOffsetStepSize',
      <String, dynamic>{'cameraId': cameraId},
    );

    return stepSize!;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    final double? appliedOffset = await _channel.invokeMethod<double>(
      'setExposureOffset',
      <String, dynamic>{
        'cameraId': cameraId,
        'offset': offset,
      },
    );

    return appliedOffset!;
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) =>
      _channel.invokeMethod<void>(
        'setFocusMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': _serializeFocusMode(mode),
        },
      );

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _channel.invokeMethod<void>(
      'setFocusPoint',
      <String, dynamic>{
        'cameraId': cameraId,
        'reset': point == null,
        'x': point?.x,
        'y': point?.y,
      },
    );
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    final double? maxZoomLevel = await _channel.invokeMethod<double>(
      'getMaxZoomLevel',
      <String, dynamic>{'cameraId': cameraId},
    );

    return maxZoomLevel!;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    final double? minZoomLevel = await _channel.invokeMethod<double>(
      'getMinZoomLevel',
      <String, dynamic>{'cameraId': cameraId},
    );

    return minZoomLevel!;
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    try {
      await _channel.invokeMethod<double>(
        'setZoomLevel',
        <String, dynamic>{
          'cameraId': cameraId,
          'zoom': zoom,
        },
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    await _channel.invokeMethod<double>(
      'pausePreview',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    await _channel.invokeMethod<double>(
      'resumePreview',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<void> setDescriptionWhileRecording(
      CameraDescription description) async {
    await _channel.invokeMethod<double>(
      'setDescriptionWhileRecording',
      <String, dynamic>{
        'cameraName': description.name,
      },
    );
  }

  @override
  Future<void> setImageFileFormat(int cameraId, ImageFileFormat format) {
    return _channel.invokeMethod<void>(
      'setImageFileFormat',
      <String, dynamic>{
        'cameraId': cameraId,
        'fileFormat': format.name,
      },
    );
  }

  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }

  String _serializeFocusMode(FocusMode mode) {
    switch (mode) {
      case FocusMode.locked:
        return 'locked';
      case FocusMode.auto:
        return 'auto';
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return 'auto';
  }

  String _serializeExposureMode(ExposureMode mode) {
    switch (mode) {
      case ExposureMode.locked:
        return 'locked';
      case ExposureMode.auto:
        return 'auto';
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return 'auto';
  }

  /// Returns the flash mode as a String.
  String _serializeFlashMode(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.off:
        return 'off';
      case FlashMode.auto:
        return 'auto';
      case FlashMode.always:
        return 'always';
      case FlashMode.torch:
        return 'torch';
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return 'off';
  }

  /// Returns the resolution preset as a String.
  String _serializeResolutionPreset(ResolutionPreset resolutionPreset) {
    switch (resolutionPreset) {
      case ResolutionPreset.max:
        return 'max';
      case ResolutionPreset.ultraHigh:
        return 'ultraHigh';
      case ResolutionPreset.veryHigh:
        return 'veryHigh';
      case ResolutionPreset.high:
        return 'high';
      case ResolutionPreset.medium:
        return 'medium';
      case ResolutionPreset.low:
        return 'low';
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return 'max';
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
