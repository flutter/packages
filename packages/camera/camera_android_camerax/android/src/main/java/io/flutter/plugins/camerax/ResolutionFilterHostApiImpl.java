// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionFilterHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import java.util.List;

/**
 * Host API implementation for {@link ResolutionFilter}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ResolutionFilterHostApiImpl implements ResolutionFilterHostApi {
  private final InstanceManager instanceManager;
  private final ResolutionFilterProxy proxy;

  /** Proxy for constructor of {@link ResolutionFilter}. */
  @VisibleForTesting
  public static class ResolutionFilterProxy {
    /**
     * Creates an instance of {@link ResolutionFilter} that moves the {@code preferredSize} to the
     * front of the list of supported resolutions such that it can be prioritized by CameraX.
     */
    @NonNull
    public ResolutionFilter createWithOnePreferredSize(@NonNull Size preferredSize) {
      return new ResolutionFilter() {
        @Override
        @NonNull
        public List<Size> filter(@NonNull List<Size> supportedSizes, int rotationDegrees) {
          int preferredSizeIndex = supportedSizes.indexOf(preferredSize);

          if (preferredSizeIndex > -1) {
            supportedSizes.remove(preferredSizeIndex);
            supportedSizes.add(0, preferredSize);
          }

          return supportedSizes;
        }
      };
    }
  }

  /**
   * Constructs a {@link ResolutionFilterHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ResolutionFilterHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new ResolutionFilterProxy());
  }

  /**
   * Constructs a {@link ResolutionFilterHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link ResolutionFilter}
   */
  @VisibleForTesting
  ResolutionFilterHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull ResolutionFilterProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates a {@link ResolutionFilter} that prioritizes the specified {@code preferredResolution}
   * over all other resolutions.
   */
  @Override
  public void createWithOnePreferredSize(
      @NonNull Long identifier, @NonNull ResolutionInfo preferredResolution) {
    Size preferredSize =
        new Size(
            preferredResolution.getWidth().intValue(), preferredResolution.getHeight().intValue());
    instanceManager.addDartCreatedInstance(
        proxy.createWithOnePreferredSize(preferredSize), identifier);
  }
}
