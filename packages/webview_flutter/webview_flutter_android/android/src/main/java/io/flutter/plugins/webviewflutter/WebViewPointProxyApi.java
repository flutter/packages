// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import androidx.annotation.NonNull;

public class WebViewPointProxyApi extends PigeonApiWebViewPoint {
  public WebViewPointProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long x(@NonNull WebViewPoint pigeon_instance) {
    return pigeon_instance.getX();
  }

  @Override
  public long y(@NonNull WebViewPoint pigeon_instance) {
    return pigeon_instance.getY();
  }
}
