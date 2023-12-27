// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;
import androidx.camera.core.SurfaceMeteringPointFactory;
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

    public void create(@NonNull Double x, @NonNull Double y, @Nullable Double size) {
        SurfaceOrientedMeteringPointFactory factory = new SurfaceOrientedMeteringPointFactory(1f, 1f); // TODO(camsim99): get feedback on using this default instead of exposing
        if (size == null) {
            return factory.createPoint(x, y);
        } else {
            return factory.createPoint(x, y, size);
        }
    }

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
  public void create(@NonNull Long identifier, @NonNull Double x, @NonNull Double y, @Nullable Double size) {
    MeteringPoint meteringPoint = proxy.create(x, y, size);
    instanceManager.addDartCreatedInstance(meteringPoint, identifier);
  }

  @Override
  @NonNull 
  public Double getDefaultPointSize() {
    return (Double) proxy.getDefaultPointSize;
  }
}
