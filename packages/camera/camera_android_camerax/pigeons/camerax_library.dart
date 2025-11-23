// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    copyrightHeader: 'pigeons/copyright.txt',
    dartOut: 'lib/src/camerax_library.g.dart',
    kotlinOut:
        'android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.camerax',
      errorClassName: 'CameraXError',
    ),
  ),
)
/// Immutable class for describing width and height dimensions in pixels.
///
/// See https://developer.android.com/reference/android/util/Size.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(fullClassName: 'android.util.Size'),
)
abstract class CameraSize {
  CameraSize();

  /// The width of the size (in pixels).
  late int width;

  /// The height of the size (in pixels).
  late int height;
}

/// A `ResolutionInfo` allows the application to know the resolution information
/// of a specific use case.
///
/// See https://developer.android.com/reference/androidx/camera/core/ResolutionInfo.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ResolutionInfo',
  ),
)
abstract class ResolutionInfo {
  /// Returns the output resolution used for the use case.
  late CameraSize resolution;
}

/// Generally classifies the overall set of the camera device functionality.
///
/// See https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_3.
enum InfoSupportedHardwareLevel {
  /// This camera device is capable of YUV reprocessing and RAW data capture, in
  /// addition to FULL-level capabilities.
  level3,

  /// This camera device is backed by an external camera connected to this
  /// Android device.
  external,

  /// This camera device is capable of supporting advanced imaging applications.
  full,

  /// This camera device is running in backward compatibility mode.
  legacy,

  /// This camera device does not have enough capabilities to qualify as a FULL
  /// device or better.
  limited,
}

/// The aspect ratio of the use case.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/AspectRatio.
enum AspectRatio {
  /// 16:9 standard aspect ratio.
  ratio16To9,

  /// 4:3 standard aspect ratio.
  ratio4To3,

  /// The aspect ratio representing no preference for aspect ratio.
  ratioDefault,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// The states the camera can be in.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraState.Type.
enum CameraStateType {
  /// Represents a state where the camera device is closed.
  closed,

  /// Represents a state where the camera device is currently closing.
  closing,

  /// Represents a state where the camera device is open.
  open,

  /// Represents a state where the camera device is currently opening.
  opening,

  /// Represents a state where the camera is waiting for a signal to attempt to
  /// open the camera device.
  pendingOpen,

  /// This value is not recognized by this wrapper.
  unknown,
}

/// The types (T) properly wrapped to be used as a LiveData<T>.
enum LiveDataSupportedType { cameraState, zoomState }

/// Immutable class for describing the range of two integer values.
///
/// This is the equivalent to `android.util.Range<Integer>`.
///
/// See https://developer.android.com/reference/android/util/Range.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(fullClassName: 'android.util.Range<*>'),
)
abstract class CameraIntegerRange {
  CameraIntegerRange();

  /// The lower endpoint.
  late int lower;

  /// The upper endpoint.
  late int upper;
}

/// Video quality constraints that will be used by a QualitySelector to choose
/// an appropriate video resolution.
///
/// These are pre-defined quality constants that are universally used for video.
///
/// See https://developer.android.com/reference/androidx/camera/video/Quality.
enum VideoQuality {
  /// Standard Definition (SD) 480p video quality.
  SD,

  /// High Definition (HD) 720p video quality.
  HD,

  /// Full High Definition (FHD) 1080p video quality.
  FHD,

  /// Ultra High Definition (UHD) 2160p video quality.
  UHD,

  /// The lowest video quality supported by the video frame producer.
  lowest,

  /// The highest video quality supported by the video frame producer.
  highest,
}

/// VideoRecordEvent is used to report video recording events and status.
///
/// See https://developer.android.com/reference/androidx/camera/video/VideoRecordEvent.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.VideoRecordEvent',
  ),
)
abstract class VideoRecordEvent {}

/// Indicates the start of recording.
///
/// See https://developer.android.com/reference/androidx/camera/video/VideoRecordEvent.Start.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.VideoRecordEvent.Start',
  ),
)
abstract class VideoRecordEventStart extends VideoRecordEvent {}

