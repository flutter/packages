// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import io.flutter.plugin.common.BinaryMessenger;

public class ProxyApiRegistrar extends AndroidWebkitLibraryPigeonProxyApiRegistrar {
  @NonNull private Context context;

  @NonNull private final FlutterAssetManager flutterAssetManager;

  public ProxyApiRegistrar(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull Context context,
      @NonNull FlutterAssetManager flutterAssetManager) {
    super(binaryMessenger);
    this.context = context;
    this.flutterAssetManager = flutterAssetManager;
  }

  // Interface for an injectable SDK version checker.
  @ChecksSdkIntAtLeast(parameter = 0)
  boolean sdkIsAtLeast(int version) {
    return Build.VERSION.SDK_INT >= version;
  }

  // Added to be overridden for tests. The test implementation calls `callback` immediately, instead
  // of waiting for the main thread to run it.
  void runOnMainThread(Runnable runnable) {
    if (context instanceof Activity) {
      ((Activity) context).runOnUiThread(runnable);
    } else {
      new Handler(Looper.getMainLooper()).post(runnable);
    }
  }

  // For logging exception received from Host -> Dart message calls.
  void logError(String tag, Throwable exception) {
    Log.e(
        tag,
        exception.getClass().getSimpleName()
            + ", Message: "
            + exception.getMessage()
            + ", Stacktrace: "
            + Log.getStackTraceString(exception));
  }

  /** Creates an exception when the `unknown` enum value is passed to a host method. */
  @NonNull
  IllegalArgumentException createUnknownEnumException(@NonNull Object enumValue) {
    return new IllegalArgumentException(enumValue + " doesn't represent a native value.");
  }

  /** Creates the error message when a method is called on an unsupported version. */
  @NonNull
  String createUnsupportedVersionMessage(
      @NonNull String method, @NonNull String versionRequirements) {
    return method + " requires " + versionRequirements + ".";
  }

  @NonNull
  @Override
  public PigeonApiWebResourceRequest getPigeonApiWebResourceRequest() {
    return new WebResourceRequestProxyApi(this);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @NonNull
  @Override
  public PigeonApiWebResourceError getPigeonApiWebResourceError() {
    return new WebResourceErrorProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebResourceErrorCompat getPigeonApiWebResourceErrorCompat() {
    return new WebResourceErrorCompatProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebViewPoint getPigeonApiWebViewPoint() {
    return new WebViewPointProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiConsoleMessage getPigeonApiConsoleMessage() {
    return new ConsoleMessageProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCookieManager getPigeonApiCookieManager() {
    return new CookieManagerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebResourceResponse getPigeonApiWebResourceResponse() {
    return new WebResourceResponseProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebView getPigeonApiWebView() {
    return new WebViewProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebSettings getPigeonApiWebSettings() {
    return new WebSettingsProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiJavaScriptChannel getPigeonApiJavaScriptChannel() {
    return new JavaScriptChannelProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebViewClient getPigeonApiWebViewClient() {
    return new WebViewClientProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiDownloadListener getPigeonApiDownloadListener() {
    return new DownloadListenerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebChromeClient getPigeonApiWebChromeClient() {
    return new WebChromeClientProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiFlutterAssetManager getPigeonApiFlutterAssetManager() {
    return new FlutterAssetManagerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebStorage getPigeonApiWebStorage() {
    return new WebStorageProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiFileChooserParams getPigeonApiFileChooserParams() {
    return new FileChooserParamsProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiPermissionRequest getPigeonApiPermissionRequest() {
    return new PermissionRequestProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCustomViewCallback getPigeonApiCustomViewCallback() {
    return new CustomViewCallbackProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiView getPigeonApiView() {
    return new ViewProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiGeolocationPermissionsCallback getPigeonApiGeolocationPermissionsCallback() {
    return new GeolocationPermissionsCallbackProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiHttpAuthHandler getPigeonApiHttpAuthHandler() {
    return new HttpAuthHandlerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiClientCertRequest getPigeonApiClientCertRequest() {
    return new ClientCertRequestProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiSslErrorHandler getPigeonApiSslErrorHandler() {
    return new SslErrorHandlerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiSslError getPigeonApiSslError() {
    return new SslErrorProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiSslCertificateDName getPigeonApiSslCertificateDName() {
    return new SslCertificateDNameProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiSslCertificate getPigeonApiSslCertificate() {
    return new SslCertificateProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiAndroidMessage getPigeonApiAndroidMessage() {
    return new MessageProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCertificate getPigeonApiCertificate() {
    return new CertificateProxyApi(this);
  }

  @NonNull
  public Context getContext() {
    return context;
  }

  public void setContext(@NonNull Context context) {
    this.context = context;
  }

  @NonNull
  public FlutterAssetManager getFlutterAssetManager() {
    return flutterAssetManager;
  }
}
