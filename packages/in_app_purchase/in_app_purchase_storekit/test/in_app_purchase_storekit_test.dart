// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/messages.g.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'fakes/fake_storekit_platform.dart';

import 'in_app_purchase_storekit_test.mocks.dart';

@GenerateMocks(<Type>[InAppPurchaseAPI])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInAppPurchaseAPI api;
  late InAppPurchaseStoreKitPlatform iapStoreKitPlatform;

  setUp(() {
    api = MockInAppPurchaseAPI();
    // InAppPurchaseStoreKitPlatform.registerPlatform();
    // iapStoreKitPlatform =
    // InAppPurchasePlatform.instance as InAppPurchaseStoreKitPlatform;
    // fakeStoreKitPlatform.reset();
  });

  // setUpAll(() {
  //   _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
  //       .defaultBinaryMessenger
  //       .setMockMethodCallHandler(
  //       SystemChannels.platform, fakeStoreKitPlatform.onMethodCall);
  // });

  test('registers instance', () {
    InAppPurchaseStoreKitPlatform.registerPlatform();
    expect(InAppPurchasePlatform.instance, isA<InAppPurchaseStoreKitPlatform>());
  });

  // test('canMakePurchase', () async {
  //   when(api.canMakePayments())
  //       .thenAnswer((_) async => true);
  //   iapStoreKitPlatform = InAppPurchaseStoreKitPlatform(api: api);
  //   expect(await iapStoreKitPlatform.isAvailable(), true);
  // });
  //
  // test('should get product list and correct invalid identifiers', () async {
  //   iapStoreKitPlatform = InAppPurchaseStoreKitPlatform(api: api);
  //   final ProductDetailsResponse response =
  //   await iapStoreKitPlatform.queryProductDetails(<String>{'123', '456', '789'});
  //   final List<ProductDetails> products = response.productDetails;
  //   expect(products.first.id, '123');
  //   expect(products[1].id, '456');
  //   expect(response.notFoundIDs, <String>['789']);
  //   expect(response.error, isNull);
  //   expect(response.productDetails.first.currencySymbol, r'$');
  //   expect(response.productDetails[1].currencySymbol, 'EUR');
  // });

}

T? _ambiguate<T>(T? value) => value;
