// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebResourceRequest;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.Collections;
import java.util.Map;

public class WebResourceRequestProxyApi extends PigeonApiWebResourceRequest {
  public WebResourceRequestProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public String url(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.getUrl().toString();
  }

  @NonNull
  @Override
  public boolean isForMainFrame(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.isForMainFrame();
  }

  @NonNull
  @Override
  public boolean isRedirect(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.isRedirect();
  }

  @NonNull
  @Override
  public boolean hasGesture(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.hasGesture();
  }

  @NonNull
  @Override
  public String method(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.getMethod();
  }

  @Nullable
  @Override
  public Map<String, String> requestHeaders(@NonNull WebResourceRequest pigeon_instance) {
    if (pigeon_instance.getRequestHeaders() == null) {
      return Collections.emptyMap();
    } else {
      return pigeon_instance.getRequestHeaders();
    }
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }
}
