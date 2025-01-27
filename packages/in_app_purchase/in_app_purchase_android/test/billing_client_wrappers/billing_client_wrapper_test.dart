// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_config_wrapper.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/pending_purchases_params_wrapper.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:in_app_purchase_android/src/pigeon_converters.dart';
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
    when(mockApi.startConnection(any, any, any)).thenAnswer((_) async =>
        PlatformBillingResult(
            responseCode: PlatformBillingResponse.ok, debugMessage: ''));
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

  group('startConnection', () {
    test('returns BillingResultWrapper', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.developerError;
      when(mockApi.startConnection(any, any, any)).thenAnswer(
        (_) async => PlatformBillingResult(
          responseCode: PlatformBillingResponse.developerError,
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
          verify(mockApi.startConnection(captureAny, captureAny, captureAny));
      expect(result.captured[0], 0);
      expect(result.captured[1], PlatformBillingChoiceMode.playBillingOnly);
      expect(
          result.captured[2],
          isA<PlatformPendingPurchasesParams>().having(
              (PlatformPendingPurchasesParams params) =>
                  params.enablePrepaidPlans,
              'enablePrepaidPlans',
              false));
    });

    test('passes billingChoiceMode alternativeBillingOnly when set', () async {
      await billingClient.startConnection(
          onBillingServiceDisconnected: () {},
          billingChoiceMode: BillingChoiceMode.alternativeBillingOnly);

      expect(
          verify(mockApi.startConnection(any, captureAny, any)).captured.first,
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

      expect(
          verify(mockApi.startConnection(any, captureAny, any)).captured.first,
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

    test('passes pendingPurchasesParams when set', () async {
      await billingClient.startConnection(
          onBillingServiceDisconnected: () {},
          billingChoiceMode: BillingChoiceMode.alternativeBillingOnly,
          pendingPurchasesParams:
              const PendingPurchasesParamsWrapper(enablePrepaidPlans: true));

      expect(
          verify(mockApi.startConnection(any, any, captureAny)).captured.first,
          isA<PlatformPendingPurchasesParams>().having(
              (PlatformPendingPurchasesParams params) =>
                  params.enablePrepaidPlans,
              'enablePrepaidPlans',
              true));
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
                    responseCode: PlatformBillingResponse.developerError,
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
                    responseCode: PlatformBillingResponse.ok,
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
      const ReplacementMode replacementMode =
          ReplacementMode.chargeProratedPrice;

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId,
              oldProduct: dummyOldPurchase.products.first,
              replacementMode: replacementMode,
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
      expect(
        params.replacementMode,
        replacementModeFromWrapper(replacementMode),
      );
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
      const ReplacementMode replacementMode = ReplacementMode.chargeFullPrice;

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId,
              oldProduct: dummyOldPurchase.products.first,
              replacementMode: replacementMode,
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
      expect(
        params.replacementMode,
        replacementModeFromWrapper(replacementMode),
      );
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
                    responseCode: PlatformBillingResponse.ok,
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
                    responseCode: PlatformBillingResponse.userCanceled,
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
    test('handles empty purchases', () async {
      const BillingResponse expectedCode = BillingResponse.userCanceled;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.queryPurchaseHistoryAsync(any))
          .thenAnswer((_) async => PlatformPurchaseHistoryResponse(
                billingResult: PlatformBillingResult(
                    responseCode: PlatformBillingResponse.userCanceled,
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
      when(mockApi
              .isFeatureSupported(PlatformBillingClientFeature.subscriptions))
          .thenAnswer((_) async => false);
      final bool isSupported = await billingClient
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isFalse);
    });

    test('isFeatureSupported returns true', () async {
      when(mockApi
              .isFeatureSupported(PlatformBillingClientFeature.subscriptions))
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
              responseCode: PlatformBillingResponse.ok,
              debugMessage: expected.debugMessage!));
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
              responseCode: PlatformBillingResponse.ok,
              debugMessage: expected.debugMessage!));
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
        responseCode: billingResponseFromWrapper(original.responseCode),
        debugMessage: original.debugMessage!,
      ),
      countryCode: original.countryCode);
}

PlatformAlternativeBillingOnlyReportingDetailsResponse
    platformAlternativeBillingOnlyReportingDetailsFromWrapper(
        AlternativeBillingOnlyReportingDetailsWrapper original) {
  return PlatformAlternativeBillingOnlyReportingDetailsResponse(
      billingResult: PlatformBillingResult(
        responseCode: billingResponseFromWrapper(original.responseCode),
        debugMessage: original.debugMessage!,
      ),
      externalTransactionToken: original.externalTransactionToken);
}
