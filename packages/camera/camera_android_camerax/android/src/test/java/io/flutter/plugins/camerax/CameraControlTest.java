// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.camera.core.CameraControl;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.FocusMeteringResult;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
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

public class CameraControlTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public CameraControl cameraControl;

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
  public void enableTorch_turnsTorchModeOnAndOffAsExpected() {
    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final CameraControlHostApiImpl cameraControlHostApiImpl =
          new CameraControlHostApiImpl(
              mockBinaryMessenger, testInstanceManager, mock(Context.class));
      final Long cameraControlIdentifier = 88L;
      final boolean enableTorch = true;

      @SuppressWarnings("unchecked")
      final ListenableFuture<Void> enableTorchFuture = mock(ListenableFuture.class);

      testInstanceManager.addDartCreatedInstance(cameraControl, cameraControlIdentifier);

      when(cameraControl.enableTorch(true)).thenReturn(enableTorchFuture);

      @SuppressWarnings("unchecked")
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      // Test successful behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> successfulMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      cameraControlHostApiImpl.enableTorch(
          cameraControlIdentifier, enableTorch, successfulMockResult);
      mockedFutures.verify(
          () -> Futures.addCallback(eq(enableTorchFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<Void> successfulEnableTorchCallback = futureCallbackCaptor.getValue();

      successfulEnableTorchCallback.onSuccess(mock(Void.class));
      verify(successfulMockResult).success(null);

      // Test failed behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> failedMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      final Throwable testThrowable = new Throwable();
      cameraControlHostApiImpl.enableTorch(cameraControlIdentifier, enableTorch, failedMockResult);
      mockedFutures.verify(
          () -> Futures.addCallback(eq(enableTorchFuture), futureCallbackCaptor.capture(), any()));

      FutureCallback<Void> failedEnableTorchCallback = futureCallbackCaptor.getValue();

      failedEnableTorchCallback.onFailure(testThrowable);
      verify(failedMockResult).error(testThrowable);
    }
  }

  @Test
  public void setZoomRatio_setsZoomAsExpected() {
    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final CameraControlHostApiImpl cameraControlHostApiImpl =
          new CameraControlHostApiImpl(
              mockBinaryMessenger, testInstanceManager, mock(Context.class));
      final Long cameraControlIdentifier = 33L;
      final Double zoomRatio = 0.2D;

      @SuppressWarnings("unchecked")
      final ListenableFuture<Void> setZoomRatioFuture = mock(ListenableFuture.class);

      testInstanceManager.addDartCreatedInstance(cameraControl, cameraControlIdentifier);

      when(cameraControl.setZoomRatio(zoomRatio.floatValue())).thenReturn(setZoomRatioFuture);

      @SuppressWarnings("unchecked")
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      // Test successful behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> successfulMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      cameraControlHostApiImpl.setZoomRatio(
          cameraControlIdentifier, zoomRatio, successfulMockResult);
      mockedFutures.verify(
          () -> Futures.addCallback(eq(setZoomRatioFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<Void> successfulSetZoomRatioCallback = futureCallbackCaptor.getValue();

      successfulSetZoomRatioCallback.onSuccess(mock(Void.class));
      verify(successfulMockResult).success(null);

      // Test failed behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> failedMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      final Throwable testThrowable = new Throwable();
      cameraControlHostApiImpl.setZoomRatio(cameraControlIdentifier, zoomRatio, failedMockResult);
      mockedFutures.verify(
          () -> Futures.addCallback(eq(setZoomRatioFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<Void> failedSetZoomRatioCallback = futureCallbackCaptor.getValue();

      failedSetZoomRatioCallback.onFailure(testThrowable);
      verify(failedMockResult).error(testThrowable);
    }
  }

  @Test
  public void startFocusAndMetering_startsFocusAndMeteringAsExpected() {
    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final CameraControlHostApiImpl cameraControlHostApiImpl =
          new CameraControlHostApiImpl(
              mockBinaryMessenger, testInstanceManager, mock(Context.class));
      final Long cameraControlIdentifier = 90L;
      final FocusMeteringAction mockAction = mock(FocusMeteringAction.class);
      final Long mockActionId = 44L;
      final FocusMeteringResult mockResult = mock(FocusMeteringResult.class);
      final Long mockResultId = 33L;

      @SuppressWarnings("unchecked")
      final ListenableFuture<FocusMeteringResult> startFocusAndMeteringFuture =
          mock(ListenableFuture.class);

      testInstanceManager.addDartCreatedInstance(cameraControl, cameraControlIdentifier);
      testInstanceManager.addDartCreatedInstance(mockResult, mockResultId);
      testInstanceManager.addDartCreatedInstance(mockAction, mockActionId);

      when(cameraControl.startFocusAndMetering(mockAction)).thenReturn(startFocusAndMeteringFuture);

      @SuppressWarnings("unchecked")
      final ArgumentCaptor<FutureCallback<FocusMeteringResult>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      // Test successful behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Long> successfulMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      cameraControlHostApiImpl.startFocusAndMetering(
          cameraControlIdentifier, mockActionId, successfulMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(startFocusAndMeteringFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<FocusMeteringResult> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(mockResult);
      verify(successfulMockResult).success(mockResultId);

      // Test failed behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Long> failedMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      final Throwable testThrowable = new Throwable();
      cameraControlHostApiImpl.startFocusAndMetering(
          cameraControlIdentifier, mockActionId, failedMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(startFocusAndMeteringFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<FocusMeteringResult> failedCallback = futureCallbackCaptor.getValue();

      failedCallback.onFailure(testThrowable);
      verify(failedMockResult).error(testThrowable);
    }
  }

  @Test
  public void cancelFocusAndMetering_cancelsFocusAndMeteringAsExpected() {
    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final CameraControlHostApiImpl cameraControlHostApiImpl =
          new CameraControlHostApiImpl(
              mockBinaryMessenger, testInstanceManager, mock(Context.class));
      final Long cameraControlIdentifier = 8L;

      @SuppressWarnings("unchecked")
      final ListenableFuture<Void> cancelFocusAndMeteringFuture = mock(ListenableFuture.class);

      testInstanceManager.addDartCreatedInstance(cameraControl, cameraControlIdentifier);

      when(cameraControl.cancelFocusAndMetering()).thenReturn(cancelFocusAndMeteringFuture);

      @SuppressWarnings("unchecked")
      final ArgumentCaptor<FutureCallback<Void>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      // Test successful behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> successfulMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      cameraControlHostApiImpl.cancelFocusAndMetering(
          cameraControlIdentifier, successfulMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(cancelFocusAndMeteringFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<Void> successfulCallback = futureCallbackCaptor.getValue();

      successfulCallback.onSuccess(mock(Void.class));
      verify(successfulMockResult).success(null);

      // Test failed behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Void> failedMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      final Throwable testThrowable = new Throwable();
      cameraControlHostApiImpl.cancelFocusAndMetering(cameraControlIdentifier, failedMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(cancelFocusAndMeteringFuture), futureCallbackCaptor.capture(), any()));

      FutureCallback<Void> failedCallback = futureCallbackCaptor.getValue();

      failedCallback.onFailure(testThrowable);
      verify(failedMockResult).error(testThrowable);
    }
  }

  @Test
  public void setExposureCompensationIndex_setsExposureCompensationIndexAsExpected() {
    try (MockedStatic<Futures> mockedFutures = Mockito.mockStatic(Futures.class)) {
      final CameraControlHostApiImpl cameraControlHostApiImpl =
          new CameraControlHostApiImpl(
              mockBinaryMessenger, testInstanceManager, mock(Context.class));
      final Long cameraControlIdentifier = 53L;
      final Long index = 2L;

      @SuppressWarnings("unchecked")
      final ListenableFuture<Integer> setExposureCompensationIndexFuture =
          mock(ListenableFuture.class);

      testInstanceManager.addDartCreatedInstance(cameraControl, cameraControlIdentifier);

      when(cameraControl.setExposureCompensationIndex(index.intValue()))
          .thenReturn(setExposureCompensationIndexFuture);

      @SuppressWarnings("unchecked")
      final ArgumentCaptor<FutureCallback<Integer>> futureCallbackCaptor =
          ArgumentCaptor.forClass(FutureCallback.class);

      // Test successful behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Long> successfulMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      cameraControlHostApiImpl.setExposureCompensationIndex(
          cameraControlIdentifier, index, successfulMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(setExposureCompensationIndexFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<Integer> successfulCallback = futureCallbackCaptor.getValue();
      final Integer fakeResult = 4;

      successfulCallback.onSuccess(fakeResult);
      verify(successfulMockResult).success(fakeResult.longValue());

      // Test failed behavior.
      @SuppressWarnings("unchecked")
      final GeneratedCameraXLibrary.Result<Long> failedMockResult =
          mock(GeneratedCameraXLibrary.Result.class);
      final Throwable testThrowable = new Throwable();
      cameraControlHostApiImpl.setExposureCompensationIndex(
          cameraControlIdentifier, index, failedMockResult);
      mockedFutures.verify(
          () ->
              Futures.addCallback(
                  eq(setExposureCompensationIndexFuture), futureCallbackCaptor.capture(), any()));
      mockedFutures.clearInvocations();

      FutureCallback<Integer> failedCallback = futureCallbackCaptor.getValue();

      failedCallback.onFailure(testThrowable);
      verify(failedMockResult).error(testThrowable);
    }
  }

  @Test
  public void flutterApiCreate_makesCallToCreateInstanceOnDartSide() {
    final CameraControlFlutterApiImpl spyFlutterApi =
        spy(new CameraControlFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    spyFlutterApi.create(cameraControl, reply -> {});

    final long cameraControlIdentifier =
        Objects.requireNonNull(testInstanceManager.getIdentifierForStrongReference(cameraControl));
    verify(spyFlutterApi).create(eq(cameraControlIdentifier), any());
  }
}
