// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

public class InAppPurchasePluginTest {

  static final String PROXY_PACKAGE_KEY = "PROXY_PACKAGE";

  @Mock Activity activity;
  @Mock Context context;
  @Mock BinaryMessenger mockMessenger;
  @Mock Application mockApplication;
  @Mock Intent mockIntent;
  @Mock ActivityPluginBinding activityPluginBinding;
  @Mock FlutterPlugin.FlutterPluginBinding flutterPluginBinding;

  AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
    when(activity.getIntent()).thenReturn(mockIntent);
    when(activityPluginBinding.getActivity()).thenReturn(activity);
    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mockMessenger);
    when(flutterPluginBinding.getApplicationContext()).thenReturn(context);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  // The PROXY_PACKAGE_KEY value of this test (io.flutter.plugins.inapppurchase) should never be changed.
  // In case there's a strong reason to change it, please inform the current code owner of the plugin.
  @Test
  public void attachToActivity_proxyIsSet_V2Embedding() {
    InAppPurchasePlugin plugin = new InAppPurchasePlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);
    // The `PROXY_PACKAGE_KEY` value is hard coded in the plugin code as "io.flutter.plugins.inapppurchase".
    // We cannot use `BuildConfig.LIBRARY_PACKAGE_NAME` directly in the plugin code because whether to read BuildConfig.APPLICATION_ID or LIBRARY_PACKAGE_NAME
    // depends on the "APP's" Android Gradle plugin version. Newer versions of AGP use LIBRARY_PACKAGE_NAME, whereas older ones use BuildConfig.APPLICATION_ID.
    Mockito.verify(mockIntent).putExtra(PROXY_PACKAGE_KEY, "io.flutter.plugins.inapppurchase");
    assertEquals("io.flutter.plugins.inapppurchase", BuildConfig.LIBRARY_PACKAGE_NAME);
  }
}
// We cannot use `BuildConfig.LIBRARY_PACKAGE_NAME` directly in the plugin code because whether to read BuildConfig.APPLICATION_ID or LIBRARY_PACKAGE_NAME
// depends on the "APP's" Android Gradle plugin version. Newer versions of AGP use LIBRARY_PACKAGE_NAME, whereas older ones use BuildConfig.APPLICATION_ID.
