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
      @Nullable ResolutionSelectorAllowedResolutionMode allowedResolutionMode,
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
    if (allowedResolutionMode != null) {
      switch (allowedResolutionMode) {
        case PREFER_CAPTURE_RATE_OVER_HIGHER_RESOLUTION:
          builder.setAllowedResolutionMode(
              ResolutionSelector.PREFER_CAPTURE_RATE_OVER_HIGHER_RESOLUTION);
          break;
        case PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE:
          builder.setAllowedResolutionMode(
              ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE);
          break;
        case UNKNOWN:
          // Default to CameraX's default behavior.
          break;
      }
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

  @Nullable
  @Override
  public ResolutionSelectorAllowedResolutionMode allowedResolutionMode(
      @NonNull ResolutionSelector pigeonInstance) {
    switch (pigeonInstance.getAllowedResolutionMode()) {
      case ResolutionSelector.PREFER_CAPTURE_RATE_OVER_HIGHER_RESOLUTION:
        return ResolutionSelectorAllowedResolutionMode.PREFER_CAPTURE_RATE_OVER_HIGHER_RESOLUTION;
      case ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE:
        return ResolutionSelectorAllowedResolutionMode.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE;
      default:
        return ResolutionSelectorAllowedResolutionMode.UNKNOWN;
    }
  }

  @NonNull
  @Override
  public AspectRatioStrategy getAspectRatioStrategy(@NonNull ResolutionSelector pigeonInstance) {
    return pigeonInstance.getAspectRatioStrategy();
  }
}
