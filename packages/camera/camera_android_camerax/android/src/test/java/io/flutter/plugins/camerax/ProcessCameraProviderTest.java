// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.annotation.Nullable;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.UseCase;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Executor;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ProcessCameraProviderTest {
  @Test
  public void getInstance_returnsExpectedProcessCameraProviderInFutureCallback() {
    final PigeonApiProcessCameraProvider api =
        new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final ListenableFuture<ProcessCameraProvider> processCameraProviderFuture =
        spy(Futures.immediateFuture(instance));

    try (MockedStatic<ProcessCameraProvider> mockedProcessCameraProvider =
            Mockito.mockStatic(ProcessCameraProvider.class);
        MockedStatic<ContextCompat> mockedContextCompat = Mockito.mockStatic(ContextCompat.class)) {
      mockedProcessCameraProvider
          .when(() -> ProcessCameraProvider.getInstance(any()))
          .thenAnswer(
              (Answer<ListenableFuture<ProcessCameraProvider>>)
                  invocation -> processCameraProviderFuture);

      mockedContextCompat
          .when(() -> ContextCompat.getMainExecutor(any()))
          .thenAnswer((Answer<Executor>) invocation -> mock(Executor.class));

      final ArgumentCaptor<Runnable> runnableCaptor = ArgumentCaptor.forClass(Runnable.class);

      final ProcessCameraProvider[] resultArray = {null};
      api.getInstance(
          ResultCompat.asCompatCallback(
              reply -> {
                resultArray[0] = reply.getOrNull();
                return null;
              }));

      verify(processCameraProviderFuture).addListener(runnableCaptor.capture(), any());
      runnableCaptor.getValue().run();
      assertEquals(resultArray[0], instance);
    }
  }

  @Test
  public void getAvailableCameraInfos_returnsExpectedCameraInfos() {
    final PigeonApiProcessCameraProvider api =
        new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final List<CameraInfo> value = Collections.singletonList(mock(CameraInfo.class));
    when(instance.getAvailableCameraInfos()).thenReturn(value);

    assertEquals(value, api.getAvailableCameraInfos(instance));
  }

  @Test
  public void bindToLifecycle_callsBindToLifecycleWithSelectorsAndUseCases() {
    final PigeonApiProcessCameraProvider api =
        new TestProxyApiRegistrar() {
          @Nullable
          @Override
          public LifecycleOwner getLifecycleOwner() {
            return mock(LifecycleOwner.class);
          }
        }.getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final androidx.camera.core.CameraSelector cameraSelector = mock(CameraSelector.class);
    final List<androidx.camera.core.UseCase> useCases =
        Collections.singletonList(mock(UseCase.class));
    final androidx.camera.core.Camera value = mock(Camera.class);
    when(instance.bindToLifecycle(
            any(), eq(cameraSelector), eq(useCases.toArray(new UseCase[] {}))))
        .thenReturn(value);

    assertEquals(value, api.bindToLifecycle(instance, cameraSelector, useCases));
  }

  @Test
  public void isBound_returnsExpectedIsBound() {
    final PigeonApiProcessCameraProvider api =
        new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final androidx.camera.core.UseCase useCase = mock(UseCase.class);
    final Boolean value = true;
    when(instance.isBound(useCase)).thenReturn(value);

    assertEquals(value, api.isBound(instance, useCase));
  }

  @Test
  public void unbind_callsUnBindOnInstance() {
    final PigeonApiProcessCameraProvider api =
        new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final List<androidx.camera.core.UseCase> useCases =
        Collections.singletonList(mock(UseCase.class));
    api.unbind(instance, useCases);

    verify(instance).unbind(useCases.toArray(new UseCase[] {}));
  }

  @Test
  public void unbindAll() {
    final PigeonApiProcessCameraProvider api =
        new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    api.unbindAll(instance);

    verify(instance).unbindAll();
  }
}
