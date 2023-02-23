// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageCaptureHostApi;
import java.io.File;
import java.io.IOException;
import java.util.Objects;
import java.util.concurrent.Executors;

public class ImageCaptureHostApiImpl implements ImageCaptureHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  private Context context;
  private SystemServicesFlutterApiImpl systemServicesFlutterApiImpl;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  public ImageCaptureHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
  }

  /**
   * Sets the context that the {@code ImageCapture} will use to find a location to save a captured
   * image.
   */
  public void setContext(Context context) {
    this.context = context;
  }

  /**
   * Creates a {@link ImageCapture} with the requested flash mode and target resolution if
   * specified.
   */
  @Override
  public void create(
      @NonNull Long identifier,
      @Nullable Long flashMode,
      @Nullable GeneratedCameraXLibrary.ResolutionInfo targetResolution) {
    ImageCapture.Builder imageCaptureBuilder = cameraXProxy.createImageCaptureBuilder();
    if (flashMode != null) {
      // This sets the requested flash mode, but may fail silently.
      imageCaptureBuilder.setFlashMode(flashMode.intValue());
    }
    if (targetResolution != null) {
      imageCaptureBuilder.setTargetResolution(
          new Size(
              targetResolution.getWidth().intValue(), targetResolution.getHeight().intValue()));
    }
    ImageCapture imageCapture = imageCaptureBuilder.build();
    instanceManager.addDartCreatedInstance(imageCapture, identifier);
  }

  /** Sets the flash mode of the {@link ImageCapture} instance with the specified identifier. */
  @Override
  public void setFlashMode(@NonNull Long identifier, @NonNull Long flashMode) {
    ImageCapture imageCapture =
        (ImageCapture) Objects.requireNonNull(instanceManager.getInstance(identifier));
    imageCapture.setFlashMode(flashMode.intValue());
  }

  /** Captures a still image and uses the result to return its absolute path in memory. */
  @Override
  public void takePicture(
      @NonNull Long identifier, @NonNull GeneratedCameraXLibrary.Result<String> result) {
    ImageCapture imageCapture =
        (ImageCapture) Objects.requireNonNull(instanceManager.getInstance(identifier));
    final File outputDir = context.getCacheDir();
    File temporaryCaptureFile;
    try {
      temporaryCaptureFile = File.createTempFile("CAP", ".jpg", outputDir);
    } catch (IOException | SecurityException e) {
      handleImageFileError(result, "Cannot create file to save captured image: " + e.getMessage());
      return;
    }

    ImageCapture.OutputFileOptions outputFileOptions =
        cameraXProxy.createImageCaptureOutputFileOptions(temporaryCaptureFile);
    ImageCapture.OnImageSavedCallback onImageSavedCallback =
        createOnImageSavedCallback(temporaryCaptureFile, result);

    imageCapture.takePicture(
        outputFileOptions, Executors.newSingleThreadExecutor(), onImageSavedCallback);
  }

  /** Creates a callback used when saving a captured image. */
  @VisibleForTesting
  public ImageCapture.OnImageSavedCallback createOnImageSavedCallback(
      @NonNull File file, @NonNull GeneratedCameraXLibrary.Result<String> result) {
    return new ImageCapture.OnImageSavedCallback() {
      @Override
      public void onImageSaved(@NonNull ImageCapture.OutputFileResults outputFileResults) {
        result.success(file.getAbsolutePath());
      }

      @Override
      public void onError(@NonNull ImageCaptureException exception) {
        handleImageFileError(result, getOnImageSavedExceptionDescription(exception));
      }
    };
  }

  /** Handle errors with creating a file to save captured image or capturing an image. */
  private void handleImageFileError(
      @NonNull GeneratedCameraXLibrary.Result<String> result, @NonNull String errorDescription) {
    // Send empty path because image was not saved.
    result.success("");

    // Send error.
    if (systemServicesFlutterApiImpl == null) {
      systemServicesFlutterApiImpl =
          cameraXProxy.createSystemServicesFlutterApiImpl(binaryMessenger);
    }
    systemServicesFlutterApiImpl.sendCameraError(errorDescription, reply -> {});
  }

  /** Gets exception description for a failure with saving a captured image. */
  private String getOnImageSavedExceptionDescription(@NonNull ImageCaptureException exception) {
    return exception.getImageCaptureError() + ": " + exception.getMessage();
  }
}
