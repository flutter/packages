// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.SslErrorHandler;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.SslErrorHandlerHostApi;
import java.util.Objects;

/**
 * Host api implementation for {@link SslErrorHandler}.
 *
 * <p>Handles creating {@link SslErrorHandler}s that intercommunicate with a paired Dart object.
 */
public class SslErrorHandlerHostApiImpl implements SslErrorHandlerHostApi {
  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  /**
   * Constructs a {@link SslErrorHandlerHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public SslErrorHandlerHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public void cancel(@NonNull Long instanceId) {
    getSslErrorHandlerInstance(instanceId).cancel();
  }

  @Override
  public void proceed(@NonNull Long instanceId) {
    getSslErrorHandlerInstance(instanceId).proceed();
  }

  private SslErrorHandler getSslErrorHandlerInstance(@NonNull Long instanceId) {
    return Objects.requireNonNull(instanceManager.getInstance(instanceId));
  }
}
