// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionSelectorHostApi;

/**
 * Host API implementation for `ResolutionSelector`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ResolutionSelectorHostApiImpl implements ResolutionSelectorHostApi {
  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private final ResolutionSelectorProxy proxy;

  /** Proxy for constructors and static method of `ResolutionSelector`. */
  @VisibleForTesting
  public static class ResolutionSelectorProxy {
    /** Creates an instance of `ResolutionSelector`. */
    @NonNull
    public ResolutionSelector create(
        @Nullable ResolutionStrategy resolutionStrategy,
        @Nullable AspectRatioStrategy aspectRatioStrategy) {
      final ResolutionSelector.Builder builder = new ResolutionSelector.Builder();
      if (resolutionStrategy != null) {
        builder.setResolutionStrategy(resolutionStrategy);
      }
      if (aspectRatioStrategy != null) {
        builder.setAspectRatioStrategy(aspectRatioStrategy);
      }
      return builder.build();
    }
  }

  /**
   * Constructs a {@link ResolutionSelectorHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ResolutionSelectorHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this(binaryMessenger, instanceManager, new ResolutionSelectorProxy());
  }

  /**
   * Constructs a {@link ResolutionSelectorHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of `ResolutionSelector`
   */
  @VisibleForTesting
  ResolutionSelectorHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull ResolutionSelectorProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(
      @NonNull Long identifier,
      @Nullable Long resolutionStrategyIdentifier,
      @Nullable Long aspectRatioStrategyIdentifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(
            resolutionStrategyIdentifier == null
                ? null
                : instanceManager.getInstance(resolutionStrategyIdentifier),
            aspectRatioStrategyIdentifier == null
                ? null
                : instanceManager.getInstance(aspectRatioStrategyIdentifier)),
        identifier);
  }
}
