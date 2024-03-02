// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' show Point;

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, PlatformException;
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'analyzer.dart';
import 'camera.dart';
import 'camera2_camera_control.dart';
import 'camera_control.dart';
import 'camera_info.dart';
import 'camera_selector.dart';
import 'camera_state.dart';
import 'camerax_library.g.dart';
import 'camerax_proxy.dart';
import 'capture_request_options.dart';
import 'device_orientation_manager.dart';
import 'exposure_state.dart';
import 'fallback_strategy.dart';
import 'focus_metering_action.dart';
import 'image_analysis.dart';
import 'image_capture.dart';
import 'image_proxy.dart';
import 'live_data.dart';
import 'metering_point.dart';
import 'observer.dart';
import 'pending_recording.dart';
import 'plane_proxy.dart';
import 'preview.dart';
import 'process_camera_provider.dart';
import 'quality_selector.dart';
import 'recorder.dart';
import 'recording.dart';
import 'resolution_selector.dart';
import 'resolution_strategy.dart';
import 'surface.dart';
import 'system_services.dart';
import 'use_case.dart';
import 'video_capture.dart';
import 'zoom_state.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  /// Constructs an [AndroidCameraCameraX].
  AndroidCameraCameraX();

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

  /// Proxy for creating `JavaObject`s and calling their methods that require
  /// testing.
  @visibleForTesting
  CameraXProxy proxy = CameraXProxy();

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

  /// The [CameraControl] instance that corresponds to the [camera] instance.
  late CameraControl cameraControl;

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

  /// Whether or not [preview] has been bound to the lifecycle of the camera by
  /// [createCamera].
  @visibleForTesting
  bool previewInitiallyBound = false;

  bool _previewIsPaused = false;

  /// The prefix used to create the filename for video recording files.
  @visibleForTesting
  final String videoPrefix = 'MOV';

  /// The [ImageCapture] instance that can be configured to capture a still image.
  @visibleForTesting
  ImageCapture? imageCapture;

  /// The flash mode currently configured for [imageCapture].
  int? _currentFlashMode;

  /// Whether or not torch flash mode has been enabled for the [camera].
  @visibleForTesting
  bool torchEnabled = false;

  /// The [ImageAnalysis] instance that can be configured to analyze individual
  /// frames.
  ImageAnalysis? imageAnalysis;

  /// The [CameraSelector] used to configure the [processCameraProvider] to use
  /// the desired camera.
  @visibleForTesting
  CameraSelector? cameraSelector;

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

  /// Whether or not the capture orientation is locked.
  ///
  /// Indicates a new target rotation should not be set as it has been locked by
  /// [lockCaptureOrientation].
  @visibleForTesting
  bool captureOrientationLocked = false;

  /// Whether or not the default rotation for [UseCase]s needs to be set
  /// manually because the capture orientation was previously locked.
  ///
  /// Currently, CameraX provides no way to unset target rotations for
  /// [UseCase]s, so once they are set and unset, this plugin must start setting
  /// the default orientation manually.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/ImageCapture#setTargetRotation(int)
  /// for an example on how setting target rotations for [UseCase]s works.
  bool shouldSetDefaultRotation = false;

  /// The currently set [FocusMeteringAction] used to enable auto-focus and
  /// auto-exposure.
  @visibleForTesting
  FocusMeteringAction? currentFocusMeteringAction;

  /// Error code indicating that exposure compensation is not supported by
  /// CameraX for the device.
  static const String exposureCompensationNotSupported =
      'exposureCompensationNotSupported';

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> cameraDescriptions = <CameraDescription>[];

    processCameraProvider ??= await proxy.getProcessCameraProvider();
    final List<CameraInfo> cameraInfos =
        await processCameraProvider!.getAvailableCameraInfos();

    CameraLensDirection? cameraLensDirection;
    int cameraCount = 0;
    int? cameraSensorOrientation;
    String? cameraName;

    for (final CameraInfo cameraInfo in cameraInfos) {
      // Determine the lens direction by filtering the CameraInfo
      // TODO(gmackall): replace this with call to CameraInfo.getLensFacing when changes containing that method are available
      if ((await proxy
              .createCameraSelector(CameraSelector.lensFacingBack)
              .filter(<CameraInfo>[cameraInfo]))
          .isNotEmpty) {
        cameraLensDirection = CameraLensDirection.back;
      } else if ((await proxy
              .createCameraSelector(CameraSelector.lensFacingFront)
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
  /// The specified [resolutionPreset] is the target resolution that CameraX
  /// will attempt to select for the [UseCase]s constructed in this method
  /// ([preview], [imageCapture], [imageAnalysis], [videoCapture]). If
  /// unavailable, a fallback behavior of targeting the next highest resolution
  /// will be attempted. See https://developer.android.com/media/camera/camerax/configuration#specify-resolution.
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
    await proxy.requestCameraPermissions(enableAudio);

    // Save CameraSelector that matches cameraDescription.
    final int cameraSelectorLensDirection =
        _getCameraSelectorLensDirection(cameraDescription.lensDirection);
    final bool cameraIsFrontFacing =
        cameraSelectorLensDirection == CameraSelector.lensFacingFront;
    cameraSelector = proxy.createCameraSelector(cameraSelectorLensDirection);
    // Start listening for device orientation changes preceding camera creation.
    proxy.startListeningForDeviceOrientationChange(
        cameraIsFrontFacing, cameraDescription.sensorOrientation);
    // Determine ResolutionSelector and QualitySelector based on
    // resolutionPreset for camera UseCases.
    final ResolutionSelector? presetResolutionSelector =
        _getResolutionSelectorFromPreset(resolutionPreset);
    final QualitySelector? presetQualitySelector =
        _getQualitySelectorFromPreset(resolutionPreset);

    // Retrieve a fresh ProcessCameraProvider instance.
    processCameraProvider ??= await proxy.getProcessCameraProvider();
    processCameraProvider!.unbindAll();

    // Configure Preview instance.
    preview = proxy.createPreview(presetResolutionSelector,
        /* use CameraX default target rotation */ null);
    final int flutterSurfaceTextureId =
        await proxy.setPreviewSurfaceProvider(preview!);

    // Configure ImageCapture instance.
    imageCapture = proxy.createImageCapture(presetResolutionSelector,
        /* use CameraX default target rotation */ null);

    // Configure ImageAnalysis instance.
    // Defaults to YUV_420_888 image format.
    imageAnalysis = proxy.createImageAnalysis(presetResolutionSelector,
        /* use CameraX default target rotation */ null);

    // Configure VideoCapture and Recorder instances.
    recorder = proxy.createRecorder(presetQualitySelector);
    videoCapture = await proxy.createVideoCapture(recorder!);

    // Bind configured UseCases to ProcessCameraProvider instance & mark Preview
    // instance as bound but not paused. Video capture is bound at first use
    // instead of here.
    camera = await processCameraProvider!.bindToLifecycle(
        cameraSelector!, <UseCase>[preview!, imageCapture!, imageAnalysis!]);
    await _updateCameraInfoAndLiveCameraState(flutterSurfaceTextureId);
    previewInitiallyBound = true;
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

    // Mark auto-focus, auto-exposure and setting points for focus & exposure
    // as available operations as CameraX does its best across devices to
    // support these by default.
    const ExposureMode exposureMode = ExposureMode.auto;
    const FocusMode focusMode = FocusMode.auto;
    const bool exposurePointSupported = true;
    const bool focusPointSupported = true;

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
    await liveCameraState?.removeObservers();
    processCameraProvider?.unbindAll();
    await imageAnalysis?.clearAnalyzer();
  }

  /// The camera has been initialized.
  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  /// The camera's resolution has changed.
  ///
  /// This stream currently has no events being added to it from this plugin.
  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraResolutionChangedEvent>();
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

  /// The camera finished recording a video.
  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    return _cameraEvents(cameraId).whereType<VideoRecordedEvent>();
  }

  /// Locks the capture orientation.
  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    // Flag that (1) default rotation for UseCases will need to be set manually
    // if orientation is ever unlocked and (2) the capture orientation is locked
    // and should not be changed until unlocked.
    shouldSetDefaultRotation = true;
    captureOrientationLocked = true;

    // Get target rotation based on locked orientation.
    final int targetLockedRotation =
        _getRotationConstantFromDeviceOrientation(orientation);

    // Update UseCases to use target device orientation.
    await imageCapture!.setTargetRotation(targetLockedRotation);
    await imageAnalysis!.setTargetRotation(targetLockedRotation);
    await videoCapture!.setTargetRotation(targetLockedRotation);
  }

  /// Unlocks the capture orientation.
  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    // Flag that default rotation should be set for UseCases as needed.
    captureOrientationLocked = false;
  }

  /// Sets the exposure point for automatically determining the exposure values.
  ///
  /// Supplying `null` for the [point] argument will result in resetting to the
  /// original exposure point value.
  ///
  /// [cameraId] is not used.
  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {
    await _startFocusAndMeteringFor(
        point: point, meteringMode: FocusMeteringAction.flagAe);
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
  /// Returns -1 if exposure compensation is not supported for the device.
  ///
  /// [cameraId] not used.
  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    final ExposureState exposureState = await cameraInfo!.getExposureState();
    final double exposureOffsetStepSize =
        exposureState.exposureCompensationStep;
    if (exposureOffsetStepSize == 0) {
      // CameraX returns a step size of 0 if exposure compensation is not
      // supported for the device.
      return -1;
    }
    return exposureOffsetStepSize;
  }

  /// Sets the exposure offset for the selected camera.
  ///
  /// The supplied [offset] value should be in EV units. 1 EV unit represents a
  /// doubling in brightness. It should be between the minimum and maximum offsets
  /// obtained through `getMinExposureOffset` and `getMaxExposureOffset` respectively.
  /// Throws a `CameraException` when trying to set exposure offset on a device
  /// that doesn't support exposure compensationan or if setting the offset fails,
  /// like in the case that an illegal offset is supplied.
  ///
  /// When the supplied [offset] value does not align with the step size obtained
  /// through `getExposureStepSize`, it will automatically be rounded to the nearest step.
  ///
  /// Returns the (rounded) offset value that was set.
  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    final double exposureOffsetStepSize =
        (await cameraInfo!.getExposureState()).exposureCompensationStep;
    if (exposureOffsetStepSize == 0) {
      throw CameraException(exposureCompensationNotSupported,
          'Exposure compensation not supported');
    }

    // (Exposure compensation index) * (exposure offset step size) =
    // (exposure offset).
    final int roundedExposureCompensationIndex =
        (offset / exposureOffsetStepSize).round();

    try {
      await cameraControl
          .setExposureCompensationIndex(roundedExposureCompensationIndex);
    } on PlatformException catch (e) {
      throw CameraException(
          'setExposureOffsetFailed',
          e.message ??
              'Setting the camera exposure compensation index failed.');
    }
    return roundedExposureCompensationIndex * exposureOffsetStepSize;
  }

  /// Sets the focus point for automatically determining the focus values.
  ///
  /// Supplying `null` for the [point] argument will result in resetting to the
  /// original focus point value.
  ///
  /// [cameraId] is not used.
  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {
    await _startFocusAndMeteringFor(
        point: point, meteringMode: FocusMeteringAction.flagAf);
  }

  /// Sets the exposure mode for taking pictures.
  ///
  /// Setting [ExposureMode.locked] will lock current exposure point until it
  /// is unset by setting [ExposureMode.auto].
  ///
  /// [cameraId] is not used.
  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {
    final Camera2CameraControl camera2Control =
        proxy.getCamera2CameraControl(cameraControl);
    final bool lockExposureMode = mode == ExposureMode.locked;

    final CaptureRequestOptions captureRequestOptions = proxy
        .createCaptureRequestOptions(<(
      CaptureRequestKeySupportedType,
      Object?
    )>[(CaptureRequestKeySupportedType.controlAeLock, lockExposureMode)]);

    await camera2Control.addCaptureRequestOptions(captureRequestOptions);
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

  /// Set the zoom level for the selected camera.
  ///
  /// The supplied [zoom] value should be between the minimum and the maximum
  /// supported zoom level returned by [getMinZoomLevel] and [getMaxZoomLevel].
  /// Throws a `CameraException` when an illegal zoom level is supplied.
  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    await cameraControl.setZoomRatio(zoom);
  }

  /// The ui orientation changed.
  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return DeviceOrientationManager
        .deviceOrientationChangedStreamController.stream;
  }

  /// Pause the active preview on the current frame for the selected camera.
  ///
  /// [cameraId] not used.
  @override
  Future<void> pausePreview(int cameraId) async {
    _previewIsPaused = true;
    await _unbindUseCaseFromLifecycle(preview!);
  }

  /// Resume the paused preview for the selected camera.
  ///
  /// [cameraId] not used.
  @override
  Future<void> resumePreview(int cameraId) async {
    _previewIsPaused = false;
    await _bindPreviewToLifecycle(cameraId);
  }

  /// Returns a widget showing a live camera preview.
  ///
  /// [createCamera] must be called before attempting to build this preview.
  @override
  Widget buildPreview(int cameraId) {
    if (!previewInitiallyBound) {
      // No camera has been created, and thus, the preview UseCase has not been
      // bound to the camera lifecycle, restricting this preview from being
      // built.
      throw CameraException(
        'cameraNotFound',
        "Camera not found. Please call the 'create' method before calling 'buildPreview'",
      );
    }
    return Texture(textureId: cameraId);
  }

  /// Captures an image and returns the file where it was saved.
  ///
  /// [cameraId] is not used.
  @override
  Future<XFile> takePicture(int cameraId) async {
    // Set flash mode.
    if (_currentFlashMode != null) {
      await imageCapture!.setFlashMode(_currentFlashMode!);
    } else if (torchEnabled) {
      // Ensure any previously set flash modes are unset when torch mode has
      // been enabled.
      await imageCapture!.setFlashMode(ImageCapture.flashModeOff);
    }

    // Set target rotation to default CameraX rotation only if capture
    // orientation not locked.
    if (!captureOrientationLocked && shouldSetDefaultRotation) {
      await imageCapture!
          .setTargetRotation(await proxy.getDefaultDisplayRotation());
    }

    final String picturePath = await imageCapture!.takePicture();
    return XFile(picturePath);
  }

  /// Sets the flash mode for the selected camera.
  ///
  /// When the [FlashMode.torch] is enabled, any previously set [FlashMode] with
  /// this method will be disabled, just as with any other [FlashMode]; while
  /// this is not default native Android behavior as defined by the CameraX API,
  /// this behavior is compliant with the plugin platform interface.
  ///
  /// This method combines the notion of setting the flash mode of the
  /// [imageCapture] UseCase and enabling the camera torch, as described
  /// by https://developer.android.com/reference/androidx/camera/core/ImageCapture
  /// and https://developer.android.com/reference/androidx/camera/core/CameraControl#enableTorch(boolean),
  /// respectively.
  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    // Turn off torch mode if it is enabled and not being redundantly set.
    if (mode != FlashMode.torch && torchEnabled) {
      await cameraControl.enableTorch(false);
      torchEnabled = false;
    }

    switch (mode) {
      case FlashMode.off:
        _currentFlashMode = ImageCapture.flashModeOff;
      case FlashMode.auto:
        _currentFlashMode = ImageCapture.flashModeAuto;
      case FlashMode.always:
        _currentFlashMode = ImageCapture.flashModeOn;
      case FlashMode.torch:
        _currentFlashMode = null;
        if (torchEnabled) {
          // Torch mode enabled already.
          return;
        }
        await cameraControl.enableTorch(true);
        torchEnabled = true;
    }
  }

  /// Configures and starts a video recording. Returns silently without doing
  /// anything if there is currently an active recording.
  ///
  /// Note that the preset resolution is used to configure the recording, but
  /// 240p ([ResolutionPreset.low]) is unsupported and will fallback to
  /// configure the recording as the next highest available quality.
  ///
  /// This method is deprecated in favour of [startVideoCapturing].
  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    return startVideoCapturing(
        VideoCaptureOptions(cameraId, maxDuration: maxVideoDuration));
  }

  /// Starts a video recording and/or streaming session.
  ///
  /// Please see [VideoCaptureOptions] for documentation on the
  /// configuration options. Currently, maxVideoDuration and streamOptions
  /// are unsupported due to the limitations of CameraX and the platform
  /// interface, respectively.
  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) async {
    if (recording != null) {
      // There is currently an active recording, so do not start a new one.
      return;
    }

    if (!(await processCameraProvider!.isBound(videoCapture!))) {
      camera = await processCameraProvider!
          .bindToLifecycle(cameraSelector!, <UseCase>[videoCapture!]);
      await _updateCameraInfoAndLiveCameraState(options.cameraId);
    }

    // Set target rotation to default CameraX rotation only if capture
    // orientation not locked.
    if (!captureOrientationLocked && shouldSetDefaultRotation) {
      await videoCapture!
          .setTargetRotation(await proxy.getDefaultDisplayRotation());
    }

    videoOutputPath =
        await SystemServices.getTempFilePath(videoPrefix, '.temp');
    pendingRecording = await recorder!.prepareRecording(videoOutputPath!);
    recording = await pendingRecording!.start();

    if (options.streamCallback != null) {
      onStreamedFrameAvailable(options.cameraId).listen(options.streamCallback);
    }
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
      await recording!.close();
      recording = null;
      pendingRecording = null;
      throw CameraException(
          'INVALID_PATH',
          'The platform did not return a path '
              'while reporting success. The platform should always '
              'return a valid path or report an error.');
    }
    await recording!.close();
    recording = null;
    pendingRecording = null;
    return XFile(videoOutputPath!);
  }

  /// Pause the current video recording if it is not null.
  @override
  Future<void> pauseVideoRecording(int cameraId) async {
    if (recording != null) {
      await recording!.pause();
    }
  }

  /// Resume the current video recording if it is not null.
  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    if (recording != null) {
      await recording!.resume();
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
      onListen: () => _configureImageAnalysis(cameraId),
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
    await _updateCameraInfoAndLiveCameraState(cameraId);
  }

  /// Configures the [imageAnalysis] instance for image streaming.
  Future<void> _configureImageAnalysis(int cameraId) async {
    // Set target rotation to default CameraX rotation only if capture
    // orientation not locked.
    if (!captureOrientationLocked && shouldSetDefaultRotation) {
      await imageAnalysis!
          .setTargetRotation(await proxy.getDefaultDisplayRotation());
    }

    // Create and set Analyzer that can read image data for image streaming.
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
      await imageProxy.close();
    }

    final Analyzer analyzer = proxy.createAnalyzer(analyze);
    await imageAnalysis!.setAnalyzer(analyzer);
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

  /// The [onCancel] callback for the stream controller used for image
  /// streaming.
  ///
  /// Removes the previously set analyzer on the [imageAnalysis] instance, since
  /// image information should no longer be streamed.
  FutureOr<void> _onFrameStreamCancel() async {
    await imageAnalysis!.clearAnalyzer();
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

  /// Updates [cameraInfo] and [cameraControl] to the information corresponding
  /// to [camera] and adds observers to the [LiveData] of the [CameraState] of
  /// the current [camera], saved as [liveCameraState].
  ///
  /// If a previous [liveCameraState] was stored, existing observers are
  /// removed, as well.
  Future<void> _updateCameraInfoAndLiveCameraState(int cameraId) async {
    cameraInfo = await camera!.getCameraInfo();
    cameraControl = await camera!.getCameraControl();
    await liveCameraState?.removeObservers();
    liveCameraState = await cameraInfo!.getCameraState();
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

    return proxy.createCameraStateObserver(onChanged);
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

  /// Returns [Surface] constant for counter-clockwise degrees of rotation from
  /// [DeviceOrientation.portraitUp] required to reach the specified
  /// [DeviceOrientation].
  int _getRotationConstantFromDeviceOrientation(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        return Surface.ROTATION_0;
      case DeviceOrientation.landscapeLeft:
        return Surface.ROTATION_90;
      case DeviceOrientation.portraitDown:
        return Surface.ROTATION_180;
      case DeviceOrientation.landscapeRight:
        return Surface.ROTATION_270;
    }
  }

  /// Returns the [ResolutionSelector] that maps to the specified resolution
  /// preset for camera [UseCase]s.
  ///
  /// If the specified [preset] is unavailable, the camera will fall back to the
  /// closest lower resolution available.
  ResolutionSelector? _getResolutionSelectorFromPreset(
      ResolutionPreset? preset) {
    const int fallbackRule =
        ResolutionStrategy.fallbackRuleClosestLowerThenHigher;

    Size? boundSize;
    ResolutionStrategy? resolutionStrategy;
    switch (preset) {
      case ResolutionPreset.low:
        boundSize = const Size(320, 240);
      case ResolutionPreset.medium:
        boundSize = const Size(720, 480);
      case ResolutionPreset.high:
        boundSize = const Size(1280, 720);
      case ResolutionPreset.veryHigh:
        boundSize = const Size(1920, 1080);
      case ResolutionPreset.ultraHigh:
        boundSize = const Size(3840, 2160);
      case ResolutionPreset.max:
        // Automatically set strategy to choose highest available.
        resolutionStrategy =
            proxy.createResolutionStrategy(highestAvailable: true);
        return proxy.createResolutionSelector(resolutionStrategy);
      case null:
        // If no preset is specified, default to CameraX's default behavior
        // for each UseCase.
        return null;
    }

    resolutionStrategy = proxy.createResolutionStrategy(
        boundSize: boundSize, fallbackRule: fallbackRule);
    return proxy.createResolutionSelector(resolutionStrategy);
  }

  /// Returns the [QualitySelector] that maps to the specified resolution
  /// preset for the camera used only for video capture.
  ///
  /// If the specified [preset] is unavailable, the camera will fall back to the
  /// closest lower resolution available.
  QualitySelector? _getQualitySelectorFromPreset(ResolutionPreset? preset) {
    VideoQuality? videoQuality;
    switch (preset) {
      case ResolutionPreset.low:
      // 240p is not supported by CameraX.
      case ResolutionPreset.medium:
        videoQuality = VideoQuality.SD;
      case ResolutionPreset.high:
        videoQuality = VideoQuality.HD;
      case ResolutionPreset.veryHigh:
        videoQuality = VideoQuality.FHD;
      case ResolutionPreset.ultraHigh:
        videoQuality = VideoQuality.UHD;
      case ResolutionPreset.max:
        videoQuality = VideoQuality.highest;
      case null:
        // If no preset is specified, default to CameraX's default behavior
        // for each UseCase.
        return null;
    }

    // We will choose the next highest video quality if the one desired
    // is unavailable.
    const VideoResolutionFallbackRule fallbackRule =
        VideoResolutionFallbackRule.lowerQualityOrHigherThan;
    final FallbackStrategy fallbackStrategy = proxy.createFallbackStrategy(
        quality: videoQuality, fallbackRule: fallbackRule);

    return proxy.createQualitySelector(
        videoQuality: videoQuality, fallbackStrategy: fallbackStrategy);
  }

  // Methods for configuring auto-focus and auto-exposure:

  /// Starts a focus and metering action.
  ///
  /// This method will modify and start the current action's metering points
  /// overriden with the [point] provided for the specified [meteringMode] type
  /// only, with all other points of other modes left untouched. Thus, the
  /// focus and metering action started will contain only the one most recently
  /// set point for each metering mode: AF, AE, AWB.
  ///
  /// Thus, if [point] is non-null, this action includes:
  ///   * metering points and their modes previously added to
  ///     [currentFocusMeteringAction] that do not share a metering mode with
  ///     [point] and
  ///   * [point] with the specified [meteringMode].
  /// If [point] is null, this action includes only metering points and
  /// their modes previously added to [currentFocusMeteringAction] that do not
  /// share a metering mode with [point]. If there are no such metering
  /// points, then the previously enabled focus and metering actions will be
  /// canceled.
  Future<void> _startFocusAndMeteringFor(
      {required Point<double>? point, required int meteringMode}) async {
    if (point == null) {
      // Try to clear any metering point from previous action with the specified
      // meteringMode.
      if (currentFocusMeteringAction == null) {
        // Attempting to clear a metering point from a previous action, but no
        // such action exists.
        return;
      }

      // Remove metering point with specified meteringMode from current focus
      // and metering action, as only one focus or exposure point may be set
      // at once in this plugin.
      final List<(MeteringPoint, int?)> newMeteringPointInfos =
          currentFocusMeteringAction!.meteringPointInfos
              .where(((MeteringPoint, int?) meteringPointInfo) =>
                  // meteringPointInfo may technically include points without a
                  // mode specified, but this logic is safe because this plugin
                  // only uses points that explicitly have mode
                  // FocusMeteringAction.flagAe or FocusMeteringAction.flagAf.
                  meteringPointInfo.$2 != meteringMode)
              .toList();

      if (newMeteringPointInfos.isEmpty) {
        // If no other metering points were specified, cancel any previously
        // started focus and metering actions.
        await cameraControl.cancelFocusAndMetering();
        currentFocusMeteringAction = null;
        return;
      }
      currentFocusMeteringAction =
          proxy.createFocusMeteringAction(newMeteringPointInfos);
    } else if (point.x < 0 || point.x > 1 || point.y < 0 || point.y > 1) {
      throw CameraException('pointInvalid',
          'The coordinates of a metering point for an auto-focus or auto-exposure action must be within (0,0) and (1,1), but point $point was provided for metering mode $meteringMode.');
    } else {
      // Add new metering point with specified meteringMode, which may involve
      // replacing a metering point with the same specified meteringMode from
      // the current focus and metering action.
      List<(MeteringPoint, int?)> newMeteringPointInfos =
          <(MeteringPoint, int?)>[];

      if (currentFocusMeteringAction != null) {
        newMeteringPointInfos = currentFocusMeteringAction!.meteringPointInfos
            .where(((MeteringPoint, int?) meteringPointInfo) =>
                // meteringPointInfo may technically include points without a
                // mode specified, but this logic is safe because this plugin
                // only uses points that explicitly have mode
                // FocusMeteringAction.flagAe or FocusMeteringAction.flagAf.
                meteringPointInfo.$2 != meteringMode)
            .toList();
      }
      final MeteringPoint newMeteringPoint =
          proxy.createMeteringPoint(point.x, point.y, cameraInfo!);
      newMeteringPointInfos.add((newMeteringPoint, meteringMode));
      currentFocusMeteringAction =
          proxy.createFocusMeteringAction(newMeteringPointInfos);
    }

    await cameraControl.startFocusAndMetering(currentFocusMeteringAction!);
  }
}
