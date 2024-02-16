// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionStrategyHostApi;

/**
 * Host API implementation for {@link ResolutionStrategy}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ResolutionStrategyHostApiImpl implements ResolutionStrategyHostApi {
  private final InstanceManager instanceManager;
  private final ResolutionStrategyProxy proxy;

  /** Proxy for constructor of {@link ResolutionStrategy}. */
  @VisibleForTesting
  public static class ResolutionStrategyProxy {

    /** Creates an instance of {@link ResolutionStrategy}. */
    @NonNull
    public ResolutionStrategy create(@NonNull Size boundSize, @NonNull Long fallbackRule) {
      return new ResolutionStrategy(boundSize, fallbackRule.intValue());
    }
  }

  /**
   * Constructs a {@link ResolutionStrategyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ResolutionStrategyHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new ResolutionStrategyProxy());
  }

  /**
   * Constructs a {@link ResolutionStrategyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link ResolutionStrategy}
   */
  @VisibleForTesting
  ResolutionStrategyHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull ResolutionStrategyProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates a {@link ResolutionStrategy} instance with the {@link
   * GeneratedCameraXLibrary.ResolutionInfo} bound size and {@code fallbackRule} if specified.
   */
  @Override
  public void create(
      @NonNull Long identifier,
      @Nullable GeneratedCameraXLibrary.ResolutionInfo boundSize,
      @Nullable Long fallbackRule) {
    ResolutionStrategy resolutionStrategy;
    if (boundSize == null && fallbackRule == null) {
      // Strategy that chooses the highest available resolution does not have a bound size or fallback rule.
      resolutionStrategy = ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY;
    } else if (boundSize == null) {
      throw new IllegalArgumentException(
          "A bound size must be specified if a non-null fallback rule is specified to create a valid ResolutionStrategy.");
    } else {
      resolutionStrategy =
          proxy.create(
              new Size(boundSize.getWidth().intValue(), boundSize.getHeight().intValue()),
              fallbackRule);
    }
    instanceManager.addDartCreatedInstance(resolutionStrategy, identifier);
  }
}
