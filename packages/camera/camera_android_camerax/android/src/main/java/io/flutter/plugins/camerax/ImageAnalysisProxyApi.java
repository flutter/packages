// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
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

  @NonNull
  @Override
  public ImageAnalysis pigeon_defaultConstructor(
      @Nullable ResolutionSelector resolutionSelector, @Nullable Long targetRotation) {
    final ImageAnalysis.Builder builder = new ImageAnalysis.Builder();
    if (resolutionSelector != null) {
      builder.setResolutionSelector(resolutionSelector);
    }
    if (targetRotation != null) {
      builder.setTargetRotation(targetRotation.intValue());
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
