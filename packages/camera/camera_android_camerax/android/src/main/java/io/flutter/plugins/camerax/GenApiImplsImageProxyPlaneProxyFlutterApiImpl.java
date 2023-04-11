
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Fix name of generated pigeon file
// TODO(bparrishMines): Import native classes
import GeneratedPigeonFilename.ImageProxyPlaneProxyFlutterApi;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.BinaryMessenger;

/**
 * Flutter API implementation for `ImageProxyPlaneProxy`.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class ImageProxyPlaneProxyFlutterApiImpl {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private ImageProxyPlaneProxyFlutterApi api;

  /**
   * Constructs a {@link ImageProxyPlaneProxyFlutterApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageProxyPlaneProxyFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    api = new ImageProxyPlaneProxyFlutterApi(binaryMessenger);
  }

  /**
   * Stores the `ImageProxyPlaneProxy` instance and notifies Dart to create and store a new
   * `ImageProxyPlaneProxy` instance that is attached to this one. If `instance` has already been
   * added, this method does nothing.
   */
  public void create(
      @NonNull ImageProxyPlaneProxy instance,
      @NonNull ImageProxyPlaneProxyFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      api.create(instanceManager.addHostCreatedInstance(instance), callback);
    }
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull ImageProxyPlaneProxyFlutterApi api) {
    this.api = api;
  }
}
