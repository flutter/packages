// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.params.OutputConfiguration;
import android.hardware.camera2.params.SessionConfiguration;
import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.util.Log;
import android.util.Range;
import android.util.Size;
import android.view.Display;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.BuildConfig;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.features.CameraFeatureFactory;
import io.flutter.plugins.camera.features.CameraFeatures;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.autofocus.AutoFocusFeature;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureLockFeature;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import io.flutter.plugins.camera.features.exposureoffset.ExposureOffsetFeature;
import io.flutter.plugins.camera.features.exposurepoint.ExposurePointFeature;
import io.flutter.plugins.camera.features.flash.FlashFeature;
import io.flutter.plugins.camera.features.flash.FlashMode;
import io.flutter.plugins.camera.features.focuspoint.FocusPointFeature;
import io.flutter.plugins.camera.features.fpsrange.FpsRangeFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.plugins.camera.features.sensororientation.DeviceOrientationManager;
import io.flutter.plugins.camera.features.zoomlevel.ZoomLevelFeature;
import io.flutter.plugins.camera.media.ImageStreamReader;
import io.flutter.plugins.camera.media.MediaRecorderBuilder;
import io.flutter.plugins.camera.types.CameraCaptureProperties;
import io.flutter.plugins.camera.types.CaptureTimeoutsWrapper;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Executors;

@FunctionalInterface
interface ErrorCallback {
  void onError(String errorCode, String errorMessage);
}

