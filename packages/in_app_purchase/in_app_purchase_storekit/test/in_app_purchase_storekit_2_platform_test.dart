// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

import 'fakes/fake_storekit_platform.dart';
import 'sk2_test_api.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeStoreKit2Platform fakeStoreKit2Platform = FakeStoreKit2Platform();
  late InAppPurchaseStoreKitPlatform iapStoreKitPlatform;

  setUpAll(() {
    TestInAppPurchase2Api.setUp(fakeStoreKit2Platform);
  });

  setUp(() {
    InAppPurchaseStoreKitPlatform.registerPlatform();
    iapStoreKitPlatform =
        InAppPurchasePlatform.instance as InAppPurchaseStoreKitPlatform;
    iapStoreKitPlatform.enableStoreKit2();
    fakeStoreKit2Platform.reset();
  });

  tearDown(() => fakeStoreKit2Platform.reset());

  group('isAvailable', () {
    test('true', () async {
      expect(await iapStoreKitPlatform.isAvailable(), isTrue);
    });
  });

  group('query product list', () {
    test('should get product list and correct invalid identifiers', () async {
      final InAppPurchaseStoreKitPlatform connection =
          InAppPurchaseStoreKitPlatform();
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>{'123', '456', '789'});
      final List<ProductDetails> products = response.productDetails;
      expect(products.first.id, '123');
      expect(products[1].id, '456');
      expect(response.notFoundIDs, <String>['789']);
      expect(response.error, isNull);
      expect(response.productDetails.first.currencySymbol, r'$');
      expect(response.productDetails[1].currencySymbol, r'$');
    });
    test(
        'if query products throws error, should get error object in the response',
        () async {
      fakeStoreKit2Platform.queryProductException = PlatformException(
          code: 'error_code',
          message: 'error_message',
          details: <Object, Object>{'info': 'error_info'});
      final InAppPurchaseStoreKitPlatform connection =
          InAppPurchaseStoreKitPlatform();
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>{'123', '456', '789'});
      expect(response.productDetails, <ProductDetails>[]);
      expect(response.notFoundIDs, <String>['123', '456', '789']);
      expect(response.error, isNotNull);
      expect(response.error!.source, kIAPSource);
      expect(response.error!.code, 'error_code');
      expect(response.error!.message, 'error_message');
      expect(response.error!.details, <Object, Object>{'info': 'error_info'});
    });
  });
}
