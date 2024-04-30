// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show Size;

import 'analyzer.dart';
import 'aspect_ratio_strategy.dart';
import 'camera2_camera_control.dart';
import 'camera_control.dart';
import 'camera_info.dart';
import 'camera_selector.dart';
import 'camera_state.dart';
import 'camerax_library.g.dart';
import 'capture_request_options.dart';
import 'device_orientation_manager.dart';
import 'fallback_strategy.dart';
import 'focus_metering_action.dart';
import 'image_analysis.dart';
import 'image_capture.dart';
import 'image_proxy.dart';
import 'metering_point.dart';
import 'observer.dart';
import 'preview.dart';
import 'process_camera_provider.dart';
import 'quality_selector.dart';
import 'recorder.dart';
import 'resolution_filter.dart';
import 'resolution_selector.dart';
import 'resolution_strategy.dart';
import 'system_services.dart';
import 'video_capture.dart';

/// Handles `JavaObject` creation and calling their methods that require
/// testing.
///
/// By default, each function will create `JavaObject`s attached to an
/// `InstanceManager` and call through to the appropriate method.
class CameraXProxy {
  /// Constructs a [CameraXProxy].
  CameraXProxy({
    this.getProcessCameraProvider = _getProcessCameraProvider,
    this.createCameraSelector = _createAttachedCameraSelector,
    this.createPreview = _createAttachedPreview,
    this.createImageCapture = _createAttachedImageCapture,
    this.createRecorder = _createAttachedRecorder,
    this.createVideoCapture = _createAttachedVideoCapture,
    this.createImageAnalysis = _createAttachedImageAnalysis,
    this.createAnalyzer = _createAttachedAnalyzer,
    this.createCameraStateObserver = _createAttachedCameraStateObserver,
    this.createResolutionStrategy = _createAttachedResolutionStrategy,
    this.createResolutionSelector = _createAttachedResolutionSelector,
    this.createFallbackStrategy = _createAttachedFallbackStrategy,
    this.createQualitySelector = _createAttachedQualitySelector,
    this.requestCameraPermissions = _requestCameraPermissions,
    this.startListeningForDeviceOrientationChange =
        _startListeningForDeviceOrientationChange,
    this.setPreviewSurfaceProvider = _setPreviewSurfaceProvider,
    this.getDefaultDisplayRotation = _getDefaultDisplayRotation,
    this.getCamera2CameraControl = _getCamera2CameraControl,
    this.createCaptureRequestOptions = _createAttachedCaptureRequestOptions,
    this.createMeteringPoint = _createAttachedMeteringPoint,
    this.createFocusMeteringAction = _createAttachedFocusMeteringAction,
    this.createAspectRatioStrategy = _createAttachedAspectRatioStrategy,
    this.createResolutionFilterWithOnePreferredSize =
        _createAttachedResolutionFilterWithOnePreferredSize,
  });

  /// Returns a [ProcessCameraProvider] instance.
  Future<ProcessCameraProvider> Function() getProcessCameraProvider;

  /// Returns a [CameraSelector] based on the specified camera lens direction.
  CameraSelector Function(int cameraSelectorLensDirection) createCameraSelector;

  /// Returns a [Preview] configured with the specified target rotation and
  /// specified [ResolutionSelector].
  Preview Function(
    ResolutionSelector? resolutionSelector,
    int? targetRotation,
  ) createPreview;

  /// Returns an [ImageCapture] configured with specified flash mode and
  /// the specified [ResolutionSelector].
  ImageCapture Function(
          ResolutionSelector? resolutionSelector, int? targetRotation)
      createImageCapture;

  /// Returns a [Recorder] for use in video capture configured with the
  /// specified [QualitySelector].
  Recorder Function(QualitySelector? qualitySelector) createRecorder;

  /// Returns a [VideoCapture] associated with the provided [Recorder].
  Future<VideoCapture> Function(Recorder recorder) createVideoCapture;

  /// Returns an [ImageAnalysis] configured with the specified
  /// [ResolutionSelector].
  ImageAnalysis Function(
          ResolutionSelector? resolutionSelector, int? targetRotation)
      createImageAnalysis;

  /// Returns an [Analyzer] configured with the specified callback for
  /// analyzing [ImageProxy]s.
  Analyzer Function(Future<void> Function(ImageProxy imageProxy) analyze)
      createAnalyzer;

