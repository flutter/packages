import 'camerax_library2.g.dart';

/// Handles constructing objects and calling static methods for the Android
/// Interactive Media Ads native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Android classes.
///
/// By default each function calls the default constructor of the class it
/// intends to return.
class CameraXProxy {
  /// Constructs an [CameraXProxy].
  const CameraXProxy({
    this.newCameraSize = CameraSize.new,
    this.newResolutionInfo = ResolutionInfo.new,
    this.newCameraIntegerRange = CameraIntegerRange.new,
    this.newMeteringPoint = MeteringPoint.new,
    this.withSizeMeteringPoint = MeteringPoint.withSize,
    this.newObserver = Observer.new,
    this.newCameraSelector = CameraSelector.new,
    this.newPreview = Preview.new,
    this.withOutputVideoCapture = VideoCapture.withOutput,
    this.newRecorder = Recorder.new,
    this.newVideoRecordEventListener = VideoRecordEventListener.new,
    this.newImageCapture = ImageCapture.new,
    this.newResolutionStrategy = ResolutionStrategy.new,
    this.newResolutionSelector = ResolutionSelector.new,
    this.newAspectRatioStrategy = AspectRatioStrategy.new,
    this.newImageAnalysis = ImageAnalysis.new,
    this.newAnalyzer = Analyzer.new,
    this.fromQualitySelector = QualitySelector.from,
    this.fromOrderedListQualitySelector = QualitySelector.fromOrderedList,
    this.higherQualityOrLowerThanFallbackStrategy =
        FallbackStrategy.higherQualityOrLowerThan,
    this.higherQualityThanFallbackStrategy = FallbackStrategy.higherQualityThan,
    this.lowerQualityOrHigherThanFallbackStrategy =
        FallbackStrategy.lowerQualityOrHigherThan,
    this.lowerQualityThanFallbackStrategy = FallbackStrategy.lowerQualityThan,
    this.newCaptureRequestOptions = CaptureRequestOptions.new,
    this.fromCamera2CameraControl = Camera2CameraControl.from,
    this.createWithOnePreferredSizeResolutionFilter =
        ResolutionFilter.createWithOnePreferredSize,
    this.fromCamera2CameraInfo = Camera2CameraInfo.from,
    this.newDisplayOrientedMeteringPointFactory =
        DisplayOrientedMeteringPointFactory.new,
    this.getInstanceProcessCameraProvider = ProcessCameraProvider.getInstance,
    this.getResolutionQualitySelector = QualitySelector.getResolution,
    this.defaultBackCameraCameraSelector = _defaultBackCameraCameraSelector,
    this.defaultFrontCameraCameraSelector = _defaultFrontCameraCameraSelector,
    this.highestAvailableStrategyResolutionStrategy =
        _highestAvailableStrategyResolutionStrategy,
    this.ratio_16_9FallbackAutoStrategyAspectRatioStrategy =
        _ratio_16_9FallbackAutoStrategyAspectRatioStrategy,
    this.ratio_4_3FallbackAutoStrategyAspectRatioStrategy =
        _ratio_4_3FallbackAutoStrategyAspectRatioStrategy,
    this.controlAELockCaptureRequest = _controlAELockCaptureRequest,
    this.infoSupportedHardwareLevelCameraCharacteristics =
        _infoSupportedHardwareLevelCameraCharacteristics,
    this.sensorOrientationCameraCharacteristics =
        _sensorOrientationCameraCharacteristics,
  });

  /// Constructs [CameraSize].
  final CameraSize Function({
    required int width,
    required int height,
  }) newCameraSize;

  /// Constructs [ResolutionInfo].
  final ResolutionInfo Function({required CameraSize resolution})
      newResolutionInfo;

  /// Constructs [CameraIntegerRange].
  final CameraIntegerRange Function({
    required int lower,
    required int upper,
  }) newCameraIntegerRange;

  /// Constructs [MeteringPoint].
  final MeteringPoint Function({
    required double x,
    required double y,
  }) newMeteringPoint;

  /// Constructs [MeteringPoint].
  final MeteringPoint Function({
    required double x,
    required double y,
    required double size,
  }) withSizeMeteringPoint;

  /// Constructs [Observer].
  final Observer Function({
    required void Function(
      Observer,
      Object,
    ) onChanged,
    required LiveDataSupportedType type,
  }) newObserver;

  /// Constructs [CameraSelector].
  final CameraSelector Function({LensFacing? requireLensFacing})
      newCameraSelector;

  /// Constructs [Preview].
  final Preview Function({
    int? targetRotation,
    ResolutionSelector? resolutionSelector,
  }) newPreview;

  /// Constructs [VideoCapture].
  final VideoCapture Function({required VideoOutput videoOutput})
      withOutputVideoCapture;

  /// Constructs [Recorder].
  final Recorder Function({
    int? aspectRatio,
    int? targetVideoEncodingBitRate,
    QualitySelector? qualitySelector,
  }) newRecorder;

  /// Constructs [VideoRecordEventListener].
  final VideoRecordEventListener Function(
      {required void Function(
        VideoRecordEventListener,
        VideoRecordEvent,
      ) onEvent}) newVideoRecordEventListener;

  /// Constructs [ImageCapture].
  final ImageCapture Function({
    int? targetRotation,
    FlashMode? flashMode,
    ResolutionSelector? resolutionSelector,
  }) newImageCapture;

