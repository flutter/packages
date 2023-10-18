// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.annotation.VisibleForTesting;

public class FlutterWebViewClient extends WebViewClient {
  @Override
  public void onLoadResource(WebView view, String url) {
    if (!resourceShouldOpenDocument(view, url)) {
      super.onLoadResource(view, url);
    }
  }

  /*
   * This method is deprecated in API 24. It is still overridden to support
   * earlier Android versions.
   */
  @SuppressWarnings("deprecation")
  @Override
  public boolean shouldOverrideUrlLoading(WebView view, String url) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      if (urlShouldRunActivity(view, url)) {
        return true;
      } else {
        view.loadUrl(url);
      }
      return false;
    }
    return super.shouldOverrideUrlLoading(view, url);
  }

  @RequiresApi(Build.VERSION_CODES.N)
  @Override
  public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      String url = request.getUrl().toString();
      if (urlShouldRunActivity(view, url)) {
        return true;
      } else {
        view.loadUrl(url);
      }
    }
    return false;
  }

  @VisibleForTesting
  public static boolean resourceShouldOpenDocument(@NonNull WebView view, @NonNull String url) {
    // Check if URL is PDF
    if (url.toLowerCase().endsWith(".pdf")) {
      Intent intent = new Intent(Intent.ACTION_VIEW);
      intent.setDataAndType(Uri.parse(url), "application/pdf");
      view.getContext().startActivity(intent);
      return true;
    }
    return false;
  }

  @VisibleForTesting
  public static boolean urlShouldRunActivity(@NonNull WebView view, @NonNull String url) {
    // Check if URL is not an HTTP(S) request.
    // Handles mailto:, sms:, etc.
    if (!url.toLowerCase().startsWith("http://") && !url.toLowerCase().startsWith("https://")) {
      Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
      view.getContext().startActivity(intent);
      return true;
    }

    // Otherwise, let WebView load URL.
    return false;
  }
}
