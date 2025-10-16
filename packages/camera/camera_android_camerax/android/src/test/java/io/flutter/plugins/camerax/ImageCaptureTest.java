// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import java.io.File;
import java.io.IOException;
import java.util.concurrent.Executor;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageCaptureTest {
  @Test
  public void pigeon_defaultConstructor_createsImageCaptureWithCorrectConfiguration() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    final ResolutionSelector mockResolutionSelector = new ResolutionSelector.Builder().build();
    final long targetResolution = Surface.ROTATION_0;
    final ImageCapture imageCapture =
        api.pigeon_defaultConstructor(
            mockResolutionSelector, targetResolution, CameraXFlashMode.OFF);

    assertEquals(imageCapture.getResolutionSelector(), mockResolutionSelector);
    assertEquals(imageCapture.getTargetRotation(), Surface.ROTATION_0);
    assertEquals(imageCapture.getFlashMode(), ImageCapture.FLASH_MODE_OFF);
  }

  @Test
  public void resolutionSelector_returnsExpectedResolutionSelector() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    final ImageCapture instance = mock(ImageCapture.class);
    final ResolutionSelector value = mock(ResolutionSelector.class);
    when(instance.getResolutionSelector()).thenReturn(value);

    assertEquals(value, api.resolutionSelector(instance));
  }

  @Test
  public void setFlashMode_setsFlashModeOfImageCaptureInstance() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    final ImageCapture instance = mock(ImageCapture.class);
    final CameraXFlashMode flashMode = io.flutter.plugins.camerax.CameraXFlashMode.AUTO;
    api.setFlashMode(instance, flashMode);

    verify(instance).setFlashMode(ImageCapture.FLASH_MODE_AUTO);
  }

  @Test
  public void
      takePicture_sendsRequestToTakePictureWithExpectedConfigurationWhenTemporaryFileCanBeCreated() {
    final ProxyApiRegistrar mockApiRegistrar = mock(ProxyApiRegistrar.class);
    final Context mockContext = mock(Context.class);
    final File mockOutputDir = mock(File.class);
    when(mockContext.getCacheDir()).thenReturn(mockOutputDir);
    when(mockApiRegistrar.getContext()).thenReturn(mockContext);

    final String filename = "myFile.jpg";
    final ImageCaptureProxyApi api =
        new ImageCaptureProxyApi(mockApiRegistrar) {
          @Override
          ImageCapture.OutputFileOptions createImageCaptureOutputFileOptions(@NonNull File file) {
            return super.createImageCaptureOutputFileOptions(file);
          }

          @NonNull
          @Override
          ImageCapture.OnImageSavedCallback createOnImageSavedCallback(
              @NonNull File file, @NonNull Function1<? super Result<String>, Unit> callback) {
            final File mockFile = mock(File.class);
            when(mockFile.getAbsolutePath()).thenReturn(filename);
            final ImageCapture.OnImageSavedCallback imageSavedCallback =
                super.createOnImageSavedCallback(mockFile, callback);
            imageSavedCallback.onImageSaved(mock(ImageCapture.OutputFileResults.class));
            return imageSavedCallback;
          }
        };

    final ImageCapture instance = mock(ImageCapture.class);

    try (MockedStatic<File> mockedStaticFile = mockStatic(File.class)) {
      final File mockFile = mock(File.class);
      mockedStaticFile
          .when(
              () ->
                  File.createTempFile(
                      ImageCaptureProxyApi.TEMPORARY_FILE_NAME,
                      ImageCaptureProxyApi.JPG_FILE_TYPE,
                      mockOutputDir))
          .thenReturn(mockFile);

      final String[] result = {null};
      api.takePicture(
          instance,
          ResultCompat.asCompatCallback(
              reply -> {
                result[0] = reply.getOrNull();
                return null;
              }));

      verify(instance)
          .takePicture(
              any(ImageCapture.OutputFileOptions.class),
              any(Executor.class),
              any(ImageCapture.OnImageSavedCallback.class));
      assertEquals(result[0], filename);
    }
  }

  @Test
  public void takePicture_sendsErrorWhenTemporaryFileCannotBeCreated() {
    final ProxyApiRegistrar mockApiRegistrar = mock(ProxyApiRegistrar.class);
    final Context mockContext = mock(Context.class);
    final File mockOutputDir = mock(File.class);
    when(mockContext.getCacheDir()).thenReturn(mockOutputDir);
    when(mockApiRegistrar.getContext()).thenReturn(mockContext);

    final PigeonApiImageCapture api = new ImageCaptureProxyApi(mockApiRegistrar);

    final ImageCapture instance = mock(ImageCapture.class);

    try (MockedStatic<File> mockedStaticFile = mockStatic(File.class)) {
      final IOException fileCreationException = new IOException();
      mockedStaticFile
          .when(
              () ->
                  File.createTempFile(
                      ImageCaptureProxyApi.TEMPORARY_FILE_NAME,
                      ImageCaptureProxyApi.JPG_FILE_TYPE,
                      mockOutputDir))
          .thenThrow(fileCreationException);

      final Throwable[] result = {null};
      api.takePicture(
          instance,
          ResultCompat.asCompatCallback(
              reply -> {
                result[0] = reply.exceptionOrNull();
                return null;
              }));

      verifyNoInteractions(instance);
      assertEquals(result[0], fileCreationException);
    }
  }

  @Test
  public void takePicture_onImageSavedCallbackCanSendsError() {
    final ProxyApiRegistrar mockApiRegistrar = mock(ProxyApiRegistrar.class);
    final Context mockContext = mock(Context.class);
    final File mockOutputDir = mock(File.class);
    when(mockContext.getCacheDir()).thenReturn(mockOutputDir);
    when(mockApiRegistrar.getContext()).thenReturn(mockContext);

    final ImageCaptureException captureException = mock(ImageCaptureException.class);
    final ImageCaptureProxyApi api =
        new ImageCaptureProxyApi(mockApiRegistrar) {
          @Override
          ImageCapture.OutputFileOptions createImageCaptureOutputFileOptions(@NonNull File file) {
            return super.createImageCaptureOutputFileOptions(file);
          }

          @NonNull
          @Override
          ImageCapture.OnImageSavedCallback createOnImageSavedCallback(
              @NonNull File file, @NonNull Function1<? super Result<String>, Unit> callback) {
            final ImageCapture.OnImageSavedCallback imageSavedCallback =
                super.createOnImageSavedCallback(mock(File.class), callback);
            imageSavedCallback.onError(captureException);
            return imageSavedCallback;
          }
        };

    final ImageCapture instance = mock(ImageCapture.class);

    try (MockedStatic<File> mockedStaticFile = mockStatic(File.class)) {
      final File mockFile = mock(File.class);
      mockedStaticFile
          .when(
              () ->
                  File.createTempFile(
                      ImageCaptureProxyApi.TEMPORARY_FILE_NAME,
                      ImageCaptureProxyApi.JPG_FILE_TYPE,
                      mockOutputDir))
          .thenReturn(mockFile);

      final Throwable[] result = {null};
      api.takePicture(
          instance,
          ResultCompat.asCompatCallback(
              reply -> {
                result[0] = reply.exceptionOrNull();
                return null;
              }));

      verify(instance)
          .takePicture(
              any(ImageCapture.OutputFileOptions.class),
              any(Executor.class),
              any(ImageCapture.OnImageSavedCallback.class));
      assertEquals(result[0], captureException);
    }
  }

  @Test
  public void setTargetRotation_makesCallToSetTargetRotation() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    final ImageCapture instance = mock(ImageCapture.class);
    final long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation((int) rotation);
  }
}
