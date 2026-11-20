// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'src/v4l2_camera.dart';

export 'src/v4l2_camera.dart' show V4l2Device;

/// Opens a capture session; see [V4l2Camera.open].
@visibleForTesting
typedef CaptureSessionOpener = CaptureSession Function(String devicePath, int width, int height);

/// Lists capture devices; see [V4l2Camera.availableDevices].
@visibleForTesting
typedef DeviceLister = List<V4l2Device> Function();

/// An implementation of [CameraPlatform] for Linux, on top of V4L2.
///
/// Frames are captured by a small native library that `hook/build.dart`
/// compiles at build time, and reach Dart as JPEG. There is no texture-based
/// preview: [buildPreview] shows the frames as they arrive, which is adequate
/// for viewfinders and scanners at webcam frame rates. Video recording,
/// flash, zoom, focus and exposure control are not supported.
class CameraLinux extends CameraPlatform {
  /// Creates a new Linux [CameraPlatform] implementation instance.
  CameraLinux({
    @visibleForTesting DeviceLister? listDevices,
    @visibleForTesting CaptureSessionOpener? openSession,
    @visibleForTesting Directory? pictureDirectory,
  }) : _listDevices = listDevices ?? V4l2Camera.availableDevices,
       _openSession = openSession ?? _openV4l2,
       _pictureDirectory = pictureDirectory;