/// Indicates the finalization of recording.
///
/// See https://developer.android.com/reference/androidx/camera/video/VideoRecordEvent.Finalize.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.VideoRecordEvent.Finalize',
  ),
)
abstract class VideoRecordEventFinalize extends VideoRecordEvent {}

/// A MeteringPoint is used to specify a region which can then be converted to
/// sensor coordinate system for focus and metering purpose.
///
/// See https://developer.android.com/reference/androidx/camera/core/MeteringPoint.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.MeteringPoint',
  ),
)
abstract class MeteringPoint {
  /// Size of the MeteringPoint width and height (ranging from 0 to 1).
  ///
  /// It is the percentage of the sensor width/height (or crop region
  /// width/height if crop region is set).
  double getSize();
}

/// A flag used for indicating metering mode regions.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/FocusMeteringAction#FLAG_AF().
enum MeteringMode {
  /// A flag used in metering mode indicating the AE (Auto Exposure) region is
  /// enabled.
  ae,

  /// A flag used in metering mode indicating the AF (Auto Focus) region is
  /// enabled.
  af,

  /// A flag used in metering mode indicating the AWB (Auto White Balance)
  /// region is enabled.
  awb,
}

/// A simple callback that can receive from LiveData.
///
/// See https://developer.android.com/reference/androidx/lifecycle/Observer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.lifecycle.Observer<*>',
  ),
)
abstract class Observer {
  Observer();

  /// Called when the data is changed to value.
  late void Function(Object value) onChanged;
}

/// An interface for retrieving camera information.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraInfo.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.CameraInfo',
  ),
)
abstract class CameraInfo {
  /// Returns the sensor rotation in degrees, relative to the device's "natural"
  /// (default) orientation.
  late int sensorRotationDegrees;

  /// Returns a ExposureState.
  late ExposureState exposureState;

  /// A LiveData of the camera's state.
  LiveData getCameraState();

  /// A LiveData of ZoomState.
  LiveData getZoomState();
}

/// Direction of lens of a camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraSelector#LENS_FACING_BACK().
enum LensFacing {
  /// A camera on the device facing the same direction as the device's screen.
  front,

  /// A camera on the device facing the opposite direction as the device's
  /// screen.
  back,

  /// An external camera that has no fixed facing relative to the device's
  /// screen.
  external,

  /// A camera on the devices that its lens facing is resolved.
  unknown,
}

/// A set of requirements and priorities used to select a camera or return a
/// filtered set of cameras.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraSelector.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.CameraSelector',
  ),
)
abstract class CameraSelector {
  CameraSelector(
    LensFacing? requireLensFacing,
    CameraInfo? cameraInfoForFilter,
  );

  /// A static `CameraSelector` that selects the default back facing camera.
  @static
  late CameraSelector defaultBackCamera;

  /// A static `CameraSelector` that selects the default front facing camera.
  @static
  late CameraSelector defaultFrontCamera;

  /// Filters the input `CameraInfo`s using the `CameraFilter`s assigned to the
  /// selector.
  List<CameraInfo> filter(List<CameraInfo> cameraInfos);
}

/// A singleton which can be used to bind the lifecycle of cameras to any
/// `LifecycleOwner` within an application's process.
///
/// See https://developer.android.com/reference/androidx/camera/lifecycle/ProcessCameraProvider.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.lifecycle.ProcessCameraProvider',
  ),
)
abstract class ProcessCameraProvider {
  /// Retrieves the ProcessCameraProvider associated with the current process.
  @async
  @static
  ProcessCameraProvider getInstance();

  /// The `CameraInfo` instances of the available cameras.
  List<CameraInfo> getAvailableCameraInfos();

  /// Binds the collection of `UseCase` to a `LifecycleOwner`.
  Camera bindToLifecycle(CameraSelector cameraSelector, List<UseCase> useCases);

  /// Returns true if the `UseCase` is bound to a lifecycle.
  bool isBound(UseCase useCase);

  /// Unbinds all specified use cases from the lifecycle provider.
  void unbind(List<UseCase> useCases);

  /// Unbinds all use cases from the lifecycle provider and removes them from
  /// CameraX.
  void unbindAll();
}

