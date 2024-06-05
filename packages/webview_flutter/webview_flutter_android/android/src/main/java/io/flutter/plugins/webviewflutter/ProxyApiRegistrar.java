package io.flutter.plugins.webviewflutter;

import android.os.Build;

import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;

import io.flutter.plugin.common.BinaryMessenger;

public class ProxyApiRegistrar extends PigeonProxyApiRegistrar {
  public ProxyApiRegistrar(@NonNull BinaryMessenger binaryMessenger) {
    super(binaryMessenger);
  }

  // Interface for an injectable SDK version checker.
  @ChecksSdkIntAtLeast(parameter = 0)
  boolean sdkIsAtLeast(int version) {
    return Build.VERSION.SDK_INT >= version;
  }

  @NonNull
  @Override
  public PigeonApiWebResourceRequest getPigeonApiWebResourceRequest() {
    return new WebResourceRequestProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiWebResourceError getPigeonApiWebResourceError() {
    return new WebResourceErrorProxyApi(this);
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
  public PigeonApiWebView getPigeonApiWebView() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiWebSettings getPigeonApiWebSettings() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiJavaScriptChannel getPigeonApiJavaScriptChannel() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiWebViewClient getPigeonApiWebViewClient() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiDownloadListener getPigeonApiDownloadListener() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiWebChromeClient getPigeonApiWebChromeClient() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiFlutterAssetManager getPigeonApiFlutterAssetManager() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiWebStorage getPigeonApiWebStorage() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiFileChooserParams getPigeonApiFileChooserParams() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiPermissionRequest getPigeonApiPermissionRequest() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCustomViewCallback getPigeonApiCustomViewCallback() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiView getPigeonApiView() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiGeolocationPermissionsCallback getPigeonApiGeolocationPermissionsCallback() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiHttpAuthHandler getPigeonApiHttpAuthHandler() {
    return null;
  }
}
