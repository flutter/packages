// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.graphics.Bitmap;
import android.os.Build;
import android.view.KeyEvent;
import android.webkit.HttpAuthHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.webkit.WebResourceErrorCompat;
import androidx.webkit.WebViewClientCompat;

/**
 * Host api implementation for {@link WebViewClient}.
 *
 * <p>Handles creating {@link WebViewClient}s that intercommunicate with a paired Dart object.
 */
public class WebViewClientProxyApi extends PigeonApiWebViewClient {
  /** Implementation of {@link WebViewClient} that passes arguments of callback methods to Dart. */
  @RequiresApi(Build.VERSION_CODES.N)
  public static class WebViewClientImpl extends WebViewClient {
    private final WebViewClientProxyApi api;
    private boolean returnValueForShouldOverrideUrlLoading = false;

    /**
     * Creates a {@link WebViewClient} that passes arguments of callbacks methods to Dart.
     *
     * @param api handles sending messages to Dart.
     */
    public WebViewClientImpl(@NonNull WebViewClientProxyApi api) {
      this.api = api;
    }

    @Override
    public void onPageStarted(@NonNull WebView view, @NonNull String url, @NonNull Bitmap favicon) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onPageStarted(this, view, url, reply -> null));
    }

    @Override
    public void onPageFinished(@NonNull WebView view, @NonNull String url) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onPageFinished(this, view, url, reply -> null));
    }

    @Override
    public void onReceivedHttpError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceResponse response) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedHttpError(this, view, request, response, reply -> null));
    }

    @Override
    public void onReceivedError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceError error) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedRequestError(this, view, request, error, reply -> null));
    }

    // Legacy codepath for < 23; newer versions use the variant above.
    @SuppressWarnings("deprecation")
    @Override
    public void onReceivedError(
        @NonNull WebView view,
        int errorCode,
        @NonNull String description,
        @NonNull String failingUrl) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () ->
                  api.onReceivedError(
                      this, view, (long) errorCode, description, failingUrl, reply -> null));
    }

    @Override
    public boolean shouldOverrideUrlLoading(
        @NonNull WebView view, @NonNull WebResourceRequest request) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.requestLoading(this, view, request, reply -> null));

      // The client is only allowed to stop navigations that target the main frame because
      // overridden URLs are passed to `loadUrl` and `loadUrl` cannot load a subframe.
      return request.isForMainFrame() && returnValueForShouldOverrideUrlLoading;
    }

    // Legacy codepath for < 24; newer versions use the variant above.
    @SuppressWarnings("deprecation")
    @Override
    public boolean shouldOverrideUrlLoading(@NonNull WebView view, @NonNull String url) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.urlLoading(this, view, url, reply -> null));
      return returnValueForShouldOverrideUrlLoading;
    }

    @Override
    public void doUpdateVisitedHistory(
        @NonNull WebView view, @NonNull String url, boolean isReload) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.doUpdateVisitedHistory(this, view, url, isReload, reply -> null));
    }

    @Override
    public void onReceivedHttpAuthRequest(
        @NonNull WebView view,
        @NonNull HttpAuthHandler handler,
        @NonNull String host,
        @NonNull String realm) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedHttpAuthRequest(this, view, handler, host, realm, reply -> null));
    }

    @Override
    public void onUnhandledKeyEvent(@NonNull WebView view, @NonNull KeyEvent event) {
      // Deliberately empty. Occasionally the webview will mark events as having failed to be
      // handled even though they were handled. We don't want to propagate those as they're not
      // truly lost.
    }

    /** Sets return value for {@link #shouldOverrideUrlLoading}. */
    public void setReturnValueForShouldOverrideUrlLoading(boolean value) {
      returnValueForShouldOverrideUrlLoading = value;
    }
  }

  /**
   * Implementation of {@link WebViewClientCompat} that passes arguments of callback methods to
   * Dart.
   */
  public static class WebViewClientCompatImpl extends WebViewClientCompat {
    private final WebViewClientProxyApi api;
    private boolean returnValueForShouldOverrideUrlLoading = false;

    public WebViewClientCompatImpl(@NonNull WebViewClientProxyApi api) {
      this.api = api;
    }

    @Override
    public void onPageStarted(@NonNull WebView view, @NonNull String url, @NonNull Bitmap favicon) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onPageStarted(this, view, url, reply -> null));
    }

    @Override
    public void onPageFinished(@NonNull WebView view, @NonNull String url) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onPageFinished(this, view, url, reply -> null));
    }

    @Override
    public void onReceivedHttpError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceResponse response) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedHttpError(this, view, request, response, reply -> null));
    }

    @Override
    public void onReceivedError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceErrorCompat error) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedRequestErrorCompat(this, view, request, error, reply -> null));
    }

    // Legacy codepath for versions that don't support the variant above.
    @SuppressWarnings("deprecation")
    @Override
    public void onReceivedError(
        @NonNull WebView view,
        int errorCode,
        @NonNull String description,
        @NonNull String failingUrl) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () ->
                  api.onReceivedError(
                      this, view, (long) errorCode, description, failingUrl, reply -> null));
    }

    @Override
    public boolean shouldOverrideUrlLoading(
        @NonNull WebView view, @NonNull WebResourceRequest request) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.requestLoading(this, view, request, reply -> null));

      // The client is only allowed to stop navigations that target the main frame because
      // overridden URLs are passed to `loadUrl` and `loadUrl` cannot load a subframe.
      return request.isForMainFrame() && returnValueForShouldOverrideUrlLoading;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean shouldOverrideUrlLoading(@NonNull WebView view, @NonNull String url) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.urlLoading(this, view, url, reply -> null));
      return returnValueForShouldOverrideUrlLoading;
    }

    @Override
    public void doUpdateVisitedHistory(
        @NonNull WebView view, @NonNull String url, boolean isReload) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.doUpdateVisitedHistory(this, view, url, isReload, reply -> null));
    }

    // Handles an HTTP authentication request.
    //
    // This callback is invoked when the WebView encounters a website requiring HTTP authentication.
    // [host] and [realm] are provided for matching against stored credentials, if any.
    @Override
    public void onReceivedHttpAuthRequest(
        @NonNull WebView view, HttpAuthHandler handler, String host, String realm) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedHttpAuthRequest(this, view, handler, host, realm, reply -> null));
    }

    @Override
    public void onUnhandledKeyEvent(@NonNull WebView view, @NonNull KeyEvent event) {
      // Deliberately empty. Occasionally the webview will mark events as having failed to be
      // handled even though they were handled. We don't want to propagate those as they're not
      // truly lost.
    }

    /** Sets return value for {@link #shouldOverrideUrlLoading}. */
    public void setReturnValueForShouldOverrideUrlLoading(boolean value) {
      returnValueForShouldOverrideUrlLoading = value;
    }
  }

  /** Creates a host API that handles creating {@link WebViewClient}s. */
  public WebViewClientProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public WebViewClient pigeon_defaultConstructor() {
    // WebViewClientCompat is used to get
    // shouldOverrideUrlLoading(WebView view, WebResourceRequest request)
    // invoked by the webview on older Android devices, without it pages that use iframes will
    // be broken when a navigationDelegate is set on Android version earlier than N.
    //
    // However, this if statement attempts to avoid using WebViewClientCompat on versions >= N due
    // to bug https://bugs.chromium.org/p/chromium/issues/detail?id=925887. Also, see
    // https://github.com/flutter/flutter/issues/29446.
    if (getPigeonRegistrar().sdkIsAtLeast(Build.VERSION_CODES.N)) {
      return new WebViewClientImpl(this);
    } else {
      return new WebViewClientCompatImpl(this);
    }
  }

  @Override
  public void setSynchronousReturnValueForShouldOverrideUrlLoading(
      @NonNull WebViewClient pigeon_instance, boolean value) {
    if (pigeon_instance instanceof WebViewClientCompatImpl) {
      ((WebViewClientCompatImpl) pigeon_instance).setReturnValueForShouldOverrideUrlLoading(value);
    } else if (getPigeonRegistrar().sdkIsAtLeast(Build.VERSION_CODES.N)
        && pigeon_instance instanceof WebViewClientImpl) {
      ((WebViewClientImpl) pigeon_instance).setReturnValueForShouldOverrideUrlLoading(value);
    } else {
      throw new IllegalStateException(
          "This WebViewClient doesn't support setting the returnValueForShouldOverrideUrlLoading.");
    }
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }
}
