
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Fix name of generated pigeon file
// TODO(bparrishMines): Import native classes
import GeneratedPigeonFilename.ImageProxyPlaneProxyHostApi;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;

/**
 * Host API implementation for `ImageProxyPlaneProxy`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ImageProxyPlaneProxyHostApiImpl implements ImageProxyPlaneProxyHostApi {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  /**
   * Constructs a {@link ImageProxyPlaneProxyHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageProxyPlaneProxyHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {

    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public dynamic getRowStride(@NonNull Long identifier) {

    final dynamic result = getImageProxyPlaneProxyInstance(identifier).getRowStride();

    if (result != null) {
      final dynamicFlutterApiImpl flutterApi =
          new dynamicFlutterApiImpl(binaryMessenger, instanceManager);
      // TODO(bparrishMines): Fill in missing parameters
      flutterApi.create(result, reply -> {});
    }
    return instanceManager.getIdentifierForStrongReference(result);
  }

  @Override
  public Long getPixelStride(@NonNull Long identifier) {

    return getImageProxyPlaneProxyInstance(identifier).getPixelStride();
  }

  @Override
  public Long getRowStride(@NonNull Long identifier) {

    return getImageProxyPlaneProxyInstance(identifier).getRowStride();
  }

  private ImageProxyPlaneProxy getImageProxyPlaneProxyInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