/// The use case which all other use cases are built on top of.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/UseCase.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.UseCase',
  ),
)
abstract class UseCase {}

/// The camera interface is used to control the flow of data to use cases,
/// control the camera via the `CameraControl`, and publish the state of the
/// camera via CameraInfo.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/Camera.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.Camera',
  ),
)
abstract class Camera {
  /// The `CameraControl` for the Camera.
  late CameraControl cameraControl;

  /// Returns information about this camera.
  CameraInfo getCameraInfo();
}

/// Convenience class for accessing system resources.
@ProxyApi()
abstract class SystemServicesManager {
  SystemServicesManager();

  late void Function(String errorDescription) onCameraError;

  @async
  CameraPermissionsError? requestCameraPermissions(bool enableAudio);

  /// Returns a path to be used to create a temp file in the current cache
  /// directory.
  String getTempFilePath(String prefix, String suffix);
}

/// Contains data when an attempt to retrieve camera permissions fails.
@ProxyApi()
abstract class CameraPermissionsError {
  late final String errorCode;
  late final String description;
}

/// Support class to help to determine the media orientation based on the
/// orientation of the device.
@ProxyApi()
abstract class DeviceOrientationManager {
  DeviceOrientationManager();

  late void Function(String orientation) onDeviceOrientationChanged;

  void startListeningForDeviceOrientationChange();

  void stopListeningForDeviceOrientationChange();

  int getDefaultDisplayRotation();

  String getUiOrientation();
}

/// A use case that provides a camera preview stream for displaying on-screen.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/Preview.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.Preview',
  ),
)
abstract class Preview extends UseCase {
  Preview(int? targetRotation, CameraIntegerRange? targetFpsRange);

  late final ResolutionSelector? resolutionSelector;

  /// Sets a SurfaceProvider to provide a Surface for Preview.
  ///
  /// This is a convenience function that
  /// 1. Creates a `SurfaceProvider` using the `SurfaceProducer` provided by the
  /// Flutter engine.
  /// 2. Sets this method with the created `SurfaceProvider`.
  /// 3. Returns the texture id of the `TextureEntry` that provided the
  /// `SurfaceProducer`.
  int setSurfaceProvider(SystemServicesManager systemServicesManager);

  /// Releases the `SurfaceProducer` created in `setSurfaceProvider` if one was
  /// created.
  void releaseSurfaceProvider();

  /// Gets selected resolution information of the `Preview`.
  ResolutionInfo? getResolutionInfo();

  /// Sets the target rotation.
  void setTargetRotation(int rotation);

  /// Returns whether or not the preview's surface producer handles correctly
  /// rotating the camera preview automatically.
  bool surfaceProducerHandlesCropAndRotation();
}

/// A use case that provides camera stream suitable for video application.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/video/VideoCapture.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.VideoCapture<*>',
  ),
)
abstract class VideoCapture extends UseCase {
  /// Create a `VideoCapture` associated with the given `VideoOutput`.
  VideoCapture.withOutput(
    VideoOutput videoOutput,
    CameraIntegerRange? targetFpsRange,
  );

  /// Gets the VideoOutput associated with this VideoCapture.
  VideoOutput getOutput();

  /// Sets the desired rotation of the output video.
  void setTargetRotation(int rotation);
}

/// A class that will produce video data from a Surface.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/video/VideoOutput.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.VideoOutput',
  ),
)
abstract class VideoOutput {}

/// An implementation of `VideoOutput` for starting video recordings that are
/// saved to a File, ParcelFileDescriptor, or MediaStore.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/video/Recorder.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.Recorder',
  ),
)
abstract class Recorder implements VideoOutput {
  Recorder(
    int? aspectRatio,
    int? targetVideoEncodingBitRate,
    QualitySelector? qualitySelector,
  );

  /// Gets the aspect ratio of this Recorder.
  int getAspectRatio();

  /// Gets the target video encoding bitrate of this Recorder.
  int getTargetVideoEncodingBitRate();

  /// The quality selector of this Recorder.
  QualitySelector getQualitySelector();

  /// Prepares a recording that will be saved to a File.
  PendingRecording prepareRecording(String path);
}

