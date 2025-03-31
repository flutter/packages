// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import androidx.annotation.NonNull;

/**
 * Host api implementation for {@link JavaScriptChannel}.
 *
 * <p>Handles creating {@link JavaScriptChannel}s that intercommunicate with a paired Dart object.
 */
public class JavaScriptChannelProxyApi extends PigeonApiJavaScriptChannel {

  /** Creates a host API that handles creating {@link JavaScriptChannel}s. */
  public JavaScriptChannelProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public JavaScriptChannel pigeon_defaultConstructor(@NonNull String channelName) {
    return new JavaScriptChannel(channelName, this);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }
}
