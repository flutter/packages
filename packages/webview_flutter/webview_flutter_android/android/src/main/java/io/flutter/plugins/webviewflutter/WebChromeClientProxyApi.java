// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.net.Uri;
import android.os.Build;
import android.os.Message;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.GeolocationPermissions;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.PermissionRequest;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.annotation.VisibleForTesting;
import java.util.List;
import java.util.Objects;

/**
 * Host api implementation for {@link WebChromeClient}.
 *
 * <p>Handles creating {@link WebChromeClient}s that intercommunicate with a paired Dart object.
 */
public class WebChromeClientProxyApi extends PigeonApiWebChromeClient {
  /**
   * Implementation of {@link WebChromeClient} that passes arguments of callback methods to Dart.
   */
  public static class WebChromeClientImpl extends SecureWebChromeClient {
    private static final String TAG = "WebChromeClientImpl";

    private final WebChromeClientProxyApi api;
    private boolean returnValueForOnShowFileChooser = false;
    private boolean returnValueForOnConsoleMessage = false;

    private boolean returnValueForOnJsAlert = false;
    private boolean returnValueForOnJsConfirm = false;
    private boolean returnValueForOnJsPrompt = false;

    /** Creates a {@link WebChromeClient} that passes arguments of callbacks methods to Dart. */
    public WebChromeClientImpl(@NonNull WebChromeClientProxyApi api) {
      this.api = api;
    }

    @Override
    public void onProgressChanged(@NonNull WebView view, int progress) {
      api.onProgressChanged(this, view, (long) progress, reply -> null);
    }

    @Override
    public void onShowCustomView(View view, WebChromeClient.CustomViewCallback callback) {
      api.onShowCustomView(this, view, callback, reply -> null);
    }

    @Override
    public void onHideCustomView() {
      api.onHideCustomView(this, reply -> null);
    }

    public void onGeolocationPermissionsShowPrompt(
        @NonNull String origin, @NonNull GeolocationPermissions.Callback callback) {
      api.onGeolocationPermissionsShowPrompt(this, origin, callback, reply -> null);
    }

    @Override
    public void onGeolocationPermissionsHidePrompt() {
      api.onGeolocationPermissionsHidePrompt(this, reply -> null);
    }

    @SuppressWarnings("LambdaLast")
    @Override
    public boolean onShowFileChooser(
        @NonNull WebView webView,
        @NonNull ValueCallback<Uri[]> filePathCallback,
        @NonNull FileChooserParams fileChooserParams) {
      final boolean currentReturnValueForOnShowFileChooser = returnValueForOnShowFileChooser;
      api.onShowFileChooser(
          this,
          webView,
          fileChooserParams,
          ResultCompat.asCompatCallback(
              reply -> {
                if (reply.isFailure()) {
                  api.getPigeonRegistrar()
                      .logError(TAG, Objects.requireNonNull(reply.exceptionOrNull()));
                  return null;
                }

                final List<String> value = Objects.requireNonNull(reply.getOrNull());

                // The returned list of file paths can only be passed to `filePathCallback` if the
                // `onShowFileChooser` method returned true.
                if (currentReturnValueForOnShowFileChooser) {
                  final Uri[] filePaths = new Uri[value.size()];
                  for (int i = 0; i < value.size(); i++) {
                    filePaths[i] = Uri.parse(value.get(i));
                  }
                  filePathCallback.onReceiveValue(filePaths);
                }

                return null;
              }));
      return currentReturnValueForOnShowFileChooser;
    }

    @Override
    public void onPermissionRequest(@NonNull PermissionRequest request) {
      api.onPermissionRequest(this, request, reply -> null);
    }

    @Override
    public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
      api.onConsoleMessage(this, consoleMessage, reply -> null);
      return returnValueForOnConsoleMessage;
    }

    /** Sets return value for {@link #onShowFileChooser}. */
    public void setReturnValueForOnShowFileChooser(boolean value) {
      returnValueForOnShowFileChooser = value;
    }

    /** Sets return value for {@link #onConsoleMessage}. */
    public void setReturnValueForOnConsoleMessage(boolean value) {
      returnValueForOnConsoleMessage = value;
    }

    public void setReturnValueForOnJsAlert(boolean value) {
      returnValueForOnJsAlert = value;
    }

    public void setReturnValueForOnJsConfirm(boolean value) {
      returnValueForOnJsConfirm = value;
    }

    public void setReturnValueForOnJsPrompt(boolean value) {
      returnValueForOnJsPrompt = value;
    }

