// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.camera.camera2.interop.Camera2Interop;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.core.content.ContextCompat;

/**
 * ProxyApi implementation for {@link ImageAnalysis}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class ImageAnalysisProxyApi extends PigeonApiImageAnalysis {
  static final long CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL_FOR_IMAGE_ANALYSIS = 1000;

  // Range<?> is defined as Range<Integer> in pigeon.
  @SuppressWarnings("unchecked")
  @OptIn(markerClass = ExperimentalCamera2Interop.class)
  @NonNull
  @Override
  public ImageAnalysis pigeon_defaultConstructor(
      @Nullable ResolutionSelector resolutionSelector,
      @Nullable Long targetRotation,
      @Nullable Range<?> targetFpsRange,
      @Nullable Long outputImageFormat) {
    final ImageAnalysis.Builder builder = new ImageAnalysis.Builder();
    if (resolutionSelector != null) {
      builder.setResolutionSelector(resolutionSelector);
    }
    if (targetRotation != null) {
      builder.setTargetRotation(targetRotation.intValue());
    }

    if (outputImageFormat != null) {
      builder.setOutputImageFormat(outputImageFormat.intValue());
    }

    if (targetFpsRange != null) {
      Camera2Interop.Extender<ImageAnalysis> extender = new Camera2Interop.Extender<>(builder);
      extender.setCaptureRequestOption(
          CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, (Range<Integer>) targetFpsRange);
    }

    return builder.build();
  }

  ImageAnalysisProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @Override
  public void setAnalyzer(ImageAnalysis pigeonInstance, @NonNull ImageAnalysis.Analyzer analyzer) {
    getPigeonRegistrar()
        .getInstanceManager()
        .setClearFinalizedWeakReferencesInterval(
            CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL_FOR_IMAGE_ANALYSIS);
    pigeonInstance.setAnalyzer(
        ContextCompat.getMainExecutor(getPigeonRegistrar().getContext()), analyzer);
  }

  @Override
  public void clearAnalyzer(ImageAnalysis pigeonInstance) {
    pigeonInstance.clearAnalyzer();
    getPigeonRegistrar()
        .getInstanceManager()
        .setClearFinalizedWeakReferencesInterval(
            getPigeonRegistrar().getDefaultClearFinalizedWeakReferencesInterval());
  }

  @Override
  public void setTargetRotation(ImageAnalysis pigeonInstance, long rotation) {
    pigeonInstance.setTargetRotation((int) rotation);
  }

  @Nullable
  @Override
  public ResolutionSelector resolutionSelector(@NonNull ImageAnalysis pigeonInstance) {
    return pigeonInstance.getResolutionSelector();
  }
}
