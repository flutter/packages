// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionStrategyHostApi;

/**
 * Host API implementation for `ResolutionStrategy`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ResolutionStrategyHostApiImpl implements ResolutionStrategyHostApi {
  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private final ResolutionStrategyProxy proxy;

  /** Proxy for constructors and static method of `ResolutionStrategy`. */
  @VisibleForTesting
  public static class ResolutionStrategyProxy {

    /** Creates an instance of `ResolutionStrategy`. */
    @NonNull
    public ResolutionStrategy create(@NonNull Size boundSize, @NonNull Long fallbackRule) {
      return new ResolutionStrategy(boundSize, fallbackRule.intValue());
    }
  }

  /**
   * Constructs a {@link ResolutionStrategyHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ResolutionStrategyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this(binaryMessenger, instanceManager, new ResolutionStrategyProxy());
  }

  /**
   * Constructs a {@link ResolutionStrategyHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of `ResolutionStrategy`
   */
  @VisibleForTesting
  ResolutionStrategyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull ResolutionStrategyProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(
      @NonNull Long identifier,
      @Nullable GeneratedCameraXLibrary.ResolutionInfo boundSize,
      @Nullable Long fallbackRule) {
    ResolutionStrategy resolutionStrategy;
    if (boundSize == null) {
      resolutionStrategy = ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY;
    }
    else {
      resolutionStrategy = proxy.create(
        new Size(boundSize.getWidth().intValue(), boundSize.getHeight().intValue()),
        fallbackRule);
    }
    instanceManager.addDartCreatedInstance(
      resolutionStrategy,
        identifier);
  }
}
