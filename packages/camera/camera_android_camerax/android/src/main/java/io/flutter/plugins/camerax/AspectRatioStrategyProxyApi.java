// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.resolutionselector.AspectRatioStrategy;

/**
 * ProxyApi implementation for {@link AspectRatioStrategy}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class AspectRatioStrategyProxyApi extends PigeonApiAspectRatioStrategy {
  AspectRatioStrategyProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public AspectRatioStrategy pigeon_defaultConstructor(
      @NonNull AspectRatio preferredAspectRatio,
      @NonNull AspectRatioStrategyFallbackRule fallbackRule) {
    int nativeAspectRatio = -2;
    switch (preferredAspectRatio) {
      case RATIO16TO9:
        nativeAspectRatio = androidx.camera.core.AspectRatio.RATIO_16_9;
        break;
      case RATIO4TO3:
        nativeAspectRatio = androidx.camera.core.AspectRatio.RATIO_4_3;
        break;
      case RATIO_DEFAULT:
        nativeAspectRatio = androidx.camera.core.AspectRatio.RATIO_DEFAULT;
        break;
      case UNKNOWN:
      default:
        // Default to nativeAspectRatio -2.
        break;
    }
    int nativeFallbackRule = -1;
    switch (fallbackRule) {
      case AUTO:
        nativeFallbackRule = AspectRatioStrategy.FALLBACK_RULE_AUTO;
        break;
      case NONE:
        nativeFallbackRule = AspectRatioStrategy.FALLBACK_RULE_NONE;
        break;
      case UNKNOWN:
      default:
        // Default to nativeFallbackRule -1.
        break;
    }
    return new AspectRatioStrategy(nativeAspectRatio, nativeFallbackRule);
  }

  @NonNull
  @Override
  public AspectRatioStrategy ratio_16_9FallbackAutoStrategy() {
    return AspectRatioStrategy.RATIO_16_9_FALLBACK_AUTO_STRATEGY;
  }

  @NonNull
  @Override
  public AspectRatioStrategy ratio_4_3FallbackAutoStrategy() {
    return AspectRatioStrategy.RATIO_4_3_FALLBACK_AUTO_STRATEGY;
  }

  @NonNull
  @Override
  public AspectRatioStrategyFallbackRule getFallbackRule(
      @NonNull AspectRatioStrategy pigeonInstance) {
    switch (pigeonInstance.getFallbackRule()) {
      case AspectRatioStrategy.FALLBACK_RULE_AUTO:
        return AspectRatioStrategyFallbackRule.AUTO;
      case AspectRatioStrategy.FALLBACK_RULE_NONE:
        return AspectRatioStrategyFallbackRule.NONE;
      default:
        return AspectRatioStrategyFallbackRule.UNKNOWN;
    }
  }

  @NonNull
  @Override
  public AspectRatio getPreferredAspectRatio(@NonNull AspectRatioStrategy pigeonInstance) {
    switch (pigeonInstance.getPreferredAspectRatio()) {
      case androidx.camera.core.AspectRatio.RATIO_16_9:
        return AspectRatio.RATIO16TO9;
      case androidx.camera.core.AspectRatio.RATIO_4_3:
        return AspectRatio.RATIO4TO3;
      case androidx.camera.core.AspectRatio.RATIO_DEFAULT:
        return AspectRatio.RATIO_DEFAULT;
      default:
        return AspectRatio.UNKNOWN;
    }
  }
}
