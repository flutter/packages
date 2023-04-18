// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageProxyHostApi;
import java.util.Objects;

/**
 * Host API implementation for {@link ImageProxy}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ImageProxyHostApiImpl implements ImageProxyHostApi {
  private final InstanceManager instanceManager;

  /**
   * Constructs a {@link ImageProxyHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageProxyHostApiImpl(
       @NonNull InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  /** Returns the array of planes of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public List getPlanes(@NonNull Long identifier) {
    return getImageProxyInstance(identifier).getPlanes();
  }

  /** Returns the image format of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public Long getFormat(@NonNull Long identifier) {
    return getImageProxyInstance(identifier).getFormat();
  }

  /** Returns the image height of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public Long getHeight(@NonNull Long identifier) {
    return getImageProxyInstance(identifier).getHeight();
  }

  /** Returns the image width of the {@link ImageProxy} instance with the specified identifier. */
  @Override
  public Long getWidth(@NonNull Long identifier) {
    return getImageProxyInstance(identifier).getWidth();
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
