// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.WebChromeClient.CustomViewCallback;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.CustomViewCallbackFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CustomViewCallbackTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public CustomViewCallback mockCustomViewCallback;

  @Mock public BinaryMessenger mockBinaryMessenger;

  @Mock public CustomViewCallbackFlutterApi mockFlutterApi;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void onCustomViewHidden() {
    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockCustomViewCallback, instanceIdentifier);

    final CustomViewCallbackHostApiImpl hostApi =
        new CustomViewCallbackHostApiImpl(mockBinaryMessenger, instanceManager);

    hostApi.onCustomViewHidden(instanceIdentifier);

    verify(mockCustomViewCallback).onCustomViewHidden();
  }

  @Test
  public void flutterApiCreate() {
    final CustomViewCallbackFlutterApiImpl flutterApi =
        new CustomViewCallbackFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockCustomViewCallback, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockCustomViewCallback));
    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }
}
