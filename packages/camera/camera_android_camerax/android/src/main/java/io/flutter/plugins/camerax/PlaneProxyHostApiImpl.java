// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageProxy;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PlaneProxyHostApi;
import java.nio.ByteBuffer;
import java.util.Objects;

/**
 * Host API implementation for {@link ImageProxy.PlaneProxy}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class PlaneProxyHostApiImpl implements PlaneProxyHostApi {
  private final InstanceManager instanceManager;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  /**
   * Constructs a {@link PlaneProxyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public PlaneProxyHostApiImpl(
      @NonNull InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  /** Returns the pixel stride. */
  @Override
  public Long getPixelStride(@NonNull Long identifier) {
    return Long.valueOf(getPlaneProxyInstance(identifier).getPixelStride());
  }

  /** Returns the pixels buffer. */
  @Override
  public byte[] getBuffer(@NonNull Long identifier) {
    ByteBuffer byteBuffer = getPlaneProxyInstance(identifier).getBuffer();
    byte[] bytes = cameraXProxy.getBytesFromBuffer(byteBuffer.remaining());
    byteBuffer.get(bytes, 0, bytes.length);
    
    return bytes;
  }

  /** Returns the row stride. */
  @Override
  public Long getRowStride(@NonNull Long identifier) {
    return Long.valueOf(getPlaneProxyInstance(identifier).getRowStride());
  }

  /** Retrieives the {@link ImageProxy.PlaneProxy} instance associated with the specified {@code identifier}. */
  private ImageProxy.PlaneProxy getPlaneProxyInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }

}
