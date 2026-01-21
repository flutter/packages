// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import java.io.File;
import java.io.IOException;
import java.util.concurrent.Executors;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * ProxyApi implementation for {@link ImageCapture}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class ImageCaptureProxyApi extends PigeonApiImageCapture {
  static final String TEMPORARY_FILE_NAME = "CAP";
  static final String JPG_FILE_TYPE = ".jpg";

  ImageCaptureProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public ImageCapture pigeon_defaultConstructor(
      @Nullable ResolutionSelector resolutionSelector,
      @Nullable Long targetRotation,
      @Nullable CameraXFlashMode flashMode) {
    final ImageCapture.Builder builder = new ImageCapture.Builder();
    if (targetRotation != null) {
      builder.setTargetRotation(targetRotation.intValue());
    }
    if (flashMode != null) {
      // This sets the requested flash mode, but may fail silently.
      switch (flashMode) {
        case AUTO:
          builder.setFlashMode(ImageCapture.FLASH_MODE_AUTO);
          break;
        case OFF:
          builder.setFlashMode(ImageCapture.FLASH_MODE_OFF);
          break;
        case ON:
          builder.setFlashMode(ImageCapture.FLASH_MODE_ON);
          break;
      }
    }
    if (resolutionSelector != null) {
      builder.setResolutionSelector(resolutionSelector);
    }
    return builder.build();
  }

  @Override
  public void setFlashMode(
      @NonNull ImageCapture pigeonInstance, @NonNull CameraXFlashMode flashMode) {
    int nativeFlashMode = -1;
    switch (flashMode) {
      case AUTO:
        nativeFlashMode = ImageCapture.FLASH_MODE_AUTO;
        break;
      case OFF:
        nativeFlashMode = ImageCapture.FLASH_MODE_OFF;
        break;
      case ON:
        nativeFlashMode = ImageCapture.FLASH_MODE_ON;
    }
    pigeonInstance.setFlashMode(nativeFlashMode);
  }

  @Override
  public void takePicture(
      @NonNull ImageCapture pigeonInstance,
      @NonNull SystemServicesManager systemServicesManager,
      @NonNull Function1<? super Result<String>, Unit> callback) {
    final File outputDir = getPigeonRegistrar().getContext().getCacheDir();
    File temporaryCaptureFile;
    try {
      temporaryCaptureFile = File.createTempFile(TEMPORARY_FILE_NAME, JPG_FILE_TYPE, outputDir);
    } catch (IOException | SecurityException e) {
      ResultCompat.failure(e, callback);
      return;
    }

    final ImageCapture.OutputFileOptions outputFileOptions =
        createImageCaptureOutputFileOptions(temporaryCaptureFile);
    final ImageCapture.OnImageSavedCallback onImageSavedCallback =
        createOnImageSavedCallback(temporaryCaptureFile, systemServicesManager, callback);

    pigeonInstance.takePicture(
        outputFileOptions, Executors.newSingleThreadExecutor(), onImageSavedCallback);
  }

  @Override
  public void setTargetRotation(ImageCapture pigeonInstance, long rotation) {
    pigeonInstance.setTargetRotation((int) rotation);
  }

  @Nullable
  @Override
  public ResolutionSelector resolutionSelector(@NonNull ImageCapture pigeonInstance) {
    return pigeonInstance.getResolutionSelector();
  }

  ImageCapture.OutputFileOptions createImageCaptureOutputFileOptions(@NonNull File file) {
    return new ImageCapture.OutputFileOptions.Builder(file).build();
  }

  @NonNull
  ImageCapture.OnImageSavedCallback createOnImageSavedCallback(
      @NonNull File file,
      @NonNull SystemServicesManager systemServicesManager,
      @NonNull Function1<? super Result<String>, Unit> callback) {
    return new ImageCapture.OnImageSavedCallback() {
      @Override
      public void onImageSaved(@NonNull ImageCapture.OutputFileResults outputFileResults) {
        ResultCompat.success(file.getAbsolutePath(), callback);
      }

      @Override
      public void onError(@NonNull ImageCaptureException exception) {
        systemServicesManager.onCameraError(
            getImageCaptureExceptionDescription(exception.getImageCaptureError()));
        ResultCompat.failure(exception, callback);
      }
    };
  }

  /**
   * Returns an error description for each {@link ImageCaptureException} error code.
   *
   * <p>See
   * https://developer.android.com/reference/androidx/camera/core/ImageCaptureException#getImageCaptureError()
   * for details on each error type.
   */
  String getImageCaptureExceptionDescription(int imageCaptureErrorCode) {
    switch (imageCaptureErrorCode) {
      case ImageCapture.ERROR_FILE_IO:
        return "An error occurred while attempting to save the captured image to a File.";
      case ImageCapture.ERROR_CAPTURE_FAILED:
        return "The camera framework failed to fulfill the image capture request.";
      case ImageCapture.ERROR_CAMERA_CLOSED:
        return "Image capture failed due to the camera being closed.";
      case ImageCapture.ERROR_INVALID_CAMERA:
        return "The ImageCapture use case was bound to an invalid camera by the Flutter camera plugin. If you see this error, please file an issue if you cannot find one that already exists: https://github.com/flutter/flutter/issues/.";
      case ImageCapture.ERROR_UNKNOWN:
      default:
        return "An unknown error has occurred while attempting to take a picture. Check the logs for more details.";
    }
  }
}
