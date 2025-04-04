// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.DownloadListener;
import androidx.annotation.NonNull;

/**
 * Host api implementation for {@link DownloadListener}.
 *
 * <p>Handles creating {@link DownloadListener}s that intercommunicate with a paired Dart object.
 */
public class DownloadListenerProxyApi extends PigeonApiDownloadListener {
  /**
   * Implementation of {@link DownloadListener} that passes arguments of callback methods to Dart.
   */
  public static class DownloadListenerImpl implements DownloadListener {
    private final DownloadListenerProxyApi api;

    /**
     * Creates a {@link DownloadListenerImpl} that passes arguments of callbacks methods to Dart.
     */
    public DownloadListenerImpl(@NonNull DownloadListenerProxyApi api) {
      this.api = api;
    }

    @Override
    public void onDownloadStart(
        @NonNull String url,
        @NonNull String userAgent,
        @NonNull String contentDisposition,
        @NonNull String mimetype,
        long contentLength) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () ->
                  api.onDownloadStart(
                      this,
                      url,
                      userAgent,
                      contentDisposition,
                      mimetype,
                      contentLength,
                      reply -> null));
    }
  }

  /** Creates a host API that handles creating {@link DownloadListener}s. */
  public DownloadListenerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public DownloadListener pigeon_defaultConstructor() {
    return new DownloadListenerImpl(this);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }
}