/// Listens for `VideoRecordEvent`s from a `PendingRecording`.
@ProxyApi()
abstract class VideoRecordEventListener {
  VideoRecordEventListener();

  late void Function(VideoRecordEvent event) onEvent;
}

/// A recording that can be started at a future time.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/video/PendingRecording.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.PendingRecording',
  ),
)
abstract class PendingRecording {
  /// Enables/disables audio to be recorded for this recording.
  PendingRecording withAudioEnabled(bool initialMuted);

  /// Configures the recording to be a persistent recording.
  ///
  /// A persistent recording will only be stopped by explicitly calling [Recording.stop] or [Recording.close]
  /// and will ignore events that would normally cause recording to stop, such as lifecycle events
  /// or explicit unbinding of a [VideoCapture] use case that the recording's Recorder is attached to.
  ///
  /// To switch to a different camera stream while a recording is in progress,
  /// first create the recording as persistent recording,
  /// then rebind the [VideoCapture] it's associated with to a different camera.
  PendingRecording asPersistentRecording();

  /// Starts the recording, making it an active recording.
  Recording start(VideoRecordEventListener listener);
}

/// Provides controls for the currently active recording.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/video/Recording.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.Recording',
  ),
)
abstract class Recording {
  /// Close this recording.
  void close();

  /// Pauses the current recording if active.
  void pause();

  /// Resumes the current recording if paused.
  void resume();

  /// Stops the recording, as if calling `close`.
  ///
  /// This method is equivalent to calling `close`.
  void stop();
}

/// FlashModes for image capture.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/ImageCapture#FLASH_MODE_AUTO().
enum CameraXFlashMode {
  /// Auto flash.
  ///
  /// The flash will be used according to the camera system's determination when
  /// taking a picture.
  auto,

  /// No flash.
  ///
  /// The flash will never be used when taking a picture.
  off,

  /// Always flash.
  ///
  /// The flash will always be used when taking a picture.
  on,
}

/// A use case for taking a picture.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/ImageCapture.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ImageCapture',
  ),
)
abstract class ImageCapture extends UseCase {
  ImageCapture(int? targetRotation, CameraXFlashMode? flashMode);

  late final ResolutionSelector? resolutionSelector;

  /// Set the flash mode.
  void setFlashMode(CameraXFlashMode flashMode);

  /// Captures a new still image for in memory access.
  @async
  String takePicture();

  /// Sets the desired rotation of the output image.
  void setTargetRotation(int rotation);
}

/// Fallback rule for choosing an alternate size when the specified bound size
/// is unavailable.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/resolutionselector/ResolutionStrategy.
enum ResolutionStrategyFallbackRule {
  /// When the specified bound size is unavailable, CameraX falls back to the
  /// closest higher resolution size.
  closestHigher,

  /// When the specified bound size is unavailable, CameraX falls back to select
  /// the closest higher resolution size.
  closestHigherThenLower,

  /// When the specified bound size is unavailable, CameraX falls back to the
  /// closest lower resolution size.
  closestLower,

  /// When the specified bound size is unavailable, CameraX falls back to select
  /// the closest lower resolution size.
  ///
  /// If CameraX still cannot find any available resolution, it will fallback to
  /// select other higher resolutions.
  closestLowerThenHigher,

  /// CameraX doesn't select an alternate size when the specified bound size is
  /// unavailable.
  none,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// The resolution strategy defines the resolution selection sequence to select
/// the best size.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/resolutionselector/ResolutionStrategy.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.resolutionselector.ResolutionStrategy',
  ),
)
abstract class ResolutionStrategy {
  ResolutionStrategy(
    CameraSize boundSize,
    ResolutionStrategyFallbackRule fallbackRule,
  );

  /// A resolution strategy chooses the highest available resolution.
  @static
  late ResolutionStrategy highestAvailableStrategy;

  /// The specified bound size.
  CameraSize? getBoundSize();

  /// The fallback rule for choosing an alternate size when the specified bound
  /// size is unavailable.
  ResolutionStrategyFallbackRule getFallbackRule();
}

