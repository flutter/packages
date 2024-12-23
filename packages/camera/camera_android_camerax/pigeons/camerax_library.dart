// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    copyrightHeader: 'pigeons/copyright.txt',
    dartOut: 'lib/src/camerax_library2.g.dart',
    dartTestOut: 'test/test_camerax_library.g.dart',
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
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.util.Size',
  ),
)
class CameraSize {
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
class ResolutionInfo {
  ResolutionInfo();

  /// Returns the output resolution used for the use case.
  late CameraSize resolution;
}

class CameraPermissionsErrorData {
  CameraPermissionsErrorData({
    required this.errorCode,
    required this.description,
  });

  String errorCode;
  String description;
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
enum LiveDataSupportedType {
  cameraState,
  zoomState,
}

/// Immutable class for describing the range of two integer values.
///
/// This is the equivalent to `android.util.Range<Integer>`.
///
/// See https://developer.android.com/reference/android/util/Range.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.util.Range<Integer>',
  ),
)
class CameraIntegerRange {
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
  /// Creates a MeteringPoint by x, y.
  MeteringPoint(double x, double y);

  /// Creates a MeteringPoint by x, y, size.
  MeteringPoint.withSize(double x, double y, double size);

  /// Size of the MeteringPoint width and height (ranging from 0 to 1).
  ///
  /// It is the percentage of the sensor width/height (or crop region
  /// width/height if crop region is set).
  late double size;
}

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

// /// The types of capture request options this plugin currently supports.
// ///
// /// If you need to add another option to support, ensure the following is done
// /// on the Dart side:
// ///
// ///  * In `camera_android_camerax/lib/src/capture_request_options.dart`, add new cases for this
// ///    option in `_CaptureRequestOptionsHostApiImpl#createFromInstances`
// ///    to create the expected Map entry of option key index and value to send to
// ///    the native side.
// ///
// /// On the native side, ensure the following is done:
// ///
// ///  * Update `CaptureRequestOptionsHostApiImpl#create` to set the correct
// ///   `CaptureRequest` key with a valid value type for this option.
// ///
// /// See https://developer.android.com/reference/android/hardware/camera2/CaptureRequest
// /// for the sorts of capture request options that can be supported via CameraX's
// /// interoperability with Camera2.
// enum CaptureRequestKeySupportedType {
//   controlAeLock,
// }

/// A simple callback that can receive from LiveData.
///
/// See https://developer.android.com/reference/androidx/lifecycle/Observer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.lifecycle.Observer',
  ),
)
abstract class Observer {
  Observer();

  /// The generic type used by this instance.
  late LiveDataSupportedType type;

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
  @attached
  late LiveData cameraState;

  /// A LiveData of ZoomState.
  @attached
  late LiveData zoomState;
}

/// Direction of lens of a camera.
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
  CameraSelector(LensFacing? requireLensFacing);

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
  Camera bindToLifecycle(
    CameraSelector cameraSelectorIdentifier,
    List<UseCase> useCases,
  );

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

@HostApi(dartHostTestHandler: 'TestSystemServicesHostApi')
abstract class SystemServicesHostApi {
  @async
  CameraPermissionsErrorData? requestCameraPermissions(bool enableAudio);

  String getTempFilePath(String prefix, String suffix);

  bool isPreviewPreTransformed();
}

@FlutterApi()
abstract class SystemServicesFlutterApi {
  void onCameraError(String errorDescription);
}

@HostApi(dartHostTestHandler: 'TestDeviceOrientationManagerHostApi')
abstract class DeviceOrientationManagerHostApi {
  void startListeningForDeviceOrientationChange(
      bool isFrontFacing, int sensorOrientation);

  void stopListeningForDeviceOrientationChange();

  int getDefaultDisplayRotation();

  String getUiOrientation();
}

@FlutterApi()
abstract class DeviceOrientationManagerFlutterApi {
  void onDeviceOrientationChanged(String orientation);
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
  Preview(int? targetRotation, ResolutionSelector? resolutionSelector);

