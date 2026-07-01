// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * App and package facing native API provided by the `webview_flutter_android` plugin.
 *
 * <p>This class follows the convention of breaking changes of the Dart API, which means that any
 * changes to the class that are not backwards compatible will only be made with a major version
 * change of the plugin.
 *
 * <p>Native code other than this external API does not follow breaking change conventions, so app
 * or plugin clients should not use any other native APIs.
 */
@SuppressWarnings("unused")
public interface WebViewFlutterAndroidExternalApi {
  /**
   * Retrieves the {@link WebView} that is associated with `identifier`.
   *
   * <p>See the Dart method `AndroidWebViewController.webViewIdentifier` to get the identifier of an
   * underlying `WebView`.
   *
   * @param binding the plugin binding provided by the Flutter engine. If the binding doesn't
   *     contain an attached instance of {@link WebViewFlutterPlugin}, this method returns null.
   * @param identifier the associated identifier of the `WebView`.
   * @return the `WebView` associated with `identifier` or null if a `WebView` instance associated
   *     with `identifier` could not be found.
   */
  @Nullable
  static WebView getWebView(@NonNull FlutterPlugin.FlutterPluginBinding binding, long identifier) {
    final WebViewFlutterPlugin webViewPlugin =
        (WebViewFlutterPlugin) binding.getPlugin(WebViewFlutterPlugin.class);

    return getWebViewFromPlugin(webViewPlugin, identifier);
  }

  /**
   * Retrieves the {@link WebView} that is associated with `identifier`.
   *
   * <p>See the Dart method `AndroidWebViewController.webViewIdentifier` to get the identifier of an
   * underlying `WebView`.
   *
   * @deprecated Use {@link #getWebView(FlutterPlugin.FlutterPluginBinding, long)} instead.
   * @param engine the execution environment the {@link WebViewFlutterPlugin} should belong to. If
   *     the engine doesn't contain an attached instance of {@link WebViewFlutterPlugin}, this
   *     method returns null.
   * @param identifier the associated identifier of the `WebView`.
   * @return the `WebView` associated with `identifier` or null if a `WebView` instance associated
   *     with `identifier` could not be found.
   */
  @Deprecated
  @Nullable
  static WebView getWebView(@NonNull FlutterEngine engine, long identifier) {
    final WebViewFlutterPlugin webViewPlugin =
        (WebViewFlutterPlugin) engine.getPlugins().get(WebViewFlutterPlugin.class);

    return getWebViewFromPlugin(webViewPlugin, identifier);
  }

  private static WebView getWebViewFromPlugin(WebViewFlutterPlugin webViewPlugin, long identifier) {
    if (webViewPlugin != null && webViewPlugin.getInstanceManager() != null) {
      final Object instance = webViewPlugin.getInstanceManager().getInstance(identifier);
      if (instance instanceof WebView) {
        return (WebView) instance;
      }
    }

    return null;
  }
}
