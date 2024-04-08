// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_config_wrapper.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../test_conversion_utils.dart';
import 'billing_client_wrapper_test.mocks.dart';
import 'product_details_wrapper_test.dart';
import 'purchase_wrapper_test.dart';

const PurchaseWrapper dummyOldPurchase = PurchaseWrapper(
  orderId: 'oldOrderId',
  packageName: 'oldPackageName',
  purchaseTime: 0,
  signature: 'oldSignature',
  products: <String>['oldProduct'],
  purchaseToken: 'oldPurchaseToken',
  isAutoRenewing: false,
  originalJson: '',
  developerPayload: 'old dummy payload',
  isAcknowledged: true,
  purchaseState: PurchaseStateWrapper.purchased,
);

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<InAppPurchaseApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInAppPurchaseApi mockApi;
  late BillingClient billingClient;

  setUp(() {
    mockApi = MockInAppPurchaseApi();
    when(mockApi.startConnection(any, any)).thenAnswer(
        (_) async => PlatformBillingResult(responseCode: 0, debugMessage: ''));
    billingClient = BillingClient(
        (PurchasesResultWrapper _) {}, (UserChoiceDetailsWrapper _) {},
        api: mockApi);
  });

  group('isReady', () {
    test('true', () async {
      when(mockApi.isReady()).thenAnswer((_) async => true);
      expect(await billingClient.isReady(), isTrue);
    });

    test('false', () async {
      when(mockApi.isReady()).thenAnswer((_) async => false);
      expect(await billingClient.isReady(), isFalse);
    });
  });

  // Make sure that the enum values are supported and that the converter call
  // does not fail
  test('response states', () async {
    const BillingResponseConverter converter = BillingResponseConverter();
    converter.fromJson(-3);
    converter.fromJson(-2);
    converter.fromJson(-1);
    converter.fromJson(0);
    converter.fromJson(1);
    converter.fromJson(2);
    converter.fromJson(3);
    converter.fromJson(4);
    converter.fromJson(5);
    converter.fromJson(6);
    converter.fromJson(7);
    converter.fromJson(8);
    converter.fromJson(12);
  });

  group('startConnection', () {
    test('returns BillingResultWrapper', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.developerError;
      when(mockApi.startConnection(any, any)).thenAnswer(
        (_) async => PlatformBillingResult(
          responseCode: const BillingResponseConverter().toJson(responseCode),
          debugMessage: debugMessage,
        ),
      );

      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      expect(
          await billingClient.startConnection(
              onBillingServiceDisconnected: () {}),
          equals(billingResult));
    });

    test('passes default values to onBillingServiceDisconnected', () async {
      await billingClient.startConnection(onBillingServiceDisconnected: () {});

      final VerificationResult result =
          verify(mockApi.startConnection(captureAny, captureAny));
      expect(result.captured[0], 0);
      expect(result.captured[1], PlatformBillingChoiceMode.playBillingOnly);
    });

    test('passes billingChoiceMode alternativeBillingOnly when set', () async {
      await billingClient.startConnection(
          onBillingServiceDisconnected: () {},
          billingChoiceMode: BillingChoiceMode.alternativeBillingOnly);

      expect(verify(mockApi.startConnection(any, captureAny)).captured.first,
          PlatformBillingChoiceMode.alternativeBillingOnly);
    });

    test('passes billingChoiceMode userChoiceBilling when set', () async {
      final Completer<UserChoiceDetailsWrapper> completer =
          Completer<UserChoiceDetailsWrapper>();
      billingClient = BillingClient((PurchasesResultWrapper _) {},
          (UserChoiceDetailsWrapper details) => completer.complete(details),
          api: mockApi);

      await billingClient.startConnection(
          onBillingServiceDisconnected: () {},
          billingChoiceMode: BillingChoiceMode.alternativeBillingOnly);

      expect(verify(mockApi.startConnection(any, captureAny)).captured.first,
          PlatformBillingChoiceMode.alternativeBillingOnly);

      const UserChoiceDetailsWrapper expected = UserChoiceDetailsWrapper(
        originalExternalTransactionId: 'TransactionId',
        externalTransactionToken: 'TransactionToken',
        products: <UserChoiceDetailsProductWrapper>[
          UserChoiceDetailsProductWrapper(
              id: 'id1',
              offerToken: 'offerToken1',
              productType: ProductType.inapp),
          UserChoiceDetailsProductWrapper(
              id: 'id2',
              offerToken: 'offerToken2',
              productType: ProductType.inapp),
        ],
      );
      billingClient.hostCallbackHandler.alternativeBillingListener!(expected);
      expect(completer.isCompleted, isTrue);
      expect(await completer.future, expected);
    });

    test('UserChoiceDetailsWrapper searilization check', () async {
      // Test ensures that changes to UserChoiceDetailsWrapper#toJson are
      // compatible with code in Translator.java.
      const String transactionIdKey = 'originalExternalTransactionId';
      const String transactionTokenKey = 'externalTransactionToken';
      const String productsKey = 'products';
      const String productIdKey = 'id';
      const String productOfferTokenKey = 'offerToken';
      const String productTypeKey = 'productType';

      const UserChoiceDetailsProductWrapper expectedProduct1 =
          UserChoiceDetailsProductWrapper(
              id: 'id1',
              offerToken: 'offerToken1',
              productType: ProductType.inapp);
      const UserChoiceDetailsProductWrapper expectedProduct2 =
          UserChoiceDetailsProductWrapper(
              id: 'id2',
              offerToken: 'offerToken2',
              productType: ProductType.inapp);
      const UserChoiceDetailsWrapper expected = UserChoiceDetailsWrapper(
        originalExternalTransactionId: 'TransactionId',
        externalTransactionToken: 'TransactionToken',
        products: <UserChoiceDetailsProductWrapper>[
          expectedProduct1,
          expectedProduct2,
        ],
      );
      final Map<String, dynamic> detailsJson = expected.toJson();
      expect(detailsJson.keys, contains(transactionIdKey));
      expect(detailsJson.keys, contains(transactionTokenKey));
      expect(detailsJson.keys, contains(productsKey));

      final Map<String, dynamic> productJson = expectedProduct1.toJson();
      expect(productJson, contains(productIdKey));
      expect(productJson, contains(productOfferTokenKey));
      expect(productJson, contains(productTypeKey));
    });
  });

  test('endConnection', () async {
    verifyNever(mockApi.endConnection());
    await billingClient.endConnection();
    verify(mockApi.endConnection()).called(1);
  });

  group('queryProductDetails', () {
    test('handles empty productDetails', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.developerError;
      when(mockApi.queryProductDetailsAsync(any))
          .thenAnswer((_) async => PlatformProductDetailsResponse(
                billingResult: PlatformBillingResult(
                    responseCode:
                        const BillingResponseConverter().toJson(responseCode),
                    debugMessage: debugMessage),
                productDetails: <PlatformProductDetails>[],
              ));

      final ProductDetailsResponseWrapper response = await billingClient
          .queryProductDetails(productList: <ProductWrapper>[
        const ProductWrapper(
            productId: 'invalid', productType: ProductType.inapp)
      ]);

      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      expect(response.billingResult, equals(billingResult));
      expect(response.productDetailsList, isEmpty);
    });

    test('returns ProductDetailsResponseWrapper', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      when(mockApi.queryProductDetailsAsync(any))
          .thenAnswer((_) async => PlatformProductDetailsResponse(
                billingResult: PlatformBillingResult(
                    responseCode:
                        const BillingResponseConverter().toJson(responseCode),
                    debugMessage: debugMessage),
                productDetails: <PlatformProductDetails>[
                  convertToPigeonProductDetails(dummyOneTimeProductDetails)
                ],
              ));

      final ProductDetailsResponseWrapper response =
          await billingClient.queryProductDetails(
        productList: <ProductWrapper>[
          const ProductWrapper(
              productId: 'invalid', productType: ProductType.inapp),
        ],
      );

      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      expect(response.billingResult, equals(billingResult));
      expect(response.productDetailsList, contains(dummyOneTimeProductDetails));
    });
  });

  group('launchBillingFlow', () {
    test('serializes and deserializes data', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String profileId = 'hashedProfileId';

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId),
          equals(expectedBillingResult));

      final VerificationResult result =
          verify(mockApi.launchBillingFlow(captureAny));
      final PlatformBillingFlowParams params =
          result.captured.single as PlatformBillingFlowParams;
      expect(params.product, equals(productDetails.productId));
      expect(params.accountId, equals(accountId));
      expect(params.obfuscatedProfileId, equals(profileId));
    });

    test(
        'Change subscription throws assertion error `oldProduct` and `purchaseToken` has different nullability',
        () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String profileId = 'hashedProfileId';

      expect(
          billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId,
              oldProduct: dummyOldPurchase.products.first),
          throwsAssertionError);

      expect(
          billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId,
              purchaseToken: dummyOldPurchase.purchaseToken),
          throwsAssertionError);
    });

    test(
        'serializes and deserializes data on change subscription without proration',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String profileId = 'hashedProfileId';

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId,
              oldProduct: dummyOldPurchase.products.first,
              purchaseToken: dummyOldPurchase.purchaseToken),
          equals(expectedBillingResult));
      final VerificationResult result =
          verify(mockApi.launchBillingFlow(captureAny));
      final PlatformBillingFlowParams params =
          result.captured.single as PlatformBillingFlowParams;
      expect(params.product, equals(productDetails.productId));
      expect(params.accountId, equals(accountId));
      expect(params.oldProduct, equals(dummyOldPurchase.products.first));
      expect(params.purchaseToken, equals(dummyOldPurchase.purchaseToken));
      expect(params.obfuscatedProfileId, equals(profileId));
    });

    test(
        'serializes and deserializes data on change subscription with proration',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String profileId = 'hashedProfileId';
      const ProrationMode prorationMode =
          ProrationMode.immediateAndChargeProratedPrice;

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId,
              oldProduct: dummyOldPurchase.products.first,
              prorationMode: prorationMode,
              purchaseToken: dummyOldPurchase.purchaseToken),
          equals(expectedBillingResult));
      final VerificationResult result =
          verify(mockApi.launchBillingFlow(captureAny));
      final PlatformBillingFlowParams params =
          result.captured.single as PlatformBillingFlowParams;
      expect(params.product, equals(productDetails.productId));
      expect(params.accountId, equals(accountId));
      expect(params.oldProduct, equals(dummyOldPurchase.products.first));
      expect(params.obfuscatedProfileId, equals(profileId));
      expect(params.purchaseToken, equals(dummyOldPurchase.purchaseToken));
      expect(params.prorationMode,
          const ProrationModeConverter().toJson(prorationMode));
    });

    test(
        'serializes and deserializes data when using immediateAndChargeFullPrice',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String profileId = 'hashedProfileId';
      const ProrationMode prorationMode =
          ProrationMode.immediateAndChargeFullPrice;

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId,
              oldProduct: dummyOldPurchase.products.first,
              prorationMode: prorationMode,
              purchaseToken: dummyOldPurchase.purchaseToken),
          equals(expectedBillingResult));
      final VerificationResult result =
          verify(mockApi.launchBillingFlow(captureAny));
      final PlatformBillingFlowParams params =
          result.captured.single as PlatformBillingFlowParams;
      expect(params.product, equals(productDetails.productId));
      expect(params.accountId, equals(accountId));
      expect(params.oldProduct, equals(dummyOldPurchase.products.first));
      expect(params.obfuscatedProfileId, equals(profileId));
      expect(params.purchaseToken, equals(dummyOldPurchase.purchaseToken));
      expect(params.prorationMode,
          const ProrationModeConverter().toJson(prorationMode));
    });

    test('handles null accountId', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId),
          equals(expectedBillingResult));
      final VerificationResult result =
          verify(mockApi.launchBillingFlow(captureAny));
      final PlatformBillingFlowParams params =
          result.captured.single as PlatformBillingFlowParams;
      expect(params.product, equals(productDetails.productId));
      expect(params.accountId, isNull);
    });
  });

  group('queryPurchases', () {
    test('serializes and deserializes data', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      final List<PurchaseWrapper> expectedList = <PurchaseWrapper>[
        dummyPurchase
      ];
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.queryPurchasesAsync(any))
          .thenAnswer((_) async => PlatformPurchasesResponse(
                billingResult: PlatformBillingResult(
                    responseCode:
                        const BillingResponseConverter().toJson(expectedCode),
                    debugMessage: debugMessage),
                purchases: expectedList
                    .map((PurchaseWrapper purchase) =>
                        convertToPigeonPurchase(purchase))
                    .toList(),
              ));

      final PurchasesResultWrapper response =
          await billingClient.queryPurchases(ProductType.inapp);

      expect(response.billingResult, equals(expectedBillingResult));
      expect(response.responseCode, equals(expectedCode));
      expect(response.purchasesList, equals(expectedList));
    });

    test('handles empty purchases', () async {
      const BillingResponse expectedCode = BillingResponse.userCanceled;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.queryPurchasesAsync(any))
          .thenAnswer((_) async => PlatformPurchasesResponse(
                billingResult: PlatformBillingResult(
                    responseCode:
                        const BillingResponseConverter().toJson(expectedCode),
                    debugMessage: debugMessage),
                purchases: <PlatformPurchase>[],
              ));

      final PurchasesResultWrapper response =
          await billingClient.queryPurchases(ProductType.inapp);

      expect(response.billingResult, equals(expectedBillingResult));
      // The top-level response code is hard-coded to "ok", as the underlying
      // API no longer returns it.
      expect(response.responseCode, BillingResponse.ok);
      expect(response.purchasesList, isEmpty);
    });
  });

  group('queryPurchaseHistory', () {
    test('serializes and deserializes data', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      final List<PurchaseHistoryRecordWrapper> expectedList =
          <PurchaseHistoryRecordWrapper>[
        dummyPurchaseHistoryRecord,
      ];
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.queryPurchaseHistoryAsync(any))
          .thenAnswer((_) async => PlatformPurchaseHistoryResponse(
                billingResult: PlatformBillingResult(
                    responseCode:
                        const BillingResponseConverter().toJson(expectedCode),
                    debugMessage: debugMessage),
                purchases: expectedList
                    .map(platformPurchaseHistoryRecordFromWrapper)
                    .toList(),
              ));

      final PurchasesHistoryResult response =
          await billingClient.queryPurchaseHistory(ProductType.inapp);
      expect(response.billingResult, equals(expectedBillingResult));
      expect(response.purchaseHistoryRecordList, equals(expectedList));
    });

    test('handles empty purchases', () async {
      const BillingResponse expectedCode = BillingResponse.userCanceled;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.queryPurchaseHistoryAsync(any))
          .thenAnswer((_) async => PlatformPurchaseHistoryResponse(
                billingResult: PlatformBillingResult(
                    responseCode:
                        const BillingResponseConverter().toJson(expectedCode),
                    debugMessage: debugMessage),
                purchases: <PlatformPurchaseHistoryRecord>[],
              ));

      final PurchasesHistoryResult response =
          await billingClient.queryPurchaseHistory(ProductType.inapp);

      expect(response.billingResult, equals(expectedBillingResult));
      expect(response.purchaseHistoryRecordList, isEmpty);
    });
  });

  group('consume purchases', () {
    test('consume purchase async success', () async {
      const String token = 'dummy token';
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.consumeAsync(token)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));

      final BillingResultWrapper billingResult =
          await billingClient.consumeAsync(token);

      expect(billingResult, equals(expectedBillingResult));
    });
  });

  group('acknowledge purchases', () {
    test('acknowledge purchase success', () async {
      const String token = 'dummy token';
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.acknowledgePurchase(token)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));

      final BillingResultWrapper billingResult =
          await billingClient.acknowledgePurchase(token);

      expect(billingResult, equals(expectedBillingResult));
    });
  });

  group('isFeatureSupported', () {
    test('isFeatureSupported returns false', () async {
      when(mockApi.isFeatureSupported('subscriptions'))
          .thenAnswer((_) async => false);
      final bool isSupported = await billingClient
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isFalse);
    });

    test('isFeatureSupported returns true', () async {
      when(mockApi.isFeatureSupported('subscriptions'))
          .thenAnswer((_) async => true);
      final bool isSupported = await billingClient
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isTrue);
    });
  });

  group('billingConfig', () {
    test('billingConfig returns object', () async {
      const BillingConfigWrapper expected = BillingConfigWrapper(
          countryCode: 'US',
          responseCode: BillingResponse.ok,
          debugMessage: '');
      when(mockApi.getBillingConfigAsync())
          .thenAnswer((_) async => platformBillingConfigFromWrapper(expected));
      final BillingConfigWrapper result =
          await billingClient.getBillingConfig();
      expect(result.countryCode, 'US');
      expect(result, expected);
    });
  });

  group('isAlternativeBillingOnlyAvailable', () {
    test('returns object', () async {
      const BillingResultWrapper expected = BillingResultWrapper(
          responseCode: BillingResponse.ok, debugMessage: 'message');
      when(mockApi.isAlternativeBillingOnlyAvailableAsync()).thenAnswer(
          (_) async => PlatformBillingResult(
              responseCode: 0, debugMessage: expected.debugMessage!));
      final BillingResultWrapper result =
          await billingClient.isAlternativeBillingOnlyAvailable();
      expect(result, expected);
    });
  });

  group('createAlternativeBillingOnlyReportingDetails', () {
    test('returns object', () async {
      const AlternativeBillingOnlyReportingDetailsWrapper expected =
          AlternativeBillingOnlyReportingDetailsWrapper(
              responseCode: BillingResponse.ok,
              debugMessage: 'debug',
              externalTransactionToken: 'abc123youandme');
      when(mockApi.createAlternativeBillingOnlyReportingDetailsAsync())
          .thenAnswer((_) async =>
              platformAlternativeBillingOnlyReportingDetailsFromWrapper(
                  expected));
      final AlternativeBillingOnlyReportingDetailsWrapper result =
          await billingClient.createAlternativeBillingOnlyReportingDetails();
      expect(result, equals(expected));
    });
  });

  group('showAlternativeBillingOnlyInformationDialog', () {
    test('returns object', () async {
      const BillingResultWrapper expected = BillingResultWrapper(
          responseCode: BillingResponse.ok, debugMessage: 'message');
      when(mockApi.showAlternativeBillingOnlyInformationDialog()).thenAnswer(
          (_) async => PlatformBillingResult(
              responseCode: 0, debugMessage: expected.debugMessage!));
      final BillingResultWrapper result =
          await billingClient.showAlternativeBillingOnlyInformationDialog();
      expect(result, expected);
    });
  });
}

