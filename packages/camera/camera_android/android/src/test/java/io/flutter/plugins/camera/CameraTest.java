// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

import android.app.Activity;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.*;
import android.hardware.camera2.params.SessionConfiguration;
import android.media.CamcorderProfile;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Range;
import android.util.Size;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LifecycleObserver;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
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
import io.flutter.plugins.camera.features.noisereduction.NoiseReductionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.plugins.camera.features.sensororientation.DeviceOrientationManager;
import io.flutter.plugins.camera.features.sensororientation.SensorOrientationFeature;
import io.flutter.plugins.camera.features.zoomlevel.ZoomLevelFeature;
import io.flutter.plugins.camera.media.ImageStreamReader;
import io.flutter.view.TextureRegistry;
import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedConstruction;
import org.mockito.MockedStatic;
import org.mockito.Mockito;

class FakeCameraDeviceWrapper implements CameraDeviceWrapper {
  final List<CaptureRequest.Builder> captureRequests;
  @Nullable final CameraCaptureSession session;

  FakeCameraDeviceWrapper(List<CaptureRequest.Builder> captureRequests) {
    this(captureRequests, null);
  }

  FakeCameraDeviceWrapper(
      List<CaptureRequest.Builder> captureRequests, CameraCaptureSession session) {
    this.captureRequests = captureRequests;
    this.session = session;
  }

  @NonNull
  @Override
  public CaptureRequest.Builder createCaptureRequest(int var1) {
    return captureRequests.remove(0);
  }

  @Override
  public void createCaptureSession(SessionConfiguration config) {
    if (session != null) {
      config.getStateCallback().onConfigured(session);
    }
  }

  @Override
  public void createCaptureSession(
      @NonNull List<Surface> outputs,
      @NonNull CameraCaptureSession.StateCallback callback,
      @Nullable Handler handler) {
    if (session != null) {
      callback.onConfigured(session);
    }
  }

  @Override
  public void close() {}
}

public class CameraTest {
  private CameraProperties mockCameraProperties;
  private TestCameraFeatureFactory mockCameraFeatureFactory;
  private DartMessenger mockDartMessenger;
  private Camera camera;
  private CameraCaptureSession mockCaptureSession;
  private CaptureRequest.Builder mockPreviewRequestBuilder;
  private MockedStatic<Camera.HandlerThreadFactory> mockHandlerThreadFactory;
  private HandlerThread mockHandlerThread;
  private MockedStatic<Camera.HandlerFactory> mockHandlerFactory;
  private Handler mockHandler;

  private RangeConstruction mockRangeConstruction;

  @Before
  public void before() {

    mockRangeConstruction = new RangeConstruction();
    mockCameraProperties = mock(CameraProperties.class);
    mockDartMessenger = mock(DartMessenger.class);
    mockCaptureSession = mock(CameraCaptureSession.class);
    mockPreviewRequestBuilder = mock(CaptureRequest.Builder.class);
    mockHandlerThreadFactory = mockStatic(Camera.HandlerThreadFactory.class);
    mockHandlerThread = mock(HandlerThread.class);
    mockHandlerFactory = mockStatic(Camera.HandlerFactory.class);
    mockHandler = mock(Handler.class);

    final Activity mockActivity = mock(Activity.class);
    final TextureRegistry.SurfaceTextureEntry mockFlutterTexture =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final String cameraName = "1";
    final ResolutionPreset resolutionPreset = ResolutionPreset.high;
    final boolean enableAudio = false;

    when(mockCameraProperties.getCameraName()).thenReturn(cameraName);
    mockHandlerFactory.when(() -> Camera.HandlerFactory.create(any())).thenReturn(mockHandler);
    mockHandlerThreadFactory
        .when(() -> Camera.HandlerThreadFactory.create(any()))
        .thenReturn(mockHandlerThread);

    // Use a wildcard, since `new Range<Integer>[] {...}`
    // results in a 'Generic array creation' error.
    @SuppressWarnings("unchecked")
    final Range<Integer>[] mockRanges =
        (Range<Integer>[]) new Range<?>[] {new Range<Integer>(10, 20)};

    when(mockCameraProperties.getControlAutoExposureAvailableTargetFpsRanges())
        .thenReturn(mockRanges);

    final FpsRangeFeature fpsRangeFeature = new FpsRangeFeature(mockCameraProperties);

    mockCameraFeatureFactory = new TestCameraFeatureFactory(fpsRangeFeature);

    camera =
        new Camera(
            mockActivity,
            mockFlutterTexture,
            mockCameraFeatureFactory,
            mockDartMessenger,
            mockCameraProperties,
            new Camera.VideoCaptureSettings(resolutionPreset, enableAudio));

    final CamcorderProfile mockProfileLegacy = mock(CamcorderProfile.class);
    mockProfileLegacy.videoFrameRate = 15;
    when(camera.getRecordingProfileLegacy()).thenReturn(mockProfileLegacy);

    camera.captureSession = mockCaptureSession;
    camera.previewRequestBuilder = mockPreviewRequestBuilder;
  }

  @After
  public void after() throws IOException {
    SdkCapabilityChecker.SDK_VERSION = 0;
    mockHandlerThreadFactory.close();
    mockHandlerFactory.close();
    mockRangeConstruction.close();
  }

  @Test
  public void shouldNotImplementLifecycleObserverInterface() {
    Class<Camera> cameraClass = Camera.class;

    assertFalse(LifecycleObserver.class.isAssignableFrom(cameraClass));
  }

