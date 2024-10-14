// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertFalse;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import android.app.Activity;
import android.hardware.camera2.CameraAccessException;
import androidx.lifecycle.LifecycleObserver;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;
import org.junit.Before;
import org.junit.Test;

public class MethodCallHandlerImplTest {

  MethodCallHandlerImpl handler;
  Messages.VoidResult mockResult;
  Camera mockCamera;

  @Before
  public void setUp() {
    handler =
        new MethodCallHandlerImpl(
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
    Class<MethodCallHandlerImpl> methodCallHandlerClass = MethodCallHandlerImpl.class;

    assertFalse(LifecycleObserver.class.isAssignableFrom(methodCallHandlerClass));
  }

  @Test
  public void onMethodCall_pausePreview_shouldPausePreviewAndSendSuccessResult()
      throws CameraAccessException {
    handler.pausePreview(1L, mockResult);

    verify(mockCamera, times(1)).pausePreview();
    verify(mockResult, times(1)).success();
  }

  @Test
  public void onMethodCall_pausePreview_shouldSendErrorResultOnCameraAccessException()
      throws CameraAccessException {
    doThrow(new CameraAccessException(0)).when(mockCamera).pausePreview();

    handler.pausePreview(1L, mockResult);

    verify(mockResult, times(1)).error(new Messages.FlutterError("CameraAccess", null, null));
  }

  @Test
  public void onMethodCall_resumePreview_shouldResumePreviewAndSendSuccessResult() {
    handler.resumePreview(1L, mockResult);

    verify(mockCamera, times(1)).resumePreview();
    verify(mockResult, times(1)).success();
  }
}