/// A set of requirements and priorities used to select a resolution for the
/// `UseCase`.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/resolutionselector/ResolutionSelector.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.resolutionselector.ResolutionSelector',
  ),
)
abstract class ResolutionSelector {
  ResolutionSelector(AspectRatioStrategy? aspectRatioStrategy);

  /// The resolution filter to output the final desired sizes list.
  late final ResolutionFilter? resolutionFilter;

  /// The resolution selection strategy for the `UseCase`.
  late final ResolutionStrategy? resolutionStrategy;

  /// Returns the specified `AspectRatioStrategy`, or
  /// `AspectRatioStrategy.ratio_4_3FallbackAutoStrategy` if none is specified
  /// when creating the ResolutionSelector.
  AspectRatioStrategy getAspectRatioStrategy();
}

/// Fallback rule for choosing the aspect ratio when the preferred aspect ratio
/// is not available.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/resolutionselector/AspectRatioStrategy#FALLBACK_RULE_AUTO().
enum AspectRatioStrategyFallbackRule {
  /// CameraX automatically chooses the next best aspect ratio which contains
  /// the closest field of view (FOV) of the camera sensor, from the remaining
  /// options.
  auto,

  /// CameraX doesn't fall back to select sizes of any other aspect ratio when
  /// this fallback rule is used.
  none,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// The aspect ratio strategy defines the sequence of aspect ratios that are
/// used to select the best size for a particular image.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/resolutionselector/AspectRatioStrategy.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'androidx.camera.core.resolutionselector.AspectRatioStrategy',
  ),
)
abstract class AspectRatioStrategy {
  /// Creates a new AspectRatioStrategy instance, configured with the specified
  /// preferred aspect ratio and fallback rule.
  AspectRatioStrategy(
    AspectRatio preferredAspectRatio,
    AspectRatioStrategyFallbackRule fallbackRule,
  );

  /// The pre-defined aspect ratio strategy that selects sizes with RATIO_16_9
  /// in priority.
  @static
  late AspectRatioStrategy ratio_16_9FallbackAutoStrategy;

  /// The pre-defined default aspect ratio strategy that selects sizes with
  /// RATIO_4_3 in priority.
  @static
  late AspectRatioStrategy ratio_4_3FallbackAutoStrategy;

  /// The specified fallback rule for choosing the aspect ratio when the
  /// preferred aspect ratio is not available.
  AspectRatioStrategyFallbackRule getFallbackRule();

  /// The specified preferred aspect ratio.
  AspectRatio getPreferredAspectRatio();
}

/// Represents the different states the camera can be in.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraState.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.CameraState',
  ),
)
abstract class CameraState {
  /// The camera's state.
  late CameraStateType type;

  /// Potentially returns an error the camera encountered.
  late CameraStateStateError? error;
}

/// An interface which contains the camera exposure related information.
///
/// See https://developer.android.com/reference/androidx/camera/core/ExposureState.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ExposureState',
  ),
)
abstract class ExposureState {
  /// Get the maximum and minimum exposure compensation values for
  /// `CameraControl.setExposureCompensationIndex`.
  late CameraIntegerRange exposureCompensationRange;

  /// Get the smallest step by which the exposure compensation can be changed.
  late double exposureCompensationStep;
}

/// An interface which contains the zoom related information from a camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/ZoomState.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ZoomState',
  ),
)
abstract class ZoomState {
  /// The minimum zoom ratio.
  late double minZoomRatio;

  /// The maximum zoom ratio.
  late double maxZoomRatio;
}

/// A use case providing CPU accessible images for an app to perform image
/// analysis on.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/ImageAnalysis.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ImageAnalysis',
  ),
)
abstract class ImageAnalysis extends UseCase {
  ImageAnalysis(
    int? targetRotation,
    CameraIntegerRange? targetFpsRange,
    int? outputImageFormat,
  );

  late final ResolutionSelector? resolutionSelector;

  /// Sets an analyzer to receive and analyze images.
  void setAnalyzer(Analyzer analyzer);

  /// Removes a previously set analyzer.
  void clearAnalyzer();

  /// Sets the target rotation.
  void setTargetRotation(int rotation);
}

/// Interface for analyzing images.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/ImageAnalysis.Analyzer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ImageAnalysis.Analyzer',
  ),
)
abstract class Analyzer {
  Analyzer();