  @Test
  public void shouldCreateCameraPluginAndSetAllFeatures() {
    final Activity mockActivity = mock(Activity.class);
    final TextureRegistry.SurfaceTextureEntry mockFlutterTexture =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final CameraFeatureFactory spyMockCameraFeatureFactory = spy(mockCameraFeatureFactory);
    final String cameraName = "1";
    final ResolutionPreset resolutionPreset = ResolutionPreset.high;
    final boolean enableAudio = false;

    when(mockCameraProperties.getCameraName()).thenReturn(cameraName);
    SensorOrientationFeature mockSensorOrientationFeature = mock(SensorOrientationFeature.class);
    when(spyMockCameraFeatureFactory.createSensorOrientationFeature(any(), any(), any()))
        .thenReturn(mockSensorOrientationFeature);

    Camera camera =
        new Camera(
            mockActivity,
            mockFlutterTexture,
            spyMockCameraFeatureFactory,
            mockDartMessenger,
            mockCameraProperties,
            new Camera.VideoCaptureSettings(resolutionPreset, enableAudio));

    verify(spyMockCameraFeatureFactory, times(1))
        .createSensorOrientationFeature(mockCameraProperties, mockActivity, mockDartMessenger);
    verify(spyMockCameraFeatureFactory, times(1))
        .createAutoFocusFeature(mockCameraProperties, false);
    verify(spyMockCameraFeatureFactory, times(1)).createExposureLockFeature(mockCameraProperties);
    verify(spyMockCameraFeatureFactory, times(1))
        .createExposurePointFeature(eq(mockCameraProperties), eq(mockSensorOrientationFeature));
    verify(spyMockCameraFeatureFactory, times(1)).createExposureOffsetFeature(mockCameraProperties);
    verify(spyMockCameraFeatureFactory, times(1)).createFlashFeature(mockCameraProperties);
    verify(spyMockCameraFeatureFactory, times(1))
        .createFocusPointFeature(eq(mockCameraProperties), eq(mockSensorOrientationFeature));
    verify(spyMockCameraFeatureFactory, times(1)).createFpsRangeFeature(mockCameraProperties);
    verify(spyMockCameraFeatureFactory, times(1)).createNoiseReductionFeature(mockCameraProperties);
    verify(spyMockCameraFeatureFactory, times(1))
        .createResolutionFeature(mockCameraProperties, resolutionPreset, cameraName);
    verify(spyMockCameraFeatureFactory, times(1)).createZoomLevelFeature(mockCameraProperties);
    assertNotNull("should create a camera", camera);
  }

  @Test
  public void getDeviceOrientationManager() {
    SensorOrientationFeature mockSensorOrientationFeature =
        mockCameraFeatureFactory.createSensorOrientationFeature(mockCameraProperties, null, null);
    DeviceOrientationManager mockDeviceOrientationManager = mock(DeviceOrientationManager.class);

    when(mockSensorOrientationFeature.getDeviceOrientationManager())
        .thenReturn(mockDeviceOrientationManager);

    DeviceOrientationManager actualDeviceOrientationManager = camera.getDeviceOrientationManager();

    verify(mockSensorOrientationFeature, times(1)).getDeviceOrientationManager();
    assertEquals(mockDeviceOrientationManager, actualDeviceOrientationManager);
  }

  @Test
  public void getExposureOffsetStepSize() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    double stepSize = 2.3;

    when(mockExposureOffsetFeature.getExposureOffsetStepSize()).thenReturn(stepSize);

    double actualSize = camera.getExposureOffsetStepSize();

