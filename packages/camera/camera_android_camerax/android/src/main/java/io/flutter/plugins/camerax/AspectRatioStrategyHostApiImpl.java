// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.AspectRatioStrategyHostApi;

/**
 * Host API implementation for `AspectRatioStrategy`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class AspectRatioStrategyHostApiImpl implements AspectRatioStrategyHostApi {
  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private final AspectRatioStrategyProxy proxy;

  /** Proxy for constructors and static method of `AspectRatioStrategy`. */
  @VisibleForTesting
  public static class AspectRatioStrategyProxy {
    /** Creates an instance of `AspectRatioStrategy`. */
    @NonNull
    public AspectRatioStrategy create(
        @NonNull Long preferredAspectRatio, @NonNull Long fallbackRule) {
      return new AspectRatioStrategy(preferredAspectRatio.intValue(), fallbackRule.intValue());
    }
  }

  /**
   * Constructs a {@link AspectRatioStrategyHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public AspectRatioStrategyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this(binaryMessenger, instanceManager, new AspectRatioStrategyProxy());
  }

  /**
   * Constructs a {@link AspectRatioStrategyHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of `AspectRatioStrategy`
   */
  @VisibleForTesting
  AspectRatioStrategyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull AspectRatioStrategyProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(
      @NonNull Long identifier, @NonNull Long preferredAspectRatio, @NonNull Long fallbackRule) {
    instanceManager.addDartCreatedInstance(
        proxy.create(preferredAspectRatio, fallbackRule), identifier);
  }
}