  /// Returns an [Observer] of the [CameraState] with the specified callback
  /// for handling changes in that state.
  Observer<CameraState> Function(void Function(Object stateAsObject) onChanged)
      createCameraStateObserver;

  /// Returns a [ResolutionStrategy] configured with the specified bounds for
  /// choosing a resolution and a fallback rule if achieving a resolution within
  /// those bounds is not possible.
  ///
  /// [highestAvailable] is used to specify whether or not the highest available
  /// [ResolutionStrategy] should be returned.
  ResolutionStrategy Function(
      {bool highestAvailable,
      Size? boundSize,
      int? fallbackRule}) createResolutionStrategy;

  /// Returns a [ResolutionSelector] configured with the specified
  /// [ResolutionStrategy], [ResolutionFilter], and [AspectRatioStrategy].
  ResolutionSelector Function(
      ResolutionStrategy resolutionStrategy,
      ResolutionFilter? resolutionFilter,
      AspectRatioStrategy? aspectRatioStrategy) createResolutionSelector;

  /// Returns a [FallbackStrategy] configured with the specified [VideoQuality]
  /// and [VideoResolutionFallbackRule].
  FallbackStrategy Function(
          {required VideoQuality quality,
          required VideoResolutionFallbackRule fallbackRule})
      createFallbackStrategy;

  /// Returns a [QualitySelector] configured with the specified [VideoQuality]
  /// and [FallbackStrategy].
  QualitySelector Function(
      {required VideoQuality videoQuality,
      required FallbackStrategy fallbackStrategy}) createQualitySelector;

  /// Requests camera permissions.
  Future<void> Function(bool enableAudio) requestCameraPermissions;

  /// Subscribes the plugin as a listener to changes in device orientation.
  void Function(bool cameraIsFrontFacing, int sensorOrientation)
      startListeningForDeviceOrientationChange;

  /// Sets the surface provider of the specified [Preview] instance and returns
  /// the ID corresponding to the surface it will provide.
  Future<int> Function(Preview preview) setPreviewSurfaceProvider;

  /// Returns default rotation for [UseCase]s in terms of one of the [Surface]
  /// rotation constants.
  Future<int> Function() getDefaultDisplayRotation;

  /// Get [Camera2CameraControl] instance from [cameraControl].
  Camera2CameraControl Function(CameraControl cameraControl)
      getCamera2CameraControl;

  /// Creates a [CaptureRequestOptions] with specified options.
  CaptureRequestOptions Function(
          List<(CaptureRequestKeySupportedType, Object?)> options)
      createCaptureRequestOptions;

  /// Returns a [MeteringPoint] with the specified coordinates based on
  /// [cameraInfo].
  MeteringPoint Function(
          double x, double y, double? size, CameraInfo cameraInfo)
      createMeteringPoint;

  /// Returns a [FocusMeteringAction] based on the specified metering points
  /// and their modes.
  FocusMeteringAction Function(List<(MeteringPoint, int?)> meteringPointInfos,
      bool? disableAutoCancel) createFocusMeteringAction;

  /// Creates an [AspectRatioStrategy] with specified aspect ratio and fallback
  /// rule.
  AspectRatioStrategy Function(int aspectRatio, int fallbackRule)
      createAspectRatioStrategy;

  /// Creates a [ResolutionFilter] that prioritizes specified resolution.
  ResolutionFilter Function(Size preferredResolution)
      createResolutionFilterWithOnePreferredSize;

  static Future<ProcessCameraProvider> _getProcessCameraProvider() {
    return ProcessCameraProvider.getInstance();
  }

  static CameraSelector _createAttachedCameraSelector(
      int cameraSelectorLensDirection) {
    switch (cameraSelectorLensDirection) {
      case CameraSelector.lensFacingFront:
        return CameraSelector.getDefaultFrontCamera();
      case CameraSelector.lensFacingBack:
        return CameraSelector.getDefaultBackCamera();
      default:
        return CameraSelector(lensFacing: cameraSelectorLensDirection);
    }
  }

  static Preview _createAttachedPreview(
      ResolutionSelector? resolutionSelector, int? targetRotation) {
    return Preview(
        initialTargetRotation: targetRotation,
        resolutionSelector: resolutionSelector);
  }

  static ImageCapture _createAttachedImageCapture(
      ResolutionSelector? resolutionSelector, int? targetRotation) {
    return ImageCapture(
        resolutionSelector: resolutionSelector,
        initialTargetRotation: targetRotation);
  }