  /// Registers the Linux implementation of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = CameraLinux();
  }

  static CaptureSession _openV4l2(String devicePath, int width, int height) =>
      V4l2Camera.open(devicePath: devicePath, width: width, height: height);

  /// How often frames are polled from the capture session while anyone is
  /// listening. Webcams rarely exceed 30 frames per second.
  static const Duration _pollInterval = Duration(milliseconds: 33);

  /// How long [takePicture] waits for a frame.
  static const Duration _captureTimeout = Duration(seconds: 5);

  final DeviceLister _listDevices;
  final CaptureSessionOpener _openSession;
  final Directory? _pictureDirectory;

  final Map<int, _Camera> _cameras = <int, _Camera>{};
  int _nextCameraId = 1;

  /// The controller that broadcasts camera events to the per-camera streams.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream.where((CameraEvent event) => event.cameraId == cameraId);

  _Camera _camera(int cameraId) {
    final _Camera? camera = _cameras[cameraId];
    if (camera == null) {
      throw CameraException('camera_not_found', 'Camera with id $cameraId was not created.');
    }
    return camera;
  }

  _Camera _openCamera(int cameraId) {
    final _Camera camera = _camera(cameraId);
    if (camera.session == null) {
      throw CameraException(
        'camera_not_initialized',
        'Camera with id $cameraId is not initialized.',
      );
    }
    return camera;
  }

  @override
  Future<List<CameraDescription>> availableCameras() async {
    return <CameraDescription>[
      for (final V4l2Device device in _listDevices())
        CameraDescription(
          name: device.path,
          // V4L2 does not say where a camera points; webcams are external
          // devices more often than not.
          lensDirection: CameraLensDirection.external,
          sensorOrientation: 0,
        ),
    ];
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
    final int cameraId = _nextCameraId++;
    _cameras[cameraId] = _Camera(
      cameraId,
      cameraDescription.name,
      _requestedSize(mediaSettings?.resolutionPreset),
    );
    return cameraId;
  }

  /// Translates a preset into the size requested from the driver, which picks
  /// the nearest size it supports.
  static Size _requestedSize(ResolutionPreset? preset) {
    switch (preset) {
      case ResolutionPreset.low:
        return const Size(320, 240);
      case ResolutionPreset.medium:
      case null:
        return const Size(640, 480);
      case ResolutionPreset.high:
        return const Size(1280, 720);
      case ResolutionPreset.veryHigh:
        return const Size(1920, 1080);
      case ResolutionPreset.ultraHigh:
        return const Size(3840, 2160);
      case ResolutionPreset.max:
        // Drivers clamp an oversized request to the largest frame size.
        return const Size(16384, 16384);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    final _Camera camera = _camera(cameraId);
    if (camera.session != null) {
      return;
    }
    // Throws a CameraException with the driver's reason on failure.
    final CaptureSession session = _openSession(
      camera.devicePath,
      camera.requestedSize.width.round(),
      camera.requestedSize.height.round(),
    );
    camera.attach(session, _pollInterval, (CameraException error) {
      cameraEventStreamController.add(CameraErrorEvent(cameraId, error.description ?? error.code));
    });
    cameraEventStreamController.add(
      CameraInitializedEvent(
        cameraId,
        session.width.toDouble(),
        session.height.toDouble(),
        ExposureMode.auto,
        false,
        FocusMode.auto,
        false,
      ),
    );
  }

  @override
  Future<void> dispose(int cameraId) async {
    final _Camera? camera = _cameras.remove(cameraId);
    if (camera == null) {
      return;
    }
    if (camera.session != null) {
      cameraEventStreamController.add(CameraClosingEvent(cameraId));
    }
    await camera.close();
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    // The frame size is fixed for the life of a session.
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
    return const Stream<VideoRecordedEvent>.empty();
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    // Desktops do not rotate. The app-facing package assumes portraitUp by
    // default, which would rotate the preview, so report landscape as the
    // Windows implementation does.
    return Stream<DeviceOrientationChangedEvent>.value(
      const DeviceOrientationChangedEvent(DeviceOrientation.landscapeRight),
    );
  }

  @override
  Future<void> lockCaptureOrientation(int cameraId, DeviceOrientation orientation) async {
    throw UnsupportedError('lockCaptureOrientation() is not supported on Linux.');
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    throw UnsupportedError('unlockCaptureOrientation() is not supported on Linux.');
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final _Camera camera = _openCamera(cameraId);
    final Uint8List jpeg;
    try {
      jpeg = await camera.frames.first.timeout(_captureTimeout);
    } on TimeoutException {
      throw CameraException('capture_error', 'No frame arrived within $_captureTimeout.');
    } on StateError {
      throw CameraException('capture_error', 'The camera was disposed.');
    }
    final Directory directory = _pictureDirectory ?? Directory.systemTemp;
    final path =
        '${directory.path}${Platform.pathSeparator}'
        'camera_linux_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(jpeg, flush: true);
    return XFile(path, mimeType: 'image/jpeg');
  }

  @override
  Future<void> prepareForVideoRecording() async {
    // No-op.
  }

  @override
  Future<void> startVideoRecording(
    int cameraId, {
    Duration? maxVideoDuration,
    String? videoOutputPath,
  }) async {
    throw UnsupportedError('Video recording is not supported on Linux.');
  }

  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) async {
    throw UnsupportedError('Video recording is not supported on Linux.');
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    throw UnsupportedError('Video recording is not supported on Linux.');
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) async {
    throw UnsupportedError('Video recording is not supported on Linux.');
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    throw UnsupportedError('Video recording is not supported on Linux.');
  }

  @override
  bool supportsImageStreaming() => true;

  @override
  Stream<CameraImageData> onStreamedFrameAvailable(
    int cameraId, {
    CameraImageStreamOptions? options,
  }) {
    final _Camera camera = _openCamera(cameraId);
    final CaptureSession session = camera.session!;
    return camera.frames.map(
      (Uint8List jpeg) => CameraImageData(
        format: const CameraImageFormat(ImageFormatGroup.jpeg, raw: 'JPEG'),
        planes: <CameraImagePlane>[CameraImagePlane(bytes: jpeg, bytesPerRow: 0)],
        width: session.width,
        height: session.height,
      ),
    );
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    throw UnsupportedError('setFlashMode() is not supported on Linux.');
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {
    throw UnsupportedError('setExposureMode() is not supported on Linux.');
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {
    throw UnsupportedError('setExposurePoint() is not supported on Linux.');
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async => 0.0;

  @override
  Future<double> getMaxExposureOffset(int cameraId) async => 0.0;

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async => 1.0;

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    throw UnsupportedError('setExposureOffset() is not supported on Linux.');
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {
    throw UnsupportedError('setFocusMode() is not supported on Linux.');
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {
    throw UnsupportedError('setFocusPoint() is not supported on Linux.');
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async => 1.0;

  @override
  Future<double> getMaxZoomLevel(int cameraId) async => 1.0;

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    throw UnsupportedError('setZoomLevel() is not supported on Linux.');
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    _openCamera(cameraId).previewPaused.value = true;
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    _openCamera(cameraId).previewPaused.value = false;
  }

  @override
  Widget buildPreview(int cameraId) {
    final _Camera camera = _openCamera(cameraId);
    return _FramePreview(frames: camera.frames, paused: camera.previewPaused);
  }
}

/// A created camera and, once initialized, its capture session and frame
/// pump.
class _Camera {
  _Camera(this.cameraId, this.devicePath, this.requestedSize);

  final int cameraId;
  final String devicePath;
  final Size requestedSize;
  final ValueNotifier<bool> previewPaused = ValueNotifier<bool>(false);

  CaptureSession? session;
  Timer? _timer;
  late final StreamController<Uint8List> _frameController = StreamController<Uint8List>.broadcast(
    onListen: _startPolling,
    onCancel: _stopPolling,
  );
  Duration _pollInterval = Duration.zero;
  void Function(CameraException error)? _onError;

  /// Every frame the camera delivers while someone listens. Preview, image
  /// streams and [CameraLinux.takePicture] all share this stream, so they do
  /// not take frames away from each other.
  Stream<Uint8List> get frames => _frameController.stream;

  void attach(
    CaptureSession session,
    Duration pollInterval,
    void Function(CameraException) onError,
  ) {
    this.session = session;
    _pollInterval = pollInterval;
    _onError = onError;
  }

  void _startPolling() {
    _timer ??= Timer.periodic(_pollInterval, (_) => _poll());
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  void _poll() {
    final CaptureSession? session = this.session;
    if (session == null) {
      return;
    }
    final Uint8List? jpeg;
    try {
      jpeg = session.readJpeg();
    } on CameraException catch (e) {
      _stopPolling();
      _frameController.addError(e);
      _onError?.call(e);
      return;
    }
    if (jpeg != null) {
      _frameController.add(jpeg);
    }
  }

  Future<void> close() async {
    _stopPolling();
    session?.close();
    session = null;
    previewPaused.dispose();
    await _frameController.close();
  }
}

/// Shows the newest frame of a camera.
class _FramePreview extends StatefulWidget {
  const _FramePreview({required this.frames, required this.paused});

  final Stream<Uint8List> frames;
  final ValueListenable<bool> paused;

  @override
  State<_FramePreview> createState() => _FramePreviewState();
}

class _FramePreviewState extends State<_FramePreview> {
  StreamSubscription<Uint8List>? _subscription;
  Uint8List? _frame;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(_FramePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frames != widget.frames) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.frames.listen((Uint8List jpeg) {
      if (!widget.paused.value && mounted) {
        setState(() => _frame = jpeg);
      }
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? frame = _frame;
    if (frame == null) {
      return const ColoredBox(color: Color(0xFF000000));
    }
    return Image.memory(
      frame,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      // A frame the decoder rejects should not take the preview down.
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
          const ColoredBox(color: Color(0xFF000000)),
    );
  }
}
