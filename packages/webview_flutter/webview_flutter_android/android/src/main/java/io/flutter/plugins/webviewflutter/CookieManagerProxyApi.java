// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.CookieManager;
import android.webkit.WebView;
import androidx.annotation.NonNull;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * Host API implementation for `CookieManager`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class CookieManagerProxyApi extends PigeonApiCookieManager {
  public CookieManagerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public CookieManager instance() {
    return CookieManager.getInstance();
  }

  @Override
  public void setCookie(@NonNull CookieManager pigeon_instance, @NonNull String url, @NonNull String value) {
    pigeon_instance.setCookie(url, value);
  }

  @Override
  public void removeAllCookies(@NonNull CookieManager pigeon_instance, @NonNull Function1<? super Result<Boolean>, Unit> callback) {
    if (getPigeonRegistrar().sdkIsAtLeast(Build.VERSION_CODES.LOLLIPOP)) {
      pigeon_instance.removeAllCookies(aBoolean -> ResultCompat.success(aBoolean, callback));
    } else {
      removeCookiesPreL(pigeon_instance);
    }
  }

  @Override
  public void setAcceptThirdPartyCookies(@NonNull CookieManager pigeon_instance, @NonNull WebView webView, boolean accept) {
    if (getPigeonRegistrar().sdkIsAtLeast(Build.VERSION_CODES.LOLLIPOP)) {
      pigeon_instance.setAcceptThirdPartyCookies(webView, accept);
    } else {
      throw new UnsupportedOperationException(
          "`setAcceptThirdPartyCookies` is unsupported on versions below `Build.VERSION_CODES.LOLLIPOP`.");
    }
  }

  /**
   * Removes all cookies from the given cookie manager, using the deprecated (pre-Lollipop)
   * implementation.
   *
   * @param cookieManager The cookie manager to clear all cookies from.
   * @return Whether any cookies were removed.
   */
  @SuppressWarnings("deprecation")
  private boolean removeCookiesPreL(CookieManager cookieManager) {
    final boolean hasCookies = cookieManager.hasCookies();
    if (hasCookies) {
      cookieManager.removeAllCookie();
    }
    return hasCookies;
  }
}
