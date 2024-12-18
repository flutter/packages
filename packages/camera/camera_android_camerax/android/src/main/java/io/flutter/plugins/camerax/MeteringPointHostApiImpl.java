// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.view.Display;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.DisplayOrientedMeteringPointFactory;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.MeteringPointHostApi;
import java.util.Objects;

/**
 * Host API implementation for {@link MeteringPoint}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class MeteringPointHostApiImpl implements MeteringPointHostApi {
  private final InstanceManager instanceManager;
  private final MeteringPointProxy proxy;

  /** Proxy for constructor and static methods of {@link MeteringPoint}. */
  @VisibleForTesting
  public static class MeteringPointProxy {
    Activity activity;

    /**
     * Creates a surface oriented {@link MeteringPoint} with the specified x, y, and size.
     *
     * <p>A {@link DisplayOrientedMeteringPointFactory} is used to construct the {@link
     * MeteringPoint} because this factory handles the transformation of specified coordinates based
     * on camera information and the device orientation automatically.
     */
    @NonNull
    public MeteringPoint create(
        @NonNull Double x,
        @NonNull Double y,
        @Nullable Double size,
        @NonNull CameraInfo cameraInfo) {
      Display display = null;

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        display = activity.getDisplay();
      } else {
        display = getDefaultDisplayForAndroidVersionBelowR(activity);
      }

      DisplayOrientedMeteringPointFactory factory =
          getDisplayOrientedMeteringPointFactory(display, cameraInfo, 1f, 1f);

      if (size == null) {
        return factory.createPoint(x.floatValue(), y.floatValue());
      } else {
        return factory.createPoint(x.floatValue(), y.floatValue(), size.floatValue());
      }
    }

    @NonNull
    @SuppressWarnings("deprecation")
    private Display getDefaultDisplayForAndroidVersionBelowR(@NonNull Activity activity) {
      return ((WindowManager) activity.getSystemService(Context.WINDOW_SERVICE))
          .getDefaultDisplay();
    }

    @VisibleForTesting
    @NonNull
    public DisplayOrientedMeteringPointFactory getDisplayOrientedMeteringPointFactory(
        @NonNull Display display, @NonNull CameraInfo cameraInfo, float width, float height) {
      return new DisplayOrientedMeteringPointFactory(display, cameraInfo, width, height);
    }

    /**
     * Returns the default point size of the {@link MeteringPoint} width and height, which is a
     * normalized percentage of the sensor width/height.
     */
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
   * @param proxy proxy for constructor and static methods of {@link MeteringPoint}
   */
  @VisibleForTesting
  MeteringPointHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull MeteringPointProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  public void setActivity(@NonNull Activity activity) {
    this.proxy.activity = activity;
  }

  @Override
  public void create(
      @NonNull Long identifier,
      @NonNull Double x,
      @NonNull Double y,
      @Nullable Double size,
      @NonNull Long cameraInfoId) {
    MeteringPoint meteringPoint =
        proxy.create(
            x,
            y,
            size,
            (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(cameraInfoId)));
    instanceManager.addDartCreatedInstance(meteringPoint, identifier);
  }

  @Override
  @NonNull
  public Double getDefaultPointSize() {
    return (double) proxy.getDefaultPointSize();
  }
}
