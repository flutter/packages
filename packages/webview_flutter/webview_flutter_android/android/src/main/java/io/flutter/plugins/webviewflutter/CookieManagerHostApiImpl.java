// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.CookieManager;

class CookieManagerHostApiImpl implements GeneratedAndroidWebView.CookieManagerHostApi {
  @Override
  public void clearCookies(GeneratedAndroidWebView.Result<Boolean> result) {
    CookieManager cookieManager = CookieManager.getInstance();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      cookieManager.removeAllCookies(result::success);
    } else {
      result.success(removeCookiesPreL(cookieManager));
    }
  }

  @Override
  public void setCookie(String url, String value) {
    CookieManager.getInstance().setCookie(url, value);
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
