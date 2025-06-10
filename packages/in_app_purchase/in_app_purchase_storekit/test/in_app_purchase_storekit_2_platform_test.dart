// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

import 'fakes/fake_storekit_platform.dart';
import 'sk2_test_api.g.dart';
import 'test_api.g.dart';

void main() {
  final SK2Product dummyProductWrapper = SK2Product(
      id: '2',
      displayName: 'name',
      displayPrice: '0.99',
      description: 'desc',
      price: 0.99,
      type: SK2ProductType.consumable,
      priceLocale: SK2PriceLocale(currencyCode: 'USD', currencySymbol: r'$'));

  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeStoreKit2Platform fakeStoreKit2Platform = FakeStoreKit2Platform();
  final FakeStoreKitPlatform fakeStoreKitPlatform = FakeStoreKitPlatform();

  late InAppPurchaseStoreKitPlatform iapStoreKitPlatform;

  setUpAll(() {
    TestInAppPurchase2Api.setUp(fakeStoreKit2Platform);
    TestInAppPurchaseApi.setUp(fakeStoreKitPlatform);
  });

  setUp(() {
    InAppPurchaseStoreKitPlatform.registerPlatform();
    iapStoreKitPlatform =
        InAppPurchasePlatform.instance as InAppPurchaseStoreKitPlatform;
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

  group('make payment', () {
    test(
        'buying non consumable, should get purchase objects in the purchase update callback',
        () async {
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        if (purchaseDetailsList.first.status == PurchaseStatus.purchased) {
          completer.complete(details);
          subscription.cancel();
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProduct2Details.fromSK2Product(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final List<PurchaseDetails> result = await completer.future;
      expect(result.length, 1);
      expect(result.first.productID, dummyProductWrapper.id);
    });

    test(
        'buying consumable, should get purchase objects in the purchase update callback',
        () async {
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        if (purchaseDetailsList.first.status == PurchaseStatus.purchased) {
          completer.complete(details);
          subscription.cancel();
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProduct2Details.fromSK2Product(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyConsumable(purchaseParam: purchaseParam);

      final List<PurchaseDetails> result = await completer.future;
      expect(result.length, 1);
      expect(result.first.productID, dummyProductWrapper.id);
    });

    test('buying consumable, should throw when autoConsume is false', () async {
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProduct2Details.fromSK2Product(dummyProductWrapper),
          applicationUserName: 'appName');
      expect(
          () => iapStoreKitPlatform.buyConsumable(
              purchaseParam: purchaseParam, autoConsume: false),
          throwsA(isInstanceOf<AssertionError>()));
    });

    test(
        'buying consumable, should get PurchaseVerificationData with serverVerificationData and localVerificationData',
        () async {
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late final StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        if (purchaseDetailsList.first.status == PurchaseStatus.purchased) {
          completer.complete(details);
          subscription.cancel();
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProduct2Details.fromSK2Product(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyConsumable(purchaseParam: purchaseParam);

      final List<PurchaseDetails> result = await completer.future;
      expect(result.length, 1);
      expect(result.first.productID, dummyProductWrapper.id);
      expect(
          result.first.verificationData.serverVerificationData, 'receiptData');
      expect(result.first.verificationData.localVerificationData,
          'jsonRepresentation');
    });

    test('should process Sk2PurchaseParam with winBackOfferId only', () async {
      final Sk2PurchaseParam purchaseParam = Sk2PurchaseParam(
        productDetails:
            AppStoreProduct2Details.fromSK2Product(dummyProductWrapper),
        applicationUserName: 'testUser',
        winBackOfferId: 'winBack123',
      );

      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final SK2ProductPurchaseOptionsMessage lastPurchaseOptions =
          fakeStoreKit2Platform.lastPurchaseOptions!;

      expect(lastPurchaseOptions.appAccountToken, 'testUser');
      expect(lastPurchaseOptions.quantity, 1);
      expect(lastPurchaseOptions.winBackOfferId, 'winBack123');
      expect(lastPurchaseOptions.promotionalOffer, isNull);
    });

    test('should process Sk2PurchaseParam with promotionalOffer only',
        () async {
      final SK2SubscriptionOfferSignature fakeSignature =
          SK2SubscriptionOfferSignature(
        keyID: 'key123',
        signature: 'signature123',
        nonce: 'nonce123',
        timestamp: 1234567890,
      );

      final Sk2PurchaseParam purchaseParam = Sk2PurchaseParam(
        productDetails:
            AppStoreProduct2Details.fromSK2Product(dummyProductWrapper),
        applicationUserName: 'testUser',
        quantity: 2,
        promotionalOffer: SK2PromotionalOffer(
          signature: fakeSignature,
          offerId: 'promo123',
        ),
      );

      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final SK2ProductPurchaseOptionsMessage lastPurchaseOptions =
          fakeStoreKit2Platform.lastPurchaseOptions!;

      expect(lastPurchaseOptions.appAccountToken, 'testUser');
      expect(lastPurchaseOptions.quantity, 2);
      expect(
          lastPurchaseOptions.promotionalOffer!.promotionalOfferId, 'promo123');
      expect(
          lastPurchaseOptions.promotionalOffer!.promotionalOfferSignature.keyID,
          'key123');
      expect(lastPurchaseOptions.winBackOfferId, isNull);
    });

    test(
        'should process Sk2PurchaseParam with no winBackOfferId or promotionalOffer',
        () async {
      final Sk2PurchaseParam purchaseParam = Sk2PurchaseParam(
        productDetails:
            AppStoreProduct2Details.fromSK2Product(dummyProductWrapper),
        applicationUserName: 'testUser',
      );

      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final SK2ProductPurchaseOptionsMessage lastPurchaseOptions =
          fakeStoreKit2Platform.lastPurchaseOptions!;

      expect(lastPurchaseOptions.appAccountToken, 'testUser');
      expect(lastPurchaseOptions.quantity, 1);
      expect(lastPurchaseOptions.winBackOfferId, isNull);
      expect(lastPurchaseOptions.promotionalOffer, isNull);
    });
  });

  group('restore purchases', () {
    test('should emit restored transactions on purchase stream', () async {
      fakeStoreKit2Platform.transactionList
          .add(fakeStoreKit2Platform.createRestoredTransaction('foo', 'RT1'));
      fakeStoreKit2Platform.transactionList
          .add(fakeStoreKit2Platform.createRestoredTransaction('foo', 'RT2'));
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          subscription.cancel();
          completer.complete(purchaseDetailsList);
        }
      });

      await iapStoreKitPlatform.restorePurchases();
      final List<PurchaseDetails> details = await completer.future;

      expect(details.length, 2);
      for (int i = 0; i < fakeStoreKit2Platform.transactionList.length; i++) {
        final SK2TransactionMessage expected =
            fakeStoreKit2Platform.transactionList[i];
        final PurchaseDetails actual = details[i];

        expect(actual.purchaseID, expected.id.toString());
        expect(actual.verificationData, isNotNull);
        expect(actual.status, PurchaseStatus.restored);
        // In storekit 2, restored purchases don't have to finished.
        expect(actual.pendingCompletePurchase, false);
      }
    });
  });

  group('billing configuration', () {
    test('country_code', () async {
      const String expectedCountryCode = 'ABC';
      final String countryCode = await iapStoreKitPlatform.countryCode();
      expect(countryCode, expectedCountryCode);
    });
  });

  group('win back offers eligibility', () {
    late FakeStoreKit2Platform fakeStoreKit2Platform;

    setUp(() async {
      fakeStoreKit2Platform = FakeStoreKit2Platform();
      fakeStoreKit2Platform.reset();
      TestInAppPurchase2Api.setUp(fakeStoreKit2Platform);
      await InAppPurchaseStoreKitPlatform.enableStoreKit2();
    });

    test('should return true when offer is eligible', () async {
      fakeStoreKit2Platform.validProductIDs = <String>{'sub1'};
      fakeStoreKit2Platform.eligibleWinBackOffers['sub1'] = <String>{
        'winback1'
      };
      fakeStoreKit2Platform.validProducts['sub1'] = SK2Product(
        id: 'sub1',
        displayName: 'Subscription',
        displayPrice: r'$9.99',
        description: 'Monthly subscription',
        price: 9.99,
        type: SK2ProductType.autoRenewable,
        subscription: const SK2SubscriptionInfo(
          subscriptionGroupID: 'group1',
          promotionalOffers: <SK2SubscriptionOffer>[],
          subscriptionPeriod: SK2SubscriptionPeriod(
            value: 1,
            unit: SK2SubscriptionPeriodUnit.month,
          ),
        ),
        priceLocale: SK2PriceLocale(currencyCode: 'USD', currencySymbol: r'$'),
      );

      final bool result = await iapStoreKitPlatform.isWinBackOfferEligible(
        'sub1',
        'winback1',
      );

      expect(result, isTrue);
    });

    test('should return false when offer is not eligible', () async {
      fakeStoreKit2Platform.validProductIDs = <String>{'sub1'};
      fakeStoreKit2Platform.eligibleWinBackOffers = <String, Set<String>>{};
      fakeStoreKit2Platform.validProducts['sub1'] = SK2Product(
        id: 'sub1',
        displayName: 'Subscription',
        displayPrice: r'$9.99',
        description: 'Monthly subscription',
        price: 9.99,
        type: SK2ProductType.autoRenewable,
        subscription: const SK2SubscriptionInfo(
          subscriptionGroupID: 'group1',
          promotionalOffers: <SK2SubscriptionOffer>[],
          subscriptionPeriod: SK2SubscriptionPeriod(
            value: 1,
            unit: SK2SubscriptionPeriodUnit.month,
          ),
        ),
        priceLocale: SK2PriceLocale(currencyCode: 'USD', currencySymbol: r'$'),
      );

      final bool result = await iapStoreKitPlatform.isWinBackOfferEligible(
        'sub1',
        'winback1',
      );

      expect(result, isFalse);
    });

    test('should throw product not found error for invalid product', () async {
      expect(
        () => iapStoreKitPlatform.isWinBackOfferEligible(
          'invalid_product',
          'winback1',
        ),
        throwsA(isA<PlatformException>().having(
          (PlatformException e) => e.code,
          'code',
          'storekit2_failed_to_fetch_product',
        )),
      );
    });

    test('should throw subscription error for non-subscription product',
        () async {
      fakeStoreKit2Platform.validProductIDs = <String>{'consumable1'};
      fakeStoreKit2Platform.validProducts['consumable1'] = SK2Product(
        id: 'consumable1',
        displayName: 'Coins',
        displayPrice: r'$0.99',
        description: 'Game currency',
        price: 0.99,
        type: SK2ProductType.consumable,
        priceLocale: SK2PriceLocale(currencyCode: 'USD', currencySymbol: r'$'),
      );

      expect(
        () => iapStoreKitPlatform.isWinBackOfferEligible(
          'consumable1',
          'winback1',
        ),
        throwsA(isA<PlatformException>().having(
          (PlatformException e) => e.code,
          'code',
          'storekit2_not_subscription',
        )),
      );
    });

    test('should throw platform exception when StoreKit2 is not supported',
        () async {
      await InAppPurchaseStoreKitPlatform.enableStoreKit1();

      expect(
        () => iapStoreKitPlatform.isWinBackOfferEligible(
          'sub1',
          'winback1',
        ),
        throwsA(isA<PlatformException>().having(
          (PlatformException e) => e.code,
          'code',
          'storekit2_not_enabled',
        )),
      );
    });
  });
}
