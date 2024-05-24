// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageAnalysisHostApi;
import java.util.Objects;

public class ImageAnalysisHostApiImpl implements ImageAnalysisHostApi {

  private InstanceManager instanceManager;
  private BinaryMessenger binaryMessenger;
  @Nullable private Context context;

  @VisibleForTesting @NonNull public CameraXProxy cameraXProxy = new CameraXProxy();

  public ImageAnalysisHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
  }

  /**
   * Sets the context that will be used to run an {@link ImageAnalysis.Analyzer} on the main thread.
   */
  public void setContext(@NonNull Context context) {
    this.context = context;
  }

  /** Creates an {@link ImageAnalysis} instance with the target resolution if specified. */
  @Override
  public void create(
      @NonNull Long identifier, @Nullable Long rotation, @Nullable Long resolutionSelectorId) {
    ImageAnalysis.Builder imageAnalysisBuilder = cameraXProxy.createImageAnalysisBuilder();

    if (rotation != null) {
      imageAnalysisBuilder.setTargetRotation(rotation.intValue());
    }
    if (resolutionSelectorId != null) {
      ResolutionSelector resolutionSelector =
          Objects.requireNonNull(instanceManager.getInstance(resolutionSelectorId));
      imageAnalysisBuilder.setResolutionSelector(resolutionSelector);
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
    if (context == null) {
      throw new IllegalStateException("Context must be set to set an Analyzer.");
    }

    // Shorten time interval used to define how often the instanceManager removes garbage
    // collected weak references to native Android objects that it manages in order to
    // account for the increased memory usage that comes from analyzing images with an
    // ImageAnalysis.Analyzer.
    instanceManager.setClearFinalizedWeakReferencesInterval(
        InstanceManager.CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL_FOR_IMAGE_ANALYSIS);
    instanceManager.releaseAllFinalizedInstances();

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

    // Restore the default time interval used to define how often the instanceManager
    // removes garbage collected weak references to native Android objects that it
    // manages since analyzing images with an ImageAnalysis.Analyzer, which involves
    // increased memory usage, is finished.
    instanceManager.setClearFinalizedWeakReferencesInterval(
        InstanceManager.DEFAULT_CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL);
  }

  /** Dynamically sets the target rotation of the {@link ImageAnalysis}. */
  @Override
  public void setTargetRotation(@NonNull Long identifier, @NonNull Long rotation) {
    ImageAnalysis imageAnalysis = getImageAnalysisInstance(identifier);
    imageAnalysis.setTargetRotation(rotation.intValue());
  }

  /**
   * Retrieives the {@link ImageAnalysis} instance associated with the specified {@code identifier}.
   */
  private ImageAnalysis getImageAnalysisInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
