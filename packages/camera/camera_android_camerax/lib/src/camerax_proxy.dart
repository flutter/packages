// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show Size;

import 'analyzer.dart';
import 'camera_selector.dart';
import 'camera_state.dart';
import 'camerax_library.g.dart';
import 'fallback_strategy.dart';
import 'image_analysis.dart';
import 'image_capture.dart';
import 'image_proxy.dart';
import 'observer.dart';
import 'preview.dart';
import 'process_camera_provider.dart';
import 'quality_selector.dart';
import 'recorder.dart';
import 'resolution_selector.dart';
import 'resolution_strategy.dart';
import 'system_services.dart';
import 'video_capture.dart';

/// Handles constructing objects and calling static methods for the CameraX
/// implementation of the camera plugin on Android.
///
/// By default, each function will create objects attached to an
/// `InstanceManager` and call through to the appropriate static methods.
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
  });

  /// Returns a [ProcessCameraProvider] instance.
  Future<ProcessCameraProvider> Function() getProcessCameraProvider;

  /// Returns a [CameraSelector] based on the specified camera lens direction.
  CameraSelector Function(int cameraSelectorLensDirection) createCameraSelector;

  /// Returns a [Preview] configured with the specified target rotation and
  /// specified [ResolutionSelector].
  Preview Function(
      {required int targetRotation,
      ResolutionSelector? resolutionSelector}) createPreview;

  /// Returns an [ImageCapture] configured with specified flash mode and
  /// the specified [ResolutionSelector].
  ImageCapture Function(ResolutionSelector? resolutionSelector)
      createImageCapture;

  /// Returns a [Recorder] for use in video capture configured with the
  /// specified [QualitySelector].
  Recorder Function(QualitySelector? qualitySelector) createRecorder;

  /// Returns a [VideoCapture] associated with the provided [Recorder].
  Future<VideoCapture> Function(Recorder recorder) createVideoCapture;

  /// Returns an [ImageAnalysis] configured with the specified
  /// [ResolutionSelector].
  ImageAnalysis Function(ResolutionSelector? resolutionSelector)
      createImageAnalysis;

  Analyzer Function(Future<void> Function(ImageProxy imageProxy) analyze)
      createAnalyzer;

  Observer<CameraState> Function(void Function(Object stateAsObject) onChanged)
      createCameraStateObserver;

  ResolutionStrategy Function(
      {bool highestAvailable,
      Size? boundSize,
      int? fallbackRule}) createResolutionStrategy;

  ResolutionSelector Function(ResolutionStrategy resolutionStrategy)
      createResolutionSelector;

  FallbackStrategy Function(
          {required VideoQuality quality,
          required VideoResolutionFallbackRule fallbackRule})
      createFallbackStrategy;

  QualitySelector Function(
      {required VideoQuality videoQuality,
      required FallbackStrategy fallbackStrategy}) createQualitySelector;

  /// Requests camera permissions.
  Future<void> Function(bool enableAudio) requestCameraPermissions;

  /// Subscribes the plugin as a listener to changes in device orientation.
  void Function(bool cameraIsFrontFacing, int sensorOrientation)
      startListeningForDeviceOrientationChange;

  // Object creation:

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
      {required int targetRotation, ResolutionSelector? resolutionSelector}) {
    return Preview(
        targetRotation: targetRotation, resolutionSelector: resolutionSelector);
  }

  static ImageCapture _createAttachedImageCapture(
      ResolutionSelector? resolutionSelector) {
    return ImageCapture(resolutionSelector: resolutionSelector);
  }

  static Recorder _createAttachedRecorder(QualitySelector? qualitySelector) {
    return Recorder(qualitySelector: qualitySelector);
  }

  static Future<VideoCapture> _createAttachedVideoCapture(
      Recorder recorder) async {
    return VideoCapture.withOutput(recorder);
  }

  static ImageAnalysis _createAttachedImageAnalysis(
      ResolutionSelector? resolutionSelector) {
    return ImageAnalysis(resolutionSelector: resolutionSelector);
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
      ResolutionStrategy resolutionStrategy) {
    return ResolutionSelector(resolutionStrategy: resolutionStrategy);
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

  // Static methods:

  static Future<void> _requestCameraPermissions(bool enableAudio) async {
    await SystemServices.requestCameraPermissions(enableAudio);
  }

  static void _startListeningForDeviceOrientationChange(
      bool cameraIsFrontFacing, int sensorOrientation) {
    SystemServices.startListeningForDeviceOrientationChange(
        cameraIsFrontFacing, sensorOrientation);
  }
}
