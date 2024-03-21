// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import io.flutter.plugins.webviewflutter.WebViewClientHostApiImpl.WebViewClientCompatImpl;
import io.flutter.plugins.webviewflutter.WebViewClientHostApiImpl.WebViewClientCreator;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebViewClientTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public WebViewClientFlutterApiImpl mockFlutterApi;

  InstanceManager instanceManager;
  WebViewClientHostApiImpl hostApiImpl;
  WebViewClientCompatImpl webViewClient;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});

    final WebViewClientCreator webViewClientCreator =
        new WebViewClientCreator() {
          @Override
          @NonNull
          public WebViewClient createWebViewClient(
              @NonNull WebViewClientFlutterApiImpl flutterApi) {
            webViewClient = (WebViewClientCompatImpl) super.createWebViewClient(flutterApi);
            return webViewClient;
          }
        };

    hostApiImpl =
        new WebViewClientHostApiImpl(instanceManager, webViewClientCreator, mockFlutterApi);
    hostApiImpl.create(1L);
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void setReturnValueForShouldOverrideUrlLoading() {
    final WebViewClientCompatImpl mockWebViewClient = mock();
    final WebViewClientHostApiImpl webViewClientHostApi =
        new WebViewClientHostApiImpl(
            instanceManager,
            new WebViewClientCreator() {
              @NonNull
              @Override
              public WebViewClient createWebViewClient(
                  @NonNull WebViewClientFlutterApiImpl flutterApi) {
                return mockWebViewClient;
              }
            },
            mockFlutterApi);

    instanceManager.addDartCreatedInstance(mockWebViewClient, 2);
    webViewClientHostApi.setSynchronousReturnValueForShouldOverrideUrlLoading(2L, false);

    verify(mockWebViewClient).setReturnValueForShouldOverrideUrlLoading(false);
  }
}
