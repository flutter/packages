// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebView;
import androidx.annotation.NonNull;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Host api implementation for {@link WebView}.
 *
 * <p>Handles creating {@link WebView}s that intercommunicate with a paired Dart object.
 */
public class FlutterAssetManagerProxyApi extends PigeonApiFlutterAssetManager {
  /** Constructs a new instance of {@link FlutterAssetManagerProxyApi}. */
  public FlutterAssetManagerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public FlutterAssetManager instance() {
    return getPigeonRegistrar().getFlutterAssetManager();
  }

  @NonNull
  @Override
  public List<String> list(@NonNull FlutterAssetManager pigeon_instance, @NonNull String path) {
    try {
      String[] paths = pigeon_instance.list(path);

      if (paths == null) {
        return new ArrayList<>();
      }

      return Arrays.asList(paths);
    } catch (IOException ex) {
      throw new RuntimeException(ex.getMessage());
    }
  }

  @NonNull
  @Override
  public String getAssetFilePathByName(
      @NonNull FlutterAssetManager pigeon_instance, @NonNull String name) {
    return pigeon_instance.getAssetFilePathByName(name);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }
}
