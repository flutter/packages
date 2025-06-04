import 'dart:async';
import 'dart:math';

import 'package:camera_linux/src/messages.g.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_transform/stream_transform.dart';

class CameraLinux extends CameraPlatform {
  final CameraApi _hostApi;

  CameraLinux({@visibleForTesting CameraApi? api})
      : _hostApi = api ?? CameraApi();

  static void registerWith() {
    CameraPlatform.instance = CameraLinux();
  }

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

  /// The per-camera handlers for messages that should be rebroadcast to
  /// clients as [CameraEvent]s.
  @visibleForTesting
  final Map<int, HostCameraMessageHandler> hostCameraHandlers =
      <int, HostCameraMessageHandler>{};

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final camerasNames = await _hostApi.getAvailableCamerasNames();
      return camerasNames.map(
        (name) {
          return CameraDescription(
            name: name,
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          );
        },
      ).toList();
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// resolutionPreset is not used on Linux.
  /// enableAudio is not used on Linux.
  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    try {
      final cameraId = await _hostApi.create(cameraDescription.name);
      return cameraId;
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

    unawaited(
      onCameraInitialized(cameraId).first.then(
            (CameraInitializedEvent value) => completer.complete(),
          ),
    );

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
    return const Stream.empty();
  }

  /// The following methods are not implemented for Linux, as they are not
  /// supported by the underlying camera API.
  @override
  Future<void> lockCaptureOrientation(
      int cameraId, DeviceOrientation orientation) {
    return Future<void>.value();
  }

  /// The following methods are not implemented for Linux, as they are not
  /// supported by the underlying camera API.
  @override
  Future<void> unlockCaptureOrientation(int cameraId) {
    return Future<void>.value();
  }

  @override
  Future<XFile> takePicture(int cameraId) {
    throw UnimplementedError('takePicture() is not implemented.');
  }

  @override
  Future<void> prepareForVideoRecording() {
    throw UnimplementedError('prepareForVideoRecording() is not implemented.');
  }

  @override
  Future<void> startVideoRecording(
    int cameraId, {
    @Deprecated(
        'This parameter is unused, and will be ignored on all platforms')
    Duration? maxVideoDuration,
  }) {
    throw UnimplementedError('startVideoRecording() is not implemented.');
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) {
    throw UnimplementedError('stopVideoRecording() is not implemented.');
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) {
    throw UnimplementedError('pauseVideoRecording() is not implemented.');
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) {
    throw UnimplementedError('resumeVideoRecording() is not implemented.');
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {}

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {}

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {}

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    return 0.0;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    return 0.0;
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    return 0.0;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    return 0.0;
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {}

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {}

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    return 1.0;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    return 0.0;
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {}

  @override
  Future<void> pausePreview(int cameraId) async {}

  @override
  Future<void> resumePreview(int cameraId) async {}

  @override
  Future<void> setDescriptionWhileRecording(
      CameraDescription description) async {}

  @override
  Widget buildPreview(int cameraId) {
    return FutureBuilder<int?>(
      future: _hostApi.getTextureId(cameraId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          print('Texture ID from dart: ${snapshot.data}');
          return RepaintBoundary(
            child: Texture(
              textureId: snapshot.data!,
              filterQuality: FilterQuality.none,
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Future<void> dispose(int cameraId) async {}

  @override
  Future<void> setImageFileFormat(int cameraId, ImageFileFormat format) async {}

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
    streamController.add(
      CameraInitializedEvent(
        cameraId,
        initialState.previewSize.width,
        initialState.previewSize.height,
        exposureModeFromPlatform(initialState.exposureMode),
        initialState.exposurePointSupported,
        focusModeFromPlatform(initialState.focusMode),
        initialState.focusPointSupported,
      ),
    );
  }
}

/// Converts a Pigeon [PlatformExposureMode] to an [ExposureMode].
ExposureMode exposureModeFromPlatform(PlatformExposureMode mode) {
  return switch (mode) {
    PlatformExposureMode.auto => ExposureMode.auto,
    PlatformExposureMode.locked => ExposureMode.locked,
  };
}

/// Converts a Pigeon [PlatformFocusMode] to an [FocusMode].
FocusMode focusModeFromPlatform(PlatformFocusMode mode) {
  return switch (mode) {
    PlatformFocusMode.auto => FocusMode.auto,
    PlatformFocusMode.locked => FocusMode.locked,
  };
}
