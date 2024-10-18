// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.SslErrorHandler;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.SslErrorHandlerFlutterApi;

/**
 * Flutter API implementation for {@link SslErrorHandler}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class SslErrorHandlerFlutterApiImpl {
  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  private final SslErrorHandlerFlutterApi api;

  /**
   * Constructs a {@link SslErrorHandlerFlutterApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public SslErrorHandlerFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    api = new SslErrorHandlerFlutterApi(binaryMessenger);
  }

  /**
   * Stores the `SslErrorHandler` instance and notifies Dart to create and store a new
   * `SslErrorHandler` instance that is attached to this one. If `instance` has already been added,
   * this method does nothing.
   */
  public void create(
      @NonNull SslErrorHandler instance, @NonNull SslErrorHandlerFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      api.create(instanceManager.addHostCreatedInstance(instance), callback);
    }
  }
}
