// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebViewClient;

public class WebViewClientImplTest extends WebViewClientTest {

  @Override
  WebViewClient createInstance(WebViewClientFlutterApiImpl flutterApi) {
    return new WebViewClientHostApiImpl.WebViewClientImpl(flutterApi);
  }

  @Override
  void setReturnValueForShouldOverrideUrlLoading(WebViewClient client, boolean value) {
    ((WebViewClientHostApiImpl.WebViewClientImpl) client)
        .setReturnValueForShouldOverrideUrlLoading(value);
  }
}
