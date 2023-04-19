// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageProxyHostApi;
import io.flutter.plugin.common.BinaryMessenger;
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

  /**
   * Constructs a {@link ImageProxyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageProxyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
       @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  /** Returns the array of identifiers for planes of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public List<Long> getPlanes(@NonNull Long identifier) {
    ImageProxy.PlaneProxy[] planes = getImageProxyInstance(identifier).getPlanes();
    PlaneProxyFlutterApiImpl planeProxyFlutterApiImpl = new PlaneProxyFlutterApiImpl(binaryMessenger, instanceManager);
    List<Long> planeIdentifiers = new ArrayList<Long>();

    for(ImageProxy.PlaneProxy plane : planes) {
      planeProxyFlutterApiImpl.create(plane, reply -> {});
      planeIdentifiers.add(instanceManager.getIdentifierForStrongReference(plane));
    }

    return planeIdentifiers;
  }

  /** Returns the image format of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public Long getFormat(@NonNull Long identifier) {
    return Long.valueOf(getImageProxyInstance(identifier).getFormat());
  }

  /** Returns the image height of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public Long getHeight(@NonNull Long identifier) {
    return Long.valueOf(getImageProxyInstance(identifier).getHeight());
  }

  /** Returns the image width of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public Long getWidth(@NonNull Long identifier) {
    return Long.valueOf(getImageProxyInstance(identifier).getWidth());
  }

  /**
   * Closes the {@link androidx.camera.core.Image} instance associated with the
   * {@link ImageProxy} instance with the specified identifier.
   */
  @Override
  public void close(@NonNull Long identifier) {
    getImageProxyInstance(identifier).close();
  }

  /** Retrieives the {@link ImageProxy} instance associated with the specified {@code identifier}. */
  private ImageProxy getImageProxyInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
