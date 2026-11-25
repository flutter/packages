// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'src/messages.g.dart';

/// FourCC value for `V4L2_PIX_FMT_ABGR32` (`'A','R','2','4'`), which lays out
/// 32-bit pixels in BGRA byte order.
const int _v4l2PixFmtAbgr32 = 0x34325241;

/// An implementation of [CameraPlatform] for Linux using Video4Linux2 (V4L2).
class CameraLinuxV4l2 extends CameraPlatform {
  /// Creates a new Linux [CameraPlatform] implementation instance.
  CameraLinuxV4l2({@visibleForTesting CameraApi? api}) : _hostApi = api ?? CameraApi();

  /// Registers the Linux implementation of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = CameraLinuxV4l2();
  }

  final CameraApi _hostApi;
  final Set<int> _initializedCameras = <int>{};

  /// Per-camera handlers for native-to-Dart Pigeon callbacks.
  @visibleForTesting
  final Map<int, HostCameraMessageHandler> hostCameraHandlers = <int, HostCameraMessageHandler>{};

  /// Broadcast controller for per-camera lifecycle and error [CameraEvent]s.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream.where((CameraEvent event) => event.cameraId == cameraId);

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final List<String> cameras = await _hostApi.getAvailableCameras();
      return cameras
          .map(
            (String devicePath) => CameraDescription(
              name: devicePath,
              // V4L2 does not report physical mounting direction; external is
              // the standard default for desktop webcams.
              lensDirection: CameraLensDirection.external,
              sensorOrientation: 0,
            ),
          )
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
  }) => createCameraWithSettings(
    cameraDescription,
    MediaSettings(resolutionPreset: resolutionPreset, enableAudio: enableAudio),
  );

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings? mediaSettings,
  ) async {
    try {
      return await _hostApi.create(
        cameraDescription.name,
        _pigeonResolutionPreset(mediaSettings?.resolutionPreset),
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    final bool inserted = !hostCameraHandlers.containsKey(cameraId);
    hostCameraHandlers.putIfAbsent(
      cameraId,
      () => HostCameraMessageHandler(cameraId, cameraEventStreamController),
    );

    final PlatformSize reply;
    try {
      reply = await _hostApi.initialize(cameraId);
    } on PlatformException catch (e) {
      if (inserted) {
        hostCameraHandlers.remove(cameraId)?.dispose();
      }
      throw CameraException(e.code, e.message);
    }

    _initializedCameras.add(cameraId);
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
    _initializedCameras.remove(cameraId);
    hostCameraHandlers[cameraId]?.closeImageStream();
    try {
      await _hostApi.dispose(cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    } finally {
      // Keep the Pigeon event handler alive until host dispose finishes so
      // CameraClosingEvent is delivered before the channel is torn down.
      hostCameraHandlers.remove(cameraId)?.dispose();
    }
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      _cameraEvents(cameraId).whereType<CameraInitializedEvent>();

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) =>
      // Resolution is fixed for the lifetime of a capture session.
      const Stream<CameraResolutionChangedEvent>.empty();

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) =>
      _cameraEvents(cameraId).whereType<CameraClosingEvent>();

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) =>
      _cameraEvents(cameraId).whereType<CameraErrorEvent>();

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      // Desktops do not rotate; report landscape so CameraPreview does not apply
      // a 90-degree mobile portrait assumption.
      Stream<DeviceOrientationChangedEvent>.value(
        const DeviceOrientationChangedEvent(DeviceOrientation.landscapeRight),
      );

  @override
  bool supportsImageStreaming() => true;

  @override
  Stream<CameraImageData> onStreamedFrameAvailable(
    int cameraId, {
    CameraImageStreamOptions? options,
  }) {
    final HostCameraMessageHandler? handler = hostCameraHandlers[cameraId];
    if (handler == null || !_initializedCameras.contains(cameraId)) {
      throw CameraException(
        'camera_not_initialized',
        'Camera with id $cameraId is not initialized.',
      );
    }
    return handler.createImageStream(
      onListen: () => _startImageStream(cameraId, handler),
      onCancel: () => _stopImageStream(cameraId),
    );
  }

  Future<void> _startImageStream(int cameraId, HostCameraMessageHandler handler) async {
    try {
      await _hostApi.startImageStream(cameraId);
    } on PlatformException catch (e) {
      handler.addImageStreamError(CameraException(e.code, e.message));
    }
  }

  Future<void> _stopImageStream(int cameraId) async {
    try {
      await _hostApi.stopImageStream(cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async => 0.0;

  @override
  Future<double> getMaxExposureOffset(int cameraId) async => 0.0;

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async => 1.0;

  @override
  Future<double> getMinZoomLevel(int cameraId) async => 1.0;

  @override
  Future<double> getMaxZoomLevel(int cameraId) async => 1.0;

  @override
  Widget buildPreview(int cameraId) => Texture(textureId: cameraId);

  static PlatformResolutionPreset _pigeonResolutionPreset(ResolutionPreset? resolutionPreset) {
    if (resolutionPreset == null) {
      return PlatformResolutionPreset.medium;
    }
    switch (resolutionPreset) {
      case ResolutionPreset.low:
        return PlatformResolutionPreset.low;
      case ResolutionPreset.medium:
        return PlatformResolutionPreset.medium;
      case ResolutionPreset.high:
        return PlatformResolutionPreset.high;
      case ResolutionPreset.veryHigh:
        return PlatformResolutionPreset.veryHigh;
      case ResolutionPreset.ultraHigh:
        return PlatformResolutionPreset.ultraHigh;
      case ResolutionPreset.max:
        return PlatformResolutionPreset.max;
    }
    // The enum comes from a different package, so provide a fallback outside
    // the switch rather than `default` so new values still trigger lints.
    // ignore: dead_code
    return PlatformResolutionPreset.medium;
  }
}

/// Callback handler for camera-level events from the Linux host plugin.
@visibleForTesting
class HostCameraMessageHandler implements CameraEventApi {
  /// Creates a handler listening for native events for [cameraId] and
  /// forwarding lifecycle/error events to [streamController].
  HostCameraMessageHandler(this.cameraId, this.streamController) {
    CameraEventApi.setUp(this, messageChannelSuffix: cameraId.toString());
  }

  /// Camera/texture identifier associated with this handler.
  final int cameraId;

  /// Broadcast controller receiving [CameraClosingEvent] and [CameraErrorEvent].
  final StreamController<CameraEvent> streamController;

  StreamController<CameraImageData>? _imageStreamController;

  /// Creates the [CameraImageData] stream for
  /// [CameraPlatform.onStreamedFrameAvailable], replacing any earlier one.
  ///
  /// [onCancel] is only called when the returned stream is still the current
  /// one at the time its subscription is cancelled.
  Stream<CameraImageData> createImageStream({
    required FutureOr<void> Function() onListen,
    required FutureOr<void> Function() onCancel,
  }) {
    closeImageStream();
    late final StreamController<CameraImageData> controller;
    controller = StreamController<CameraImageData>(
      onListen: onListen,
      onPause: _onImageStreamPauseResume,
      onResume: _onImageStreamPauseResume,
      onCancel: () async {
        // A stream that was replaced by a newer one, or closed because the
        // camera was disposed, must not stop the native stream.
        if (identical(_imageStreamController, controller)) {
          _imageStreamController = null;
          await onCancel();
        }
      },
    );
    _imageStreamController = controller;
    return controller.stream;
  }

  /// Forwards an asynchronous start error onto the active image stream.
  void addImageStreamError(Object error) {
    final StreamController<CameraImageData>? controller = _imageStreamController;
    if (controller != null && !controller.isClosed) {
      controller.addError(error);
    }
  }

  /// Closes any active image stream controller without unregistering events.
  void closeImageStream() {
    final StreamController<CameraImageData>? controller = _imageStreamController;
    _imageStreamController = null;
    if (controller != null && !controller.isClosed) {
      unawaited(controller.close());
    }
  }

  void _onImageStreamPauseResume() {
    throw CameraException(
      'InvalidCall',
      'Pause and resume are not supported for onStreamedFrameAvailable',
    );
  }

  /// Detaches Pigeon handlers and closes any open image stream.
  void dispose() {
    CameraEventApi.setUp(null, messageChannelSuffix: cameraId.toString());
    closeImageStream();
  }

  @override
  void onFrameAvailable(int width, int height, int bytesPerRow, Uint8List bytes) {
    final StreamController<CameraImageData>? controller = _imageStreamController;
    if (controller == null || controller.isClosed || !controller.hasListener) {
      return;
    }
    controller.add(
      CameraImageData(
        format: const CameraImageFormat(ImageFormatGroup.bgra8888, raw: _v4l2PixFmtAbgr32),
        planes: <CameraImagePlane>[
          CameraImagePlane(
            bytes: bytes,
            bytesPerRow: bytesPerRow,
            bytesPerPixel: 4,
            width: width,
            height: height,
          ),
        ],
        width: width,
        height: height,
      ),
    );
  }

  @override
  void cameraClosing() {
    streamController.add(CameraClosingEvent(cameraId));
  }

  @override
  void error(String errorMessage) {
    streamController.add(CameraErrorEvent(cameraId, errorMessage));
  }
}
