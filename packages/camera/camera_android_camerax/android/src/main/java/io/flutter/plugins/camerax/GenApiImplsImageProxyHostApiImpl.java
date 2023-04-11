
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Fix name of generated pigeon file
// TODO(bparrishMines): Import native classes
import GeneratedPigeonFilename.ImageProxyHostApi;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;

/**
 * Host API implementation for `ImageProxy`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ImageProxyHostApiImpl implements ImageProxyHostApi {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  /**
   * Constructs a {@link ImageProxyHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageProxyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {

    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public List getPlanes(@NonNull Long identifier) {

    return getImageProxyInstance(identifier).getPlanes();
  }

  @Override
  public Long getFormat(@NonNull Long identifier) {

    return getImageProxyInstance(identifier).getFormat();
  }

  @Override
  public Long getHeight(@NonNull Long identifier) {

    return getImageProxyInstance(identifier).getHeight();
  }

  @Override
  public Long getWidth(@NonNull Long identifier) {

    return getImageProxyInstance(identifier).getWidth();
  }

  @Override
  public void close(@NonNull Long identifier) {

    getImageProxyInstance(identifier).close();
  }

  private ImageProxy getImageProxyInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
