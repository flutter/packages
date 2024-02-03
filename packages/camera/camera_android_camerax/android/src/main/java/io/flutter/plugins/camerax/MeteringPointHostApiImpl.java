// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;
import androidx.camera.core.SurfaceOrientedMeteringPointFactory;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.MeteringPointHostApi;

/**
 * Host API implementation for {@link MeteringPoint}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class MeteringPointHostApiImpl implements MeteringPointHostApi {
  private final InstanceManager instanceManager;
  private final MeteringPointProxy proxy;

  /** Proxy for constructors and static method of {@link MeteringPoint}. */
  @VisibleForTesting
  public static class MeteringPointProxy {

    /**
     * Creates a surface oriented {@link MeteringPoint} with the specified x, y, and size.
     *
     * <p>A {@link SurfaceOrientedMeteringPointFactory} is used to construct the {@link
     * MeteringPoint} because underlying the camera preview that this plugin uses is a Flutter
     * texture that is backed by a {@link Surface} created by the Flutter Android embedding.
     */
    @NonNull
    public MeteringPoint create(@NonNull Double x, @NonNull Double y, @Nullable Double size) {
      SurfaceOrientedMeteringPointFactory factory = getSurfaceOrientedMeteringPointFactory(1f, 1f);
      if (size == null) {
        return factory.createPoint(x.floatValue(), y.floatValue());
      } else {
        return factory.createPoint(x.floatValue(), y.floatValue(), size.floatValue());
      }
    }

    @VisibleForTesting
    @NonNull
    public SurfaceOrientedMeteringPointFactory getSurfaceOrientedMeteringPointFactory(
        float width, float height) {
      return new SurfaceOrientedMeteringPointFactory(width, height);
    }

    /**
     * Returns the default point size of the {@link MeteringPoint} width and height, which is a
     * normalized percentage of the sensor width/height.
     */
    @NonNull
    public float getDefaultPointSize() {
      return MeteringPointFactory.getDefaultPointSize();
    }
  }
  /**
   * Constructs a {@link MeteringPointHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public MeteringPointHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new MeteringPointProxy());
  }

  /**
   * Constructs a {@link MeteringPointHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of {@link MeteringPoint}
   */
  @VisibleForTesting
  MeteringPointHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull MeteringPointProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(
      @NonNull Long identifier, @NonNull Double x, @NonNull Double y, @Nullable Double size) {
    MeteringPoint meteringPoint = proxy.create(x, y, size);
    instanceManager.addDartCreatedInstance(meteringPoint, identifier);
  }

  @Override
  @NonNull
  public Double getDefaultPointSize() {
    return (double) proxy.getDefaultPointSize();
  }
}
