// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.util.Size;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugins.camerax.CameraXProxy;
import io.flutter.plugins.camerax.ImageAnalysisFlutterApiImpl;
import io.flutter.plugins.camerax.ImageAnalysisHostApiImpl;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageInformation;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImagePlaneInformation;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import io.flutter.plugins.camerax.InstanceManager;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.concurrent.Executor;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageAnalysisTest {
    @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

    @Mock public ImageAnalysis mockImageAnalysis;
    @Mock public BinaryMessenger mockBinaryMessenger;
    @Mock public CameraXProxy mockCameraXProxy;
  
    InstanceManager testInstanceManager;
    private Context context;
  
    @Before
    public void setUp() throws Exception {
      testInstanceManager = spy(InstanceManager.open(identifier -> {}));
      context = ApplicationProvider.getApplicationContext();
    }
  
    @After
    public void tearDown() {
      testInstanceManager.close();
    }

    @Test
    public void create_buildsExpectedImageAnalysisInstance() {
        final ImageAnalysisHostApiImpl imageAnalysisHostApiImpl =
            new ImageAnalysisHostApiImpl(mockBinaryMessenger, testInstanceManager);
        final Long imageAnalysisIdentifier = 83L;
        final int targetResolutionWidth = 11;
        final int targetResolutionHeight = 51;
        final GeneratedCameraXLibrary.ResolutionInfo resolutionInfo =
            new GeneratedCameraXLibrary.ResolutionInfo.Builder()
                .setWidth(Long.valueOf(targetResolutionWidth))
                .setHeight(Long.valueOf(targetResolutionHeight))
                .build();
        final ImageAnalysis.Builder mockImageAnalysisBuilder = mock(ImageAnalysis.Builder.class);

        imageAnalysisHostApiImpl.cameraXProxy = mockCameraXProxy;
        when(mockCameraXProxy.createImageAnalysisBuilder()).thenReturn(mockImageAnalysisBuilder);
        when(mockImageAnalysisBuilder.build()).thenReturn(mockImageAnalysis);

        final ArgumentCaptor<Size> sizeCaptor = ArgumentCaptor.forClass(Size.class);

        imageAnalysisHostApiImpl.create(imageAnalysisIdentifier, resolutionInfo);

        verify(mockImageAnalysisBuilder).setTargetResolution(sizeCaptor.capture());
        assertEquals(sizeCaptor.getValue().getWidth(), targetResolutionWidth);
        assertEquals(sizeCaptor.getValue().getHeight(), targetResolutionHeight);
        verify(mockImageAnalysisBuilder).build();
        verify(testInstanceManager).addDartCreatedInstance(mockImageAnalysis, imageAnalysisIdentifier);
    }

    @Test
    public void setAnalyzer_setsAnalyzerThatSendsExpectedImageInformation() {
        final ImageAnalysisHostApiImpl imageAnalysisHostApiImpl =
            new ImageAnalysisHostApiImpl(mockBinaryMessenger, testInstanceManager);
        final ImageAnalysisFlutterApiImpl mockImageAnalysisFlutterApiImpl = mock(ImageAnalysisFlutterApiImpl.class);
        final Long mockImageAnalysisIdentifier = 37L;
        final ImageProxy mockImageProxy = mock(ImageProxy.class);

        testInstanceManager.addDartCreatedInstance(mockImageAnalysis, mockImageAnalysisIdentifier);
        imageAnalysisHostApiImpl.setContext(context);
        imageAnalysisHostApiImpl.cameraXProxy = mockCameraXProxy;
        when(mockCameraXProxy.createImageAnalysisFlutterApiImpl(mockBinaryMessenger)).thenReturn(mockImageAnalysisFlutterApiImpl);

        final ArgumentCaptor<ImageAnalysis.Analyzer> analyzerCaptor = ArgumentCaptor.forClass(ImageAnalysis.Analyzer.class);

        // Test that analyzer is set:

        imageAnalysisHostApiImpl.setAnalyzer(mockImageAnalysisIdentifier);

        verify(mockImageAnalysis).setAnalyzer(any(Executor.class), analyzerCaptor.capture());
        ImageAnalysis.Analyzer analyzer = analyzerCaptor.getValue();

        // Test that the expected image information is sent:

        final ImageProxy.PlaneProxy mockPlaneProxy = mock(ImageProxy.PlaneProxy.class);
        final ImageProxy.PlaneProxy[] mockPlanes = new ImageProxy.PlaneProxy[] { mockPlaneProxy };
        final ByteBuffer mockByteBuffer = mock(ByteBuffer.class);
        final int remainingBytes = 1;
        final int rowStride = 40;
        final int pixelStride = 36;
        final int width = 50;
        final int height = 10;
        final int format = 35;

        when(mockImageProxy.getPlanes()).thenReturn(mockPlanes);
        when(mockPlaneProxy.getBuffer()).thenReturn(mockByteBuffer);
        when(mockByteBuffer.remaining()).thenReturn(remainingBytes);
        when(mockPlaneProxy.getRowStride()).thenReturn(rowStride);
        when(mockPlaneProxy.getPixelStride()).thenReturn(pixelStride);
        when(mockImageProxy.getWidth()).thenReturn(width);
        when(mockImageProxy.getHeight()).thenReturn(height);
        when(mockImageProxy.getFormat()).thenReturn(format);

        final ArgumentCaptor<GeneratedCameraXLibrary.ImageInformation> imageInformationCaptor = ArgumentCaptor.forClass(GeneratedCameraXLibrary.ImageInformation.class);

        analyzer.analyze(mockImageProxy);

        verify(mockImageAnalysisFlutterApiImpl).sendOnImageAnalyzedEvent(imageInformationCaptor.capture(), any());
        verify(mockImageProxy).close();

        ImageInformation imageInformation = imageInformationCaptor.getValue();
        assertEquals(imageInformation.getWidth(), Long.valueOf(width));
        assertEquals(imageInformation.getHeight(), Long.valueOf(height));
        assertEquals(imageInformation.getFormat(), Long.valueOf(format));
        List<ImagePlaneInformation> imagePlanesInformation = imageInformation.getImagePlanesInformation();
        ImagePlaneInformation imagePlaneInformation = imagePlanesInformation.get(0);
        assertEquals(imagePlaneInformation.getBytesPerRow(), Long.valueOf(rowStride));
        assertEquals(imagePlaneInformation.getBytesPerPixel(), Long.valueOf(pixelStride));
        // We expect one (remainingBytes) bye. This byte should equal the byte contained by the mock ByteBuffer.
        assertEquals(imagePlaneInformation.getBytes().length, remainingBytes);
        assertEquals(imagePlaneInformation.getBytes()[0], mockByteBuffer.get());
    }

    @Test
    public void clearAnalyzer_makesCallToClearAnalyzer() {
        final ImageAnalysisHostApiImpl imageAnalysisHostApiImpl =
            new ImageAnalysisHostApiImpl(mockBinaryMessenger, testInstanceManager);
        final Long mockImageAnalysisIdentifier = 12L;

        testInstanceManager.addDartCreatedInstance(mockImageAnalysis, mockImageAnalysisIdentifier);

        imageAnalysisHostApiImpl.clearAnalyzer(mockImageAnalysisIdentifier);

        verify(mockImageAnalysis).clearAnalyzer();
    }

    @Test
    public void sendOnImageAnalyzedEvent_callsOnImageAnalyzed() {
        final ImageAnalysisFlutterApiImpl spyFlutterApi =
            spy(new ImageAnalysisFlutterApiImpl(mockBinaryMessenger));
        final ImageInformation mockImageInformation = mock(ImageInformation.class);

        spyFlutterApi.sendOnImageAnalyzedEvent(mockImageInformation, reply -> {});

        verify(spyFlutterApi).onImageAnalyzed(eq(mockImageInformation), any());
    }
 }
