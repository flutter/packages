// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.AspectRatioStrategyHostApi;

/**
 * Host API implementation for {@link AspectRatioStrategy}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class AspectRatioStrategyHostApiImpl implements AspectRatioStrategyHostApi {
  private final InstanceManager instanceManager;
  private final AspectRatioStrategyProxy proxy;

  /** Proxy for constructors and static method of {@link AspectRatioStrategy}. */
  @VisibleForTesting
  public static class AspectRatioStrategyProxy {
    /** Creates an instance of {@link AspectRatioStrategy}. */
    @NonNull
    public AspectRatioStrategy create(
        @NonNull Long preferredAspectRatio, @NonNull Long fallbackRule) {
      return new AspectRatioStrategy(preferredAspectRatio.intValue(), fallbackRule.intValue());
    }
  }

  /**
   * Constructs an {@link AspectRatioStrategyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public AspectRatioStrategyHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new AspectRatioStrategyProxy());
  }

  /**
   * Constructs an {@link AspectRatioStrategyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of {@link AspectRatioStrategy}
   */
  @VisibleForTesting
  AspectRatioStrategyHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull AspectRatioStrategyProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates an {@link AspectRatioStrategy} instance with the preferred aspect ratio and fallback
   * rule specified.
   */
  @Override
  public void create(
      @NonNull Long identifier, @NonNull Long preferredAspectRatio, @NonNull Long fallbackRule) {
    instanceManager.addDartCreatedInstance(
        proxy.create(preferredAspectRatio, fallbackRule), identifier);
  }
}
