// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageProxyHostApi;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Host API implementation for {@link ImageProxy}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ImageProxyHostApiImpl implements ImageProxyHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting @NonNull public CameraXProxy cameraXProxy = new CameraXProxy();

  @VisibleForTesting @NonNull public PlaneProxyFlutterApiImpl planeProxyFlutterApiImpl;

  /**
   * Constructs a {@link ImageProxyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageProxyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    planeProxyFlutterApiImpl = new PlaneProxyFlutterApiImpl(binaryMessenger, instanceManager);
  }

  /**
   * Returns the array of identifiers for planes of the {@link ImageProxy} instance with the
   * specified identifier.
   */
  @Override
  @NonNull
  public List<Long> getPlanes(@NonNull Long identifier) {
    ImageProxy.PlaneProxy[] planes = getImageProxyInstance(identifier).getPlanes();
    List<Long> planeIdentifiers = new ArrayList<Long>();

    for (ImageProxy.PlaneProxy plane : planes) {
      ByteBuffer byteBuffer = plane.getBuffer();
      byte[] bytes = cameraXProxy.getBytesFromBuffer(byteBuffer.remaining());
      byteBuffer.get(bytes, 0, bytes.length);
      Long pixelStride = Long.valueOf(plane.getPixelStride());
      Long rowStride = Long.valueOf(plane.getRowStride());

      planeProxyFlutterApiImpl.create(plane, bytes, pixelStride, rowStride, reply -> {});
      planeIdentifiers.add(instanceManager.getIdentifierForStrongReference(plane));
    }

    return planeIdentifiers;
  }

  /**
   * Closes the {@link androidx.camera.core.Image} instance associated with the {@link ImageProxy}
   * instance with the specified identifier.
   */
  @Override
  public void close(@NonNull Long identifier) {
    getImageProxyInstance(identifier).close();
  }

  /**
   * Retrieives the {@link ImageProxy} instance associated with the specified {@code identifier}.
   */
  private ImageProxy getImageProxyInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
