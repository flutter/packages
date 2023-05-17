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
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import io.flutter.plugin.common.BinaryMessenger;
import java.io.File;
import java.io.IOException;
import java.util.concurrent.Executor;
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
public class ImageCaptureTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ImageCapture mockImageCapture;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public CameraXProxy mockCameraXProxy;

  InstanceManager testInstanceManager;
  private Context context;
  private MockedStatic<File> mockedStaticFile;

  @Before
  public void setUp() throws Exception {
    testInstanceManager = spy(InstanceManager.create(identifier -> {}));
    context = mock(Context.class);
    mockedStaticFile = mockStatic(File.class);
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
    mockedStaticFile.close();
  }

  @Test
  public void create_createsImageCaptureWithCorrectConfiguration() {
    final ImageCaptureHostApiImpl imageCaptureHostApiImpl =
        new ImageCaptureHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final ImageCapture.Builder mockImageCaptureBuilder = mock(ImageCapture.Builder.class);
    final Long imageCaptureIdentifier = 74L;
    final Long flashMode = Long.valueOf(ImageCapture.FLASH_MODE_ON);
    final int targetResolutionWidth = 10;
    final int targetResolutionHeight = 50;
    final GeneratedCameraXLibrary.ResolutionInfo resolutionInfo =
        new GeneratedCameraXLibrary.ResolutionInfo.Builder()
            .setWidth(Long.valueOf(targetResolutionWidth))
            .setHeight(Long.valueOf(targetResolutionHeight))
            .build();

    imageCaptureHostApiImpl.cameraXProxy = mockCameraXProxy;
    when(mockCameraXProxy.createImageCaptureBuilder()).thenReturn(mockImageCaptureBuilder);
    when(mockImageCaptureBuilder.build()).thenReturn(mockImageCapture);

    final ArgumentCaptor<Size> sizeCaptor = ArgumentCaptor.forClass(Size.class);

    imageCaptureHostApiImpl.create(imageCaptureIdentifier, flashMode, resolutionInfo);

    verify(mockImageCaptureBuilder).setFlashMode(flashMode.intValue());
    verify(mockImageCaptureBuilder).setTargetResolution(sizeCaptor.capture());
    assertEquals(sizeCaptor.getValue().getWidth(), targetResolutionWidth);
    assertEquals(sizeCaptor.getValue().getHeight(), targetResolutionHeight);
    verify(mockImageCaptureBuilder).build();
    verify(testInstanceManager).addDartCreatedInstance(mockImageCapture, imageCaptureIdentifier);
  }

  @Test
  public void setFlashMode_setsFlashModeOfImageCaptureInstance() {
    final ImageCaptureHostApiImpl imageCaptureHostApiImpl =
        new ImageCaptureHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final Long imageCaptureIdentifier = 85L;
    final Long flashMode = Long.valueOf(ImageCapture.FLASH_MODE_AUTO);

    testInstanceManager.addDartCreatedInstance(mockImageCapture, imageCaptureIdentifier);

    imageCaptureHostApiImpl.setFlashMode(imageCaptureIdentifier, flashMode);

    verify(mockImageCapture).setFlashMode(flashMode.intValue());
  }

  @Test
  public void
      takePicture_sendsRequestToTakePictureWithExpectedConfigurationWhenTemporaryFileCanBeCreated() {
    final ImageCaptureHostApiImpl imageCaptureHostApiImpl =
        spy(new ImageCaptureHostApiImpl(mockBinaryMessenger, testInstanceManager, context));
    final Long imageCaptureIdentifier = 6L;
    final File mockOutputDir = mock(File.class);
    final File mockFile = mock(File.class);
    final ImageCapture.OutputFileOptions mockOutputFileOptions =
        mock(ImageCapture.OutputFileOptions.class);
    final ImageCapture.OnImageSavedCallback mockOnImageSavedCallback =
        mock(ImageCapture.OnImageSavedCallback.class);
    @SuppressWarnings("unchecked")
    final GeneratedCameraXLibrary.Result<String> mockResult =
        mock(GeneratedCameraXLibrary.Result.class);

    testInstanceManager.addDartCreatedInstance(mockImageCapture, imageCaptureIdentifier);
    when(context.getCacheDir()).thenReturn(mockOutputDir);
    imageCaptureHostApiImpl.cameraXProxy = mockCameraXProxy;
    mockedStaticFile
        .when(
            () ->
                File.createTempFile(
                    ImageCaptureHostApiImpl.TEMPORARY_FILE_NAME,
                    ImageCaptureHostApiImpl.JPG_FILE_TYPE,
                    mockOutputDir))
        .thenReturn(mockFile);
    when(mockCameraXProxy.createImageCaptureOutputFileOptions(mockFile))
        .thenReturn(mockOutputFileOptions);
    when(imageCaptureHostApiImpl.createOnImageSavedCallback(mockFile, mockResult))
        .thenReturn(mockOnImageSavedCallback);

    imageCaptureHostApiImpl.takePicture(imageCaptureIdentifier, mockResult);

    verify(mockImageCapture)
        .takePicture(eq(mockOutputFileOptions), any(Executor.class), eq(mockOnImageSavedCallback));
  }

  @Test
  public void takePicture_sendsErrorWhenTemporaryFileCannotBeCreated() {
    final ImageCaptureHostApiImpl imageCaptureHostApiImpl =
        new ImageCaptureHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final Long imageCaptureIdentifier = 6L;
    final File mockOutputDir = mock(File.class);
    final File mockTemporaryCaptureFile = mock(File.class);
    @SuppressWarnings("unchecked")
    final GeneratedCameraXLibrary.Result<String> mockResult =
        mock(GeneratedCameraXLibrary.Result.class);
    final IOException fileCreationException = new IOException();

    testInstanceManager.addDartCreatedInstance(mockImageCapture, imageCaptureIdentifier);
    imageCaptureHostApiImpl.cameraXProxy = mockCameraXProxy;
    when(context.getCacheDir()).thenReturn(mockOutputDir);
    mockedStaticFile
        .when(
            () ->
                File.createTempFile(
                    ImageCaptureHostApiImpl.TEMPORARY_FILE_NAME,
                    ImageCaptureHostApiImpl.JPG_FILE_TYPE,
                    mockOutputDir))
        .thenThrow(fileCreationException);

    imageCaptureHostApiImpl.takePicture(imageCaptureIdentifier, mockResult);

    verify(mockResult).error(fileCreationException);
    verify(mockImageCapture, times(0))
        .takePicture(
            any(ImageCapture.OutputFileOptions.class),
            any(Executor.class),
            any(ImageCapture.OnImageSavedCallback.class));
  }

  @Test
  public void takePicture_usesExpectedOnImageSavedCallback() {
    final ImageCaptureHostApiImpl imageCaptureHostApiImpl =
        new ImageCaptureHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final SystemServicesFlutterApiImpl mockSystemServicesFlutterApiImpl =
        mock(SystemServicesFlutterApiImpl.class);
    final File mockFile = mock(File.class);
    @SuppressWarnings("unchecked")
    final GeneratedCameraXLibrary.Result<String> mockResult =
        mock(GeneratedCameraXLibrary.Result.class);
    final ImageCapture.OutputFileResults mockOutputFileResults =
        mock(ImageCapture.OutputFileResults.class);
    final String mockFileAbsolutePath = "absolute/path/to/captured/image";
    final ImageCaptureException mockException = mock(ImageCaptureException.class);

    imageCaptureHostApiImpl.cameraXProxy = mockCameraXProxy;
    when(mockFile.getAbsolutePath()).thenReturn(mockFileAbsolutePath);

    ImageCapture.OnImageSavedCallback onImageSavedCallback =
        imageCaptureHostApiImpl.createOnImageSavedCallback(mockFile, mockResult);

    // Test success case.
    onImageSavedCallback.onImageSaved(mockOutputFileResults);

    verify(mockResult).success(mockFileAbsolutePath);

    // Test error case.
    onImageSavedCallback.onError(mockException);

    verify(mockResult).error(mockException);
  }
}