class Camera
    implements CameraCaptureCallback.CameraCaptureStateListener,
        ImageReader.OnImageAvailableListener {
  private static final String TAG = "Camera";

  /**
   * Holds all of the camera features/settings and will be used to update the request builder when
   * one changes.
   */
  CameraFeatures cameraFeatures;

  private int imageFormatGroup;

  /**
   * Takes an input/output surface and orients the recording correctly. This is needed because
   * switching cameras while recording causes the wrong orientation.
   */
  @VisibleForTesting VideoRenderer videoRenderer;

  /**
   * Whether or not the camera aligns with the initial way the camera was facing if the camera was
   * flipped.
   */
  @VisibleForTesting int initialCameraFacing;

  @VisibleForTesting final SurfaceTextureEntry flutterTexture;
  private final VideoCaptureSettings videoCaptureSettings;
  private final Context applicationContext;
  final DartMessenger dartMessenger;
  private CameraProperties cameraProperties;
  private final CameraFeatureFactory cameraFeatureFactory;
  private final Activity activity;
  /** A {@link CameraCaptureSession.CaptureCallback} that handles events related to JPEG capture. */
  private final CameraCaptureCallback cameraCaptureCallback;
  /** A {@link Handler} for running tasks in the background. */
  Handler backgroundHandler;

  /** An additional thread for running tasks that shouldn't block the UI. */
  private HandlerThread backgroundHandlerThread;

  CameraDeviceWrapper cameraDevice;
  CameraCaptureSession captureSession;
  @VisibleForTesting ImageReader pictureImageReader;
  ImageStreamReader imageStreamReader;
  /** {@link CaptureRequest.Builder} for the camera preview */
  CaptureRequest.Builder previewRequestBuilder;

  @VisibleForTesting MediaRecorder mediaRecorder;
  /** True when recording video. */
  boolean recordingVideo;
  /** True when the preview is paused. */
  @VisibleForTesting boolean pausedPreview;

  private File captureFile;

  /** Holds the current capture timeouts */
  private CaptureTimeoutsWrapper captureTimeouts;
  /** Holds the last known capture properties */
  private CameraCaptureProperties captureProps;

  Messages.Result<String> flutterResult;

  /** A CameraDeviceWrapper implementation that forwards calls to a CameraDevice. */
  private class DefaultCameraDeviceWrapper implements CameraDeviceWrapper {
    private final CameraDevice cameraDevice;

    DefaultCameraDeviceWrapper(CameraDevice cameraDevice) {
      this.cameraDevice = cameraDevice;
    }

    @NonNull
    @Override
    public CaptureRequest.Builder createCaptureRequest(int templateType)
        throws CameraAccessException {
      return cameraDevice.createCaptureRequest(templateType);
    }

    @TargetApi(VERSION_CODES.P)
    @Override
    public void createCaptureSession(SessionConfiguration config) throws CameraAccessException {
      cameraDevice.createCaptureSession(config);
    }

    @SuppressWarnings("deprecation")
    @Override
    public void createCaptureSession(
        @NonNull List<Surface> outputs,
        @NonNull CameraCaptureSession.StateCallback callback,
        @Nullable Handler handler)
        throws CameraAccessException {
      cameraDevice.createCaptureSession(outputs, callback, backgroundHandler);
    }

    @Override
    public void close() {
      cameraDevice.close();
    }
  }

  public static class VideoCaptureSettings {
    @NonNull public final ResolutionPreset resolutionPreset;
    public final boolean enableAudio;
    @Nullable public final Integer fps;
    @Nullable public final Integer videoBitrate;
    @Nullable public final Integer audioBitrate;

    public VideoCaptureSettings(
        @NonNull ResolutionPreset resolutionPreset,
        boolean enableAudio,
        @Nullable Integer fps,
        @Nullable Integer videoBitrate,
        @Nullable Integer audioBitrate) {
      this.resolutionPreset = resolutionPreset;
      this.enableAudio = enableAudio;
      this.fps = fps;
      this.videoBitrate = videoBitrate;
      this.audioBitrate = audioBitrate;
    }

    public VideoCaptureSettings(@NonNull ResolutionPreset resolutionPreset, boolean enableAudio) {
      this(resolutionPreset, enableAudio, null, null, null);
    }
  }

  public Camera(
      final Activity activity,
      final SurfaceTextureEntry flutterTexture,
      final CameraFeatureFactory cameraFeatureFactory,
      final DartMessenger dartMessenger,
      final CameraProperties cameraProperties,
      final VideoCaptureSettings videoCaptureSettings) {

    if (activity == null) {
      throw new IllegalStateException("No activity available!");
    }
    this.activity = activity;
    this.flutterTexture = flutterTexture;
    this.dartMessenger = dartMessenger;
    this.applicationContext = activity.getApplicationContext();
    this.cameraProperties = cameraProperties;
    this.cameraFeatureFactory = cameraFeatureFactory;
    this.videoCaptureSettings = videoCaptureSettings;
    this.cameraFeatures =
        CameraFeatures.init(
            cameraFeatureFactory,
            cameraProperties,
            activity,
            dartMessenger,
            videoCaptureSettings.resolutionPreset);

    Integer recordingFps = null;

    if (videoCaptureSettings.fps != null && videoCaptureSettings.fps.intValue() > 0) {
      recordingFps = videoCaptureSettings.fps;
    } else {

      if (SdkCapabilityChecker.supportsEncoderProfiles()) {
        EncoderProfiles encoderProfiles = getRecordingProfile();
        if (encoderProfiles != null && encoderProfiles.getVideoProfiles().size() > 0) {
          recordingFps = encoderProfiles.getVideoProfiles().get(0).getFrameRate();
        }
      } else {
        CamcorderProfile camcorderProfile = getRecordingProfileLegacy();
        recordingFps = null != camcorderProfile ? camcorderProfile.videoFrameRate : null;
      }
    }

    if (recordingFps != null && recordingFps.intValue() > 0) {

      final FpsRangeFeature fpsRange = new FpsRangeFeature(cameraProperties);
      fpsRange.setValue(new Range<Integer>(recordingFps, recordingFps));
      this.cameraFeatures.setFpsRange(fpsRange);
    }

    // Create capture callback.
    captureTimeouts = new CaptureTimeoutsWrapper(3000, 3000);
    captureProps = new CameraCaptureProperties();
    cameraCaptureCallback = CameraCaptureCallback.create(this, captureTimeouts, captureProps);

    startBackgroundThread();
  }

  @Override
  public void onConverged() {
    takePictureAfterPrecapture();
  }

  @Override
  public void onPrecapture() {
    runPrecaptureSequence();
  }

  /**
   * Updates the builder settings with all of the available features.
   *
   * @param requestBuilder request builder to update.
   */
  void updateBuilderSettings(CaptureRequest.Builder requestBuilder) {
    for (CameraFeature<?> feature : cameraFeatures.getAllFeatures()) {
      if (BuildConfig.DEBUG) {
        Log.d(TAG, "Updating builder with feature: " + feature.getDebugName());
      }
      feature.updateBuilder(requestBuilder);
    }
  }

  private void prepareMediaRecorder(String outputFilePath) throws IOException {
    Log.i(TAG, "prepareMediaRecorder");

    if (mediaRecorder != null) {
      mediaRecorder.release();
    }
    closeRenderer();

    final PlatformChannel.DeviceOrientation lockedOrientation =
        cameraFeatures.getSensorOrientation().getLockedCaptureOrientation();

    MediaRecorderBuilder mediaRecorderBuilder;

    // TODO(camsim99): Revert changes that allow legacy code to be used when recordingProfile is null
    // once this has largely been fixed on the Android side. https://github.com/flutter/flutter/issues/119668
    if (SdkCapabilityChecker.supportsEncoderProfiles() && getRecordingProfile() != null) {
      mediaRecorderBuilder =
          new MediaRecorderBuilder(
              getRecordingProfile(),
              new MediaRecorderBuilder.RecordingParameters(
                  outputFilePath,
                  videoCaptureSettings.fps,
                  videoCaptureSettings.videoBitrate,
                  videoCaptureSettings.audioBitrate));
    } else {
      mediaRecorderBuilder =
          new MediaRecorderBuilder(
              getRecordingProfileLegacy(),
              new MediaRecorderBuilder.RecordingParameters(
                  outputFilePath,
                  videoCaptureSettings.fps,
                  videoCaptureSettings.videoBitrate,
                  videoCaptureSettings.audioBitrate));
    }

    mediaRecorder =
        mediaRecorderBuilder
            .setEnableAudio(videoCaptureSettings.enableAudio)
            .setMediaOrientation(
                lockedOrientation == null
                    ? getDeviceOrientationManager().getVideoOrientation()
                    : getDeviceOrientationManager().getVideoOrientation(lockedOrientation))
            .build();
  }

  @SuppressLint("MissingPermission")
  public void open(Integer imageFormatGroup) throws CameraAccessException {
    this.imageFormatGroup = imageFormatGroup;
    final ResolutionFeature resolutionFeature = cameraFeatures.getResolution();

    if (!resolutionFeature.checkIsSupported()) {
      // Tell the user that the camera they are trying to open is not supported,
      // as its {@link android.media.CamcorderProfile} cannot be fetched due to the name
      // not being a valid parsable integer.
      dartMessenger.sendCameraErrorEvent(
          "Camera with name \""
              + cameraProperties.getCameraName()
              + "\" is not supported by this plugin.");
      return;
    }

    // Always capture using JPEG format.
    pictureImageReader =
        ImageReader.newInstance(
            resolutionFeature.getCaptureSize().getWidth(),
            resolutionFeature.getCaptureSize().getHeight(),
            ImageFormat.JPEG,
            1);

    imageStreamReader =
        new ImageStreamReader(
            resolutionFeature.getPreviewSize().getWidth(),
            resolutionFeature.getPreviewSize().getHeight(),
            this.imageFormatGroup,
            1);

    // Open the camera.
    CameraManager cameraManager = CameraUtils.getCameraManager(activity);
    cameraManager.openCamera(
        cameraProperties.getCameraName(),
        new CameraDevice.StateCallback() {
          @Override
          public void onOpened(@NonNull CameraDevice device) {
            cameraDevice = new DefaultCameraDeviceWrapper(device);
            try {
              startPreview();
              if (!recordingVideo) { // only send initialization if we werent already recording and switching cameras
                dartMessenger.sendCameraInitializedEvent(
                    resolutionFeature.getPreviewSize().getWidth(),
                    resolutionFeature.getPreviewSize().getHeight(),
                    cameraFeatures.getExposureLock().getValue(),
                    cameraFeatures.getAutoFocus().getValue(),
                    cameraFeatures.getExposurePoint().checkIsSupported(),
                    cameraFeatures.getFocusPoint().checkIsSupported());
              }
            } catch (Exception e) {
              String message =
                  (e.getMessage() == null)
                      ? (e.getClass().getName() + " occurred while opening camera.")
                      : e.getMessage();
              if (BuildConfig.DEBUG) {
                Log.i(TAG, "open | onOpened error: " + message);
              }
              dartMessenger.sendCameraErrorEvent(message);
              close();
            }
          }

          @Override
          public void onClosed(@NonNull CameraDevice camera) {
            Log.i(TAG, "open | onClosed");

            // Prevents calls to methods that would otherwise result in IllegalStateException
            // exceptions.
            cameraDevice = null;
            closeCaptureSession();
            dartMessenger.sendCameraClosingEvent();
          }

          @Override
          public void onDisconnected(@NonNull CameraDevice cameraDevice) {
            Log.i(TAG, "open | onDisconnected");

            close();
            dartMessenger.sendCameraErrorEvent("The camera was disconnected.");
          }

          @Override
          public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
            Log.i(TAG, "open | onError");

            close();
            String errorDescription;
            switch (errorCode) {
              case ERROR_CAMERA_IN_USE:
                errorDescription = "The camera device is in use already.";
                break;
              case ERROR_MAX_CAMERAS_IN_USE:
                errorDescription = "Max cameras in use";
                break;
              case ERROR_CAMERA_DISABLED:
                errorDescription = "The camera device could not be opened due to a device policy.";
                break;
              case ERROR_CAMERA_DEVICE:
                errorDescription = "The camera device has encountered a fatal error";
                break;
              case ERROR_CAMERA_SERVICE:
                errorDescription = "The camera service has encountered a fatal error.";
                break;
              default:
                errorDescription = "Unknown camera error";
            }
            dartMessenger.sendCameraErrorEvent(errorDescription);
          }
        },
        backgroundHandler);
  }

  @VisibleForTesting
  void createCaptureSession(int templateType, Surface... surfaces) throws CameraAccessException {
    createCaptureSession(templateType, null, surfaces);
  }

  private void createCaptureSession(
      int templateType, Runnable onSuccessCallback, Surface... surfaces)
      throws CameraAccessException {
    // Close any existing capture session.
    captureSession = null;

    // Create a new capture builder.
    previewRequestBuilder = cameraDevice.createCaptureRequest(templateType);

    // Build Flutter surface to render to.
    ResolutionFeature resolutionFeature = cameraFeatures.getResolution();
    SurfaceTexture surfaceTexture = flutterTexture.surfaceTexture();
    surfaceTexture.setDefaultBufferSize(
        resolutionFeature.getPreviewSize().getWidth(),
        resolutionFeature.getPreviewSize().getHeight());
    Surface flutterSurface = new Surface(surfaceTexture);
    previewRequestBuilder.addTarget(flutterSurface);

    List<Surface> remainingSurfaces = Arrays.asList(surfaces);
    if (templateType != CameraDevice.TEMPLATE_PREVIEW) {
      // If it is not preview mode, add all surfaces as targets
      // except the surface used for still capture as this should
      // not be part of a repeating request.
      Surface pictureImageReaderSurface = pictureImageReader.getSurface();
      for (Surface surface : remainingSurfaces) {
        if (surface == pictureImageReaderSurface) {
          continue;
        }
        previewRequestBuilder.addTarget(surface);
      }
    }

    // Update camera regions.
    Size cameraBoundaries =
        CameraRegionUtils.getCameraBoundaries(cameraProperties, previewRequestBuilder);
    cameraFeatures.getExposurePoint().setCameraBoundaries(cameraBoundaries);
    cameraFeatures.getFocusPoint().setCameraBoundaries(cameraBoundaries);

    // Prepare the callback.
    CameraCaptureSession.StateCallback callback =
        new CameraCaptureSession.StateCallback() {
          boolean captureSessionClosed = false;

          @Override
          public void onConfigured(@NonNull CameraCaptureSession session) {
            Log.i(TAG, "CameraCaptureSession onConfigured");
            // Camera was already closed.
            if (cameraDevice == null || captureSessionClosed) {
              dartMessenger.sendCameraErrorEvent("The camera was closed during configuration.");
              return;
            }
            captureSession = session;

            Log.i(TAG, "Updating builder settings");
            updateBuilderSettings(previewRequestBuilder);

            refreshPreviewCaptureSession(
                onSuccessCallback, (code, message) -> dartMessenger.sendCameraErrorEvent(message));
          }

          @Override
          public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
            Log.i(TAG, "CameraCaptureSession onConfigureFailed");
            dartMessenger.sendCameraErrorEvent("Failed to configure camera session.");
          }

          @Override
          public void onClosed(@NonNull CameraCaptureSession session) {
            Log.i(TAG, "CameraCaptureSession onClosed");
            captureSessionClosed = true;
          }
        };

    // Start the session.
    if (SdkCapabilityChecker.supportsSessionConfiguration()) {
      // Collect all surfaces to render to.
      List<OutputConfiguration> configs = new ArrayList<>();
      configs.add(new OutputConfiguration(flutterSurface));
      for (Surface surface : remainingSurfaces) {
        configs.add(new OutputConfiguration(surface));
      }
      createCaptureSessionWithSessionConfig(configs, callback);
    } else {
      // Collect all surfaces to render to.
      List<Surface> surfaceList = new ArrayList<>();
      surfaceList.add(flutterSurface);
      surfaceList.addAll(remainingSurfaces);
      createCaptureSession(surfaceList, callback);
    }
  }

  @TargetApi(VERSION_CODES.P)
  private void createCaptureSessionWithSessionConfig(
      List<OutputConfiguration> outputConfigs, CameraCaptureSession.StateCallback callback)
      throws CameraAccessException {
    cameraDevice.createCaptureSession(
        new SessionConfiguration(
            SessionConfiguration.SESSION_REGULAR,
            outputConfigs,
            Executors.newSingleThreadExecutor(),
            callback));
  }

  @SuppressWarnings("deprecation")
  private void createCaptureSession(
      List<Surface> surfaces, CameraCaptureSession.StateCallback callback)
      throws CameraAccessException {
    cameraDevice.createCaptureSession(surfaces, callback, backgroundHandler);
  }

  // Send a repeating request to refresh  capture session.
  void refreshPreviewCaptureSession(
      @Nullable Runnable onSuccessCallback, @NonNull ErrorCallback onErrorCallback) {
    Log.i(TAG, "refreshPreviewCaptureSession");

    if (captureSession == null) {
      Log.i(
          TAG,
          "refreshPreviewCaptureSession: captureSession not yet initialized, "
              + "skipping preview capture session refresh.");
      return;
    }

    try {
      if (!pausedPreview) {
        captureSession.setRepeatingRequest(
            previewRequestBuilder.build(), cameraCaptureCallback, backgroundHandler);
      }

      if (onSuccessCallback != null) {
        onSuccessCallback.run();
      }

    } catch (IllegalStateException e) {
      onErrorCallback.onError("cameraAccess", "Camera is closed: " + e.getMessage());
    } catch (CameraAccessException e) {
      onErrorCallback.onError("cameraAccess", e.getMessage());
    }
  }

  private void startCapture(boolean record, boolean stream) throws CameraAccessException {
    List<Surface> surfaces = new ArrayList<>();
    Runnable successCallback = null;
    if (record) {
      surfaces.add(mediaRecorder.getSurface());
      successCallback = () -> mediaRecorder.start();
    }
    if (stream && imageStreamReader != null) {
      surfaces.add(imageStreamReader.getSurface());
    }

    // Add pictureImageReader surface to allow for still capture
    // during recording/image streaming.
    surfaces.add(pictureImageReader.getSurface());

    createCaptureSession(
        CameraDevice.TEMPLATE_RECORD, successCallback, surfaces.toArray(new Surface[0]));
  }

  public void takePicture(@NonNull final Messages.Result<String> result) {
    // Only take one picture at a time.
    if (cameraCaptureCallback.getCameraState() != CameraState.STATE_PREVIEW) {
      result.error(
          new Messages.FlutterError(
              "captureAlreadyActive", "Picture is currently already being captured", null));
      return;
    }

    flutterResult = result;

    // Create temporary file.
    final File outputDir = applicationContext.getCacheDir();
    try {
      captureFile = File.createTempFile("CAP", ".jpg", outputDir);
      captureTimeouts.reset();
    } catch (IOException | SecurityException e) {
      dartMessenger.error(flutterResult, "cannotCreateFile", e.getMessage(), null);
      return;
    }

    // Listen for picture being taken.
    pictureImageReader.setOnImageAvailableListener(this, backgroundHandler);

    final AutoFocusFeature autoFocusFeature = cameraFeatures.getAutoFocus();
    final boolean isAutoFocusSupported = autoFocusFeature.checkIsSupported();
    if (isAutoFocusSupported && autoFocusFeature.getValue() == FocusMode.auto) {
      runPictureAutoFocus();
    } else {
      runPrecaptureSequence();
    }
  }

  /**
   * Run the precapture sequence for capturing a still image. This method should be called when a
   * response is received in {@link #cameraCaptureCallback} from lockFocus().
   */
  private void runPrecaptureSequence() {
    Log.i(TAG, "runPrecaptureSequence");
    try {
      // First set precapture state to idle or else it can hang in STATE_WAITING_PRECAPTURE_START.
      previewRequestBuilder.set(
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE);
      captureSession.capture(
          previewRequestBuilder.build(), cameraCaptureCallback, backgroundHandler);

      // Repeating request to refresh preview session.
      refreshPreviewCaptureSession(
          null,
          (code, message) -> dartMessenger.error(flutterResult, "cameraAccess", message, null));

      // Start precapture.
      cameraCaptureCallback.setCameraState(CameraState.STATE_WAITING_PRECAPTURE_START);

      previewRequestBuilder.set(
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_START);

      // Trigger one capture to start AE sequence.
      captureSession.capture(
          previewRequestBuilder.build(), cameraCaptureCallback, backgroundHandler);

    } catch (CameraAccessException e) {
      e.printStackTrace();
    }
  }

  /**
   * Capture a still picture. This method should be called when a response is received {@link
   * #cameraCaptureCallback} from both lockFocus().
   */
  private void takePictureAfterPrecapture() {
    Log.i(TAG, "captureStillPicture");
    cameraCaptureCallback.setCameraState(CameraState.STATE_CAPTURING);

    if (cameraDevice == null) {
      return;
    }
    // This is the CaptureRequest.Builder that is used to take a picture.
    CaptureRequest.Builder stillBuilder;
    try {
      stillBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
    } catch (CameraAccessException e) {
      dartMessenger.error(flutterResult, "cameraAccess", e.getMessage(), null);
      return;
    }
    stillBuilder.addTarget(pictureImageReader.getSurface());

    // Zoom.
    stillBuilder.set(
        CaptureRequest.SCALER_CROP_REGION,
        previewRequestBuilder.get(CaptureRequest.SCALER_CROP_REGION));

    // Have all features update the builder.
    updateBuilderSettings(stillBuilder);

    // Orientation.
    final PlatformChannel.DeviceOrientation lockedOrientation =
        cameraFeatures.getSensorOrientation().getLockedCaptureOrientation();
    stillBuilder.set(
        CaptureRequest.JPEG_ORIENTATION,
        lockedOrientation == null
            ? getDeviceOrientationManager().getPhotoOrientation()
            : getDeviceOrientationManager().getPhotoOrientation(lockedOrientation));

    CameraCaptureSession.CaptureCallback captureCallback =
        new CameraCaptureSession.CaptureCallback() {
          @Override
          public void onCaptureCompleted(
              @NonNull CameraCaptureSession session,
              @NonNull CaptureRequest request,
              @NonNull TotalCaptureResult result) {
            unlockAutoFocus();
          }
        };

    try {
      Log.i(TAG, "sending capture request");
      captureSession.capture(stillBuilder.build(), captureCallback, backgroundHandler);
    } catch (CameraAccessException e) {
      dartMessenger.error(flutterResult, "cameraAccess", e.getMessage(), null);
    }
  }

  @SuppressWarnings("deprecation")
  private Display getDefaultDisplay() {
    return activity.getWindowManager().getDefaultDisplay();
  }

  /** Starts a background thread and its {@link Handler}. */
  public void startBackgroundThread() {
    if (backgroundHandlerThread != null) {
      return;
    }

    backgroundHandlerThread = HandlerThreadFactory.create("CameraBackground");
    try {
      backgroundHandlerThread.start();
    } catch (IllegalThreadStateException e) {
      // Ignore exception in case the thread has already started.
    }
    backgroundHandler = HandlerFactory.create(backgroundHandlerThread.getLooper());
  }

  /** Stops the background thread and its {@link Handler}. */
  public void stopBackgroundThread() {
    if (backgroundHandlerThread != null) {
      backgroundHandlerThread.quitSafely();
    }
    backgroundHandlerThread = null;
    backgroundHandler = null;
  }

  /** Start capturing a picture, doing autofocus first. */
  private void runPictureAutoFocus() {
    Log.i(TAG, "runPictureAutoFocus");

    cameraCaptureCallback.setCameraState(CameraState.STATE_WAITING_FOCUS);
    lockAutoFocus();
  }

  private void lockAutoFocus() {
    Log.i(TAG, "lockAutoFocus");
    if (captureSession == null) {
      Log.i(TAG, "[unlockAutoFocus] captureSession null, returning");
      return;
    }

    // Trigger AF to start.
    previewRequestBuilder.set(
        CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_START);

    try {
      captureSession.capture(previewRequestBuilder.build(), null, backgroundHandler);
    } catch (CameraAccessException e) {
      String message =
          (e.getMessage() == null)
              ? "CameraAccessException occurred while locking autofocus."
              : e.getMessage();
      dartMessenger.sendCameraErrorEvent(message);
    }
  }

  /** Cancel and reset auto focus state and refresh the preview session. */
  void unlockAutoFocus() {
    Log.i(TAG, "unlockAutoFocus");
    if (captureSession == null) {
      Log.i(TAG, "[unlockAutoFocus] captureSession null, returning");
      return;
    }
    try {
      // Cancel existing AF state.
      previewRequestBuilder.set(
          CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_CANCEL);
      captureSession.capture(previewRequestBuilder.build(), null, backgroundHandler);

      // Set AF state to idle again.
      previewRequestBuilder.set(
          CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_IDLE);

      captureSession.capture(previewRequestBuilder.build(), null, backgroundHandler);
    } catch (CameraAccessException e) {
      String message =
          (e.getMessage() == null)
              ? "CameraAccessException occurred while unlocking autofocus."
              : e.getMessage();
      dartMessenger.sendCameraErrorEvent(message);
      return;
    }

    refreshPreviewCaptureSession(
        null,
        (errorCode, errorMessage) ->
            dartMessenger.error(flutterResult, errorCode, errorMessage, null));
  }

  public void startVideoRecording(@Nullable EventChannel imageStreamChannel) {
    prepareRecording();

    if (imageStreamChannel != null) {
      setStreamHandler(imageStreamChannel);
    }
    initialCameraFacing = cameraProperties.getLensFacing();
    recordingVideo = true;
    try {
      startCapture(true, imageStreamChannel != null);
    } catch (CameraAccessException e) {
      recordingVideo = false;
      captureFile = null;
      throw new Messages.FlutterError("videoRecordingFailed", e.getMessage(), null);
    }
  }

  private void closeRenderer() {
    if (videoRenderer != null) {
      videoRenderer.close();
      videoRenderer = null;
    }
  }

  public String stopVideoRecording() {
    if (!recordingVideo) {
      return "";
    }
    // Re-create autofocus feature so it's using continuous capture focus mode now.
    cameraFeatures.setAutoFocus(
        cameraFeatureFactory.createAutoFocusFeature(cameraProperties, false));
    recordingVideo = false;
    try {
      closeRenderer();
      captureSession.abortCaptures();
      mediaRecorder.stop();
    } catch (CameraAccessException | IllegalStateException e) {
      // Ignore exceptions and try to continue (changes are camera session already aborted capture).
    }
    mediaRecorder.reset();
    try {
      startPreview();
    } catch (CameraAccessException | IllegalStateException | InterruptedException e) {
      throw new Messages.FlutterError("videoRecordingFailed", e.getMessage(), null);
    }
    String path = captureFile.getAbsolutePath();
    captureFile = null;
    return path;
  }

  public void pauseVideoRecording() {
    if (!recordingVideo) {
      return;
    }

    try {
      if (SdkCapabilityChecker.supportsVideoPause()) {
        mediaRecorder.pause();
      } else {
        throw new Messages.FlutterError(
            "videoRecordingFailed", "pauseVideoRecording requires Android API +24.", null);
      }
    } catch (IllegalStateException e) {
      throw new Messages.FlutterError("videoRecordingFailed", e.getMessage(), null);
    }
  }

  public void resumeVideoRecording() {
    if (!recordingVideo) {
      return;
    }

    try {
      if (SdkCapabilityChecker.supportsVideoPause()) {
        mediaRecorder.resume();
      } else {
        throw new Messages.FlutterError(
            "videoRecordingFailed", "resumeVideoRecording requires Android API +24.", null);
      }
    } catch (IllegalStateException e) {
      throw new Messages.FlutterError("videoRecordingFailed", e.getMessage(), null);
    }
  }

  /**
   * Method handler for setting new flash modes.
   *
   * @param result Flutter result.
   * @param newMode new mode.
   */
  public void setFlashMode(@NonNull final Messages.VoidResult result, @NonNull FlashMode newMode) {
    // Save the new flash mode setting.
    final FlashFeature flashFeature = cameraFeatures.getFlash();
    flashFeature.setValue(newMode);
    flashFeature.updateBuilder(previewRequestBuilder);

    refreshPreviewCaptureSession(
        result::success,
        (code, message) ->
            result.error(
                new Messages.FlutterError(
                    "setFlashModeFailed", "Could not set flash mode.", null)));
  }

  /**
   * Method handler for setting new exposure modes.
   *
   * @param result Flutter result.
   * @param newMode new mode.
   */
  public void setExposureMode(
      @NonNull final Messages.VoidResult result, @NonNull ExposureMode newMode) {
    final ExposureLockFeature exposureLockFeature = cameraFeatures.getExposureLock();
    exposureLockFeature.setValue(newMode);
    exposureLockFeature.updateBuilder(previewRequestBuilder);

    refreshPreviewCaptureSession(
        result::success,
        (code, message) ->
            result.error(
                new Messages.FlutterError(
                    "setExposureModeFailed", "Could not set exposure mode.", null)));
  }

  /**
   * Sets new exposure point from dart.
   *
   * @param result Flutter result.
   * @param point The exposure point.
   */
  public void setExposurePoint(@NonNull final Messages.VoidResult result, @Nullable Point point) {
    final ExposurePointFeature exposurePointFeature = cameraFeatures.getExposurePoint();
    exposurePointFeature.setValue(point);
    exposurePointFeature.updateBuilder(previewRequestBuilder);

    refreshPreviewCaptureSession(
        result::success,
        (code, message) ->
            result.error(
                new Messages.FlutterError(
                    "setExposurePointFailed", "Could not set exposure point.", null)));
  }

  /** Return the max exposure offset value supported by the camera to dart. */
  public double getMaxExposureOffset() {
    return cameraFeatures.getExposureOffset().getMaxExposureOffset();
  }

  /** Return the min exposure offset value supported by the camera to dart. */
  public double getMinExposureOffset() {
    return cameraFeatures.getExposureOffset().getMinExposureOffset();
  }

  /** Return the exposure offset step size to dart. */
  public double getExposureOffsetStepSize() {
    return cameraFeatures.getExposureOffset().getExposureOffsetStepSize();
  }

  /**
   * Sets new focus mode from dart.
   *
   * @param newMode New mode.
   */
  public void setFocusMode(@NonNull FocusMode newMode) {
    final AutoFocusFeature autoFocusFeature = cameraFeatures.getAutoFocus();
    autoFocusFeature.setValue(newMode);
    autoFocusFeature.updateBuilder(previewRequestBuilder);

    /*
     * For focus mode an extra step of actually locking/unlocking the
     * focus has to be done, in order to ensure it goes into the correct state.
     */
    if (!pausedPreview) {
      switch (newMode) {
        case locked:
          // Perform a single focus trigger.
          if (captureSession == null) {
            Log.i(TAG, "[unlockAutoFocus] captureSession null, returning");
            return;
          }
          lockAutoFocus();

          // Set AF state to idle again.
          previewRequestBuilder.set(
              CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_IDLE);

          try {
            captureSession.setRepeatingRequest(
                previewRequestBuilder.build(), null, backgroundHandler);
          } catch (CameraAccessException e) {
            throw new Messages.FlutterError(
                "setFocusModeFailed", "Error setting focus mode: " + e.getMessage(), null);
          }
          break;
        case auto:
          // Cancel current AF trigger and set AF to idle again.
          unlockAutoFocus();
          break;
      }
    }
  }

  /**
   * Sets new focus point from dart.
   *
   * @param result Flutter result.
   * @param point the new coordinates.
   */
  public void setFocusPoint(@NonNull final Messages.VoidResult result, @Nullable Point point) {
    final FocusPointFeature focusPointFeature = cameraFeatures.getFocusPoint();
    focusPointFeature.setValue(point);
    focusPointFeature.updateBuilder(previewRequestBuilder);

    refreshPreviewCaptureSession(
        result::success,
        (code, message) ->
            result.error(
                new Messages.FlutterError(
                    "setFocusPointFailed", "Could not set focus point.", null)));

    this.setFocusMode(cameraFeatures.getAutoFocus().getValue());
  }

  /**
   * Sets a new exposure offset from dart. From dart the offset comes as a double, like +1.3 or
   * -1.3.
   *
   * @param result flutter result.
   * @param offset new value.
   */
  public void setExposureOffset(@NonNull final Messages.Result<Double> result, double offset) {
    final ExposureOffsetFeature exposureOffsetFeature = cameraFeatures.getExposureOffset();
    exposureOffsetFeature.setValue(offset);
    exposureOffsetFeature.updateBuilder(previewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(exposureOffsetFeature.getValue()),
        (code, message) ->
            result.error(
                new Messages.FlutterError(
                    "setExposureOffsetFailed", "Could not set exposure offset.", null)));
  }

  public float getMaxZoomLevel() {
    return cameraFeatures.getZoomLevel().getMaximumZoomLevel();
  }

  public float getMinZoomLevel() {
    return cameraFeatures.getZoomLevel().getMinimumZoomLevel();
  }

  /** Shortcut to get current recording profile. Legacy method provides support for SDK < 31. */
  CamcorderProfile getRecordingProfileLegacy() {
    return cameraFeatures.getResolution().getRecordingProfileLegacy();
  }

  EncoderProfiles getRecordingProfile() {
    return cameraFeatures.getResolution().getRecordingProfile();
  }

  /** Shortut to get deviceOrientationListener. */
  DeviceOrientationManager getDeviceOrientationManager() {
    return cameraFeatures.getSensorOrientation().getDeviceOrientationManager();
  }

  /**
   * Sets zoom level from dart.
   *
   * @param result Flutter result.
   * @param zoom new value.
   */
  public void setZoomLevel(@NonNull final Messages.VoidResult result, float zoom) {
    final ZoomLevelFeature zoomLevel = cameraFeatures.getZoomLevel();
    float maxZoom = zoomLevel.getMaximumZoomLevel();
    float minZoom = zoomLevel.getMinimumZoomLevel();

    if (zoom > maxZoom || zoom < minZoom) {
      String errorMessage =
          String.format(
              Locale.ENGLISH,
              "Zoom level out of bounds (zoom level should be between %f and %f).",
              minZoom,
              maxZoom);
      result.error(new Messages.FlutterError("ZOOM_ERROR", errorMessage, null));
      return;
    }

    zoomLevel.setValue(zoom);
    zoomLevel.updateBuilder(previewRequestBuilder);

    refreshPreviewCaptureSession(
        result::success,
        (code, message) ->
            result.error(
                new Messages.FlutterError(
                    "setZoomLevelFailed", "Could not set zoom level.", null)));
  }

  /**
   * Lock capture orientation from dart.
   *
   * @param orientation new orientation.
   */
  public void lockCaptureOrientation(PlatformChannel.DeviceOrientation orientation) {
    cameraFeatures.getSensorOrientation().lockCaptureOrientation(orientation);
  }

  /** Unlock capture orientation from dart. */
  public void unlockCaptureOrientation() {
    cameraFeatures.getSensorOrientation().unlockCaptureOrientation();
  }

  /** Pause the preview from dart. */
  public void pausePreview() throws CameraAccessException {
    if (!this.pausedPreview) {
      this.pausedPreview = true;

      if (this.captureSession != null) {
        this.captureSession.stopRepeating();
      }
    }
  }

  /** Resume the preview from dart. */
  public void resumePreview() {
    this.pausedPreview = false;
    this.refreshPreviewCaptureSession(
        null, (code, message) -> dartMessenger.sendCameraErrorEvent(message));
  }

  public void startPreview() throws CameraAccessException, InterruptedException {
    // If recording is already in progress, the camera is being flipped, so send it through the VideoRenderer to keep the correct orientation.
    if (recordingVideo) {
      startPreviewWithVideoRendererStream();
    } else {
      startRegularPreview();
    }
  }

  private void startRegularPreview() throws CameraAccessException {
    if (pictureImageReader == null || pictureImageReader.getSurface() == null) return;
    Log.i(TAG, "startPreview");
    createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, pictureImageReader.getSurface());
  }

  private void startPreviewWithVideoRendererStream()
      throws CameraAccessException, InterruptedException {
    if (videoRenderer == null) return;

    // get rotation for rendered video
    final PlatformChannel.DeviceOrientation lockedOrientation =
        cameraFeatures.getSensorOrientation().getLockedCaptureOrientation();
    DeviceOrientationManager orientationManager =
        cameraFeatures.getSensorOrientation().getDeviceOrientationManager();

    int rotation = 0;
    if (orientationManager != null) {
      rotation =
          lockedOrientation == null
              ? orientationManager.getVideoOrientation()
              : orientationManager.getVideoOrientation(lockedOrientation);
    }

    if (cameraProperties.getLensFacing() != initialCameraFacing) {

      // If the new camera is facing the opposite way than the initial recording,
      // the rotation should be flipped 180 degrees.
      rotation = (rotation + 180) % 360;
    }
    videoRenderer.setRotation(rotation);

    createCaptureSession(CameraDevice.TEMPLATE_RECORD, videoRenderer.getInputSurface());
  }

  public void startPreviewWithImageStream(EventChannel imageStreamChannel)
      throws CameraAccessException {
    setStreamHandler(imageStreamChannel);

    startCapture(false, true);
    Log.i(TAG, "startPreviewWithImageStream");
  }

  /**
   * This a callback object for the {@link ImageReader}. "onImageAvailable" will be called when a
   * still image is ready to be saved.
   */
  @Override
  public void onImageAvailable(ImageReader reader) {
    Log.i(TAG, "onImageAvailable");

    // Use acquireNextImage since image reader is only for one image.
    Image image = reader.acquireNextImage();
    if (image == null) {
      return;
    }

    backgroundHandler.post(
        new ImageSaver(
            image,
            captureFile,
            new ImageSaver.Callback() {
              @Override
              public void onComplete(@NonNull String absolutePath) {
                dartMessenger.finish(flutterResult, absolutePath);
              }

              @Override
              public void onError(@NonNull String errorCode, @NonNull String errorMessage) {
                dartMessenger.error(flutterResult, errorCode, errorMessage, null);
              }
            }));
    cameraCaptureCallback.setCameraState(CameraState.STATE_PREVIEW);
  }

  @VisibleForTesting
  void prepareRecording() {
    final File outputDir = applicationContext.getCacheDir();
    try {
      captureFile = File.createTempFile("REC", ".mp4", outputDir);
    } catch (IOException | SecurityException e) {
      throw new Messages.FlutterError("cannotCreateFile", e.getMessage(), null);
    }
    try {
      prepareMediaRecorder(captureFile.getAbsolutePath());
    } catch (IOException e) {
      recordingVideo = false;
      captureFile = null;
      throw new Messages.FlutterError("videoRecordingFailed", e.getMessage(), null);
    }
    // Re-create autofocus feature so it's using video focus mode now.
    cameraFeatures.setAutoFocus(
        cameraFeatureFactory.createAutoFocusFeature(cameraProperties, true));
  }

  private void setStreamHandler(EventChannel imageStreamChannel) {
    imageStreamChannel.setStreamHandler(
        new EventChannel.StreamHandler() {
          @Override
          public void onListen(Object o, EventChannel.EventSink imageStreamSink) {
            setImageStreamImageAvailableListener(imageStreamSink);
          }

          @Override
          public void onCancel(Object o) {
            if (imageStreamReader == null) {
              return;
            }

            imageStreamReader.removeListener(backgroundHandler);
          }
        });
  }

  void setImageStreamImageAvailableListener(final EventChannel.EventSink imageStreamSink) {
    if (imageStreamReader == null) {
      return;
    }

    imageStreamReader.subscribeListener(this.captureProps, imageStreamSink, backgroundHandler);
  }

  void closeCaptureSession() {
    if (captureSession != null) {
      Log.i(TAG, "closeCaptureSession");

      captureSession.close();
      captureSession = null;
    }
  }

  public void close() {
    Log.i(TAG, "close");

    stopAndReleaseCamera();

    if (pictureImageReader != null) {
      pictureImageReader.close();
      pictureImageReader = null;
    }
    if (imageStreamReader != null) {
      imageStreamReader.close();
      imageStreamReader = null;
    }
    if (mediaRecorder != null) {
      mediaRecorder.reset();
      mediaRecorder.release();
      mediaRecorder = null;
    }

    stopBackgroundThread();
  }

  private void stopAndReleaseCamera() {
    if (cameraDevice != null) {
      cameraDevice.close();
      cameraDevice = null;

      // Closing the CameraDevice without closing the CameraCaptureSession is recommended
      // for quickly closing the camera:
      // https://developer.android.com/reference/android/hardware/camera2/CameraCaptureSession#close()
      captureSession = null;
    } else {
      closeCaptureSession();
    }
  }

  private void prepareVideoRenderer() {
    if (videoRenderer != null) return;
    final ResolutionFeature resolutionFeature = cameraFeatures.getResolution();

    // handle videoRenderer errors
    Thread.UncaughtExceptionHandler videoRendererUncaughtExceptionHandler =
        new Thread.UncaughtExceptionHandler() {
          @Override
          public void uncaughtException(Thread thread, Throwable ex) {
            dartMessenger.sendCameraErrorEvent(
                "Failed to process frames after camera was flipped.");
          }
        };

    videoRenderer =
        new VideoRenderer(
            mediaRecorder.getSurface(),
            resolutionFeature.getCaptureSize().getWidth(),
            resolutionFeature.getCaptureSize().getHeight(),
            videoRendererUncaughtExceptionHandler);
  }

  public void setDescriptionWhileRecording(CameraProperties properties) {

    if (!recordingVideo) {
      throw new Messages.FlutterError(
          "setDescriptionWhileRecordingFailed", "Device was not recording", null);
    }

    // See VideoRenderer.java; support for this EGL extension is required to switch camera while recording.
    if (!SdkCapabilityChecker.supportsEglRecordableAndroid()) {
      throw new Messages.FlutterError(
          "setDescriptionWhileRecordingFailed",
          "Device does not support switching the camera while recording",
          null);
    }

    stopAndReleaseCamera();
    prepareVideoRenderer();
    cameraProperties = properties;
    cameraFeatures =
        CameraFeatures.init(
            cameraFeatureFactory,
            cameraProperties,
            activity,
            dartMessenger,
            videoCaptureSettings.resolutionPreset);
    cameraFeatures.setAutoFocus(
        cameraFeatureFactory.createAutoFocusFeature(cameraProperties, true));
    try {
      open(imageFormatGroup);
    } catch (CameraAccessException e) {
      throw new Messages.FlutterError("setDescriptionWhileRecordingFailed", e.getMessage(), null);
    }
  }

  public void dispose() {
    Log.i(TAG, "dispose");

    close();
    flutterTexture.release();
    getDeviceOrientationManager().stop();
  }

  /** Factory class that assists in creating a {@link HandlerThread} instance. */
  static class HandlerThreadFactory {
    /**
     * Creates a new instance of the {@link HandlerThread} class.
     *
     * <p>This method is visible for testing purposes only and should never be used outside this *
     * class.
     *
     * @param name to give to the HandlerThread.
     * @return new instance of the {@link HandlerThread} class.
     */
    @VisibleForTesting
    public static HandlerThread create(String name) {
      return new HandlerThread(name);
    }
  }

  /** Factory class that assists in creating a {@link Handler} instance. */
  static class HandlerFactory {
    /**
     * Creates a new instance of the {@link Handler} class.
     *
     * <p>This method is visible for testing purposes only and should never be used outside this *
     * class.
     *
     * @param looper to give to the Handler.
     * @return new instance of the {@link Handler} class.
     */
    @VisibleForTesting
    public static Handler create(Looper looper) {
      return new Handler(looper);
    }
  }
}