  /// Analyzes an image to produce a result.
  late void Function(ImageProxy image) analyze;
}

/// Code for a `CameraState` error.
///
/// https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_CAMERA_DISABLED()
enum CameraStateErrorCode {
  /// An error indicating that the camera device could not be opened due to a
  /// device policy.
  cameraDisabled,

  /// An error indicating that the camera device was closed due to a fatal
  /// error.
  cameraFatalError,

  /// An error indicating that the camera device is already in use.
  cameraInUse,

  /// An error indicating that the camera could not be opened because "Do Not
  /// Disturb" mode is enabled on devices affected by a bug in Android 9 (API
  /// level 28).
  doNotDisturbModeEnabled,

  /// An error indicating that the limit number of open cameras has been
  /// reached, and more cameras cannot be opened until other instances are
  /// closed.
  maxCamerasInUse,

  /// An error indicating that the camera device has encountered a recoverable
  /// error.
  otherRecoverableError,

  /// An error indicating that configuring the camera has failed.
  streamConfig,

  /// The value is not recognized by this wrapper.
  unknown,
}

/// Error that the camera has encountered.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraState.StateError.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.CameraState.StateError',
  ),
)
abstract class CameraStateStateError {
  /// The code of this error.
  late CameraStateErrorCode code;
}

/// LiveData is a data holder class that can be observed within a given
/// lifecycle.
///
/// This is a wrapper around the native class to better support the generic
/// type. Java has type erasure;
///
/// See https://developer.android.com/reference/androidx/lifecycle/LiveData.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'io.flutter.plugins.camerax.LiveDataProxyApi.LiveDataWrapper',
  ),
)
abstract class LiveData {
  /// The generic type used by this instance.
  late LiveDataSupportedType type;

  /// Adds the given observer to the observers list within the lifespan of the
  /// given owner.
  void observe(Observer observer);

  /// Removes all observers that are tied to the given `LifecycleOwner`.
  void removeObservers();

  /// Returns the current value.
  Object? getValue();
}

/// An image proxy which has a similar interface as `android.media.Image`.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/ImageProxy.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ImageProxy',
  ),
)
abstract class ImageProxy {
  /// The image format.
  late int format;

  /// The image width.
  late int width;

  /// The image height.
  late int height;

  /// Returns the array of planes.
  List<PlaneProxy> getPlanes();

  /// Closes the underlying `android.media.Image`.
  void close();
}

/// Utilities for working with [ImageProxy]s.
@ProxyApi()
abstract class ImageProxyUtils {
  /// Returns a single buffer that is representative of three NV21-compatible [planes].
  @static
  Uint8List getNv21Buffer(
    int imageWidth,
    int imageHeight,
    List<PlaneProxy> planes,
  );
}

/// A plane proxy which has an analogous interface as
/// `android.media.Image.Plane`.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/ImageProxy.PlaneProxy.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.ImageProxy.PlaneProxy',
  ),
)
abstract class PlaneProxy {
  /// The pixels buffer.
  late Uint8List buffer;

  /// The pixel stride.
  late int pixelStride;

  /// The row stride.
  late int rowStride;
}

/// Defines a desired quality setting that can be used to configure components
/// with quality setting requirements such as creating a Recorder.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/video/QualitySelector.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.QualitySelector',
  ),
)
abstract class QualitySelector {
  /// Gets an instance of QualitySelector with a desired quality.
  QualitySelector.from(
    VideoQuality quality,
    FallbackStrategy? fallbackStrategy,
  );

  /// Gets an instance of QualitySelector with ordered desired qualities.
  QualitySelector.fromOrderedList(
    List<VideoQuality> qualities,
    FallbackStrategy? fallbackStrategy,
  );

  /// Gets the corresponding resolution from the input quality.
  @static
  CameraSize? getResolution(CameraInfo cameraInfo, VideoQuality quality);
}

