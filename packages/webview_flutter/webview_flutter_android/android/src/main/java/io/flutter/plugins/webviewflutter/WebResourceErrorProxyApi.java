// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebResourceError;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

@RequiresApi(api = Build.VERSION_CODES.M)
public class WebResourceErrorProxyApi extends PigeonApiWebResourceError {
  public WebResourceErrorProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long errorCode(@NonNull WebResourceError pigeon_instance) {
    return pigeon_instance.getErrorCode();
  }

  @NonNull
  @Override
  public String description(@NonNull WebResourceError pigeon_instance) {
    return pigeon_instance.getDescription().toString();
  }
}
