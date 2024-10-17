// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebResourceResponse;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class WebResourceResponseProxyApi extends PigeonApiWebResourceResponse {
  public WebResourceResponseProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long statusCode(@NonNull WebResourceResponse pigeon_instance) {
    return pigeon_instance.getStatusCode();
  }
}
