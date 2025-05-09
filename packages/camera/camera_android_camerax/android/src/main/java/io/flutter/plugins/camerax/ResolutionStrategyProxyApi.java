// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.resolutionselector.ResolutionStrategy;

/**
 * ProxyApi implementation for {@link ResolutionStrategy}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class ResolutionStrategyProxyApi extends PigeonApiResolutionStrategy {
  ResolutionStrategyProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ResolutionStrategy pigeon_defaultConstructor(
      @NonNull Size boundSize, @NonNull ResolutionStrategyFallbackRule fallbackRule) {
    int nativeFallbackRule = -1;
    switch (fallbackRule) {
      case CLOSEST_HIGHER:
        nativeFallbackRule = ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER;
        break;
      case CLOSEST_HIGHER_THEN_LOWER:
        nativeFallbackRule = ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER;
        break;
      case CLOSEST_LOWER:
        nativeFallbackRule = ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER;
        break;
      case CLOSEST_LOWER_THEN_HIGHER:
        nativeFallbackRule = ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER_THEN_HIGHER;
        break;
      case NONE:
        nativeFallbackRule = ResolutionStrategy.FALLBACK_RULE_NONE;
        break;
      case UNKNOWN:
        // Default to nativeFallbackRule -1.
        break;
    }
    return new ResolutionStrategy(boundSize, nativeFallbackRule);
  }

  @NonNull
  @Override
  public ResolutionStrategy highestAvailableStrategy() {
    return ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY;
  }

  @Nullable
  @Override
  public Size getBoundSize(@NonNull ResolutionStrategy pigeonInstance) {
    return pigeonInstance.getBoundSize();
  }

  @NonNull
  @Override
  public ResolutionStrategyFallbackRule getFallbackRule(
      @NonNull ResolutionStrategy pigeonInstance) {
    switch (pigeonInstance.getFallbackRule()) {
      case ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER:
        return ResolutionStrategyFallbackRule.CLOSEST_HIGHER;
      case ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER:
        return ResolutionStrategyFallbackRule.CLOSEST_HIGHER_THEN_LOWER;
      case ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER:
        return ResolutionStrategyFallbackRule.CLOSEST_LOWER;
      case ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER_THEN_HIGHER:
        return ResolutionStrategyFallbackRule.CLOSEST_LOWER_THEN_HIGHER;
      case ResolutionStrategy.FALLBACK_RULE_NONE:
        return ResolutionStrategyFallbackRule.NONE;
      default:
        return ResolutionStrategyFallbackRule.UNKNOWN;
    }
  }
}
