// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.util.Size;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.camera.core.Preview;
import androidx.camera.core.ResolutionInfo;
import androidx.camera.core.SurfaceRequest;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.core.util.Consumer;
import io.flutter.view.TextureRegistry;
import java.util.concurrent.Executor;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class PreviewTest {
  @Test
  public void pigeon_defaultConstructor_createsPreviewWithCorrectConfiguration() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final ResolutionSelector mockResolutionSelector = new ResolutionSelector.Builder().build();
    final long targetResolution = Surface.ROTATION_0;
    final Preview instance =
        api.pigeon_defaultConstructor(mockResolutionSelector, targetResolution);

    assertEquals(instance.getResolutionSelector(), mockResolutionSelector);
    assertEquals(instance.getTargetRotation(), Surface.ROTATION_0);
  }

  @Test
  public void resolutionSelector_returnsExpectedResolutionSelector() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final androidx.camera.core.resolutionselector.ResolutionSelector value =
        mock(ResolutionSelector.class);
    when(instance.getResolutionSelector()).thenReturn(value);

    assertEquals(value, api.resolutionSelector(instance));
  }

  @Test
  public void setSurfaceProvider_createsSurfaceProviderAndReturnsTextureEntryId() {
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    final long textureId = 0;
    when(mockSurfaceProducer.id()).thenReturn(textureId);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    final PigeonApiPreview api =
        new TestProxyApiRegistrar() {
          @NonNull
          @Override
          TextureRegistry getTextureRegistry() {
            return mockTextureRegistry;
          }
        }.getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final SystemServicesManager systemServicesManager = mock(SystemServicesManager.class);

    assertEquals(textureId, api.setSurfaceProvider(instance, systemServicesManager));
    verify(instance).setSurfaceProvider(any(Preview.SurfaceProvider.class));
  }

  @Test
  public void createSurfaceProducer_setsExpectedSurfaceProducerCallback() {
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    final long textureId = 0;
    when(mockSurfaceProducer.id()).thenReturn(textureId);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    final PreviewProxyApi api =
        (PreviewProxyApi)
            new TestProxyApiRegistrar() {
              @NonNull
              @Override
              TextureRegistry getTextureRegistry() {
                return mockTextureRegistry;
              }
            }.getPigeonApiPreview();

    final SystemServicesManager mockSystemServicesManager = mock(SystemServicesManager.class);
    final SurfaceRequest mockSurfaceRequest = mock(SurfaceRequest.class);
    final ArgumentCaptor<TextureRegistry.SurfaceProducer.Callback> callbackCaptor =
        ArgumentCaptor.forClass(TextureRegistry.SurfaceProducer.Callback.class);

    when(mockSurfaceRequest.getResolution()).thenReturn(new Size(5, 6));
    when(mockSurfaceProducer.getSurface()).thenReturn(mock(Surface.class));

    final Preview.SurfaceProvider previewSurfaceProvider =
        api.createSurfaceProvider(mockSurfaceProducer, mockSystemServicesManager);
    previewSurfaceProvider.onSurfaceRequested(mockSurfaceRequest);

    verify(mockSurfaceProducer).setCallback(callbackCaptor.capture());

    final TextureRegistry.SurfaceProducer.Callback callback = callbackCaptor.getValue();

    // Verify callback's onSurfaceCleanup invalidates SurfaceRequest.
    simulateSurfaceCleanup(callback);
    verify(mockSurfaceRequest).invalidate();

    reset(mockSurfaceRequest);

    // Verify callback's onSurfaceAvailable does not interact with the SurfaceRequest.
    callback.onSurfaceAvailable();
    verifyNoMoreInteractions(mockSurfaceRequest);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void createSurfaceProvider_createsExpectedPreviewSurfaceProvider() {
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    final long textureId = 0;
    when(mockSurfaceProducer.id()).thenReturn(textureId);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    final PreviewProxyApi api =
        (PreviewProxyApi)
            new TestProxyApiRegistrar() {
              @NonNull
              @Override
              TextureRegistry getTextureRegistry() {
                return mockTextureRegistry;
              }
            }.getPigeonApiPreview();

    final SystemServicesManager mockSystemServicesManager = mock(SystemServicesManager.class);

    final Surface mockSurface = mock(Surface.class);
    final SurfaceRequest mockSurfaceRequest = mock(SurfaceRequest.class);
    final SurfaceRequest.Result mockSurfaceRequestResult = mock(SurfaceRequest.Result.class);

    final int resolutionWidth = 200;
    final int resolutionHeight = 500;
    final Long surfaceProducerEntryId = 120L;

    when(mockSurfaceRequest.getResolution())
        .thenReturn(new Size(resolutionWidth, resolutionHeight));
    when(mockSurfaceProducer.getSurface()).thenReturn(mockSurface);

    final ArgumentCaptor<Surface> surfaceCaptor = ArgumentCaptor.forClass(Surface.class);
    final ArgumentCaptor<Consumer<SurfaceRequest.Result>> consumerCaptor =
        ArgumentCaptor.forClass(Consumer.class);

    final Preview.SurfaceProvider previewSurfaceProvider =
        api.createSurfaceProvider(mockSurfaceProducer, mockSystemServicesManager);
    previewSurfaceProvider.onSurfaceRequested(mockSurfaceRequest);

    verify(mockSurfaceProducer).setSize(resolutionWidth, resolutionHeight);
    verify(mockSurfaceRequest)
        .provideSurface(surfaceCaptor.capture(), any(Executor.class), consumerCaptor.capture());

    // Test that the surface derived from the surface texture entry will be provided to the surface
    // request.
    assertEquals(surfaceCaptor.getValue(), mockSurface);

    // Test that the Consumer used to handle surface request result releases Flutter surface texture
    // appropriately
    // and sends camera errors appropriately.
    Consumer<SurfaceRequest.Result> capturedConsumer = consumerCaptor.getValue();

    // Case where Surface should be released.
    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_REQUEST_CANCELLED);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_REQUEST_CANCELLED);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_WILL_NOT_PROVIDE_SURFACE);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_SURFACE_USED_SUCCESSFULLY);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    // Case where error must be sent.
    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_INVALID_SURFACE);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    verify(mockSystemServicesManager).onCameraError(anyString());
  }

  @Test
  public void releaseSurfaceProvider_makesCallToReleaseFlutterSurfaceTexture() {
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    when(mockSurfaceProducer.id()).thenReturn(0L);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    final PigeonApiPreview api =
        new TestProxyApiRegistrar() {
          @NonNull
          @Override
          TextureRegistry getTextureRegistry() {
            return mockTextureRegistry;
          }
        }.getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final SystemServicesManager systemServicesManager = mock(SystemServicesManager.class);
    api.setSurfaceProvider(instance, systemServicesManager);
    api.releaseSurfaceProvider(instance);

    verify(mockSurfaceProducer).release();
  }

  @Test
  public void getResolutionInfo_returnsExpectedResolutionInfo() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final androidx.camera.core.ResolutionInfo value = mock(ResolutionInfo.class);
    when(instance.getResolutionInfo()).thenReturn(value);

    assertEquals(value, api.getResolutionInfo(instance));
  }

  @Test
  public void setTargetRotation_returnsExpectedTargetRotation() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation((int) rotation);
  }

  @Test
  public void
      surfaceProducerHandlesCropAndRotation_returnsIfSurfaceProducerHandlesCropAndRotation() {
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    when(mockSurfaceProducer.id()).thenReturn(0L);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    final PigeonApiPreview api =
        new TestProxyApiRegistrar() {
          @NonNull
          @Override
          TextureRegistry getTextureRegistry() {
            return mockTextureRegistry;
          }
        }.getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final SystemServicesManager systemServicesManager = mock(SystemServicesManager.class);
    api.setSurfaceProvider(instance, systemServicesManager);
    api.surfaceProducerHandlesCropAndRotation(instance);

    verify(mockSurfaceProducer).handlesCropAndRotation();
  }

  // TODO(bparrishMines): Replace with inline calls to onSurfaceCleanup once available on stable;
  // see https://github.com/flutter/flutter/issues/16125. This separate method only exists to scope
  // the suppression.
  @SuppressWarnings({"deprecation", "removal"})
  void simulateSurfaceCleanup(TextureRegistry.SurfaceProducer.Callback producerLifecycle) {
    producerLifecycle.onSurfaceCleanup();
  }
}