/// A class represents the strategy that will be adopted when the device does
/// not support all the desired Quality in QualitySelector in order to select
/// the quality as possible.
///
/// See https://developer.android.com/reference/androidx/camera/video/FallbackStrategy.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.FallbackStrategy',
  ),
)
abstract class FallbackStrategy {
  /// Returns a fallback strategy that will choose the quality that is closest
  /// to and higher than the input quality.
  FallbackStrategy.higherQualityOrLowerThan(VideoQuality quality);

  /// Returns a fallback strategy that will choose the quality that is closest
  /// to and higher than the input quality.
  FallbackStrategy.higherQualityThan(VideoQuality quality);

  /// Returns a fallback strategy that will choose the quality that is closest
  /// to and lower than the input quality.
  FallbackStrategy.lowerQualityOrHigherThan(VideoQuality quality);

  /// Returns a fallback strategy that will choose the quality that is closest
  /// to and lower than the input quality.
  FallbackStrategy.lowerQualityThan(VideoQuality quality);
}

/// The CameraControl provides various asynchronous operations like zoom, focus
/// and metering which affects output of all UseCases currently bound to that
/// camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraControl.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.CameraControl',
  ),
)
abstract class CameraControl {
  /// Enable the torch or disable the torch.
  @async
  void enableTorch(bool torch);

  /// Sets current zoom by ratio.
  @async
  void setZoomRatio(double ratio);

  /// Starts a focus and metering action configured by the
  /// `FocusMeteringAction`.
  @async
  FocusMeteringResult? startFocusAndMetering(FocusMeteringAction action);

  /// Cancels current FocusMeteringAction and clears AF/AE/AWB regions.
  @async
  void cancelFocusAndMetering();

  /// Set the exposure compensation value for the camera.
  @async
  int? setExposureCompensationIndex(int index);
}

/// The builder used to create the `FocusMeteringAction`.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/FocusMeteringAction.Builder.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.FocusMeteringAction.Builder',
  ),
)
abstract class FocusMeteringActionBuilder {
  /// Creates a Builder from a `MeteringPoint` with default mode FLAG_AF |
  /// FLAG_AE | FLAG_AWB.
  FocusMeteringActionBuilder(MeteringPoint point);

  /// Creates a Builder from a `MeteringPoint` and `MeteringMode`.
  FocusMeteringActionBuilder.withMode(MeteringPoint point, MeteringMode mode);

  /// Adds another MeteringPoint with default metering mode.
  void addPoint(MeteringPoint point);

  /// Adds another MeteringPoint with specified meteringMode.
  void addPointWithMode(MeteringPoint point, MeteringMode mode);

  /// Disables the auto-cancel.
  void disableAutoCancel();

  /// Builds the `FocusMeteringAction` instance.
  FocusMeteringAction build();
}

/// A configuration used to trigger a focus and/or metering action.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/FocusMeteringAction.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.FocusMeteringAction',
  ),
)
abstract class FocusMeteringAction {
  /// All MeteringPoints used for AE regions.
  late List<MeteringPoint> meteringPointsAe;

  /// All MeteringPoints used for AF regions.
  late List<MeteringPoint> meteringPointsAf;

  /// All MeteringPoints used for AWB regions.
  late List<MeteringPoint> meteringPointsAwb;

  /// If auto-cancel is enabled or not.
  late bool isAutoCancelEnabled;
}

/// Result of the `CameraControl.startFocusAndMetering`.
///
/// See https://developer.android.com/reference/androidx/camera/core/FocusMeteringResult.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.FocusMeteringResult',
  ),
)
abstract class FocusMeteringResult {
  /// If auto focus is successful.
  late bool isFocusSuccessful;
}

/// An immutable package of settings and outputs needed to capture a single
/// image from the camera device.
///
/// See https://developer.android.com/reference/android/hardware/camera2/CaptureRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.hardware.camera2.CaptureRequest',
  ),
)
abstract class CaptureRequest {
  /// Whether auto-exposure (AE) is currently locked to its latest calculated
  /// values.
  ///
  /// Value is boolean.
  ///
  /// This key is available on all devices.
  @static
  late CaptureRequestKey controlAELock;
}

/// A Key is used to do capture request field lookups with CaptureRequest.get or
/// to set fields with `CaptureRequest.Builder.set`.
///
/// See https://developer.android.com/reference/android/hardware/camera2/CaptureRequest.Key.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.hardware.camera2.CaptureRequest.Key<*>',
  ),
)
abstract class CaptureRequestKey {}

