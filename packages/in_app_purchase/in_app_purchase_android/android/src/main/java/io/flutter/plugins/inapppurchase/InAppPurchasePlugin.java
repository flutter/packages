// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingClient;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;

/** Wraps a {@link BillingClient} instance and responds to Dart calls for it. */
public class InAppPurchasePlugin implements FlutterPlugin, ActivityAware {

  static final String PROXY_PACKAGE_KEY = "PROXY_PACKAGE";
  // The proxy value has to match the <package> value in library's AndroidManifest.xml.
  // This is important that the <package> is not changed, so we hard code the value here then having
  // a unit test to make sure. If there is a strong reason to change the <package> value, please inform the
  // code owner of this package.
  static final String PROXY_VALUE = "io.flutter.plugins.inapppurchase";

  private MethodCallHandlerImpl methodCallHandler;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
    setUpMethodChannel(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
    teardownMethodChannel(binding.getBinaryMessenger());
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    binding.getActivity().getIntent().putExtra(PROXY_PACKAGE_KEY, PROXY_VALUE);
    methodCallHandler.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    methodCallHandler.setActivity(null);
    methodCallHandler.onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    methodCallHandler.setActivity(null);
  }

  private void setUpMethodChannel(BinaryMessenger messenger, Context context) {
    Messages.InAppPurchaseCallbackApi handler = new Messages.InAppPurchaseCallbackApi(messenger);
    methodCallHandler =
        new MethodCallHandlerImpl(
            /*activity=*/ null, context, handler, new BillingClientFactoryImpl());
    Messages.InAppPurchaseApi.setUp(messenger, methodCallHandler);
  }

  private void teardownMethodChannel(BinaryMessenger messenger) {
    Messages.InAppPurchaseApi.setUp(messenger, null);
    methodCallHandler = null;
  }

  @VisibleForTesting
  void setMethodCallHandler(MethodCallHandlerImpl methodCallHandler) {
    this.methodCallHandler = methodCallHandler;
  }
}
