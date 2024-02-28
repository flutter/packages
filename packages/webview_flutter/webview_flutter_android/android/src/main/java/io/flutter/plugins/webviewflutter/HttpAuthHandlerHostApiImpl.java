// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.HttpAuthHandler;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.HttpAuthHandlerHostApi;
import java.util.Objects;

/**
 * Host api implementation for {@link HttpAuthHandler}.
 *
 * <p>Handles creating {@link HttpAuthHandler}s that intercommunicate with a paired Dart object.
 */
public class HttpAuthHandlerHostApiImpl implements HttpAuthHandlerHostApi {
  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  /**
   * Constructs a {@link HttpAuthHandlerHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public HttpAuthHandlerHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @NonNull
  @Override
  public Boolean useHttpAuthUsernamePassword(@NonNull Long instanceId) {
    return getHttpAuthHandlerInstance(instanceId).useHttpAuthUsernamePassword();
  }

  @Override
  public void cancel(@NonNull Long instanceId) {
    getHttpAuthHandlerInstance(instanceId).cancel();
  }

  @Override
  public void proceed(
      @NonNull Long instanceId, @NonNull String username, @NonNull String password) {
    getHttpAuthHandlerInstance(instanceId).proceed(username, password);
  }

  private HttpAuthHandler getHttpAuthHandlerInstance(@NonNull Long instanceId) {
    return Objects.requireNonNull(instanceManager.getInstance(instanceId));
  }
}
