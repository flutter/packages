// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.camera2.interop.Camera2CameraControl;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import androidx.camera.core.CameraControl;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;

public class Camera2CameraControlTest {
  @Test
  public void from_createsInstanceFromCameraControlInstance() {
    final PigeonApiCamera2CameraControl api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraControl();

    final CameraControl mockCameraControl = mock(CameraControl.class);
    final Camera2CameraControl mockCamera2CameraControl = mock(Camera2CameraControl.class);

    try (MockedStatic<Camera2CameraControl> mockedCamera2CameraControl =
        Mockito.mockStatic(Camera2CameraControl.class)) {
      mockedCamera2CameraControl
          .when(() -> Camera2CameraControl.from(mockCameraControl))
          .thenAnswer((Answer<Camera2CameraControl>) invocation -> mockCamera2CameraControl);

      assertEquals(api.from(mockCameraControl), mockCamera2CameraControl);
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void addCaptureRequestOptions_respondsAsExpectedToSuccessful() {
    final PigeonApiCamera2CameraControl api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraControl();

    final Camera2CameraControl instance = mock(Camera2CameraControl.class);
    final androidx.camera.camera2.interop.CaptureRequestOptions bundle =
        mock(CaptureRequestOptions.class);

    final ListenableFuture<Void> addCaptureRequestOptionsFuture = mock(ListenableFuture.class);
    when(instance.addCaptureRequestOptions(bundle)).thenReturn(addCaptureRequestOptionsFuture);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      final boolean[] isSuccess = {false};
      api.addCaptureRequestOptions(
          instance,
          bundle,
          ResultCompat.asCompatCallback(
              reply -> {
                isSuccess[0] = reply.isSuccess();
                return null;
              }));

      verify(instance).addCaptureRequestOptions(bundle);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(addCaptureRequestOptionsFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      final FutureCallback<Void> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(mock(Void.class));
      assertTrue(isSuccess[0]);
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void addCaptureRequestOptions_respondsAsExpectedToFailure() {
    final PigeonApiCamera2CameraControl api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraControl();

    final Camera2CameraControl instance = mock(Camera2CameraControl.class);
    final androidx.camera.camera2.interop.CaptureRequestOptions bundle =
        mock(CaptureRequestOptions.class);

    final ListenableFuture<Void> addCaptureRequestOptionsFuture = mock(ListenableFuture.class);
    when(instance.addCaptureRequestOptions(bundle)).thenReturn(addCaptureRequestOptionsFuture);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      final boolean[] isFailure = {false};
      api.addCaptureRequestOptions(
          instance,
          bundle,
          ResultCompat.asCompatCallback(
              reply -> {
                isFailure[0] = reply.isFailure();
                return null;
              }));

      verify(instance).addCaptureRequestOptions(bundle);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(addCaptureRequestOptionsFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      final FutureCallback<Void> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onFailure(new Throwable());
      assertTrue(isFailure[0]);
    }
  }
}
