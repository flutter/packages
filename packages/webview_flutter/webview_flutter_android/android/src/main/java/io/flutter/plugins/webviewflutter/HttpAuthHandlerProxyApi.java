// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.HttpAuthHandler;
import androidx.annotation.NonNull;

/**
 * Host api implementation for {@link HttpAuthHandler}.
 *
 * <p>Handles creating {@link HttpAuthHandler}s that intercommunicate with a paired Dart object.
 */
public class HttpAuthHandlerProxyApi extends PigeonApiHttpAuthHandler {
  /** Constructs a {@link HttpAuthHandlerProxyApi}. */
  public HttpAuthHandlerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public boolean useHttpAuthUsernamePassword(@NonNull HttpAuthHandler pigeon_instance) {
    return pigeon_instance.useHttpAuthUsernamePassword();
  }

  @Override
  public void cancel(@NonNull HttpAuthHandler pigeon_instance) {
    pigeon_instance.cancel();
  }

  @Override
  public void proceed(
      @NonNull HttpAuthHandler pigeon_instance,
      @NonNull String username,
      @NonNull String password) {
    pigeon_instance.proceed(username, password);
  }
}
