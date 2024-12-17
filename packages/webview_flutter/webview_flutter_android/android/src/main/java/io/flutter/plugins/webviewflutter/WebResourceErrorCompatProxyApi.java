// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.SuppressLint;
import androidx.annotation.NonNull;
import androidx.webkit.WebResourceErrorCompat;

public class WebResourceErrorCompatProxyApi extends PigeonApiWebResourceErrorCompat {
  public WebResourceErrorCompatProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @SuppressLint("RequiresFeature")
  @Override
  public long errorCode(@NonNull WebResourceErrorCompat pigeon_instance) {
    return pigeon_instance.getErrorCode();
  }

  @SuppressLint("RequiresFeature")
  @NonNull
  @Override
  public String description(@NonNull WebResourceErrorCompat pigeon_instance) {
    return pigeon_instance.getDescription().toString();
  }
}