/// A bundle of Camera2 capture request options.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/camera2/interop/CaptureRequestOptions.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.camera2.interop.CaptureRequestOptions',
  ),
)
abstract class CaptureRequestOptions {
  CaptureRequestOptions(Map<CaptureRequestKey, Object?> options);

  /// Returns a value for the given CaptureRequestKey or null if it hasn't been
  /// set.
  Object? getCaptureRequestOption(CaptureRequestKey key);
}

/// An class that provides ability to interoperate with the
/// 1android.hardware.camera21 APIs.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/camera2/interop/Camera2CameraControl.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.camera2.interop.Camera2CameraControl',
  ),
)
abstract class Camera2CameraControl {
  /// Gets the `Camera2CameraControl` from a `CameraControl`.
  Camera2CameraControl.from(CameraControl cameraControl);

  /// Adds a `CaptureRequestOptions` updates the session with the options it
  /// contains.
  @async
  void addCaptureRequestOptions(CaptureRequestOptions bundle);
}

/// Applications can filter out unsuitable sizes and sort the resolution list in
/// the preferred order by implementing the resolution filter interface.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/resolutionselector/ResolutionFilter.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.resolutionselector.ResolutionFilter',
  ),
)
abstract class ResolutionFilter {
  ResolutionFilter.createWithOnePreferredSize(CameraSize preferredSize);
}

/// A Key is used to do camera characteristics field lookups with
/// `CameraCharacteristics.get`.
///
/// See https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics.Key.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.hardware.camera2.CameraCharacteristics.Key<*>',
  ),
)
abstract class CameraCharacteristicsKey {}

/// The properties describing a `CameraDevice`.
///
/// See https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.hardware.camera2.CameraCharacteristics',
  ),
)
abstract class CameraCharacteristics {
  /// Generally classifies the overall set of the camera device functionality.
  ///
  /// Value is `InfoSupportedHardwareLevel`.
  ///
  /// This key is available on all devices.
  @static
  late CameraCharacteristicsKey infoSupportedHardwareLevel;

  /// Clockwise angle through which the output image needs to be rotated to be
  /// upright on the device screen in its native orientation..
  ///
  /// Value is int.
  ///
  /// This key is available on all devices.
  @static
  late CameraCharacteristicsKey sensorOrientation;
}

/// An interface for retrieving Camera2-related camera information.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/camera2/interop/Camera2CameraInfo.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.camera2.interop.Camera2CameraInfo',
  ),
)
abstract class Camera2CameraInfo {
  /// Gets the `Camera2CameraInfo` from a `CameraInfo`.
  Camera2CameraInfo.from(CameraInfo cameraInfo);

  /// Gets the string camera ID.
  String getCameraId();

  /// Gets a camera characteristic value.
  Object? getCameraCharacteristic(CameraCharacteristicsKey key);
}

/// A factory to create a MeteringPoint.
///
/// See https://developer.android.com/reference/androidx/camera/core/MeteringPointFactory.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.MeteringPointFactory',
  ),
)
abstract class MeteringPointFactory {
  /// Creates a MeteringPoint by x, y.
  MeteringPoint createPoint(double x, double y);

  /// Creates a MeteringPoint by x, y, size.
  MeteringPoint createPointWithSize(double x, double y, double size);
}

/// A MeteringPointFactory that can convert a View (x, y) into a MeteringPoint
/// which can then be used to construct a FocusMeteringAction to start a focus
/// and metering action.
///
/// See https://developer.android.com/reference/androidx/camera/core/DisplayOrientedMeteringPointFactory.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.core.DisplayOrientedMeteringPointFactory',
  ),
)
abstract class DisplayOrientedMeteringPointFactory
    extends MeteringPointFactory {
  /// Creates a DisplayOrientedMeteringPointFactory for converting View (x, y)
  /// into a MeteringPoint based on the current display's rotation and
  /// CameraInfo.
  DisplayOrientedMeteringPointFactory(
    CameraInfo cameraInfo,
    double width,
    double height,
  );
}
