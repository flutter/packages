// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.camera.camera2.interop.Camera2CameraControl;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import androidx.camera.core.CameraControl;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;

public class Camera2CameraControlTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public Camera2CameraControl mockCamera2CameraControl;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Test
  public void create_createsInstanceFromCameraControlInstance() {
    final Camera2CameraControlHostApiImpl hostApi =
        new Camera2CameraControlHostApiImpl(testInstanceManager, mock(Context.class));
    final long instanceIdentifier = 40;
    final CameraControl mockCameraControl = mock(CameraControl.class);
    final long cameraControlIdentifier = 29;

    testInstanceManager.addDartCreatedInstance(mockCameraControl, cameraControlIdentifier);
    try (MockedStatic<Camera2CameraControl> mockedCamera2CameraControl =
        Mockito.mockStatic(Camera2CameraControl.class)) {
      mockedCamera2CameraControl
          .when(() -> Camera2CameraControl.from(mockCameraControl))
          .thenAnswer((Answer<Camera2CameraControl>) invocation -> mockCamera2CameraControl);

      hostApi.create(instanceIdentifier, cameraControlIdentifier);
      assertEquals(testInstanceManager.getInstance(instanceIdentifier), mockCamera2CameraControl);
    }
  }

  @Test
  public void addCaptureRequestOptions_respondsAsExpectedToSuccessfulAndFailedAttempts() {
    final Camera2CameraControlHostApiImpl hostApi =
        new Camera2CameraControlHostApiImpl(testInstanceManager, mock(Context.class));
    final long instanceIdentifier = 0;

    final CaptureRequestOptions mockCaptureRequestOptions = mock(CaptureRequestOptions.class);
    final long captureRequestOptionsIdentifier = 8;

    testInstanceManager.addDartCreatedInstance(mockCamera2CameraControl, instanceIdentifier);
    testInstanceManager.addDartCreatedInstance(
        mockCaptureRequestOptions, captureRequestOptionsIdentifier);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      @SuppressWarnings("unchecked")
      final ListenableFuture<Void> addCaptureRequestOptionsFuture = mock(ListenableFuture.class);

      when(mockCamera2CameraControl.addCaptureRequestOptions(mockCaptureRequestOptions))
          .thenReturn(addCaptureRequestOptionsFuture);

      @SuppressWarnings("unchecked")
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      // Test successfully adding capture request options.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> successfulMockResult =
          mock(GeneratedCameraXLibrary.Result.class);

      hostApi.addCaptureRequestOptions(
          instanceIdentifier, captureRequestOptionsIdentifier, successfulMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(addCaptureRequestOptionsFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<Void> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(mock(Void.class));
      verify(successfulMockResult).success(null);

      // Test failed attempt to add capture request options.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> failedMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      final Throwable testThrowable = new Throwable();
      hostApi.addCaptureRequestOptions(
          instanceIdentifier, captureRequestOptionsIdentifier, failedMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(addCaptureRequestOptionsFuture), futureCallbackCaptor.capture(), any()));

      FutureCallback<Void> failedCallback = futureCallbackCaptor.getValue();

      failedCallback.onFailure(testThrowable);
      verify(failedMockResult).error(testThrowable);
    }
  }
}
