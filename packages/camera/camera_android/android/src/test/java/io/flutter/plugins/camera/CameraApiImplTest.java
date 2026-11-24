// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraManager;
import android.media.MediaRecorder;
import androidx.lifecycle.LifecycleObserver;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;
import java.util.ArrayList;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedConstruction;

public class CameraApiImplTest {

  CameraApiImpl handler;
  Messages.VoidResult mockResult;
  Camera mockCamera;

  @Before
  public void setUp() {
    handler =
        new CameraApiImpl(
            mock(Activity.class),
            mock(BinaryMessenger.class),
            mock(CameraPermissions.class),
            mock(CameraPermissions.PermissionsRegistry.class),
            mock(TextureRegistry.class));
    mockResult = mock(Messages.VoidResult.class);
    mockCamera = mock(Camera.class);
    handler.camera = mockCamera;
  }

  @Test
  public void shouldNotImplementLifecycleObserverInterface() {
    Class<CameraApiImpl> methodCallHandlerClass = CameraApiImpl.class;

    assertFalse(LifecycleObserver.class.isAssignableFrom(methodCallHandlerClass));
  }

  @Test
  public void onMethodCall_pausePreview_shouldPausePreviewAndSendSuccessResult()
      throws CameraAccessException {
    handler.pausePreview();

    verify(mockCamera, times(1)).pausePreview();
  }

  @Test
  public void onMethodCall_pausePreview_shouldSendErrorResultOnCameraAccessException()
      throws CameraAccessException {
    doThrow(new CameraAccessException(0)).when(mockCamera).pausePreview();

    assertThrows(Messages.FlutterError.class, () -> handler.pausePreview());
  }

  @Test
  public void onMethodCall_resumePreview_shouldResumePreviewAndSendSuccessResult() {
    handler.resumePreview();

    verify(mockCamera, times(1)).resumePreview();
  }

  @SuppressWarnings({"try", "unchecked"})
  @Test
  public void create_passesVideoEncoderToCamera() {
    final Activity mockActivity = mock(Activity.class);
    when(mockActivity.getSystemService(Context.CAMERA_SERVICE))
        .thenReturn(mock(CameraManager.class));
    final CameraPermissions mockCameraPermissions = mock(CameraPermissions.class);
    doAnswer(
            invocation -> {
              ((CameraPermissions.ResultCallback) invocation.getArgument(3)).onResult(null, null);
              return null;
            })
        .when(mockCameraPermissions)
        .requestPermissions(any(), any(), anyBoolean(), any());
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    when(mockTextureRegistry.createSurfaceTexture())
        .thenReturn(mock(TextureRegistry.SurfaceTextureEntry.class));
    final CameraApiImpl cameraApi =
        new CameraApiImpl(
            mockActivity,
            mock(BinaryMessenger.class),
            mockCameraPermissions,
            mock(CameraPermissions.PermissionsRegistry.class),
            mockTextureRegistry);
    final Messages.PlatformMediaSettings settings =
        new Messages.PlatformMediaSettings.Builder()
            .setResolutionPreset(Messages.PlatformResolutionPreset.HIGH)
            .setEnableAudio(false)
            .setVideoCodec(Messages.PlatformVideoCodec.HEVC)
            .build();
    final List<Camera.VideoCaptureSettings> videoCaptureSettings = new ArrayList<>();

    try (MockedConstruction<Camera> mockedCamera =
        mockConstruction(
            Camera.class,
            (mock, context) ->
                videoCaptureSettings.add(
                    (Camera.VideoCaptureSettings) context.arguments().get(5)))) {
      cameraApi.create("0", settings, mock(Messages.Result.class));
    }

    assertEquals(1, videoCaptureSettings.size());
    assertEquals(
        Integer.valueOf(MediaRecorder.VideoEncoder.HEVC), videoCaptureSettings.get(0).videoEncoder);
  }
}
