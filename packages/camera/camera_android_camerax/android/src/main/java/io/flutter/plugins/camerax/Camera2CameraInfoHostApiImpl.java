// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import android.hardware.camera2.CameraCharacteristics;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.annotation.VisibleForTesting;
import androidx.camera.camera2.interop.Camera2CameraInfo;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.core.CameraInfo;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Camera2CameraInfoHostApi;
import java.util.Objects;

/**
 * Host API implementation for {@link Camera2CameraInfo}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class Camera2CameraInfoHostApiImpl implements Camera2CameraInfoHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private final Camera2CameraInfoProxy proxy;

  /** Proxy for methods of {@link Camera2CameraInfo}. */
  @VisibleForTesting
  @OptIn(markerClass = ExperimentalCamera2Interop.class)
  public static class Camera2CameraInfoProxy {

    @NonNull
    public Camera2CameraInfo createFrom(@NonNull CameraInfo cameraInfo) {
      return Camera2CameraInfo.from(cameraInfo);
    }

    @NonNull
    public Integer getSupportedHardwareLevel(@NonNull Camera2CameraInfo camera2CameraInfo) {
      return camera2CameraInfo.getCameraCharacteristic(
          CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL);
    }

    @NonNull
    public String getCameraId(@NonNull Camera2CameraInfo camera2CameraInfo) {
      return camera2CameraInfo.getCameraId();
    }

    @NonNull
    public Long getSensorOrientation(@NonNull Camera2CameraInfo camera2CameraInfo) {
      return Long.valueOf(
          camera2CameraInfo.getCameraCharacteristic(CameraCharacteristics.SENSOR_ORIENTATION));
    }
  }

  /**
   * Constructs an {@link Camera2CameraInfoHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param context {@link Context} used to retrieve {@code Executor}
   */
  public Camera2CameraInfoHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this(binaryMessenger, instanceManager, new Camera2CameraInfoProxy());
  }

  /**
   * Constructs an {@link Camera2CameraInfoHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for methods of {@link Camera2CameraInfo}
   */
  @VisibleForTesting
  Camera2CameraInfoHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull Camera2CameraInfoProxy proxy) {
    this.instanceManager = instanceManager;
    this.binaryMessenger = binaryMessenger;
    this.proxy = proxy;
  }

  @OptIn(markerClass = ExperimentalCamera2Interop.class)
  @Override
  @NonNull
  public Long createFrom(@NonNull Long cameraInfoIdentifier) {
    final CameraInfo cameraInfo =
        Objects.requireNonNull(instanceManager.getInstance(cameraInfoIdentifier));
    final Camera2CameraInfo camera2CameraInfo = proxy.createFrom(cameraInfo);
    final Camera2CameraInfoFlutterApiImpl flutterApi =
        new Camera2CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);

    flutterApi.create(camera2CameraInfo, reply -> {});
    return instanceManager.getIdentifierForStrongReference(camera2CameraInfo);
  }

  @Override
  @NonNull
  public Long getSupportedHardwareLevel(@NonNull Long identifier) {
    return Long.valueOf(proxy.getSupportedHardwareLevel(getCamera2CameraInfoInstance(identifier)));
  }

  @Override
  @NonNull
  public String getCameraId(@NonNull Long identifier) {
    return proxy.getCameraId(getCamera2CameraInfoInstance(identifier));
  }

  @Override
  @NonNull
  public Long getSensorOrientation(@NonNull Long identifier) {
    return proxy.getSensorOrientation(getCamera2CameraInfoInstance(identifier));
  }

  @OptIn(markerClass = ExperimentalCamera2Interop.class)
  private Camera2CameraInfo getCamera2CameraInfoInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
