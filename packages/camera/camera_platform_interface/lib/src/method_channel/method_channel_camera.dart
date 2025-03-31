// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../camera_platform_interface.dart';
import '../utils/utils.dart';
import 'type_conversion.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/camera');

/// An implementation of [CameraPlatform] that uses method channels.
class MethodChannelCamera extends CameraPlatform {
  /// Construct a new method channel camera instance.
  MethodChannelCamera() {
    const MethodChannel channel =
        MethodChannel('flutter.io/cameraPlugin/device');
    channel.setMethodCallHandler(
        (MethodCall call) => handleDeviceMethodCall(call));
  }

  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

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

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to general device events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<DeviceEvent> deviceEventStreamController =
      StreamController<DeviceEvent>.broadcast();

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
      final List<Map<dynamic, dynamic>>? cameras = await _channel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');

      if (cameras == null) {
        return <CameraDescription>[];
      }

      return cameras.map((Map<dynamic, dynamic> camera) {
        return CameraDescription(
          name: camera['name']! as String,
          lensDirection:
              parseCameraLensDirection(camera['lensFacing']! as String),
          sensorOrientation: camera['sensorOrientation']! as int,
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
  }) async =>
      createCameraWithSettings(
          cameraDescription,
          MediaSettings(
              resolutionPreset: resolutionPreset, enableAudio: enableAudio));

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings mediaSettings,
  ) async {
    try {
      final ResolutionPreset? resolutionPreset = mediaSettings.resolutionPreset;
      final Map<String, dynamic>? reply = await _channel
          .invokeMapMethod<String, dynamic>('create', <String, dynamic>{
        'cameraName': cameraDescription.name,
        'resolutionPreset': resolutionPreset != null
            ? _serializeResolutionPreset(mediaSettings.resolutionPreset!)
            : null,
        'fps': mediaSettings.fps,
        'videoBitrate': mediaSettings.videoBitrate,
        'audioBitrate': mediaSettings.audioBitrate,
        'enableAudio': mediaSettings.enableAudio,
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
    _channels.putIfAbsent(cameraId, () {
      final MethodChannel channel =
          MethodChannel('flutter.io/cameraPlugin/camera$cameraId');
      channel.setMethodCallHandler(
          (MethodCall call) => handleCameraMethodCall(call, cameraId));
      return channel;
    });

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
    if (_channels.containsKey(cameraId)) {
      final MethodChannel? cameraChannel = _channels[cameraId];
      cameraChannel?.setMethodCallHandler(null);
      _channels.remove(cameraId);
    }

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
    return deviceEventStreamController.stream
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
      _installStreamController().stream.listen(options.streamCallback);
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
    await _channel.invokeMethod<void>('startImageStream');
    _startStreamListener();
  }

  void _startStreamListener() {
    const EventChannel cameraEventChannel =
        EventChannel('plugins.flutter.io/camera/imageStream');
    _platformImageStreamSubscription =
        cameraEventChannel.receiveBroadcastStream().listen((dynamic imageData) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          _channel.invokeMethod<void>('receivedImageStreamData');
        } on PlatformException catch (e) {
          throw CameraException(e.code, e.message);
        }
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
          'mode': serializeExposureMode(mode),
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
          'mode': serializeFocusMode(mode),
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
  }

  /// Converts messages received from the native platform into device events.
  ///
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  Future<dynamic> handleDeviceMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'orientation_changed':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        deviceEventStreamController.add(DeviceOrientationChangedEvent(
            deserializeDeviceOrientation(arguments['orientation']! as String)));
      default:
        throw MissingPluginException();
    }
  }

  /// Converts messages received from the native platform into camera events.
  ///
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  Future<dynamic> handleCameraMethodCall(MethodCall call, int cameraId) async {
    switch (call.method) {
      case 'initialized':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        cameraEventStreamController.add(CameraInitializedEvent(
          cameraId,
          arguments['previewWidth']! as double,
          arguments['previewHeight']! as double,
          deserializeExposureMode(arguments['exposureMode']! as String),
          arguments['exposurePointSupported']! as bool,
          deserializeFocusMode(arguments['focusMode']! as String),
          arguments['focusPointSupported']! as bool,
        ));
      case 'resolution_changed':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        cameraEventStreamController.add(CameraResolutionChangedEvent(
          cameraId,
          arguments['captureWidth']! as double,
          arguments['captureHeight']! as double,
        ));
      case 'camera_closing':
        cameraEventStreamController.add(CameraClosingEvent(
          cameraId,
        ));
      case 'video_recorded':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        cameraEventStreamController.add(VideoRecordedEvent(
          cameraId,
          XFile(arguments['path']! as String),
          arguments['maxVideoDuration'] != null
              ? Duration(milliseconds: arguments['maxVideoDuration']! as int)
              : null,
        ));
      case 'error':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        cameraEventStreamController.add(CameraErrorEvent(
          cameraId,
          arguments['description']! as String,
        ));
      default:
        throw MissingPluginException();
    }
  }

  /// Returns the arguments of [call] as typed string-keyed Map.
  ///
  /// This does not do any type validation, so is only safe to call if the
  /// arguments are known to be a map.
  Map<String, Object?> _getArgumentDictionary(MethodCall call) {
    return (call.arguments as Map<Object?, Object?>).cast<String, Object?>();
  }
}
