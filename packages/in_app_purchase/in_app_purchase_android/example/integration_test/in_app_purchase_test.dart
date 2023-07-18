// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    InAppPurchaseAndroidPlatform.registerPlatform();
  });

  testWidgets('Can create InAppPurchaseAndroid instance',
      (WidgetTester tester) async {
    final InAppPurchasePlatform androidPlatform =
        InAppPurchasePlatform.instance;
    expect(androidPlatform, isNotNull);
  });

  group('Method channel interaction works for', () {
    late final BillingClient billingClient;

    setUpAll(() {
      billingClient = BillingClient((PurchasesResultWrapper _) {});
    });

    test('BillingClient.acknowledgePurchase', () async {
      try {
        await billingClient.acknowledgePurchase('purchaseToken');
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });

    test('BillingClient.consumeAsync', () async {
      try {
        await billingClient.consumeAsync('purchaseToken');
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });

    test('BillingClient.endConnection', () async {
      try {
        await billingClient.endConnection();
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });

    test('BillingClient.isFeatureSupported', () async {
      try {
        await billingClient
            .isFeatureSupported(BillingClientFeature.productDetails);
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });

    test('BillingClient.isReady', () async {
      try {
        await billingClient.isReady();
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });

    test('BillingClient.launchBillingFlow', () async {
      try {
        await billingClient.launchBillingFlow(product: 'product');
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      } on PlatformException catch (e) {
        // A [PlatformException] is expected, as we do not fetch products first.
        if (e.code != 'NOT_FOUND') {
          rethrow;
        }
      }
    });

    test('BillingClient.queryProductDetails', () async {
      try {
        await billingClient
            .queryProductDetails(productList: <ProductWrapper>[]);
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      } on PlatformException catch (e) {
        // A [PlatformException] is expected, as we send an empty product list.
        if (!(e.message?.startsWith('Product list cannot be empty.') ??
            false)) {
          rethrow;
        }
      }
    });

    test('BillingClient.queryPurchaseHistory', () async {
      try {
        await billingClient.queryPurchaseHistory(ProductType.inapp);
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });

    test('BillingClient.queryPurchases', () async {
      try {
        await billingClient.queryPurchases(ProductType.inapp);
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });

    test('BillingClient.startConnection', () async {
      try {
        await billingClient.startConnection(
            onBillingServiceDisconnected: () {});
      } on MissingPluginException {
        fail('Method channel is not setup correctly');
      }
    });
  });
}
