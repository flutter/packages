// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebChromeClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.Arrays;
import java.util.List;

/**
 * Flutter Api implementation for {@link android.webkit.WebChromeClient.FileChooserParams}.
 *
 * <p>Passes arguments of callbacks methods from a {@link
 * android.webkit.WebChromeClient.FileChooserParams} to Dart.
 */
public class FileChooserParamsProxyApi extends PigeonApiFileChooserParams {
  /** Creates a Flutter api that sends messages to Dart. */
  public FileChooserParamsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public boolean isCaptureEnabled(@NonNull WebChromeClient.FileChooserParams pigeon_instance) {
    return pigeon_instance.isCaptureEnabled();
  }

  @NonNull
  @Override
  public List<String> acceptTypes(@NonNull WebChromeClient.FileChooserParams pigeon_instance) {
    return Arrays.asList(pigeon_instance.getAcceptTypes());
  }

  @NonNull
  @Override
  public FileChooserMode mode(@NonNull WebChromeClient.FileChooserParams pigeon_instance) {
    switch (pigeon_instance.getMode()) {
      case WebChromeClient.FileChooserParams.MODE_OPEN:
        return FileChooserMode.OPEN;
      case WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE:
        return FileChooserMode.OPEN_MULTIPLE;
      case WebChromeClient.FileChooserParams.MODE_SAVE:
        return FileChooserMode.SAVE;
      default:
        return FileChooserMode.UNKNOWN;
    }
  }

  @Nullable
  @Override
  public String filenameHint(@NonNull WebChromeClient.FileChooserParams pigeon_instance) {
    return pigeon_instance.getFilenameHint();
  }
}