  static Recorder _createAttachedRecorder(QualitySelector? qualitySelector) {
    return Recorder(qualitySelector: qualitySelector);
  }

  static Future<VideoCapture> _createAttachedVideoCapture(
      Recorder recorder) async {
    return VideoCapture.withOutput(recorder);
  }

  static ImageAnalysis _createAttachedImageAnalysis(
      ResolutionSelector? resolutionSelector, int? targetRotation) {
    return ImageAnalysis(
        resolutionSelector: resolutionSelector,
        initialTargetRotation: targetRotation);
  }

  static Analyzer _createAttachedAnalyzer(
      Future<void> Function(ImageProxy imageProxy) analyze) {
    return Analyzer(analyze: analyze);
  }

  static Observer<CameraState> _createAttachedCameraStateObserver(
      void Function(Object stateAsObject) onChanged) {
    return Observer<CameraState>(onChanged: onChanged);
  }

  static ResolutionStrategy _createAttachedResolutionStrategy(
      {bool highestAvailable = false, Size? boundSize, int? fallbackRule}) {
    if (highestAvailable) {
      return ResolutionStrategy.highestAvailableStrategy();
    }

    return ResolutionStrategy(
        boundSize: boundSize!, fallbackRule: fallbackRule);
  }

  static ResolutionSelector _createAttachedResolutionSelector(
      ResolutionStrategy resolutionStrategy,
      ResolutionFilter? resolutionFilter,
      AspectRatioStrategy? aspectRatioStrategy) {
    return ResolutionSelector(
        resolutionStrategy: resolutionStrategy,
        resolutionFilter: resolutionFilter,
        aspectRatioStrategy: aspectRatioStrategy);
  }

  static FallbackStrategy _createAttachedFallbackStrategy(
      {required VideoQuality quality,
      required VideoResolutionFallbackRule fallbackRule}) {
    return FallbackStrategy(quality: quality, fallbackRule: fallbackRule);
  }

  static QualitySelector _createAttachedQualitySelector(
      {required VideoQuality videoQuality,
      required FallbackStrategy fallbackStrategy}) {
    return QualitySelector.from(
        quality: VideoQualityData(quality: videoQuality),
        fallbackStrategy: fallbackStrategy);
  }

  static Future<void> _requestCameraPermissions(bool enableAudio) async {
    await SystemServices.requestCameraPermissions(enableAudio);
  }

  static void _startListeningForDeviceOrientationChange(
      bool cameraIsFrontFacing, int sensorOrientation) {
    DeviceOrientationManager.startListeningForDeviceOrientationChange(
        cameraIsFrontFacing, sensorOrientation);
  }

  static Future<int> _setPreviewSurfaceProvider(Preview preview) async {
    return preview.setSurfaceProvider();
  }

  static Future<int> _getDefaultDisplayRotation() async {
    return DeviceOrientationManager.getDefaultDisplayRotation();
  }

  static Camera2CameraControl _getCamera2CameraControl(
      CameraControl cameraControl) {
    return Camera2CameraControl(cameraControl: cameraControl);
  }

  static CaptureRequestOptions _createAttachedCaptureRequestOptions(
      List<(CaptureRequestKeySupportedType, Object?)> options) {
    return CaptureRequestOptions(requestedOptions: options);
  }

  static MeteringPoint _createAttachedMeteringPoint(
      double x, double y, double? size, CameraInfo cameraInfo) {
    return MeteringPoint(x: x, y: y, size: size, cameraInfo: cameraInfo);
  }

  static FocusMeteringAction _createAttachedFocusMeteringAction(
      List<(MeteringPoint, int?)> meteringPointInfos, bool? disableAutoCancel) {
    return FocusMeteringAction(
        meteringPointInfos: meteringPointInfos,
        disableAutoCancel: disableAutoCancel);
  }

  static AspectRatioStrategy _createAttachedAspectRatioStrategy(
      int preferredAspectRatio, int fallbackRule) {
    return AspectRatioStrategy(
        preferredAspectRatio: preferredAspectRatio, fallbackRule: fallbackRule);
  }

  static ResolutionFilter _createAttachedResolutionFilterWithOnePreferredSize(
      Size preferredSize) {
    return ResolutionFilter.onePreferredSize(
        preferredResolution: preferredSize);
  }
}
