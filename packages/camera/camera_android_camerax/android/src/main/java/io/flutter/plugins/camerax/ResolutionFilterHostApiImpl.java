// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionSelector.ResolutionFilter;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionFilterHostApi;

/**
 * Host API implementation for {@link ResolutionFilter}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ResolutionFilterHostApiImpl implements ResolutionFilterHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private final ResolutionFilterProxy proxy;

  /** Proxy for constructor of {@link ResolutionFilter}. */
  @VisibleForTesting
  public static class ResolutionFilterProxy {

    /** Creates an instance of {@link ResolutionFilterImpl}. */
    @NonNull
    public ResolutionFilterImpl create(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      return new ResolutionFilterImpl(binaryMessenger, instanceManager);
    }
  }

  /**
   * Implementation of {@link ResolutionFilter} that passes arguments of callback methods to
   * Dart.
   */
  public static class ResolutionFilterImpl implements ResolutionFilter {
    private BinaryMessenger binaryMessenger;
    private InstanceManager instanceManager;
    private ResolutionFilterFlutterApiImpl api;

    /**
     * Constructs an instance of {@link ResolutionFilter} that passes arguments of callbacks
     * methods to Dart.
     */
    public ResolutionFilterImpl(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      super();
      this.binaryMessenger = binaryMessenger;
      this.instanceManager = instanceManager;
      api = new ResolutionFilterFlutterApiImpl(binaryMessenger, instanceManager);
    }

    @Override
    @NonNull
    List<Size> filter(@NonNull List<Size> supportedSizes, int rotationDegrees) {
      List<supportedResolutionInfos> = new ArrayList<

      List<ResolutionInfo> filteredResolutionInfos = api.filter(this, supportedResolutionInfos, rotationDegrees);
      List<Size> filteredSizes = ...

      return filteredSizes;
    }

    private List<Size> getSizesFromResolutionInfos(List<ResolutionInfo> resolutionInfos) {
      for (ResolutionInfo supportedSize : supportedSizes) {

      }
    }

    /**
     * Flutter API used to send messages back to Dart.
     *
     * <p>This is only visible for testing.
     */
    @VisibleForTesting
    void setApi(@NonNull ResolutionFilterFlutterApiImpl api) {
      this.api = api;
    }
  }

  /**
   * Constructs a {@link ResolutionFilterHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ResolutionFilterHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this(binaryMessenger, instanceManager, new ResolutionFilterProxy());
  }

  /**
   * Constructs a {@link ResolutionFilterHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link ResolutionFilter}
   */
  @VisibleForTesting
  ResolutionFilterHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull ResolutionFilterProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates an {@link ResolutionFilterProxy} that represents an {@link ResolutionFilter} instance
   * with the specified identifier.
   */
  @Override
  public void create(@NonNull Long identifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(binaryMessenger, instanceManager), identifier);
  }
}
