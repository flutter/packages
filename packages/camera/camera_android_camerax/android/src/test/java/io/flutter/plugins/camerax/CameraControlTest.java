// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.CameraControl;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.FocusMeteringResult;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import org.mockito.Mockito;

public class CameraControlTest {
  @SuppressWarnings("unchecked")
  @Test
  public void enableTorch_turnsTorchModeOnAndOffAsExpected() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);

    final ListenableFuture<Void> mockListenableFuture = mock(ListenableFuture.class);
    final boolean enable = true;
    when(instance.enableTorch(enable)).thenReturn(mockListenableFuture);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      final boolean[] isSuccess = {false};
      api.enableTorch(
          instance,
          enable,
          ResultCompat.asCompatCallback(
              reply -> {
                isSuccess[0] = reply.isSuccess();
                return null;
              }));

      verify(instance).enableTorch(enable);
      mockedFutures.verify(
          () ->
              Futures.addCallback(eq(mockListenableFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      final FutureCallback<Void> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(mock(Void.class));
      assertTrue(isSuccess[0]);
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void setZoomRatio_setsZoomAsExpected() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);

    final ListenableFuture<Void> mockListenableFuture = mock(ListenableFuture.class);
    final float ratio = 1.0f;
    when(instance.setZoomRatio(ratio)).thenReturn(mockListenableFuture);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      final boolean[] isSuccess = {false};
      api.setZoomRatio(
          instance,
          ratio,
          ResultCompat.asCompatCallback(
              reply -> {
                isSuccess[0] = reply.isSuccess();
                return null;
              }));

      verify(instance).setZoomRatio(ratio);
      mockedFutures.verify(
          () ->
              Futures.addCallback(eq(mockListenableFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      final FutureCallback<Void> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(mock(Void.class));
      assertTrue(isSuccess[0]);
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void startFocusAndMetering_startsFocusAndMeteringAsExpected() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);

    final ListenableFuture<FocusMeteringResult> mockListenableFuture = mock(ListenableFuture.class);
    final androidx.camera.core.FocusMeteringAction action = mock(FocusMeteringAction.class);
    when(instance.startFocusAndMetering(action)).thenReturn(mockListenableFuture);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final ArgumentCaptor<FutureCallback<FocusMeteringResult>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      final FocusMeteringResult[] resultArray = {null};
      api.startFocusAndMetering(
          instance,
          action,
          ResultCompat.asCompatCallback(
              reply -> {
                resultArray[0] = reply.getOrNull();
                return null;
              }));

      verify(instance).startFocusAndMetering(action);
      mockedFutures.verify(
          () ->
              Futures.addCallback(eq(mockListenableFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      final FutureCallback<FocusMeteringResult> successfulCallback =
          futureCallbackCaptor.getValue();

      final FocusMeteringResult result = mock(FocusMeteringResult.class);
      successfulCallback.onSuccess(result);
      assertEquals(resultArray[0], result);
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void cancelFocusAndMetering_cancelsFocusAndMeteringAsExpected() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);

    final ListenableFuture<Void> mockListenableFuture = mock(ListenableFuture.class);
    when(instance.cancelFocusAndMetering()).thenReturn(mockListenableFuture);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      final boolean[] isSuccess = {false};
      api.cancelFocusAndMetering(
          instance,
          ResultCompat.asCompatCallback(
              reply -> {
                isSuccess[0] = reply.isSuccess();
                return null;
              }));

      verify(instance).cancelFocusAndMetering();
      mockedFutures.verify(
          () ->
              Futures.addCallback(eq(mockListenableFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      final FutureCallback<Void> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(mock(Void.class));
      assertTrue(isSuccess[0]);
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void setExposureCompensationIndex_setsExposureCompensationIndexAsExpected() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);

    final ListenableFuture<Integer> mockListenableFuture = mock(ListenableFuture.class);
    final int index = 1;
    when(instance.setExposureCompensationIndex(index)).thenReturn(mockListenableFuture);

    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final ArgumentCaptor<FutureCallback<Integer>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      final Long[] resultArray = {-1L};
      api.setExposureCompensationIndex(
          instance,
          index,
          ResultCompat.asCompatCallback(
              reply -> {
                resultArray[0] = reply.getOrNull();
                return null;
              }));

      verify(instance).setExposureCompensationIndex(index);
      mockedFutures.verify(
          () ->
              Futures.addCallback(eq(mockListenableFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      final FutureCallback<Integer> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(index);
      assertEquals(resultArray[0], Long.valueOf(index));
    }
  }
}
