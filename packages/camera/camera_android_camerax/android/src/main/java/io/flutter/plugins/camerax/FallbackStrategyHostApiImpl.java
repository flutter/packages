// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FallbackStrategyHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQuality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoResolutionFallbackRule;

/**
 * Host API implementation for {@link FallbackStrategy}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class FallbackStrategyHostApiImpl implements FallbackStrategyHostApi {
  private final InstanceManager instanceManager;

  private final FallbackStrategyProxy proxy;

  /** Proxy for constructor of {@link FallbackStrategy}. */
  @VisibleForTesting
  public static class FallbackStrategyProxy {
    /** Creates an instance of {@link FallbackStrategy}. */
    public @NonNull FallbackStrategy create(
        @NonNull VideoQuality videoQuality, @NonNull VideoResolutionFallbackRule fallbackRule) {
      Quality quality = QualitySelectorHostApiImpl.getQualityFromVideoQuality(videoQuality);

      switch (fallbackRule) {
        case HIGHER_QUALITY_OR_LOWER_THAN:
          return FallbackStrategy.higherQualityOrLowerThan(quality);
        case HIGHER_QUALITY_THAN:
          return FallbackStrategy.higherQualityThan(quality);
        case LOWER_QUALITY_OR_HIGHER_THAN:
          return FallbackStrategy.lowerQualityOrHigherThan(quality);
        case LOWER_QUALITY_THAN:
          return FallbackStrategy.lowerQualityThan(quality);
      }
      throw new IllegalArgumentException(
          "Specified fallback rule " + fallbackRule + " unrecognized.");
    }
  }

  /**
   * Constructs a {@link FallbackStrategyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public FallbackStrategyHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new FallbackStrategyProxy());
  }

  /**
   * Constructs a {@link FallbackStrategyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link FallbackStrategy}
   */
  FallbackStrategyHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull FallbackStrategyProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates a {@link FallbackStrategy} instance with the video quality and fallback rule specified.
   */
  @Override
  public void create(
      @NonNull Long identifier,
      @NonNull VideoQuality videoQuality,
      @NonNull VideoResolutionFallbackRule fallbackRule) {
    instanceManager.addDartCreatedInstance(proxy.create(videoQuality, fallbackRule), identifier);
  }
}
