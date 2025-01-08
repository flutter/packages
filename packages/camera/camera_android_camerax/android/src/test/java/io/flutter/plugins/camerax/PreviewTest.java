// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.util.Size;
import android.view.Surface;
import androidx.camera.core.Preview;
import androidx.camera.core.SurfaceRequest;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.core.util.Consumer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesFlutterApi.Reply;
import io.flutter.view.TextureRegistry;
import java.util.concurrent.Executor;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class PreviewTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public Preview mockPreview;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public TextureRegistry mockTextureRegistry;
  @Mock public CameraXProxy mockCameraXProxy;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = spy(InstanceManager.create(identifier -> {}));
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Test
  public void create_createsPreviewWithCorrectConfiguration() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final Preview.Builder mockPreviewBuilder = mock(Preview.Builder.class);
    final int targetRotation = 90;
    final Long previewIdentifier = 3L;
    final ResolutionSelector mockResolutionSelector = mock(ResolutionSelector.class);
    final long mockResolutionSelectorId = 90;

    previewHostApi.cameraXProxy = mockCameraXProxy;
    testInstanceManager.addDartCreatedInstance(mockResolutionSelector, mockResolutionSelectorId);
    when(mockCameraXProxy.createPreviewBuilder()).thenReturn(mockPreviewBuilder);
    when(mockPreviewBuilder.build()).thenReturn(mockPreview);

    previewHostApi.create(
        previewIdentifier, Long.valueOf(targetRotation), mockResolutionSelectorId);

    verify(mockPreviewBuilder).setTargetRotation(targetRotation);
    verify(mockPreviewBuilder).setResolutionSelector(mockResolutionSelector);
    verify(mockPreviewBuilder).build();
    verify(testInstanceManager).addDartCreatedInstance(mockPreview, previewIdentifier);
  }

  @Test
  public void setSurfaceProvider_createsSurfaceProviderAndReturnsTextureEntryId() {
    final PreviewHostApiImpl previewHostApi =
        spy(new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry));
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    final Long previewIdentifier = 5L;
    final Long surfaceProducerEntryId = 120L;

    previewHostApi.cameraXProxy = mockCameraXProxy;
    testInstanceManager.addDartCreatedInstance(mockPreview, previewIdentifier);

    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    when(mockSurfaceProducer.id()).thenReturn(surfaceProducerEntryId);

    final ArgumentCaptor<Preview.SurfaceProvider> surfaceProviderCaptor =
        ArgumentCaptor.forClass(Preview.SurfaceProvider.class);

    // Test that surface provider was set and the surface texture ID was returned.
    assertEquals(previewHostApi.setSurfaceProvider(previewIdentifier), surfaceProducerEntryId);
    verify(mockPreview).setSurfaceProvider(surfaceProviderCaptor.capture());
    verify(previewHostApi).createSurfaceProvider(mockSurfaceProducer);
  }

  @Test
  public void createSurfaceProducer_setsExpectedSurfaceProducerCallback() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    final SurfaceRequest mockSurfaceRequest = mock(SurfaceRequest.class);
    final ArgumentCaptor<TextureRegistry.SurfaceProducer.Callback> callbackCaptor =
        ArgumentCaptor.forClass(TextureRegistry.SurfaceProducer.Callback.class);

    when(mockSurfaceRequest.getResolution()).thenReturn(new Size(5, 6));
    when(mockSurfaceProducer.getSurface()).thenReturn(mock(Surface.class));

    Preview.SurfaceProvider previewSurfaceProvider =
        previewHostApi.createSurfaceProvider(mockSurfaceProducer);
    previewSurfaceProvider.onSurfaceRequested(mockSurfaceRequest);

    verify(mockSurfaceProducer).setCallback(callbackCaptor.capture());

    TextureRegistry.SurfaceProducer.Callback callback = callbackCaptor.getValue();

    // Verify callback's onSurfaceDestroyed invalidates SurfaceRequest.
    simulateSurfaceDestruction(callback);
    verify(mockSurfaceRequest).invalidate();

    reset(mockSurfaceRequest);

    // Verify callback's onSurfaceAvailable does not interact with the SurfaceRequest.
    callback.onSurfaceAvailable();
    verifyNoMoreInteractions(mockSurfaceRequest);
  }

  @Test
  public void createSurfaceProvider_createsExpectedPreviewSurfaceProvider() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);
    final Surface mockSurface = mock(Surface.class);
    final SurfaceRequest mockSurfaceRequest = mock(SurfaceRequest.class);
    final SurfaceRequest.Result mockSurfaceRequestResult = mock(SurfaceRequest.Result.class);
    final SystemServicesFlutterApiImpl mockSystemServicesFlutterApi =
        mock(SystemServicesFlutterApiImpl.class);
    final int resolutionWidth = 200;
    final int resolutionHeight = 500;
    final Long surfaceProducerEntryId = 120L;

    previewHostApi.cameraXProxy = mockCameraXProxy;
    when(mockSurfaceRequest.getResolution())
        .thenReturn(new Size(resolutionWidth, resolutionHeight));
    when(mockCameraXProxy.createSystemServicesFlutterApiImpl(mockBinaryMessenger))
        .thenReturn(mockSystemServicesFlutterApi);
    when(mockSurfaceProducer.getSurface()).thenReturn(mockSurface);

    final ArgumentCaptor<Surface> surfaceCaptor = ArgumentCaptor.forClass(Surface.class);
    @SuppressWarnings("unchecked")
    final ArgumentCaptor<Consumer<SurfaceRequest.Result>> consumerCaptor =
        ArgumentCaptor.forClass(Consumer.class);

    Preview.SurfaceProvider previewSurfaceProvider =
        previewHostApi.createSurfaceProvider(mockSurfaceProducer);
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
    verify(mockSystemServicesFlutterApi)
        .sendCameraError(anyString(), ArgumentMatchers.<Reply<Void>>any());
  }

  @Test
  public void releaseFlutterSurfaceTexture_makesCallToReleaseFlutterSurfaceTexture() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer =
        mock(TextureRegistry.SurfaceProducer.class);

    previewHostApi.flutterSurfaceProducer = mockSurfaceProducer;

    previewHostApi.releaseFlutterSurfaceTexture();
    verify(mockSurfaceProducer).release();
  }

  @Test
  public void getResolutionInfo_makesCallToRetrievePreviewResolutionInfo() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final androidx.camera.core.ResolutionInfo mockResolutionInfo =
        mock(androidx.camera.core.ResolutionInfo.class);
    final Long previewIdentifier = 23L;
    final int resolutionWidth = 500;
    final int resolutionHeight = 200;

    testInstanceManager.addDartCreatedInstance(mockPreview, previewIdentifier);
    when(mockPreview.getResolutionInfo()).thenReturn(mockResolutionInfo);
    when(mockResolutionInfo.getResolution())
        .thenReturn(new Size(resolutionWidth, resolutionHeight));

    ResolutionInfo resolutionInfo = previewHostApi.getResolutionInfo(previewIdentifier);
    assertEquals(resolutionInfo.getWidth(), Long.valueOf(resolutionWidth));
    assertEquals(resolutionInfo.getHeight(), Long.valueOf(resolutionHeight));
  }

  @Test
  public void setTargetRotation_makesCallToSetTargetRotation() {
    final PreviewHostApiImpl hostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final long instanceIdentifier = 52;
    final int targetRotation = Surface.ROTATION_180;

    testInstanceManager.addDartCreatedInstance(mockPreview, instanceIdentifier);

    hostApi.setTargetRotation(instanceIdentifier, Long.valueOf(targetRotation));

    verify(mockPreview).setTargetRotation(targetRotation);
  }

  // TODO(bparrishMines): Replace with inline calls to onSurfaceCleanup once available on stable;
  // see https://github.com/flutter/flutter/issues/16125. This separate method only exists to scope
  // the suppression.
  @SuppressWarnings({"deprecation", "removal"})
  void simulateSurfaceDestruction(TextureRegistry.SurfaceProducer.Callback producerLifecycle) {
    producerLifecycle.onSurfaceDestroyed();
  }
}
