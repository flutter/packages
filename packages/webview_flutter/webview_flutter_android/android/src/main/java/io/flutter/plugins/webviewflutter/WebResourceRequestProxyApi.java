// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebResourceRequest;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import java.util.Collections;
import java.util.Map;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class WebResourceRequestProxyApi extends PigeonApiWebResourceRequest {
  public WebResourceRequestProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public String url(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.getUrl().toString();
  }

  @Override
  public boolean isForMainFrame(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.isForMainFrame();
  }

  @Override
  public Boolean isRedirect(@NonNull WebResourceRequest pigeon_instance) {
    if (getPigeonRegistrar().sdkIsAtLeast(Build.VERSION_CODES.N)) {
      return pigeon_instance.isRedirect();
    }

    return null;
  }

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
