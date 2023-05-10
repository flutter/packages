// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'analyzer.dart';
import 'camera.dart';
import 'camera_info.dart';
import 'camera_selector.dart';
import 'camera_state.dart';
import 'camerax_library.g.dart';
import 'exposure_state.dart';
import 'image_analysis.dart';
import 'image_capture.dart';
import 'image_proxy.dart';
import 'live_data.dart';
import 'observer.dart';
import 'pending_recording.dart';
import 'plane_proxy.dart';
import 'preview.dart';
import 'process_camera_provider.dart';
import 'recorder.dart';
import 'recording.dart';
import 'surface.dart';
import 'system_services.dart';
import 'use_case.dart';
import 'video_capture.dart';
import 'zoom_state.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  /// Constructs an [AndroidCameraCameraX].
  AndroidCameraCameraX() : _shouldCreateDetachedObjectForTesting = false;

  /// Constructs an [AndroidCameraCameraX] that is able to set
  /// [_shouldCreateDetachedObjectForTesting] to create detached objects
  /// for testing purposes only.
  @visibleForTesting
  AndroidCameraCameraX.forTesting(
      {bool shouldCreateDetachedObjectForTesting = false})
      : _shouldCreateDetachedObjectForTesting =
            shouldCreateDetachedObjectForTesting;

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

  /// The [ProcessCameraProvider] instance used to access camera functionality.
  @visibleForTesting
  ProcessCameraProvider? processCameraProvider;

  /// The [Camera] instance returned by the [processCameraProvider] when a [UseCase] is
  /// bound to the lifecycle of the camera it manages.
  @visibleForTesting
  Camera? camera;

  /// The [CameraInfo] instance that corresponds to the [camera] instance.
  @visibleForTesting
  CameraInfo? cameraInfo;

  /// The [LiveData] of the [CameraState] that represents the state of the
  /// [camera] instance.
  LiveData<CameraState>? liveCameraState;

  /// The [Preview] instance that can be configured to present a live camera preview.
  @visibleForTesting
  Preview? preview;

  /// The [VideoCapture] instance that can be instantiated and configured to
  /// handle video recording
  @visibleForTesting
  VideoCapture? videoCapture;

  /// The [Recorder] instance handling the current creating a new [PendingRecording].
  @visibleForTesting
  Recorder? recorder;

  /// The [PendingRecording] instance used to create an active [Recording].
  @visibleForTesting
  PendingRecording? pendingRecording;

  /// The [Recording] instance representing the current recording.
  @visibleForTesting
  Recording? recording;

  /// The path at which the video file will be saved for the current [Recording].
  @visibleForTesting
  String? videoOutputPath;

  bool _previewIsPaused = false;

  /// The prefix used to create the filename for video recording files.
  @visibleForTesting
  final String videoPrefix = 'MOV';

  /// The [ImageCapture] instance that can be configured to capture a still image.
  @visibleForTesting
  ImageCapture? imageCapture;

  /// The [ImageAnalysis] instance that can be configured to analyze individual
  /// frames.
  ImageAnalysis? imageAnalysis;

  /// The [CameraSelector] used to configure the [processCameraProvider] to use
  /// the desired camera.
  @visibleForTesting
  CameraSelector? cameraSelector;

  /// The resolution preset used to create a camera that should be used for
  /// capturing still images and recording video.
  ResolutionPreset? _resolutionPreset;

  /// The controller we need to broadcast the different camera events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// The stream of camera events.
  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  /// Conditional used to create detached objects for testing their
  /// callback methods.
  final bool _shouldCreateDetachedObjectForTesting;

  /// The controller we need to stream image data.
  @visibleForTesting
  StreamController<CameraImageData>? cameraImageDataStreamController;

  /// Constant representing the multi-plane Android YUV 420 image format.
  ///
  /// See https://developer.android.com/reference/android/graphics/ImageFormat#YUV_420_888.
  static const int imageFormatYuv420_888 = 35;

  /// Constant representing the compressed JPEG image format.
  ///
  /// See https://developer.android.com/reference/android/graphics/ImageFormat#JPEG.
  static const int imageFormatJpeg = 256;

  /// Error code indicating a [ZoomState] was requested, but one has not been
  /// set for the camera in use.
  static const String zoomStateNotSetErrorCode = 'zoomStateNotSet';

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> cameraDescriptions = <CameraDescription>[];

    processCameraProvider ??= await ProcessCameraProvider.getInstance();
    final List<CameraInfo> cameraInfos =
        await processCameraProvider!.getAvailableCameraInfos();

    CameraLensDirection? cameraLensDirection;
    int cameraCount = 0;
    int? cameraSensorOrientation;
    String? cameraName;

    for (final CameraInfo cameraInfo in cameraInfos) {
      // Determine the lens direction by filtering the CameraInfo
      // TODO(gmackall): replace this with call to CameraInfo.getLensFacing when changes containing that method are available
      if ((await createCameraSelector(CameraSelector.lensFacingBack)
              .filter(<CameraInfo>[cameraInfo]))
          .isNotEmpty) {
        cameraLensDirection = CameraLensDirection.back;
      } else if ((await createCameraSelector(CameraSelector.lensFacingFront)
              .filter(<CameraInfo>[cameraInfo]))
          .isNotEmpty) {
        cameraLensDirection = CameraLensDirection.front;
      } else {
        //Skip this CameraInfo as its lens direction is unknown
        continue;
      }

      cameraSensorOrientation = await cameraInfo.getSensorRotationDegrees();
      cameraName = 'Camera $cameraCount';
      cameraCount++;

      cameraDescriptions.add(CameraDescription(
          name: cameraName,
          lensDirection: cameraLensDirection,
          sensorOrientation: cameraSensorOrientation));
    }

    return cameraDescriptions;
  }

  /// Creates an uninitialized camera instance and returns the camera ID.
  ///
  /// In the CameraX library, cameras are accessed by combining [UseCase]s
  /// to an instance of a [ProcessCameraProvider]. Thus, to create an
  /// uninitialized camera instance, this method retrieves a
  /// [ProcessCameraProvider] instance.
  ///
  /// To return the camera ID, which is equivalent to the ID of the surface texture
  /// that a camera preview can be drawn to, a [Preview] instance is configured
  /// and bound to the [ProcessCameraProvider] instance.
  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    // Must obtain proper permissions before attempting to access a camera.
    await requestCameraPermissions(enableAudio);

    // Save CameraSelector that matches cameraDescription.
    final int cameraSelectorLensDirection =
        _getCameraSelectorLensDirection(cameraDescription.lensDirection);
    final bool cameraIsFrontFacing =
        cameraSelectorLensDirection == CameraSelector.lensFacingFront;
    cameraSelector = createCameraSelector(cameraSelectorLensDirection);
    // Start listening for device orientation changes preceding camera creation.
    startListeningForDeviceOrientationChange(
        cameraIsFrontFacing, cameraDescription.sensorOrientation);

    // Retrieve a fresh ProcessCameraProvider instance.
    processCameraProvider ??= await ProcessCameraProvider.getInstance();
    processCameraProvider!.unbindAll();

    // Configure Preview instance.
    _resolutionPreset = resolutionPreset;
    final int targetRotation =
        _getTargetRotation(cameraDescription.sensorOrientation);
    final ResolutionInfo? previewTargetResolution =
        _getTargetResolutionForPreview(resolutionPreset);
    preview = createPreview(targetRotation, previewTargetResolution);
    final int flutterSurfaceTextureId = await preview!.setSurfaceProvider();

    // Configure ImageCapture instance.
    final ResolutionInfo? imageCaptureTargetResolution =
        _getTargetResolutionForImageCapture(_resolutionPreset);
    imageCapture = createImageCapture(null, imageCaptureTargetResolution);

    // Configure VideoCapture and Recorder instances.
    // TODO(gmackall): Enable video capture resolution configuration in createRecorder().
    recorder = createRecorder();
    videoCapture = await createVideoCapture(recorder!);

    // Bind configured UseCases to ProcessCameraProvider instance & mark Preview
    // instance as bound but not paused. Video capture is bound at first use
    // instead of here.
    camera = await processCameraProvider!
        .bindToLifecycle(cameraSelector!, <UseCase>[preview!, imageCapture!]);
    await _updateLiveCameraState(flutterSurfaceTextureId);
    cameraInfo = await camera!.getCameraInfo();
    _previewIsPaused = false;

    return flutterSurfaceTextureId;
  }

  /// Initializes the camera on the device.
  ///
  /// Since initialization of a camera does not directly map as an operation to
  /// the CameraX library, this method just retrieves information about the
  /// camera and sends a [CameraInitializedEvent].
  ///
  /// [imageFormatGroup] is used to specify the image format used for image
  /// streaming, but CameraX currently only supports YUV_420_888 (supported by
  /// Flutter) and RGBA (not supported by Flutter). CameraX uses YUV_420_888
  /// by default, so [imageFormatGroup] is not used.
  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    // Configure CameraInitializedEvent to send as representation of a
    // configured camera:
    // Retrieve preview resolution.
    if (preview == null) {
      // No camera has been created; createCamera must be called before initializeCamera.
      throw CameraException(
        'cameraNotFound',
        "Camera not found. Please call the 'create' method before calling 'initialize'",
      );
    }

    final ResolutionInfo previewResolutionInfo =
        await preview!.getResolutionInfo();

    // Retrieve exposure and focus mode configurations:
    // TODO(camsim99): Implement support for retrieving exposure mode configuration.
    // https://github.com/flutter/flutter/issues/120468
    const ExposureMode exposureMode = ExposureMode.auto;
    const bool exposurePointSupported = false;

    // TODO(camsim99): Implement support for retrieving focus mode configuration.
    // https://github.com/flutter/flutter/issues/120467
    const FocusMode focusMode = FocusMode.auto;
    const bool focusPointSupported = false;

    cameraEventStreamController.add(CameraInitializedEvent(
        cameraId,
        previewResolutionInfo.width.toDouble(),
        previewResolutionInfo.height.toDouble(),
        exposureMode,
        exposurePointSupported,
        focusMode,
        focusPointSupported));
  }

  /// Releases the resources of the accessed camera.
  ///
  /// [cameraId] not used.
  @override
  Future<void> dispose(int cameraId) async {
    preview?.releaseFlutterSurfaceTexture();
    liveCameraState?.removeObservers();
    processCameraProvider?.unbindAll();
    imageAnalysis?.clearAnalyzer();
  }

  /// The camera has been initialized.
  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  /// The camera started to close.
  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraClosingEvent>();
  }

  /// The camera experienced an error.
  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return StreamGroup.mergeBroadcast<
        CameraErrorEvent>(<Stream<CameraErrorEvent>>[
      SystemServices.cameraErrorStreamController.stream
          .map<CameraErrorEvent>((String errorDescription) {
        return CameraErrorEvent(cameraId, errorDescription);
      }),
      _cameraEvents(cameraId).whereType<CameraErrorEvent>()
    ]);
  }

  /// Gets the minimum supported exposure offset for the selected camera in EV units.
  ///
  /// [cameraId] not used.
  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    final ExposureState exposureState = await cameraInfo!.getExposureState();
    return exposureState.exposureCompensationRange.minCompensation *
        exposureState.exposureCompensationStep;
  }

  /// Gets the maximum supported exposure offset for the selected camera in EV units.
  ///
  /// [cameraId] not used.
  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    final ExposureState exposureState = await cameraInfo!.getExposureState();
    return exposureState.exposureCompensationRange.maxCompensation *
        exposureState.exposureCompensationStep;
  }

  /// Gets the supported step size for exposure offset for the selected camera in EV units.
  ///
  /// Returns 0 when exposure compensation is not supported.
  ///
  /// [cameraId] not used.
  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    final ExposureState exposureState = await cameraInfo!.getExposureState();
    return exposureState.exposureCompensationStep;
  }

  /// Gets the maximum supported zoom level for the selected camera.
  ///
  /// [cameraId] not used.
  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    final LiveData<ZoomState> liveZoomState = await cameraInfo!.getZoomState();
    final ZoomState? zoomState = await liveZoomState.getValue();

    if (zoomState == null) {
      throw CameraException(
        zoomStateNotSetErrorCode,
        'No explicit ZoomState has been set on the LiveData instance for the camera in use.',
      );
    }
    return zoomState.maxZoomRatio;
  }

  /// Gets the minimum supported zoom level for the selected camera.
  ///
  /// [cameraId] not used.
  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    final LiveData<ZoomState> liveZoomState = await cameraInfo!.getZoomState();
    final ZoomState? zoomState = await liveZoomState.getValue();

    if (zoomState == null) {
      throw CameraException(
        zoomStateNotSetErrorCode,
        'No explicit ZoomState has been set on the LiveData instance for the camera in use.',
      );
    }
    return zoomState.minZoomRatio;
  }

  /// The ui orientation changed.
  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return SystemServices.deviceOrientationChangedStreamController.stream;
  }

  /// Pause the active preview on the current frame for the selected camera.
  ///
  /// [cameraId] not used.
  @override
  Future<void> pausePreview(int cameraId) async {
    _unbindUseCaseFromLifecycle(preview!);
    _previewIsPaused = true;
  }

  /// Resume the paused preview for the selected camera.
  ///
  /// [cameraId] not used.
  @override
  Future<void> resumePreview(int cameraId) async {
    await _bindPreviewToLifecycle(cameraId);
    _previewIsPaused = false;
  }

  /// Returns a widget showing a live camera preview.
  @override
  Widget buildPreview(int cameraId) {
    return FutureBuilder<void>(
        future: _bindPreviewToLifecycle(cameraId),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              // Do nothing while waiting for preview to be bound to lifecyle.
              return const SizedBox.shrink();
            case ConnectionState.done:
              return Texture(textureId: cameraId);
          }
        });
  }

  /// Captures an image and returns the file where it was saved.
  ///
  /// [cameraId] is not used.
  @override
  Future<XFile> takePicture(int cameraId) async {
    // TODO(camsim99): Add support for flash mode configuration.
    // https://github.com/flutter/flutter/issues/120715
    final String picturePath = await imageCapture!.takePicture();

    return XFile(picturePath);
  }

  /// Configures and starts a video recording. Returns silently without doing
  /// anything if there is currently an active recording.
  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    assert(cameraSelector != null);
    assert(processCameraProvider != null);

    if (recording != null) {
      // There is currently an active recording, so do not start a new one.
      return;
    }

    if (!(await processCameraProvider!.isBound(videoCapture!))) {
      camera = await processCameraProvider!
          .bindToLifecycle(cameraSelector!, <UseCase>[videoCapture!]);
    }

    videoOutputPath =
        await SystemServices.getTempFilePath(videoPrefix, '.temp');
    pendingRecording = await recorder!.prepareRecording(videoOutputPath!);
    recording = await pendingRecording!.start();
  }

  /// Stops the video recording and returns the file where it was saved.
  /// Throws a CameraException if the recording is currently null, or if the
  /// videoOutputPath is null.
  ///
  /// If the videoOutputPath is null the recording objects are cleaned up
  /// so starting a new recording is possible.
  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    if (recording == null) {
      throw CameraException(
          'videoRecordingFailed',
          'Attempting to stop a '
              'video recording while no recording is in progress.');
    }
    if (videoOutputPath == null) {
      // Stop the current active recording as we will be unable to complete it
      // in this error case.
      recording!.close();
      recording = null;
      pendingRecording = null;
      throw CameraException(
          'INVALID_PATH',
          'The platform did not return a path '
              'while reporting success. The platform should always '
              'return a valid path or report an error.');
    }
    recording!.close();
    recording = null;
    pendingRecording = null;
    return XFile(videoOutputPath!);
  }

  /// Pause the current video recording if it is not null.
  @override
  Future<void> pauseVideoRecording(int cameraId) async {
    if (recording != null) {
      recording!.pause();
    }
  }

  /// Resume the current video recording if it is not null.
  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    if (recording != null) {
      recording!.resume();
    }
  }

  /// A new streamed frame is available.
  ///
  /// Listening to this stream will start streaming, and canceling will stop.
  /// To temporarily stop receiving frames, cancel, then listen again later.
  /// Pausing/resuming is not supported, as pausing the stream would cause
  /// very high memory usage, and will throw an exception due to the
  /// implementation using a broadcast [StreamController], which does not
  /// support those operations.
  ///
  /// [cameraId] and [options] are not used.
  @override
  Stream<CameraImageData> onStreamedFrameAvailable(int cameraId,
      {CameraImageStreamOptions? options}) {
    cameraImageDataStreamController = StreamController<CameraImageData>(
      onListen: _onFrameStreamListen,
      onCancel: _onFrameStreamCancel,
    );
    return cameraImageDataStreamController!.stream;
  }

  // Methods for binding UseCases to the lifecycle of the camera controlled
  // by a ProcessCameraProvider instance:

  /// Binds [preview] instance to the camera lifecycle controlled by the
  /// [processCameraProvider].
  ///
  /// [cameraId] used to build [CameraEvent]s should you wish to filter
  /// these based on a reference to a cameraId received from calling
  /// `createCamera(...)`.
  Future<void> _bindPreviewToLifecycle(int cameraId) async {
    final bool previewIsBound = await processCameraProvider!.isBound(preview!);
    if (previewIsBound || _previewIsPaused) {
      // Only bind if preview is not already bound or intentionally paused.
      return;
    }

    camera = await processCameraProvider!
        .bindToLifecycle(cameraSelector!, <UseCase>[preview!]);
    await _updateLiveCameraState(cameraId);
    cameraInfo = await camera!.getCameraInfo();
  }

  /// Configures the [imageAnalysis] instance for image streaming and binds it
  /// to camera lifecycle controlled by the [processCameraProvider].
  Future<void> _configureAndBindImageAnalysisToLifecycle() async {
    if (imageAnalysis != null &&
        await processCameraProvider!.isBound(imageAnalysis!)) {
      // imageAnalysis already configured and bound to lifecycle.
      return;
    }

    // Create Analyzer that can read image data for image streaming.
    final WeakReference<AndroidCameraCameraX> weakThis =
        WeakReference<AndroidCameraCameraX>(this);
    Future<void> analyze(ImageProxy imageProxy) async {
      final List<PlaneProxy> planes = await imageProxy.getPlanes();
      final List<CameraImagePlane> cameraImagePlanes = <CameraImagePlane>[];
      for (final PlaneProxy plane in planes) {
        cameraImagePlanes.add(CameraImagePlane(
            bytes: plane.buffer,
            bytesPerRow: plane.rowStride,
            bytesPerPixel: plane.pixelStride));
      }

      final int format = imageProxy.format;
      final CameraImageFormat cameraImageFormat = CameraImageFormat(
          _imageFormatGroupFromPlatformData(format),
          raw: format);

      final CameraImageData cameraImageData = CameraImageData(
          format: cameraImageFormat,
          planes: cameraImagePlanes,
          height: imageProxy.height,
          width: imageProxy.width);

      weakThis.target!.cameraImageDataStreamController!.add(cameraImageData);
      imageProxy.close();
    }

    // shouldCreateDetachedObjectForTesting is used to create an Analyzer
    // detached from the native sideonly to test the logic of the Analyzer
    // instance that will be used for image streaming.
    final Analyzer analyzer = _shouldCreateDetachedObjectForTesting
        ? Analyzer.detached(analyze: analyze)
        : Analyzer(analyze: analyze);

    // TODO(camsim99): Support resolution configuration.
    // Defaults to YUV_420_888 image format.
    imageAnalysis = createImageAnalysis(null);
    imageAnalysis!.setAnalyzer(analyzer);

    // TODO(camsim99): Reset live camera state observers here when
    // https://github.com/flutter/packages/pull/3419 lands.
    camera = await processCameraProvider!
        .bindToLifecycle(cameraSelector!, <UseCase>[imageAnalysis!]);
    cameraInfo = await camera!.getCameraInfo();
  }

  /// Unbinds [useCase] from camera lifecycle controlled by the
  /// [processCameraProvider].
  Future<void> _unbindUseCaseFromLifecycle(UseCase useCase) async {
    final bool useCaseIsBound = await processCameraProvider!.isBound(useCase);
    if (!useCaseIsBound) {
      return;
    }

    processCameraProvider!.unbind(<UseCase>[useCase]);
  }

  // Methods for configuring image streaming:

  /// The [onListen] callback for the stream controller used for image
  /// streaming.
  Future<void> _onFrameStreamListen() async {
    _configureAndBindImageAnalysisToLifecycle();
  }

  /// The [onCancel] callback for the stream controller used for image
  /// streaming.
  ///
  /// Removes the previously set analyzer on the [imageAnalysis] instance, since
  /// image information should no longer be streamed.
  FutureOr<void> _onFrameStreamCancel() async {
    imageAnalysis!.clearAnalyzer();
  }

  /// Converts between Android ImageFormat constants and [ImageFormatGroup]s.
  ///
  /// See https://developer.android.com/reference/android/graphics/ImageFormat.
  ImageFormatGroup _imageFormatGroupFromPlatformData(dynamic data) {
    switch (data) {
      case imageFormatYuv420_888: // android.graphics.ImageFormat.YUV_420_888
        return ImageFormatGroup.yuv420;
      case imageFormatJpeg: // android.graphics.ImageFormat.JPEG
        return ImageFormatGroup.jpeg;
    }

    return ImageFormatGroup.unknown;
  }

  // Methods concerning camera state:

  /// Adds observers to the [LiveData] of the [CameraState] of the current
  /// [camera], saved as [liveCameraState].
  ///
  /// If a previous [liveCameraState] was stored, existing observers are
  /// removed, as well.
  Future<void> _updateLiveCameraState(int cameraId) async {
    final CameraInfo cameraInfo = await camera!.getCameraInfo();
    liveCameraState?.removeObservers();
    liveCameraState = await cameraInfo.getCameraState();
    await liveCameraState!.observe(_createCameraClosingObserver(cameraId));
  }

  /// Creates [Observer] of the [CameraState] that will:
  ///
  ///  * Send a [CameraClosingEvent] if the [CameraState] indicates that the
  ///    camera has begun to close.
  ///  * Send a [CameraErrorEvent] if the [CameraState] indicates that the
  ///    camera is in error state.
  Observer<CameraState> _createCameraClosingObserver(int cameraId) {
    final WeakReference<AndroidCameraCameraX> weakThis =
        WeakReference<AndroidCameraCameraX>(this);

    // Callback method used to implement the behavior described above:
    void onChanged(Object stateAsObject) {
      // This cast is safe because the Observer implementation ensures
      // the type of stateAsObject is the same as the observer this callback
      // is attached to.
      final CameraState state = stateAsObject as CameraState;
      if (state.type == CameraStateType.closing) {
        weakThis.target!.cameraEventStreamController
            .add(CameraClosingEvent(cameraId));
      }
      if (state.error != null) {
        weakThis.target!.cameraEventStreamController
            .add(CameraErrorEvent(cameraId, state.error!.getDescription()));
      }
    }

    // shouldCreateDetachedObjectForTesting is used to create an Observer
    // detached from the native side only to test the logic of the Analyzer
    // instance that will be used for image streaming.
    return _shouldCreateDetachedObjectForTesting
        ? Observer<CameraState>.detached(onChanged: onChanged)
        : Observer<CameraState>(onChanged: onChanged);
  }

  // Methods for mapping Flutter camera constants to CameraX constants:

  /// Returns [CameraSelector] lens direction that maps to specified
  /// [CameraLensDirection].
  int _getCameraSelectorLensDirection(CameraLensDirection lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.front:
        return CameraSelector.lensFacingFront;
      case CameraLensDirection.back:
        return CameraSelector.lensFacingBack;
      case CameraLensDirection.external:
        return CameraSelector.lensFacingExternal;
    }
  }

  /// Returns [Surface] target rotation constant that maps to specified sensor
  /// orientation.
  int _getTargetRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return Surface.ROTATION_90;
      case 180:
        return Surface.ROTATION_180;
      case 270:
        return Surface.ROTATION_270;
      case 0:
        return Surface.ROTATION_0;
      default:
        throw ArgumentError(
            '"$sensorOrientation" is not a valid sensor orientation value');
    }
  }

  /// Returns [ResolutionInfo] that maps to the specified resolution preset for
  /// a camera preview.
  ResolutionInfo? _getTargetResolutionForPreview(ResolutionPreset? resolution) {
    // TODO(camsim99): Implement resolution configuration.
    // https://github.com/flutter/flutter/issues/120462
    return null;
  }

  /// Returns [ResolutionInfo] that maps to the specified resolution preset for
  /// image capture.
  ResolutionInfo? _getTargetResolutionForImageCapture(
      ResolutionPreset? resolution) {
    // TODO(camsim99): Implement resolution configuration.
    // https://github.com/flutter/flutter/issues/120462
    return null;
  }

  // Methods for calls that need to be tested:

  /// Requests camera permissions.
  @visibleForTesting
  Future<void> requestCameraPermissions(bool enableAudio) async {
    await SystemServices.requestCameraPermissions(enableAudio);
  }

  /// Subscribes the plugin as a listener to changes in device orientation.
  @visibleForTesting
  void startListeningForDeviceOrientationChange(
      bool cameraIsFrontFacing, int sensorOrientation) {
    SystemServices.startListeningForDeviceOrientationChange(
        cameraIsFrontFacing, sensorOrientation);
  }

  /// Returns a [CameraSelector] based on the specified camera lens direction.
  @visibleForTesting
  CameraSelector createCameraSelector(int cameraSelectorLensDirection) {
    switch (cameraSelectorLensDirection) {
      case CameraSelector.lensFacingFront:
        return CameraSelector.getDefaultFrontCamera();
      case CameraSelector.lensFacingBack:
        return CameraSelector.getDefaultBackCamera();
      default:
        return CameraSelector(lensFacing: cameraSelectorLensDirection);
    }
  }

  /// Returns a [Preview] configured with the specified target rotation and
  /// resolution.
  @visibleForTesting
  Preview createPreview(int targetRotation, ResolutionInfo? targetResolution) {
    return Preview(
        targetRotation: targetRotation, targetResolution: targetResolution);
  }

  /// Returns an [ImageCapture] configured with specified flash mode and
  /// target resolution.
  @visibleForTesting
  ImageCapture createImageCapture(
      int? flashMode, ResolutionInfo? targetResolution) {
    return ImageCapture(
        targetFlashMode: flashMode, targetResolution: targetResolution);
  }

  /// Returns a [Recorder] for use in video capture.
  @visibleForTesting
  Recorder createRecorder() {
    return Recorder();
  }

  /// Returns a [VideoCapture] associated with the provided [Recorder].
  @visibleForTesting
  Future<VideoCapture> createVideoCapture(Recorder recorder) async {
    return VideoCapture.withOutput(recorder);
  }

  /// Returns an [ImageAnalysis] configured with specified target resolution.
  @visibleForTesting
  ImageAnalysis createImageAnalysis(ResolutionInfo? targetResolution) {
    return ImageAnalysis(targetResolution: targetResolution);
  }
}
