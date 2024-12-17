// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebStorage;
import androidx.annotation.NonNull;

/**
 * Host api implementation for {@link WebStorage}.
 *
 * <p>Handles creating {@link WebStorage}s that intercommunicate with a paired Dart object.
 */
public class WebStorageProxyApi extends PigeonApiWebStorage {
  /** Creates a host API that handles creating {@link WebStorage} and invoke its methods. */
  public WebStorageProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public WebStorage instance() {
    return WebStorage.getInstance();
  }

  @Override
  public void deleteAllData(@NonNull WebStorage pigeon_instance) {
    pigeon_instance.deleteAllData();
  }
}