  /// Constructs [ResolutionStrategy].
  final ResolutionStrategy Function({
    required CameraSize boundSize,
    required ResolutionStrategyFallbackRule fallbackRule,
  }) newResolutionStrategy;

  /// Constructs [ResolutionSelector].
  final ResolutionSelector Function({
    AspectRatioStrategy? aspectRatioStrategy,
    ResolutionStrategy? resolutionStrategy,
    ResolutionFilter? resolutionFilter,
  }) newResolutionSelector;

  /// Constructs [AspectRatioStrategy].
  final AspectRatioStrategy Function({
    required int preferredAspectRatio,
    required AspectRatioStrategyFallbackRule fallbackRule,
  }) newAspectRatioStrategy;

  /// Constructs [ImageAnalysis].
  final ImageAnalysis Function({
    int? targetRotation,
    ResolutionSelector? resolutionSelector,
  }) newImageAnalysis;

  /// Constructs [Analyzer].
  final Analyzer Function(
      {required void Function(
        Analyzer,
        ImageProxy,
      ) analyze}) newAnalyzer;

  /// Constructs [QualitySelector].
  final QualitySelector Function({
    required VideoQuality quality,
    FallbackStrategy? fallbackStrategy,
  }) fromQualitySelector;

  /// Constructs [QualitySelector].
  final QualitySelector Function({
    required List<VideoQuality> qualities,
    FallbackStrategy? fallbackStrategy,
  }) fromOrderedListQualitySelector;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({required VideoQuality quality})
      higherQualityOrLowerThanFallbackStrategy;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({required VideoQuality quality})
      higherQualityThanFallbackStrategy;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({required VideoQuality quality})
      lowerQualityOrHigherThanFallbackStrategy;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({required VideoQuality quality})
      lowerQualityThanFallbackStrategy;

  /// Constructs [CaptureRequestOptions].
  final CaptureRequestOptions Function(
          {required Map<CaptureRequestKey, Object?> options})
      newCaptureRequestOptions;

  /// Constructs [Camera2CameraControl].
  final Camera2CameraControl Function({required CameraControl cameraControl})
      fromCamera2CameraControl;

  /// Constructs [ResolutionFilter].
  final ResolutionFilter Function({required CameraSize preferredSize})
      createWithOnePreferredSizeResolutionFilter;

  /// Constructs [Camera2CameraInfo].
  final Camera2CameraInfo Function({required CameraInfo cameraInfo})
      fromCamera2CameraInfo;

  /// Constructs [DisplayOrientedMeteringPointFactory].
  final DisplayOrientedMeteringPointFactory Function({
    required CameraInfo cameraInfo,
    required double width,
    required double height,
  }) newDisplayOrientedMeteringPointFactory;

  /// Calls to [ProcessCameraProvider.getInstance].
  final Future<ProcessCameraProvider> Function()
      getInstanceProcessCameraProvider;

  /// Calls to [QualitySelector.getResolution].
  final Future<CameraSize?> Function(
    CameraInfo,
    VideoQuality,
  ) getResolutionQualitySelector;

  /// Calls to [CameraSelector.defaultBackCamera].
  final CameraSelector Function() defaultBackCameraCameraSelector;

  /// Calls to [CameraSelector.defaultFrontCamera].
  final CameraSelector Function() defaultFrontCameraCameraSelector;

  /// Calls to [ResolutionStrategy.highestAvailableStrategy].
  final ResolutionStrategy Function()
      highestAvailableStrategyResolutionStrategy;

  /// Calls to [AspectRatioStrategy.ratio_16_9FallbackAutoStrategy].
  final AspectRatioStrategy Function()
      ratio_16_9FallbackAutoStrategyAspectRatioStrategy;

  /// Calls to [AspectRatioStrategy.ratio_4_3FallbackAutoStrategy].
  final AspectRatioStrategy Function()
      ratio_4_3FallbackAutoStrategyAspectRatioStrategy;

  /// Calls to [CaptureRequest.controlAELock].
  final CaptureRequestKey Function() controlAELockCaptureRequest;

  /// Calls to [CameraCharacteristics.infoSupportedHardwareLevel].
  final CameraCharacteristicsKey Function()
      infoSupportedHardwareLevelCameraCharacteristics;

  /// Calls to [CameraCharacteristics.sensorOrientation].
  final CameraCharacteristicsKey Function()
      sensorOrientationCameraCharacteristics;

  static CameraSelector _defaultBackCameraCameraSelector() =>
      CameraSelector.defaultBackCamera;

  static CameraSelector _defaultFrontCameraCameraSelector() =>
      CameraSelector.defaultFrontCamera;

  static ResolutionStrategy _highestAvailableStrategyResolutionStrategy() =>
      ResolutionStrategy.highestAvailableStrategy;

  static AspectRatioStrategy
      _ratio_16_9FallbackAutoStrategyAspectRatioStrategy() =>
          AspectRatioStrategy.ratio_16_9FallbackAutoStrategy;

  static AspectRatioStrategy
      _ratio_4_3FallbackAutoStrategyAspectRatioStrategy() =>
          AspectRatioStrategy.ratio_4_3FallbackAutoStrategy;

  static CaptureRequestKey _controlAELockCaptureRequest() =>
      CaptureRequest.controlAELock;

  static CameraCharacteristicsKey
      _infoSupportedHardwareLevelCameraCharacteristics() =>
          CameraCharacteristics.infoSupportedHardwareLevel;

  static CameraCharacteristicsKey _sensorOrientationCameraCharacteristics() =>
      CameraCharacteristics.sensorOrientation;
}
