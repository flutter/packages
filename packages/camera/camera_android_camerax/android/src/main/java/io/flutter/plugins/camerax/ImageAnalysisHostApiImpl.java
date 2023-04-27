// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageAnalysis;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageAnalysisHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import java.util.Objects;

public class ImageAnalysisHostApiImpl implements ImageAnalysisHostApi {

  private InstanceManager instanceManager;
  private BinaryMessenger binaryMessenger;
  private Context context;

  @VisibleForTesting @NonNull public CameraXProxy cameraXProxy = new CameraXProxy();

  public ImageAnalysisHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  /**
   * Sets the context that will be used to run an {@link ImageAnalysis.Analyzer} on the main thread.
   */
  public void setContext(@NonNull Context context) {
    this.context = context;
  }

  /** Creates an {@link ImageAnalysis} instance with the target resolution if specified. */
  @Override
  public void create(@NonNull Long identifier, @Nullable ResolutionInfo targetResolution) {
    ImageAnalysis.Builder imageAnalysisBuilder = cameraXProxy.createImageAnalysisBuilder();

    if (targetResolution != null) {
      imageAnalysisBuilder.setTargetResolution(CameraXProxy.sizeFromResolution(targetResolution));
    }

    ImageAnalysis imageAnalysis = imageAnalysisBuilder.build();
    instanceManager.addDartCreatedInstance(imageAnalysis, identifier);
  }

  /**
   * Sets {@link ImageAnalysis.Analyzer} instance with specified {@code analyzerIdentifier} on the
   * {@link ImageAnalysis} instance with the specified {@code identifier} to receive and analyze
   * images.
   */
  @Override
  public void setAnalyzer(@NonNull Long identifier, @NonNull Long analyzerIdentifier) {
    getImageAnalysisInstance(identifier)
        .setAnalyzer(
            ContextCompat.getMainExecutor(context),
            Objects.requireNonNull(instanceManager.getInstance(analyzerIdentifier)));
  }

  /** Clears any analyzer previously set on the specified {@link ImageAnalysis} instance. */
  @Override
  public void clearAnalyzer(@NonNull Long identifier) {
    ImageAnalysis imageAnalysis =
        (ImageAnalysis) Objects.requireNonNull(instanceManager.getInstance(identifier));
    imageAnalysis.clearAnalyzer();
  }

  /**
   * Retrieives the {@link ImageAnalysis} instance associated with the specified {@code identifier}.
   */
  private ImageAnalysis getImageAnalysisInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
