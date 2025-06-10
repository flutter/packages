import 'dart:async';
import 'dart:math';

import 'package:camera_linux/src/messages.g.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
      PlatformResolutionPreset pigeonResolutionPreset =
          PlatformResolutionPreset.veryHigh;

      if (resolutionPreset != null) {
        switch (resolutionPreset) {
          case ResolutionPreset.low:
            pigeonResolutionPreset = PlatformResolutionPreset.low;
            break;
          case ResolutionPreset.medium:
            pigeonResolutionPreset = PlatformResolutionPreset.medium;
            break;
          case ResolutionPreset.high:
            pigeonResolutionPreset = PlatformResolutionPreset.high;
            break;
          case ResolutionPreset.veryHigh:
            pigeonResolutionPreset = PlatformResolutionPreset.veryHigh;
            break;
          case ResolutionPreset.ultraHigh:
            pigeonResolutionPreset = PlatformResolutionPreset.ultraHigh;
            break;
          case ResolutionPreset.max:
            pigeonResolutionPreset = PlatformResolutionPreset.max;
        }
      }
      final cameraId =
          await _hostApi.create(cameraDescription.name, pigeonResolutionPreset);
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

    PlatformImageFormatGroup imageFormat = PlatformImageFormatGroup.rgb8;
    switch (imageFormatGroup) {
      case ImageFormatGroup.jpeg:
        imageFormat = PlatformImageFormatGroup.rgb8;
        break;
      case ImageFormatGroup.unknown:
      case ImageFormatGroup.yuv420:
      case ImageFormatGroup.nv21:
      case ImageFormatGroup.bgra8888:
      default:
        imageFormat = PlatformImageFormatGroup.mono8;
        break;
    }

    try {
      await _hostApi.initialize(cameraId, imageFormat);
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
  Future<XFile> takePicture(int cameraId) async {
    try {
      final directory = await getTemporaryDirectory();
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();
      final path = '${directory.path}/$uuid.jpg';
      await _hostApi.takePicture(cameraId, path);
      return XFile(path);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> prepareForVideoRecording() async {
// No-op for Linux no preparation is needed.
  }

  @override
  Future<void> startVideoRecording(
    int cameraId, {
    @Deprecated(
        'This parameter is unused, and will be ignored on all platforms')
    Duration? maxVideoDuration,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();
      final path = '${directory.path}/$uuid.mp4';
      await _hostApi.startVideoRecording(cameraId, path);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
    // No-op for Linux, as video recording is not supported.
    return Future<void>.value();
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    try {
      final path = await _hostApi.stopVideoRecording(cameraId);
      return XFile(path);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
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
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    // No-op for Linux, as flash mode is not supported.
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {
    try {
      await _hostApi.setExposureMode(cameraId, exposureModeToPlatform(mode));
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {
    // No-op for Linux, as exposure point is not supported.
  }

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
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {
    try {
      await _hostApi.setFocusMode(cameraId, focusModeToPlatform(mode));
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {
    // No-op for Linux, as focus point is not supported.
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    return 0.0;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    return 0.0;
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    // No-op for Linux, as zoom is not supported.
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    throw UnimplementedError('pausePreview() is not implemented.');
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    throw UnimplementedError('resumePreview() is not implemented.');
  }

  @override
  Future<void> setDescriptionWhileRecording(
      CameraDescription description) async {
    throw UnimplementedError(
        'setDescriptionWhileRecording() is not implemented.');
  }

  @override
  Widget buildPreview(int cameraId) {
    unawaited(
      _hostApi.getTextureId(cameraId).then(
        (int? textureId) {
          cameraEventStreamController.add(TextureIdEvent(cameraId, textureId));
        },
      ),
    );
    return StreamBuilder<int?>(
      stream: _cameraEvents(cameraId)
          .whereType<TextureIdEvent>()
          .map((event) => event.textureId),
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data == -1) {
          return const Center(child: CircularProgressIndicator());
        }

        return RepaintBoundary(
          child: Texture(
            textureId: snapshot.data!,
            filterQuality: FilterQuality.none,
          ),
        );
      },
    );
  }

  @override
  Future<void> dispose(int cameraId) async {
    // Remove the handler for this camera.
    final HostCameraMessageHandler? handler =
        hostCameraHandlers.remove(cameraId);
    handler?.dispose();

    try {
      await _hostApi.dispose(cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// The following methods are not implemented for Linux, as only jpeg is supported
  @override
  Future<void> setImageFileFormat(int cameraId, ImageFileFormat format) async {}

  Future<void> setImageFormatGroup(
      int cameraId, PlatformImageFormatGroup format) async {
    try {
      await _hostApi.setImageFormatGroup(cameraId, format);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }
}

/// An event fired when the camera texture id changed.
class TextureIdEvent extends CameraEvent {
  const TextureIdEvent(
    super.cameraId,
    this.textureId,
  );

  TextureIdEvent.fromJson(Map<String, dynamic> json)
      : textureId = json['textureId']! as int?,
        super(json['cameraId']! as int);

  /// The texture ID of the camera.
  final int? textureId;

  Map<String, dynamic> toJson() => <String, Object>{
        'cameraId': cameraId,
        if (textureId != null) 'textureId': textureId!,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TextureIdEvent &&
          runtimeType == other.runtimeType &&
          textureId == other.textureId;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        textureId,
      );
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

  @override
  void textureId(int textureId) {
    streamController.add(TextureIdEvent(cameraId, textureId));
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

PlatformFocusMode focusModeToPlatform(FocusMode mode) {
  return switch (mode) {
    FocusMode.auto => PlatformFocusMode.auto,
    FocusMode.locked => PlatformFocusMode.locked,
  };
}

PlatformExposureMode exposureModeToPlatform(ExposureMode mode) {
  return switch (mode) {
    ExposureMode.auto => PlatformExposureMode.auto,
    ExposureMode.locked => PlatformExposureMode.locked,
  };
}
