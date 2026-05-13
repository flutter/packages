// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.resolutionselector.ResolutionStrategy;

/**
 * ProxyApi implementation for {@link ResolutionSelector}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class ResolutionSelectorProxyApi extends PigeonApiResolutionSelector {
  ResolutionSelectorProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ResolutionSelector pigeon_defaultConstructor(
      @Nullable ResolutionFilter resolutionFilter,
      @Nullable ResolutionStrategy resolutionStrategy,
      @Nullable AspectRatioStrategy aspectRatioStrategy) {
    final ResolutionSelector.Builder builder = new ResolutionSelector.Builder();
    if (aspectRatioStrategy != null) {
      builder.setAspectRatioStrategy(aspectRatioStrategy);
    }
    if (resolutionStrategy != null) {
      builder.setResolutionStrategy(resolutionStrategy);
    }
    if (resolutionFilter != null) {
      builder.setResolutionFilter(resolutionFilter);
    }
    return builder.build();
  }

  @Nullable
  @Override
  public ResolutionFilter resolutionFilter(@NonNull ResolutionSelector pigeonInstance) {
    return pigeonInstance.getResolutionFilter();
  }

  @Nullable
  @Override
  public ResolutionStrategy resolutionStrategy(@NonNull ResolutionSelector pigeonInstance) {
    return pigeonInstance.getResolutionStrategy();
  }

  @NonNull
  @Override
  public AspectRatioStrategy getAspectRatioStrategy(@NonNull ResolutionSelector pigeonInstance) {
    return pigeonInstance.getAspectRatioStrategy();
  }
}
