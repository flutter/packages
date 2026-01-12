// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.graphics.Bitmap;
import android.view.KeyEvent;
import android.webkit.HttpAuthHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Host api implementation for {@link WebViewClient}.
 *
 * <p>Handles creating {@link WebViewClient}s that intercommunicate with a paired Dart object.
 */
public class WebViewClientProxyApi extends PigeonApiWebViewClient {
  /** Implementation of {@link WebViewClient} that passes arguments of callback methods to Dart. */
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

    @Override
    public boolean shouldOverrideUrlLoading(
        @NonNull WebView view, @NonNull WebResourceRequest request) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.requestLoading(this, view, request, reply -> null));

      // The client is only allowed to stop navigations that target the main frame because
      // overridden URLs are passed to `loadUrl` and `loadUrl` cannot load a subframe.
      return request.isForMainFrame() && returnValueForShouldOverrideUrlLoading;
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
    public void onFormResubmission(
        @NonNull android.webkit.WebView view,
        @NonNull android.os.Message dontResend,
        @NonNull android.os.Message resend) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onFormResubmission(this, view, dontResend, resend, reply -> null));
    }

    @Override
    public void onLoadResource(@NonNull android.webkit.WebView view, @NonNull String url) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onLoadResource(this, view, url, reply -> null));
    }

    @Override
    public void onPageCommitVisible(@NonNull android.webkit.WebView view, @NonNull String url) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onPageCommitVisible(this, view, url, reply -> null));
    }

    @Override
    public void onReceivedClientCertRequest(
        @NonNull android.webkit.WebView view, @NonNull android.webkit.ClientCertRequest request) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedClientCertRequest(this, view, request, reply -> null));
    }

    @Override
    public void onReceivedLoginRequest(
        @NonNull android.webkit.WebView view,
        @NonNull String realm,
        @Nullable String account,
        @NonNull String args) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              () -> api.onReceivedLoginRequest(this, view, realm, account, args, reply -> null));
    }

    @Override
    public void onReceivedSslError(
        @NonNull android.webkit.WebView view,
        @NonNull android.webkit.SslErrorHandler handler,
        @NonNull android.net.http.SslError error) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onReceivedSslError(this, view, handler, error, reply -> null));
    }

    @Override
    public void onScaleChanged(
        @NonNull android.webkit.WebView view, float oldScale, float newScale) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onScaleChanged(this, view, oldScale, newScale, reply -> null));
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
    return new WebViewClientImpl(this);
  }

  @Override
  public void setSynchronousReturnValueForShouldOverrideUrlLoading(
      @NonNull WebViewClient pigeon_instance, boolean value) {
    if (pigeon_instance instanceof WebViewClientImpl) {
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