    @Override
    public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
      if (returnValueForOnJsAlert) {
        api.onJsAlert(
            this,
            view,
            url,
            message,
            ResultCompat.asCompatCallback(
                reply -> {
                  if (reply.isFailure()) {
                    api.getPigeonRegistrar()
                        .logError(TAG, Objects.requireNonNull(reply.exceptionOrNull()));
                    return null;
                  }

                  result.confirm();
                  return null;
                }));
        return true;
      } else {
        return false;
      }
    }

    @Override
    public boolean onJsConfirm(WebView view, String url, String message, JsResult result) {
      if (returnValueForOnJsConfirm) {
        api.onJsConfirm(
            this,
            view,
            url,
            message,
            ResultCompat.asCompatCallback(
                reply -> {
                  if (reply.isFailure()) {
                    api.getPigeonRegistrar()
                        .logError(TAG, Objects.requireNonNull(reply.exceptionOrNull()));
                    return null;
                  }

                  if (Boolean.TRUE.equals(reply.getOrNull())) {
                    result.confirm();
                  } else {
                    result.cancel();
                  }

                  return null;
                }));
        return true;
      } else {
        return false;
      }
    }

    @Override
    public boolean onJsPrompt(
        WebView view, String url, String message, String defaultValue, JsPromptResult result) {
      if (returnValueForOnJsPrompt) {
        api.onJsPrompt(
            this,
            view,
            url,
            message,
            defaultValue,
            ResultCompat.asCompatCallback(
                reply -> {
                  if (reply.isFailure()) {
                    api.getPigeonRegistrar()
                        .logError(TAG, Objects.requireNonNull(reply.exceptionOrNull()));
                    return null;
                  }

                  @Nullable final String inputMessage = reply.getOrNull();

                  if (inputMessage != null) {
                    result.confirm(inputMessage);
                  } else {
                    result.cancel();
                  }

                  return null;
                }));
        return true;
      } else {
        return false;
      }
    }
  }

  /**
   * Implementation of {@link WebChromeClient} that only allows secure urls when opening a new
   * window.
   */
  public static class SecureWebChromeClient extends WebChromeClient {
    @Nullable WebViewClient webViewClient;

    @Override
    public boolean onCreateWindow(
        @NonNull final WebView view,
        boolean isDialog,
        boolean isUserGesture,
        @NonNull Message resultMsg) {
      return onCreateWindow(view, resultMsg, new WebView(view.getContext()));
    }

    /**
     * Verifies that a url opened by `Window.open` has a secure url.
     *
     * @param view the WebView from which the request for a new window originated.
     * @param resultMsg the message to send when once a new WebView has been created. resultMsg.obj
     *     is a {@link WebView.WebViewTransport} object. This should be used to transport the new
     *     WebView, by calling WebView.WebViewTransport.setWebView(WebView)
     * @param onCreateWindowWebView the temporary WebView used to verify the url is secure
     * @return this method should return true if the host application will create a new window, in
     *     which case resultMsg should be sent to its target. Otherwise, this method should return
     *     false. Returning false from this method but also sending resultMsg will result in
     *     undefined behavior
     */
    @VisibleForTesting
    boolean onCreateWindow(
        @NonNull final WebView view,
        @NonNull Message resultMsg,
        @Nullable WebView onCreateWindowWebView) {
      // WebChromeClient requires a WebViewClient because of a bug fix that makes
      // calls to WebViewClient.requestLoading/WebViewClient.urlLoading when a new
      // window is opened. This is to make sure a url opened by `Window.open` has
      // a secure url.
      if (webViewClient == null) {
        return false;
      }

      final WebViewClient windowWebViewClient =
          new WebViewClient() {
            @RequiresApi(api = Build.VERSION_CODES.N)
            @Override
            public boolean shouldOverrideUrlLoading(
                @NonNull WebView windowWebView, @NonNull WebResourceRequest request) {
              if (!webViewClient.shouldOverrideUrlLoading(view, request)) {
                view.loadUrl(request.getUrl().toString());
              }
              return true;
            }

            // Legacy codepath for < N.
            @Override
            @SuppressWarnings({"deprecation", "RedundantSuppression"})
            public boolean shouldOverrideUrlLoading(WebView windowWebView, String url) {
              if (!webViewClient.shouldOverrideUrlLoading(view, url)) {
                view.loadUrl(url);
              }
              return true;
            }
          };

      if (onCreateWindowWebView == null) {
        onCreateWindowWebView = new WebView(view.getContext());
      }
      onCreateWindowWebView.setWebViewClient(windowWebViewClient);

      final WebView.WebViewTransport transport = (WebView.WebViewTransport) resultMsg.obj;
      transport.setWebView(onCreateWindowWebView);
      resultMsg.sendToTarget();

      return true;
    }

    /**
     * Set the {@link WebViewClient} that calls to {@link WebChromeClient#onCreateWindow} are passed
     * to.
     *
     * @param webViewClient the forwarding {@link WebViewClient}
     */
    public void setWebViewClient(@NonNull WebViewClient webViewClient) {
      this.webViewClient = webViewClient;
    }
  }

  /** Creates a host API that handles creating {@link WebChromeClient}s. */
  public WebChromeClientProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public WebChromeClientImpl pigeon_defaultConstructor() {
    return new WebChromeClientImpl(this);
  }

  @Override
  public void setSynchronousReturnValueForOnShowFileChooser(
      @NonNull WebChromeClientImpl pigeon_instance, boolean value) {
    pigeon_instance.setReturnValueForOnShowFileChooser(value);
  }

  @Override
  public void setSynchronousReturnValueForOnConsoleMessage(
      @NonNull WebChromeClientImpl pigeon_instance, boolean value) {
    pigeon_instance.setReturnValueForOnConsoleMessage(value);
  }

  @Override
  public void setSynchronousReturnValueForOnJsAlert(
      @NonNull WebChromeClientImpl pigeon_instance, boolean value) {
    pigeon_instance.setReturnValueForOnJsAlert(value);
  }

  @Override
  public void setSynchronousReturnValueForOnJsConfirm(
      @NonNull WebChromeClientImpl pigeon_instance, boolean value) {
    pigeon_instance.setReturnValueForOnJsConfirm(value);
  }

  @Override
  public void setSynchronousReturnValueForOnJsPrompt(
      @NonNull WebChromeClientImpl pigeon_instance, boolean value) {
    pigeon_instance.setReturnValueForOnJsPrompt(value);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }
}
