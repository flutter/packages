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
import java.util.Objects;

/**
 * Host api implementation for {@link WebViewClient}.
 *
 * <p>Handles creating {@link WebViewClient}s that intercommunicate with a paired Dart object.
 */
public class WebViewClientHostApiImpl implements GeneratedAndroidWebView.WebViewClientHostApi {
  private final InstanceManager instanceManager;
  private final WebViewClientCreator webViewClientCreator;
  private final WebViewClientFlutterApiImpl flutterApi;

  /** Implementation of {@link WebViewClient} that passes arguments of callback methods to Dart. */
  @RequiresApi(Build.VERSION_CODES.N)
  public static class WebViewClientImpl extends WebViewClient {
    private final WebViewClientFlutterApiImpl flutterApi;
    private boolean returnValueForShouldOverrideUrlLoading = false;

    /**
     * Creates a {@link WebViewClient} that passes arguments of callbacks methods to Dart.
     *
     * @param flutterApi handles sending messages to Dart.
     */
    public WebViewClientImpl(@NonNull WebViewClientFlutterApiImpl flutterApi) {
      this.flutterApi = flutterApi;
    }

    @Override
    public void onPageStarted(@NonNull WebView view, @NonNull String url, @NonNull Bitmap favicon) {
      flutterApi.onPageStarted(this, view, url, reply -> {});
    }

    @Override
    public void onPageFinished(@NonNull WebView view, @NonNull String url) {
      flutterApi.onPageFinished(this, view, url, reply -> {});
    }

    @Override
    public void onReceivedHttpError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceResponse response) {
      flutterApi.onReceivedHttpError(this, view, request, response, reply -> {});
    }

