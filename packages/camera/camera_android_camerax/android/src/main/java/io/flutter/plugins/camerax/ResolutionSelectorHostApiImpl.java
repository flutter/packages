// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionSelectorHostApi;
import java.util.Objects;

/**
 * Host API implementation for {@link ResolutionSelector}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ResolutionSelectorHostApiImpl implements ResolutionSelectorHostApi {
  private final InstanceManager instanceManager;
  private final ResolutionSelectorProxy proxy;

  /** Proxy for constructor of {@link ResolutionSelector}. */
  @VisibleForTesting
  public static class ResolutionSelectorProxy {
    /** Creates an instance of {@link ResolutionSelector}. */
    @NonNull
    public ResolutionSelector create(
        @Nullable ResolutionStrategy resolutionStrategy,
        @Nullable AspectRatioStrategy aspectRatioStrategy,
        @Nullable ResolutionFilter resolutionFilter) {
      final ResolutionSelector.Builder builder = new ResolutionSelector.Builder();
      if (resolutionStrategy != null) {
        builder.setResolutionStrategy(resolutionStrategy);
      }
      if (aspectRatioStrategy != null) {
        builder.setAspectRatioStrategy(aspectRatioStrategy);
      }
      if (resolutionFilter != null) {
        builder.setResolutionFilter(resolutionFilter);
      }
      return builder.build();
    }
  }

  /**
   * Constructs a {@link ResolutionSelectorHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ResolutionSelectorHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new ResolutionSelectorProxy());
  }

  /**
   * Constructs a {@link ResolutionSelectorHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link ResolutionSelector}
   */
  @VisibleForTesting
  ResolutionSelectorHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull ResolutionSelectorProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates a {@link ResolutionSelector} instance with the {@link ResolutionStrategy}, {@link
   * ResolutionFilter}, and {@link AspectRatio} that have the identifiers specified if provided.
   */
  @Override
  public void create(
      @NonNull Long identifier,
      @Nullable Long resolutionStrategyIdentifier,
      @Nullable Long resolutionFilterIdentifier,
      @Nullable Long aspectRatioStrategyIdentifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(
            resolutionStrategyIdentifier == null
                ? null
                : Objects.requireNonNull(instanceManager.getInstance(resolutionStrategyIdentifier)),
            aspectRatioStrategyIdentifier == null
                ? null
                : Objects.requireNonNull(
                    instanceManager.getInstance(aspectRatioStrategyIdentifier)),
            resolutionFilterIdentifier == null
                ? null
                : Objects.requireNonNull(instanceManager.getInstance(resolutionFilterIdentifier))),
        identifier);
  }
}