    verify(mockExposureOffsetFeature, times(1)).getExposureOffsetStepSize();
    assertEquals(stepSize, actualSize, 0);
  }

  @Test
  public void getMaxExposureOffset() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    double expectedMaxOffset = 42.0;

    when(mockExposureOffsetFeature.getMaxExposureOffset()).thenReturn(expectedMaxOffset);

    double actualMaxOffset = camera.getMaxExposureOffset();

    verify(mockExposureOffsetFeature, times(1)).getMaxExposureOffset();
    assertEquals(expectedMaxOffset, actualMaxOffset, 0);
  }

  @Test
  public void getMinExposureOffset() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    double expectedMinOffset = 21.5;

    when(mockExposureOffsetFeature.getMinExposureOffset()).thenReturn(21.5);

    double actualMinOffset = camera.getMinExposureOffset();

    verify(mockExposureOffsetFeature, times(1)).getMinExposureOffset();
    assertEquals(expectedMinOffset, actualMinOffset, 0);
  }

  @Test
  public void getMaxZoomLevel() {
    ZoomLevelFeature mockZoomLevelFeature =
        mockCameraFeatureFactory.createZoomLevelFeature(mockCameraProperties);
    float expectedMaxZoomLevel = 4.2f;

    when(mockZoomLevelFeature.getMaximumZoomLevel()).thenReturn(expectedMaxZoomLevel);

    float actualMaxZoomLevel = camera.getMaxZoomLevel();

    verify(mockZoomLevelFeature, times(1)).getMaximumZoomLevel();
    assertEquals(expectedMaxZoomLevel, actualMaxZoomLevel, 0);
  }

  @Test
  public void getMinZoomLevel() {
    ZoomLevelFeature mockZoomLevelFeature =
        mockCameraFeatureFactory.createZoomLevelFeature(mockCameraProperties);
    float expectedMinZoomLevel = 4.2f;

    when(mockZoomLevelFeature.getMinimumZoomLevel()).thenReturn(expectedMinZoomLevel);

    float actualMinZoomLevel = camera.getMinZoomLevel();

    verify(mockZoomLevelFeature, times(1)).getMinimumZoomLevel();
    assertEquals(expectedMinZoomLevel, actualMinZoomLevel, 0);
  }

  @Test
  public void setExposureMode_shouldUpdateExposureLockFeature() {
    ExposureLockFeature mockExposureLockFeature =
        mockCameraFeatureFactory.createExposureLockFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    ExposureMode exposureMode = ExposureMode.locked;

    camera.setExposureMode(mockResult, exposureMode);

    verify(mockExposureLockFeature, times(1)).setValue(exposureMode);
    verify(mockResult, never()).error(any(), any(), any());
    verify(mockResult, times(1)).success(null);
  }

  @Test
  public void setExposureMode_shouldUpdateBuilder() {
    ExposureLockFeature mockExposureLockFeature =
        mockCameraFeatureFactory.createExposureLockFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    ExposureMode exposureMode = ExposureMode.locked;

    camera.setExposureMode(mockResult, exposureMode);

    verify(mockExposureLockFeature, times(1)).updateBuilder(any());
  }

  @Test
  public void setExposureMode_shouldCallErrorOnResultOnCameraAccessException()
      throws CameraAccessException {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    ExposureMode exposureMode = ExposureMode.locked;
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));

    camera.setExposureMode(mockResult, exposureMode);

    verify(mockResult, never()).success(any());
    verify(mockResult, times(1))
        .error("setExposureModeFailed", "Could not set exposure mode.", null);
  }

  @Test
  public void setExposurePoint_shouldUpdateExposurePointFeature() {
    SensorOrientationFeature mockSensorOrientationFeature = mock(SensorOrientationFeature.class);
    ExposurePointFeature mockExposurePointFeature =
        mockCameraFeatureFactory.createExposurePointFeature(
            mockCameraProperties, mockSensorOrientationFeature);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);

    camera.setExposurePoint(mockResult, point);

    verify(mockExposurePointFeature, times(1)).setValue(point);
    verify(mockResult, never()).error(any(), any(), any());
    verify(mockResult, times(1)).success(null);
  }

  @Test
  public void setExposurePoint_shouldUpdateBuilder() {
    SensorOrientationFeature mockSensorOrientationFeature = mock(SensorOrientationFeature.class);
    ExposurePointFeature mockExposurePointFeature =
        mockCameraFeatureFactory.createExposurePointFeature(
            mockCameraProperties, mockSensorOrientationFeature);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);

    camera.setExposurePoint(mockResult, point);

    verify(mockExposurePointFeature, times(1)).updateBuilder(any());
  }

  @Test
  public void setExposurePoint_shouldCallErrorOnResultOnCameraAccessException()
      throws CameraAccessException {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));

    camera.setExposurePoint(mockResult, point);

    verify(mockResult, never()).success(any());
    verify(mockResult, times(1))
        .error("setExposurePointFailed", "Could not set exposure point.", null);
  }

  @Test
  public void setFlashMode_shouldUpdateFlashFeature() {
    FlashFeature mockFlashFeature =
        mockCameraFeatureFactory.createFlashFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    FlashMode flashMode = FlashMode.always;

    camera.setFlashMode(mockResult, flashMode);

    verify(mockFlashFeature, times(1)).setValue(flashMode);
    verify(mockResult, never()).error(any(), any(), any());
    verify(mockResult, times(1)).success(null);
  }

  @Test
  public void setFlashMode_shouldUpdateBuilder() {
    FlashFeature mockFlashFeature =
        mockCameraFeatureFactory.createFlashFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    FlashMode flashMode = FlashMode.always;

    camera.setFlashMode(mockResult, flashMode);

    verify(mockFlashFeature, times(1)).updateBuilder(any());
  }

  @Test
  public void setFlashMode_shouldCallErrorOnResultOnCameraAccessException()
      throws CameraAccessException {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    FlashMode flashMode = FlashMode.always;
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));

    camera.setFlashMode(mockResult, flashMode);

    verify(mockResult, never()).success(any());
    verify(mockResult, times(1)).error("setFlashModeFailed", "Could not set flash mode.", null);
  }

  @Test
  public void setFocusPoint_shouldUpdateFocusPointFeature() {
    SensorOrientationFeature mockSensorOrientationFeature = mock(SensorOrientationFeature.class);
    FocusPointFeature mockFocusPointFeature =
        mockCameraFeatureFactory.createFocusPointFeature(
            mockCameraProperties, mockSensorOrientationFeature);
    AutoFocusFeature mockAutoFocusFeature =
        mockCameraFeatureFactory.createAutoFocusFeature(mockCameraProperties, false);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);
    when(mockAutoFocusFeature.getValue()).thenReturn(FocusMode.auto);

    camera.setFocusPoint(mockResult, point);

    verify(mockFocusPointFeature, times(1)).setValue(point);
    verify(mockResult, never()).error(any(), any(), any());
    verify(mockResult, times(1)).success(null);
  }

  @Test
  public void setFocusPoint_shouldUpdateBuilder() {
    SensorOrientationFeature mockSensorOrientationFeature = mock(SensorOrientationFeature.class);
    FocusPointFeature mockFocusPointFeature =
        mockCameraFeatureFactory.createFocusPointFeature(
            mockCameraProperties, mockSensorOrientationFeature);
    AutoFocusFeature mockAutoFocusFeature =
        mockCameraFeatureFactory.createAutoFocusFeature(mockCameraProperties, false);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);
    when(mockAutoFocusFeature.getValue()).thenReturn(FocusMode.auto);

    camera.setFocusPoint(mockResult, point);

    verify(mockFocusPointFeature, times(1)).updateBuilder(any());
  }

  @Test
  public void setFocusPoint_shouldCallErrorOnResultOnCameraAccessException()
      throws CameraAccessException {
    AutoFocusFeature mockAutoFocusFeature =
        mockCameraFeatureFactory.createAutoFocusFeature(mockCameraProperties, false);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);
    when(mockAutoFocusFeature.getValue()).thenReturn(FocusMode.auto);
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));

    camera.setFocusPoint(mockResult, point);

    verify(mockResult, never()).success(any());
    verify(mockResult, times(1)).error("setFocusPointFailed", "Could not set focus point.", null);
  }

  @Test
  public void setZoomLevel_shouldUpdateZoomLevelFeature() throws CameraAccessException {
    ZoomLevelFeature mockZoomLevelFeature =
        mockCameraFeatureFactory.createZoomLevelFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    float zoomLevel = 1.0f;

    when(mockZoomLevelFeature.getValue()).thenReturn(zoomLevel);
    when(mockZoomLevelFeature.getMinimumZoomLevel()).thenReturn(0f);
    when(mockZoomLevelFeature.getMaximumZoomLevel()).thenReturn(2f);

    camera.setZoomLevel(mockResult, zoomLevel);

    verify(mockZoomLevelFeature, times(1)).setValue(zoomLevel);
    verify(mockResult, never()).error(any(), any(), any());
    verify(mockResult, times(1)).success(null);
  }

  @Test
  public void setZoomLevel_shouldUpdateBuilder() throws CameraAccessException {
    ZoomLevelFeature mockZoomLevelFeature =
        mockCameraFeatureFactory.createZoomLevelFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    float zoomLevel = 1.0f;

    when(mockZoomLevelFeature.getValue()).thenReturn(zoomLevel);
    when(mockZoomLevelFeature.getMinimumZoomLevel()).thenReturn(0f);
    when(mockZoomLevelFeature.getMaximumZoomLevel()).thenReturn(2f);

    camera.setZoomLevel(mockResult, zoomLevel);

    verify(mockZoomLevelFeature, times(1)).updateBuilder(any());
  }

  @Test
  public void setZoomLevel_shouldCallErrorOnResultOnCameraAccessException()
      throws CameraAccessException {
    ZoomLevelFeature mockZoomLevelFeature =
        mockCameraFeatureFactory.createZoomLevelFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    float zoomLevel = 1.0f;

    when(mockZoomLevelFeature.getValue()).thenReturn(zoomLevel);
    when(mockZoomLevelFeature.getMinimumZoomLevel()).thenReturn(0f);
    when(mockZoomLevelFeature.getMaximumZoomLevel()).thenReturn(2f);
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));

    camera.setZoomLevel(mockResult, zoomLevel);

    verify(mockResult, never()).success(any());
    verify(mockResult, times(1)).error("setZoomLevelFailed", "Could not set zoom level.", null);
  }

  @Test
  public void pauseVideoRecording_shouldSendNullResultWhenNotRecording() {
    camera.recordingVideo = false;
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.pauseVideoRecording(mockResult);

    verify(mockResult, times(1)).success(null);
    verify(mockResult, never()).error(any(), any(), any());
  }

  @Test
  public void pauseVideoRecording_shouldCallPauseWhenRecordingAndOnAPIN() {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    camera.mediaRecorder = mockMediaRecorder;
    camera.recordingVideo = true;
    SdkCapabilityChecker.SDK_VERSION = 24;

    camera.pauseVideoRecording(mockResult);

    verify(mockMediaRecorder, times(1)).pause();
    verify(mockResult, times(1)).success(null);
    verify(mockResult, never()).error(any(), any(), any());
  }

  @Test
  public void pauseVideoRecording_shouldSendVideoRecordingFailedErrorWhenVersionCodeSmallerThenN() {
    camera.recordingVideo = true;
    SdkCapabilityChecker.SDK_VERSION = 23;
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.pauseVideoRecording(mockResult);

    verify(mockResult, times(1))
        .error("videoRecordingFailed", "pauseVideoRecording requires Android API +24.", null);
    verify(mockResult, never()).success(any());
  }

  @Test
  public void
      pauseVideoRecording_shouldSendVideoRecordingFailedErrorWhenMediaRecorderPauseThrowsIllegalStateException() {
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    camera.mediaRecorder = mockMediaRecorder;
    camera.recordingVideo = true;
    SdkCapabilityChecker.SDK_VERSION = 24;

    IllegalStateException expectedException = new IllegalStateException("Test error message");

    doThrow(expectedException).when(mockMediaRecorder).pause();

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.pauseVideoRecording(mockResult);

    verify(mockResult, times(1)).error("videoRecordingFailed", "Test error message", null);
    verify(mockResult, never()).success(any());
  }

  @Test
  public void resumeVideoRecording_shouldSendNullResultWhenNotRecording() {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    camera.recordingVideo = false;

    camera.resumeVideoRecording(mockResult);

    verify(mockResult, times(1)).success(null);
    verify(mockResult, never()).error(any(), any(), any());
  }

  @Test
  public void resumeVideoRecording_shouldCallPauseWhenRecordingAndOnAPIN() {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    camera.mediaRecorder = mockMediaRecorder;
    camera.recordingVideo = true;
    SdkCapabilityChecker.SDK_VERSION = 24;

    camera.resumeVideoRecording(mockResult);

    verify(mockMediaRecorder, times(1)).resume();
    verify(mockResult, times(1)).success(null);
    verify(mockResult, never()).error(any(), any(), any());
  }

  @Test
  public void setDescriptionWhileRecording_errorsWhenUnsupported() {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    VideoRenderer mockVideoRenderer = mock(VideoRenderer.class);
    camera.mediaRecorder = mockMediaRecorder;
    camera.recordingVideo = true;
    camera.videoRenderer = mockVideoRenderer;
    SdkCapabilityChecker.SDK_VERSION = Build.VERSION_CODES.LOLLIPOP;

    final CameraProperties newCameraProperties = mock(CameraProperties.class);
    camera.setDescriptionWhileRecording(mockResult, newCameraProperties);

    verify(mockResult, times(1))
        .error(
            eq("setDescriptionWhileRecordingFailed"),
            eq("Device does not support switching the camera while recording"),
            eq(null));
  }

  @Test
  public void setDescriptionWhileRecording_succeedsWhenSupported() {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    VideoRenderer mockVideoRenderer = mock(VideoRenderer.class);
    camera.mediaRecorder = mockMediaRecorder;
    camera.recordingVideo = true;
    camera.videoRenderer = mockVideoRenderer;
    SdkCapabilityChecker.SDK_VERSION = Build.VERSION_CODES.O;

    final CameraProperties newCameraProperties = mock(CameraProperties.class);
    camera.setDescriptionWhileRecording(mockResult, newCameraProperties);

    verify(mockResult, times(1)).success(null);
    verify(mockResult, never()).error(any(), any(), any());
  }

  @Test
  public void startPreview_shouldPullStreamFromVideoRenderer()
      throws InterruptedException, CameraAccessException {
    VideoRenderer mockVideoRenderer = mock(VideoRenderer.class);
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    Size mockSize = mock(Size.class);
    camera.recordingVideo = true;
    camera.videoRenderer = mockVideoRenderer;
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    camera.cameraDevice = fakeCamera;
    ImageReader mockPictureImageReader = mock(ImageReader.class);
    camera.pictureImageReader = mockPictureImageReader;

    TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = camera.flutterTexture;
    ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

    when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);

    camera.startPreview();
    verify(mockVideoRenderer, times(1))
        .getInputSurface(); // stream pulled from videoRenderer's surface.
  }

  @Test
  public void startPreview_shouldPullStreamFromImageReader()
      throws InterruptedException, CameraAccessException {
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    Size mockSize = mock(Size.class);
    ImageReader mockImageReader = mock(ImageReader.class);
    camera.recordingVideo = false;
    camera.pictureImageReader = mockImageReader;
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    camera.cameraDevice = fakeCamera;

    TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = camera.flutterTexture;
    ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

    when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);
    when(mockImageReader.getSurface()).thenReturn(mock(Surface.class));

    camera.startPreview();
    verify(mockImageReader, times(2)) // we expect two calls to start regular preview.
        .getSurface(); // stream pulled from regular imageReader's surface.
  }

  @Test
  public void startPreview_shouldFlipRotation() throws InterruptedException, CameraAccessException {
    VideoRenderer mockVideoRenderer = mock(VideoRenderer.class);
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    Size mockSize = mock(Size.class);
    camera.recordingVideo = true;
    camera.videoRenderer = mockVideoRenderer;
    camera.initialCameraFacing = CameraMetadata.LENS_FACING_BACK;
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    camera.cameraDevice = fakeCamera;
    ImageReader mockPictureImageReader = mock(ImageReader.class);
    camera.pictureImageReader = mockPictureImageReader;

    TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = camera.flutterTexture;
    ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

    when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);
    when(mockCameraProperties.getLensFacing()).thenReturn(CameraMetadata.LENS_FACING_FRONT);

    camera.startPreview();
    verify(mockVideoRenderer, times(1)).setRotation(180);
  }

  @Test
  public void startPreviewWithImageStream_shouldPullStreamsFromImageReaders()
      throws InterruptedException, CameraAccessException {
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    Size mockSize = mock(Size.class);
    ImageReader mockPictureImageReader = mock(ImageReader.class);
    ImageStreamReader mockImageStreamReader = mock(ImageStreamReader.class);
    camera.recordingVideo = false;
    camera.pictureImageReader = mockPictureImageReader;
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    camera.cameraDevice = fakeCamera;
    camera.imageStreamReader = mockImageStreamReader;

    TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = camera.flutterTexture;
    ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

    when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);

    camera.startPreviewWithImageStream(mock(EventChannel.class));
    verify(mockImageStreamReader, times(1))
        .getSurface(); // stream pulled from image streaming imageReader's surface.
    verify(
            mockPictureImageReader,
            times(2)) // we expect one call to start the capture, one to create the capture session.
        .getSurface(); // stream pulled from regular imageReader's surface.
  }

  @Test
  public void setDescriptionWhileRecording_shouldErrorWhenNotRecording() {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    camera.recordingVideo = false;
    final CameraProperties newCameraProperties = mock(CameraProperties.class);
    camera.setDescriptionWhileRecording(mockResult, newCameraProperties);

    verify(mockResult, times(1))
        .error("setDescriptionWhileRecordingFailed", "Device was not recording", null);
    verify(mockResult, never()).success(any());
  }

  @Test
  public void
      resumeVideoRecording_shouldSendVideoRecordingFailedErrorWhenVersionCodeSmallerThanN() {
    camera.recordingVideo = true;
    SdkCapabilityChecker.SDK_VERSION = 23;

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.resumeVideoRecording(mockResult);

    verify(mockResult, times(1))
        .error("videoRecordingFailed", "resumeVideoRecording requires Android API +24.", null);
    verify(mockResult, never()).success(any());
  }

  @Test
  public void
      resumeVideoRecording_shouldSendVideoRecordingFailedErrorWhenMediaRecorderPauseThrowsIllegalStateException() {
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    camera.mediaRecorder = mockMediaRecorder;
    camera.recordingVideo = true;
    SdkCapabilityChecker.SDK_VERSION = 24;

    IllegalStateException expectedException = new IllegalStateException("Test error message");

    doThrow(expectedException).when(mockMediaRecorder).resume();

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.resumeVideoRecording(mockResult);

    verify(mockResult, times(1)).error("videoRecordingFailed", "Test error message", null);
    verify(mockResult, never()).success(any());
  }

  @Test
  public void setFocusMode_shouldUpdateAutoFocusFeature() {
    AutoFocusFeature mockAutoFocusFeature =
        mockCameraFeatureFactory.createAutoFocusFeature(mockCameraProperties, false);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.setFocusMode(mockResult, FocusMode.auto);

    verify(mockAutoFocusFeature, times(1)).setValue(FocusMode.auto);
    verify(mockResult, never()).error(any(), any(), any());
    verify(mockResult, times(1)).success(null);
  }

  @Test
  public void setFocusMode_shouldUpdateBuilder() {
    AutoFocusFeature mockAutoFocusFeature =
        mockCameraFeatureFactory.createAutoFocusFeature(mockCameraProperties, false);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.setFocusMode(mockResult, FocusMode.auto);

    verify(mockAutoFocusFeature, times(1)).updateBuilder(any());
  }

  @Test
  public void setFocusMode_shouldUnlockAutoFocusForAutoMode() {
    camera.setFocusMode(mock(MethodChannel.Result.class), FocusMode.auto);
    verify(mockPreviewRequestBuilder, times(1))
        .set(CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_CANCEL);
    verify(mockPreviewRequestBuilder, times(1))
        .set(CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_IDLE);
  }

  @Test
  public void setFocusMode_shouldSkipUnlockAutoFocusWhenNullCaptureSession() {
    camera.captureSession = null;
    camera.setFocusMode(mock(MethodChannel.Result.class), FocusMode.auto);
    verify(mockPreviewRequestBuilder, never())
        .set(CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_CANCEL);
    verify(mockPreviewRequestBuilder, never())
        .set(CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_IDLE);
  }

  @Test
  public void setFocusMode_shouldSendErrorEventOnUnlockAutoFocusCameraAccessException()
      throws CameraAccessException {
    when(mockCaptureSession.capture(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));
    camera.setFocusMode(mock(MethodChannel.Result.class), FocusMode.auto);
    verify(mockDartMessenger, times(1)).sendCameraErrorEvent(any());
  }

  @Test
  public void startVideoRecording_shouldPullStreamsFromMediaRecorderAndImageReader()
      throws InterruptedException, IOException, CameraAccessException {
    Camera cameraSpy = spy(camera);
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    Size mockSize = mock(Size.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    ImageReader mockPictureImageReader = mock(ImageReader.class);
    cameraSpy.mediaRecorder = mockMediaRecorder;
    cameraSpy.recordingVideo = false;
    cameraSpy.pictureImageReader = mockPictureImageReader;
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    cameraSpy.cameraDevice = fakeCamera;
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = cameraSpy.flutterTexture;
    ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

    when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);
    doNothing().when(cameraSpy).prepareRecording(mockResult);

    cameraSpy.startVideoRecording(mockResult, null);
    verify(mockMediaRecorder, times(1))
        .getSurface(); // stream pulled from media recorder's surface.
    verify(
            mockPictureImageReader,
            times(2)) // we expect one call to start the capture, one to create the capture session.
        .getSurface(); // stream pulled from image streaming imageReader's surface.
  }

  @Test
  public void setFocusMode_shouldLockAutoFocusForLockedMode() throws CameraAccessException {
    camera.setFocusMode(mock(MethodChannel.Result.class), FocusMode.locked);
    verify(mockPreviewRequestBuilder, times(1))
        .set(CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_START);
    verify(mockCaptureSession, times(1)).capture(any(), any(), any());
    verify(mockCaptureSession, times(1)).setRepeatingRequest(any(), any(), any());
  }

  @Test
  public void setFocusMode_shouldSkipLockAutoFocusWhenNullCaptureSession() {
    camera.captureSession = null;
    camera.setFocusMode(mock(MethodChannel.Result.class), FocusMode.locked);
    verify(mockPreviewRequestBuilder, never())
        .set(CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_START);
  }

  @Test
  public void setFocusMode_shouldSendErrorEventOnLockAutoFocusCameraAccessException()
      throws CameraAccessException {
    when(mockCaptureSession.capture(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));
    camera.setFocusMode(mock(MethodChannel.Result.class), FocusMode.locked);
    verify(mockDartMessenger, times(1)).sendCameraErrorEvent(any());
  }

  @Test
  public void setFocusMode_shouldCallErrorOnResultOnCameraAccessException()
      throws CameraAccessException {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));

    camera.setFocusMode(mockResult, FocusMode.locked);

    verify(mockResult, never()).success(any());
    verify(mockResult, times(1))
        .error("setFocusModeFailed", "Error setting focus mode: null", null);
  }

  @Test
  public void setExposureOffset_shouldUpdateExposureOffsetFeature() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    when(mockExposureOffsetFeature.getValue()).thenReturn(1.0);

    camera.setExposureOffset(mockResult, 1.0);

    verify(mockExposureOffsetFeature, times(1)).setValue(1.0);
    verify(mockResult, never()).error(any(), any(), any());
    verify(mockResult, times(1)).success(1.0);
  }

  @Test
  public void setExposureOffset_shouldAndUpdateBuilder() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    camera.setExposureOffset(mockResult, 1.0);

    verify(mockExposureOffsetFeature, times(1)).updateBuilder(any());
  }

  @Test
  public void setExposureOffset_shouldCallErrorOnResultOnCameraAccessException()
      throws CameraAccessException {
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0, ""));

    camera.setExposureOffset(mockResult, 1.0);

    verify(mockResult, never()).success(any());
    verify(mockResult, times(1))
        .error("setExposureOffsetFailed", "Could not set exposure offset.", null);
  }

  @Test
  public void lockCaptureOrientation_shouldLockCaptureOrientation() {
    final Activity mockActivity = mock(Activity.class);
    SensorOrientationFeature mockSensorOrientationFeature =
        mockCameraFeatureFactory.createSensorOrientationFeature(
            mockCameraProperties, mockActivity, mockDartMessenger);

    camera.lockCaptureOrientation(PlatformChannel.DeviceOrientation.PORTRAIT_UP);

    verify(mockSensorOrientationFeature, times(1))
        .lockCaptureOrientation(PlatformChannel.DeviceOrientation.PORTRAIT_UP);
  }

  @Test
  public void unlockCaptureOrientation_shouldUnlockCaptureOrientation() {
    final Activity mockActivity = mock(Activity.class);
    SensorOrientationFeature mockSensorOrientationFeature =
        mockCameraFeatureFactory.createSensorOrientationFeature(
            mockCameraProperties, mockActivity, mockDartMessenger);

    camera.unlockCaptureOrientation();

    verify(mockSensorOrientationFeature, times(1)).unlockCaptureOrientation();
  }

  @Test
  public void pausePreview_shouldPausePreview() throws CameraAccessException {
    camera.pausePreview();

    camera.pausedPreview = true;
    verify(mockCaptureSession, times(1)).stopRepeating();
  }

  @Test
  public void resumePreview_shouldResumePreview() throws CameraAccessException {
    camera.resumePreview();

    camera.pausedPreview = false;
    verify(mockCaptureSession, times(1)).setRepeatingRequest(any(), any(), any());
  }

  @Test
  public void resumePreview_shouldSendErrorEventOnCameraAccessException()
      throws CameraAccessException {
    when(mockCaptureSession.setRepeatingRequest(any(), any(), any()))
        .thenThrow(new CameraAccessException(0));

    camera.resumePreview();

    verify(mockDartMessenger, times(1)).sendCameraErrorEvent(any());
  }

  @Test
  public void startBackgroundThread_shouldStartNewThread() {
    camera.startBackgroundThread();

    verify(mockHandlerThread, times(1)).start();
    assertEquals(mockHandler, camera.backgroundHandler);
  }

  @Test
  public void startBackgroundThread_shouldNotStartNewThreadWhenAlreadyCreated() {
    camera.startBackgroundThread();
    camera.startBackgroundThread();

    verify(mockHandlerThread, times(1)).start();
  }

  @Test
  public void stopBackgroundThread_quitsSafely() throws InterruptedException {
    camera.startBackgroundThread();
    camera.stopBackgroundThread();

    verify(mockHandlerThread).quitSafely();
    verify(mockHandlerThread, never()).join();
  }

  @Test
  public void onConverge_shouldTakePictureWithoutAbortingSession() throws CameraAccessException {
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    // Stub out other features used by the flow.
    camera.cameraDevice = fakeCamera;
    camera.pictureImageReader = mock(ImageReader.class);
    SensorOrientationFeature mockSensorOrientationFeature =
        mockCameraFeatureFactory.createSensorOrientationFeature(mockCameraProperties, null, null);
    DeviceOrientationManager mockDeviceOrientationManager = mock(DeviceOrientationManager.class);
    when(mockSensorOrientationFeature.getDeviceOrientationManager())
        .thenReturn(mockDeviceOrientationManager);

    // Simulate a post-precapture flow.
    camera.onConverged();
    // A picture should be taken.
    verify(mockCaptureSession, times(1)).capture(any(), any(), any());
    // The session shuold not be aborted as part of this flow, as this breaks capture on some
    // devices, and causes delays on others.
    verify(mockCaptureSession, never()).abortCaptures();
  }

  @Test
  public void createCaptureSession_doesNotCloseCaptureSession() throws CameraAccessException {
    Surface mockSurface = mock(Surface.class);
    SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    ResolutionFeature mockResolutionFeature = mock(ResolutionFeature.class);
    Size mockSize = mock(Size.class);
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    camera.cameraDevice = fakeCamera;

    TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = camera.flutterTexture;
    CameraFeatures cameraFeatures = camera.cameraFeatures;
    ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

    when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);

    camera.createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, mockSurface);

    verify(mockCaptureSession, never()).close();
  }

  @Test
  public void createCaptureSession_shouldNotAddPictureImageSurfaceToPreviewRequest()
      throws CameraAccessException {
    Surface mockSurface = mock(Surface.class);
    Surface mockSecondarySurface = mock(Surface.class);
    SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    ResolutionFeature mockResolutionFeature = mock(ResolutionFeature.class);
    Size mockSize = mock(Size.class);
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    CameraDeviceWrapper fakeCamera = spy(new FakeCameraDeviceWrapper(mockRequestBuilders));
    ImageReader mockPictureImageReader = mock(ImageReader.class);
    camera.cameraDevice = fakeCamera;
    camera.pictureImageReader = mockPictureImageReader;
    CaptureRequest.Builder mockPreviewRequestBuilder = mock(CaptureRequest.Builder.class);

    TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = camera.flutterTexture;
    CameraFeatures cameraFeatures = camera.cameraFeatures;
    ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

    when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);
    when(fakeCamera.createCaptureRequest(anyInt())).thenReturn(mockPreviewRequestBuilder);
    when(mockPictureImageReader.getSurface()).thenReturn(mockSurface);

    // Test with preview template.
    camera.createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, mockSurface, mockSecondarySurface);
    verify(mockPreviewRequestBuilder, times(0)).addTarget(mockSurface);

    // Test with non-preview template.
    camera.createCaptureSession(CameraDevice.TEMPLATE_RECORD, mockSurface, mockSecondarySurface);
    verify(mockPreviewRequestBuilder, times(0)).addTarget(mockSurface);
    verify(mockPreviewRequestBuilder).addTarget(mockSecondarySurface);
  }

  @Test
  public void close_doesCloseCaptureSessionWhenCameraDeviceNull() {
    camera.close();

    verify(mockCaptureSession).close();
  }

  @Test
  public void close_doesNotCloseCaptureSessionWhenCameraDeviceNonNull() {
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    camera.cameraDevice = fakeCamera;

    camera.close();

    verify(mockCaptureSession, never()).close();
  }

  @Test
  public void startVideoRecording_shouldApplySettingsToMediaRecorder()
      throws InterruptedException, IOException, CameraAccessException {

    final Activity mockActivity = mock(Activity.class);
    final TextureRegistry.SurfaceTextureEntry mockFlutterTexture =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final String cameraName = "1";
    final ResolutionPreset resolutionPreset = ResolutionPreset.high;
    final boolean enableAudio = true;

    //region These parameters should be set in android MediaRecorder.
    final int fps = 15;
    final int videoBitrate = 200000;
    final int audioBitrate = 32000;
    //endregion

    when(mockCameraProperties.getCameraName()).thenReturn(cameraName);

    final Camera.VideoCaptureSettings parameters =
        new Camera.VideoCaptureSettings(
            resolutionPreset, enableAudio, fps, videoBitrate, audioBitrate);

    // Use a wildcard, since `new Range<Integer>[] {...}`
    // results in a 'Generic array creation' error.
    @SuppressWarnings("unchecked")
    final Range<Integer>[] mockRanges =
        (Range<Integer>[]) new Range<?>[] {new Range<Integer>(10, 20)};

    when(mockCameraProperties.getControlAutoExposureAvailableTargetFpsRanges())
        .thenReturn(mockRanges);

    final Context mockApplicationContext = mock(Context.class);
    when(mockActivity.getApplicationContext()).thenReturn(mockApplicationContext);

    try (final MockedStatic<File> mockFile = mockStatic(File.class);
        final MockedConstruction<MediaRecorder> mockMediaRecorder =
            Mockito.mockConstruction(MediaRecorder.class)) {

      assertNotNull(mockMediaRecorder);

      mockFile
          .when(() -> File.createTempFile(any(), any(), any()))
          .thenReturn(new File("/tmp/file.mp4"));

      final FpsRangeFeature fpsRangeFeature = new FpsRangeFeature(mockCameraProperties);

      final Camera camera =
          spy(
              new Camera(
                  mockActivity,
                  mockFlutterTexture,
                  mockCameraFeatureFactory,
                  mockDartMessenger,
                  mockCameraProperties,
                  parameters));

      final CamcorderProfile mockProfileLegacy = mock(CamcorderProfile.class);
      mockProfileLegacy.videoFrameRate = fps;
      when(camera.getRecordingProfileLegacy()).thenReturn(mockProfileLegacy);

      final SensorOrientationFeature mockSensorOrientationFeature =
          mockCameraFeatureFactory.createSensorOrientationFeature(mockCameraProperties, null, null);
      DeviceOrientationManager mockDeviceOrientationManager = mock(DeviceOrientationManager.class);

      when(mockSensorOrientationFeature.getDeviceOrientationManager())
          .thenReturn(mockDeviceOrientationManager);

      camera.captureSession = mockCaptureSession;
      camera.previewRequestBuilder = mockPreviewRequestBuilder;

      final ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
      CaptureRequest.Builder mockRequestBuilder = mock(CaptureRequest.Builder.class);
      mockRequestBuilders.add(mockRequestBuilder);
      final SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
      final Size mockSize = mock(Size.class);
      final ImageReader mockPictureImageReader = mock(ImageReader.class);
      camera.pictureImageReader = mockPictureImageReader;
      final CameraDeviceWrapper fakeCamera =
          new FakeCameraDeviceWrapper(mockRequestBuilders, mockCaptureSession);

      camera.cameraDevice = fakeCamera;
      MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

      TextureRegistry.SurfaceTextureEntry cameraFlutterTexture = camera.flutterTexture;

      ResolutionFeature resolutionFeature = mockCameraFeatureFactory.mockResolutionFeature;

      assertNotNull(cameraFlutterTexture);
      when(cameraFlutterTexture.surfaceTexture()).thenReturn(mockSurfaceTexture);

      assertNotNull(resolutionFeature);
      when(resolutionFeature.getPreviewSize()).thenReturn(mockSize);

      camera.startVideoRecording(mockResult, null);

      //region Check that FPS parameter affects AE range at which the camera captures frames.
      assertEquals(camera.cameraFeatures.getFpsRange().getValue().getLower(), Integer.valueOf(fps));
      assertEquals(camera.cameraFeatures.getFpsRange().getValue().getUpper(), Integer.valueOf(fps));

      verify(mockRequestBuilder)
          .set(
              eq(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE),
              argThat(
                  (Range<Integer> range) -> range.getLower() == fps && range.getUpper() == fps));
      //endregion

      final MediaRecorder recorder = camera.mediaRecorder;

      //region Check that parameters affects movies, written by MediaRecorder.
      verify(recorder).setVideoFrameRate(fps);
      verify(recorder).setAudioEncodingBitRate(audioBitrate);
      verify(recorder).setVideoEncodingBitRate(videoBitrate);
      //endregion
    }
  }

  @Test
  public void pausePreview_doesNotCallStopRepeatingWhenCameraClosed() throws CameraAccessException {
    ArrayList<CaptureRequest.Builder> mockRequestBuilders = new ArrayList<>();
    mockRequestBuilders.add(mock(CaptureRequest.Builder.class));
    CameraDeviceWrapper fakeCamera = new FakeCameraDeviceWrapper(mockRequestBuilders);
    camera.cameraDevice = fakeCamera;

    camera.close();
    camera.pausePreview();

    verify(mockCaptureSession, never()).stopRepeating();
  }

  /// Allow to use `new android.util.Range(Integer, Integer)`
  private static class RangeConstruction implements Closeable {
    final Map<Range<Integer>, Integer> lowers = new HashMap<>();
    final Map<Range<Integer>, Integer> uppers = new HashMap<>();

    @SuppressWarnings({"rawtypes"})
    final MockedConstruction<Range> rangeMockedConstruction;

    @SuppressWarnings({"unchecked"})
    public RangeConstruction() {
      this.rangeMockedConstruction =
          Mockito.mockConstruction(
              Range.class,
              (mock, context) -> {
                int lower = (int) context.arguments().get(0);
                int upper = (int) context.arguments().get(1);
                lowers.put((Range<Integer>) mock, lower);
                uppers.put((Range<Integer>) mock, upper);
                when(((Range<Integer>) mock).getUpper())
                    .thenReturn(lowers.getOrDefault((Range<Integer>) mock, 15));
                when(((Range<Integer>) mock).getLower())
                    .thenReturn(uppers.getOrDefault((Range<Integer>) mock, 15));
                when(mock.toString())
                    .thenReturn(
                        String.format(
                            "mocked [%s, %s]",
                            lowers.getOrDefault(mock, 15), uppers.getOrDefault(mock, 15)));
              });
    }

    @Override
    public void close() throws IOException {
      rangeMockedConstruction.close();
    }
  }

  private static class TestCameraFeatureFactory implements CameraFeatureFactory {
    private final AutoFocusFeature mockAutoFocusFeature;
    private final ExposureLockFeature mockExposureLockFeature;
    private final ExposureOffsetFeature mockExposureOffsetFeature;
    private final ExposurePointFeature mockExposurePointFeature;
    private final FlashFeature mockFlashFeature;
    private final FocusPointFeature mockFocusPointFeature;
    private final FpsRangeFeature mockFpsRangeFeature;
    private final NoiseReductionFeature mockNoiseReductionFeature;
    private final ResolutionFeature mockResolutionFeature;
    private final SensorOrientationFeature mockSensorOrientationFeature;
    private final ZoomLevelFeature mockZoomLevelFeature;

    public TestCameraFeatureFactory(FpsRangeFeature fpsRangeFeature) {
      this.mockAutoFocusFeature = mock(AutoFocusFeature.class);
      this.mockExposureLockFeature = mock(ExposureLockFeature.class);
      this.mockExposureOffsetFeature = mock(ExposureOffsetFeature.class);
      this.mockExposurePointFeature = mock(ExposurePointFeature.class);
      this.mockFlashFeature = mock(FlashFeature.class);
      this.mockFocusPointFeature = mock(FocusPointFeature.class);
      this.mockFpsRangeFeature = fpsRangeFeature;
      this.mockNoiseReductionFeature = mock(NoiseReductionFeature.class);
      this.mockResolutionFeature = mock(ResolutionFeature.class);
      this.mockSensorOrientationFeature = mock(SensorOrientationFeature.class);
      this.mockZoomLevelFeature = mock(ZoomLevelFeature.class);
    }

    @Override
    public AutoFocusFeature createAutoFocusFeature(
        @NonNull CameraProperties cameraProperties, boolean recordingVideo) {
      return mockAutoFocusFeature;
    }

    @Override
    public ExposureLockFeature createExposureLockFeature(
        @NonNull CameraProperties cameraProperties) {
      return mockExposureLockFeature;
    }

    @Override
    public ExposureOffsetFeature createExposureOffsetFeature(
        @NonNull CameraProperties cameraProperties) {
      return mockExposureOffsetFeature;
    }

    @Override
    public FlashFeature createFlashFeature(@NonNull CameraProperties cameraProperties) {
      return mockFlashFeature;
    }

    @Override
    public ResolutionFeature createResolutionFeature(
        @NonNull CameraProperties cameraProperties,
        ResolutionPreset initialSetting,
        String cameraName) {
      return mockResolutionFeature;
    }

    @Override
    public FocusPointFeature createFocusPointFeature(
        @NonNull CameraProperties cameraProperties,
        @NonNull SensorOrientationFeature sensorOrienttionFeature) {
      return mockFocusPointFeature;
    }

    @Override
    public FpsRangeFeature createFpsRangeFeature(@NonNull CameraProperties cameraProperties) {
      return mockFpsRangeFeature;
    }

    @Override
    public SensorOrientationFeature createSensorOrientationFeature(
        @NonNull CameraProperties cameraProperties,
        @NonNull Activity activity,
        @NonNull DartMessenger dartMessenger) {
      return mockSensorOrientationFeature;
    }

    @Override
    public ZoomLevelFeature createZoomLevelFeature(@NonNull CameraProperties cameraProperties) {
      return mockZoomLevelFeature;
    }

    @Override
    public ExposurePointFeature createExposurePointFeature(
        @NonNull CameraProperties cameraProperties,
        @NonNull SensorOrientationFeature sensorOrientationFeature) {
      return mockExposurePointFeature;
    }

    @Override
    public NoiseReductionFeature createNoiseReductionFeature(
        @NonNull CameraProperties cameraProperties) {
      return mockNoiseReductionFeature;
    }
  }
}