    @Override
    public void onReceivedError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceError error) {
      flutterApi.onReceivedRequestError(this, view, request, error, reply -> {});
    }

    // Legacy codepath for < 23; newer versions use the variant above.
    @SuppressWarnings("deprecation")
    @Override
    public void onReceivedError(
        @NonNull WebView view,
        int errorCode,
        @NonNull String description,
        @NonNull String failingUrl) {
      flutterApi.onReceivedError(
          this, view, (long) errorCode, description, failingUrl, reply -> {});
    }

    @Override
    public boolean shouldOverrideUrlLoading(
        @NonNull WebView view, @NonNull WebResourceRequest request) {
      flutterApi.requestLoading(this, view, request, reply -> {});

      // The client is only allowed to stop navigations that target the main frame because
      // overridden URLs are passed to `loadUrl` and `loadUrl` cannot load a subframe.
      return request.isForMainFrame() && returnValueForShouldOverrideUrlLoading;
    }

    // Legacy codepath for < 24; newer versions use the variant above.
    @SuppressWarnings("deprecation")
    @Override
    public boolean shouldOverrideUrlLoading(@NonNull WebView view, @NonNull String url) {
      flutterApi.urlLoading(this, view, url, reply -> {});
      return returnValueForShouldOverrideUrlLoading;
    }

    @Override
    public void doUpdateVisitedHistory(
        @NonNull WebView view, @NonNull String url, boolean isReload) {
      flutterApi.doUpdateVisitedHistory(this, view, url, isReload, reply -> {});
    }

    @Override
    public void onReceivedHttpAuthRequest(
        @NonNull WebView view,
        @NonNull HttpAuthHandler handler,
        @NonNull String host,
        @NonNull String realm) {
      flutterApi.onReceivedHttpAuthRequest(this, view, handler, host, realm, reply -> {});
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
    private final WebViewClientFlutterApiImpl flutterApi;
    private boolean returnValueForShouldOverrideUrlLoading = false;

    public WebViewClientCompatImpl(@NonNull WebViewClientFlutterApiImpl flutterApi) {
      this.flutterApi = flutterApi;
    }

    @Override
    public void onPageStarted(@NonNull WebView view, @NonNull String url, @NonNull Bitmap favicon) {
      flutterApi.onPageStarted(this, view, url, reply -> {});
    }

    @Override
    public void onPageFinished(@NonNull WebView view, @NonNull String url) {
      flutterApi.onPageFinished(this, view, url, reply -> {});
    }

    @Override
    public void onReceivedHttpError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceResponse response) {
      flutterApi.onReceivedHttpError(this, view, request, response, reply -> {});
    }

    @Override
    public void onReceivedError(
        @NonNull WebView view,
        @NonNull WebResourceRequest request,
        @NonNull WebResourceErrorCompat error) {
      flutterApi.onReceivedRequestError(this, view, request, error, reply -> {});
    }

    // Legacy codepath for versions that don't support the variant above.
    @SuppressWarnings("deprecation")
    @Override
    public void onReceivedError(
        @NonNull WebView view,
        int errorCode,
        @NonNull String description,
        @NonNull String failingUrl) {
      flutterApi.onReceivedError(
          this, view, (long) errorCode, description, failingUrl, reply -> {});
    }

    @Override
    public boolean shouldOverrideUrlLoading(
        @NonNull WebView view, @NonNull WebResourceRequest request) {
      flutterApi.requestLoading(this, view, request, reply -> {});

      // The client is only allowed to stop navigations that target the main frame because
      // overridden URLs are passed to `loadUrl` and `loadUrl` cannot load a subframe.
      return request.isForMainFrame() && returnValueForShouldOverrideUrlLoading;
    }

    // Legacy codepath for < Lollipop; newer versions use the variant above.
    @SuppressWarnings("deprecation")
    @Override
    public boolean shouldOverrideUrlLoading(@NonNull WebView view, @NonNull String url) {
      flutterApi.urlLoading(this, view, url, reply -> {});
      return returnValueForShouldOverrideUrlLoading;
    }

    @Override
    public void doUpdateVisitedHistory(
        @NonNull WebView view, @NonNull String url, boolean isReload) {
      flutterApi.doUpdateVisitedHistory(this, view, url, isReload, reply -> {});
    }

    // Handles an HTTP authentication request.
    //
    // This callback is invoked when the WebView encounters a website requiring HTTP authentication.
    // [host] and [realm] are provided for matching against stored credentials, if any.
    @Override
    public void onReceivedHttpAuthRequest(
        @NonNull WebView view, HttpAuthHandler handler, String host, String realm) {
      flutterApi.onReceivedHttpAuthRequest(this, view, handler, host, realm, reply -> {});
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

  /** Handles creating {@link WebViewClient}s for a {@link WebViewClientHostApiImpl}. */
  public static class WebViewClientCreator {
    /**
     * Creates a {@link WebViewClient}.
     *
     * @param flutterApi handles sending messages to Dart
     * @return the created {@link WebViewClient}
     */
    @NonNull
    public WebViewClient createWebViewClient(@NonNull WebViewClientFlutterApiImpl flutterApi) {
      // WebViewClientCompat is used to get
      // shouldOverrideUrlLoading(WebView view, WebResourceRequest request)
      // invoked by the webview on older Android devices, without it pages that use iframes will
      // be broken when a navigationDelegate is set on Android version earlier than N.
      //
      // However, this if statement attempts to avoid using WebViewClientCompat on versions >= N due
      // to bug https://bugs.chromium.org/p/chromium/issues/detail?id=925887. Also, see
      // https://github.com/flutter/flutter/issues/29446.
      if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        return new WebViewClientImpl(flutterApi);
      } else {
        return new WebViewClientCompatImpl(flutterApi);
      }
    }
  }

  /**
   * Creates a host API that handles creating {@link WebViewClient}s.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   * @param webViewClientCreator handles creating {@link WebViewClient}s
   * @param flutterApi handles sending messages to Dart
   */
  public WebViewClientHostApiImpl(
      @NonNull InstanceManager instanceManager,
      @NonNull WebViewClientCreator webViewClientCreator,
      @NonNull WebViewClientFlutterApiImpl flutterApi) {
    this.instanceManager = instanceManager;
    this.webViewClientCreator = webViewClientCreator;
    this.flutterApi = flutterApi;
  }

  @Override
  public void create(@NonNull Long instanceId) {
    final WebViewClient webViewClient = webViewClientCreator.createWebViewClient(flutterApi);
    instanceManager.addDartCreatedInstance(webViewClient, instanceId);
  }

  @Override
  public void setSynchronousReturnValueForShouldOverrideUrlLoading(
      @NonNull Long instanceId, @NonNull Boolean value) {
    final WebViewClient webViewClient =
        Objects.requireNonNull(instanceManager.getInstance(instanceId));
    if (webViewClient instanceof WebViewClientCompatImpl) {
      ((WebViewClientCompatImpl) webViewClient).setReturnValueForShouldOverrideUrlLoading(value);
    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N
        && webViewClient instanceof WebViewClientImpl) {
      ((WebViewClientImpl) webViewClient).setReturnValueForShouldOverrideUrlLoading(value);
    } else {
      throw new IllegalStateException(
          "This WebViewClient doesn't support setting the returnValueForShouldOverrideUrlLoading.");
    }
  }
}