  /// Sets a SurfaceProvider to provide a Surface for Preview.
  ///
  /// This is a convenience function that
  /// 1. Creates a `SurfaceProvider` using the `SurfaceProducer` provided by the
  /// Flutter engine.
  /// 2. Sets this method with the created `SurfaceProvider`.
  /// 3. Returns the texture id of the `TextureEntry` that provided the
  /// `SurfaceProducer`.
  int setSurfaceProvider();

  /// Releases the `SurfaceProducer` created in `setSurfaceProvider` if one was
  /// created.
  void releaseSurfaceProvider();

  /// Gets selected resolution information of the `Preview`.
  ResolutionInfo? getResolutionInfo();

  /// Sets the target rotation.
  void setTargetRotation(int rotation);
}

/// A use case that provides camera stream suitable for video application.
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/video/VideoCapture.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.camera.video.VideoCapture',
  ),
)
abstract class VideoCapture extends UseCase {
  /// Create a `VideoCapture` associated with the given `VideoOutput`.
  VideoCapture.withOutput(VideoOutput videoOutput);

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
enum FlashMode {
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

  /// Screen flash.
  ///
  /// Display screen brightness will be used as alternative to flash when taking
  /// a picture with front camera.
  screen,
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
  ImageCapture(
    int? targetRotation,
    FlashMode? flashMode,
    ResolutionSelector? resolutionSelector,
  );

  /// Set the flash mode.
  void setFlashMode(FlashMode flashMode);

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
  closestLowerThenHigher,

  /// CameraX doesn't select an alternate size when the specified bound size is
  /// unavailable.
  none,
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

  @static
  late ResolutionStrategy highestAvailableStrategy;
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
  ResolutionSelector(
    AspectRatioStrategy? aspectRatioStrategy,
    ResolutionStrategy? resolutionStrategy,
    ResolutionFilter? resolutionFilter,
  );
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
    int preferredAspectRatio,
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
  late CameraStateStateError error;
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
  ImageAnalysis(int? targetRotation, ResolutionSelector? resolutionSelector);

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
  disabled,

  /// An error indicating that the camera device was closed due to a fatal
  /// error.
  fatalError,

  /// An error indicating that the camera device is already in use.
  inUse,

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
/// See https://developer.android.com/reference/androidx/lifecycle/LiveData.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.lifecycle.LiveData',
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
class FallbackStrategy {
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
  FocusMeteringResult startFocusAndMetering(FocusMeteringAction action);

  /// Cancels current FocusMeteringAction and clears AF/AE/AWB regions.
  @async
  void cancelFocusAndMetering();

  /// Set the exposure compensation value for the camera.
  @async
  int setExposureCompensationIndex(int index);
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
  /// Adds another MeteringPoint with default metering mode.
  void addPoint(MeteringPoint point);

  /// Adds another MeteringPoint with specified meteringMode.
  void addPointWithMode(MeteringPoint point, List<MeteringMode> modes);

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
abstract class FocusMeteringAction {}

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

@HostApi(dartHostTestHandler: 'TestCaptureRequestOptionsHostApi')
abstract class CaptureRequestOptionsHostApi {
  void create(int identifier, Map<int, Object?> options);
}

@HostApi(dartHostTestHandler: 'TestCamera2CameraControlHostApi')
abstract class Camera2CameraControlHostApi {
  void create(int identifier, int cameraControlIdentifier);

  @async
  void addCaptureRequestOptions(
      int identifier, int captureRequestOptionsIdentifier);
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

@HostApi(dartHostTestHandler: 'TestCamera2CameraInfoHostApi')
abstract class Camera2CameraInfoHostApi {
  int createFrom(int cameraInfoIdentifier);

  int getSupportedHardwareLevel(int identifier);

  String getCameraId(int identifier);

  int getSensorOrientation(int identifier);
}

@FlutterApi()
abstract class Camera2CameraInfoFlutterApi {
  void create(int identifier);
}