PlatformBillingConfigResponse platformBillingConfigFromWrapper(
    BillingConfigWrapper original) {
  return PlatformBillingConfigResponse(
      billingResult: PlatformBillingResult(
        responseCode:
            const BillingResponseConverter().toJson(original.responseCode),
        debugMessage: original.debugMessage!,
      ),
      countryCode: original.countryCode);
}

PlatformAlternativeBillingOnlyReportingDetailsResponse
    platformAlternativeBillingOnlyReportingDetailsFromWrapper(
        AlternativeBillingOnlyReportingDetailsWrapper original) {
  return PlatformAlternativeBillingOnlyReportingDetailsResponse(
      billingResult: PlatformBillingResult(
        responseCode:
            const BillingResponseConverter().toJson(original.responseCode),
        debugMessage: original.debugMessage!,
      ),
      externalTransactionToken: original.externalTransactionToken);
}

PlatformPurchaseHistoryRecord platformPurchaseHistoryRecordFromWrapper(
    PurchaseHistoryRecordWrapper wrapper) {
  return PlatformPurchaseHistoryRecord(
    // For some reason quantity is not currently exposed in
    // PurchaseHistoryRecordWrapper.
    quantity: 99,
    purchaseTime: wrapper.purchaseTime,
    originalJson: wrapper.originalJson,
    purchaseToken: wrapper.purchaseToken,
    signature: wrapper.signature,
    products: wrapper.products,
    developerPayload: wrapper.developerPayload,
  );
}
