// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_config_wrapper.dart';
import 'package:in_app_purchase_android/src/channel.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../stub_in_app_purchase_platform.dart';
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

  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  late MockInAppPurchaseApi mockApi;
  late BillingClient billingClient;

  setUpAll(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, stubPlatform.fakeMethodCallHandler));

  setUp(() {
    mockApi = MockInAppPurchaseApi();
    when(mockApi.startConnection(any, any)).thenAnswer(
        (_) async => PlatformBillingResult(responseCode: 0, debugMessage: ''));
    billingClient = BillingClient((PurchasesResultWrapper _) {}, api: mockApi);
    stubPlatform.reset();
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

    test('passes billingChoiceMode when set', () async {
      await billingClient.startConnection(
          onBillingServiceDisconnected: () {},
          billingChoiceMode: BillingChoiceMode.alternativeBillingOnly);

      expect(verify(mockApi.startConnection(any, captureAny)).captured.first,
          PlatformBillingChoiceMode.alternativeBillingOnly);
    });
  });

  test('endConnection', () async {
    verifyNever(mockApi.endConnection());
    await billingClient.endConnection();
    verify(mockApi.endConnection()).called(1);
  });

  group('queryProductDetails', () {
    const String queryMethodName =
        'BillingClient#queryProductDetailsAsync(QueryProductDetailsParams, ProductDetailsResponseListener)';

    test('handles empty productDetails', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.developerError;
      stubPlatform.addResponse(name: queryMethodName, value: <dynamic, dynamic>{
        'billingResult': <String, dynamic>{
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
        'productDetailsList': <Map<String, dynamic>>[]
      });

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
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'billingResult': <String, dynamic>{
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
        'productDetailsList': <Map<String, dynamic>>[
          buildProductMap(dummyOneTimeProductDetails)
        ],
      });

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

    test('handles null method channel response', () async {
      stubPlatform.addResponse(name: queryMethodName);

      final ProductDetailsResponseWrapper response =
          await billingClient.queryProductDetails(
        productList: <ProductWrapper>[
          const ProductWrapper(
              productId: 'invalid', productType: ProductType.inapp),
        ],
      );

      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: BillingResponse.error,
          debugMessage: kInvalidBillingResultErrorMessage);
      expect(response.billingResult, equals(billingResult));
      expect(response.productDetailsList, isEmpty);
    });
  });

  group('launchBillingFlow', () {
    const String launchMethodName =
        'BillingClient#launchBillingFlow(Activity, BillingFlowParams)';

    test('serializes and deserializes data', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: launchMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String profileId = 'hashedProfileId';

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId,
              accountId: accountId,
              obfuscatedProfileId: profileId),
          equals(expectedBillingResult));
      final Map<dynamic, dynamic> arguments = stubPlatform
          .previousCallMatching(launchMethodName)
          .arguments as Map<dynamic, dynamic>;
      expect(arguments['product'], equals(productDetails.productId));
      expect(arguments['accountId'], equals(accountId));
      expect(arguments['obfuscatedProfileId'], equals(profileId));
    });

    test(
        'Change subscription throws assertion error `oldProduct` and `purchaseToken` has different nullability',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: launchMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
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
      stubPlatform.addResponse(
        name: launchMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
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
      final Map<dynamic, dynamic> arguments = stubPlatform
          .previousCallMatching(launchMethodName)
          .arguments as Map<dynamic, dynamic>;
      expect(arguments['product'], equals(productDetails.productId));
      expect(arguments['accountId'], equals(accountId));
      expect(arguments['oldProduct'], equals(dummyOldPurchase.products.first));
      expect(
          arguments['purchaseToken'], equals(dummyOldPurchase.purchaseToken));
      expect(arguments['obfuscatedProfileId'], equals(profileId));
    });

    test(
        'serializes and deserializes data on change subscription with proration',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: launchMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
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
      final Map<dynamic, dynamic> arguments = stubPlatform
          .previousCallMatching(launchMethodName)
          .arguments as Map<dynamic, dynamic>;
      expect(arguments['product'], equals(productDetails.productId));
      expect(arguments['accountId'], equals(accountId));
      expect(arguments['oldProduct'], equals(dummyOldPurchase.products.first));
      expect(arguments['obfuscatedProfileId'], equals(profileId));
      expect(
          arguments['purchaseToken'], equals(dummyOldPurchase.purchaseToken));
      expect(arguments['prorationMode'],
          const ProrationModeConverter().toJson(prorationMode));
    });

    test(
        'serializes and deserializes data when using immediateAndChargeFullPrice',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: launchMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
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
      final Map<dynamic, dynamic> arguments = stubPlatform
          .previousCallMatching(launchMethodName)
          .arguments as Map<dynamic, dynamic>;
      expect(arguments['product'], equals(productDetails.productId));
      expect(arguments['accountId'], equals(accountId));
      expect(arguments['oldProduct'], equals(dummyOldPurchase.products.first));
      expect(arguments['obfuscatedProfileId'], equals(profileId));
      expect(
          arguments['purchaseToken'], equals(dummyOldPurchase.purchaseToken));
      expect(arguments['prorationMode'],
          const ProrationModeConverter().toJson(prorationMode));
    });

    test('handles null accountId', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: launchMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;

      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId),
          equals(expectedBillingResult));
      final Map<dynamic, dynamic> arguments = stubPlatform
          .previousCallMatching(launchMethodName)
          .arguments as Map<dynamic, dynamic>;
      expect(arguments['product'], equals(productDetails.productId));
      expect(arguments['accountId'], isNull);
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: launchMethodName,
      );
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      expect(
          await billingClient.launchBillingFlow(
              product: productDetails.productId),
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
    });
  });

  group('queryPurchases', () {
    const String queryPurchasesMethodName =
        'BillingClient#queryPurchasesAsync(QueryPurchaseParams, PurchaseResponseListener)';

    test('serializes and deserializes data', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      final List<PurchaseWrapper> expectedList = <PurchaseWrapper>[
        dummyPurchase
      ];
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform
          .addResponse(name: queryPurchasesMethodName, value: <String, dynamic>{
        'billingResult': buildBillingResultMap(expectedBillingResult),
        'responseCode': const BillingResponseConverter().toJson(expectedCode),
        'purchasesList': expectedList
            .map((PurchaseWrapper purchase) => buildPurchaseMap(purchase))
            .toList(),
      });

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
      stubPlatform
          .addResponse(name: queryPurchasesMethodName, value: <String, dynamic>{
        'billingResult': buildBillingResultMap(expectedBillingResult),
        'responseCode': const BillingResponseConverter().toJson(expectedCode),
        'purchasesList': <dynamic>[],
      });

      final PurchasesResultWrapper response =
          await billingClient.queryPurchases(ProductType.inapp);

      expect(response.billingResult, equals(expectedBillingResult));
      expect(response.responseCode, equals(expectedCode));
      expect(response.purchasesList, isEmpty);
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: queryPurchasesMethodName,
      );
      final PurchasesResultWrapper response =
          await billingClient.queryPurchases(ProductType.inapp);

      expect(
          response.billingResult,
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
      expect(response.responseCode, BillingResponse.error);
      expect(response.purchasesList, isEmpty);
    });
  });

  group('queryPurchaseHistory', () {
    const String queryPurchaseHistoryMethodName =
        'BillingClient#queryPurchaseHistoryAsync(QueryPurchaseHistoryParams, PurchaseHistoryResponseListener)';

    test('serializes and deserializes data', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      final List<PurchaseHistoryRecordWrapper> expectedList =
          <PurchaseHistoryRecordWrapper>[
        dummyPurchaseHistoryRecord,
      ];
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: queryPurchaseHistoryMethodName,
          value: <String, dynamic>{
            'billingResult': buildBillingResultMap(expectedBillingResult),
            'purchaseHistoryRecordList': expectedList
                .map((PurchaseHistoryRecordWrapper purchaseHistoryRecord) =>
                    buildPurchaseHistoryRecordMap(purchaseHistoryRecord))
                .toList(),
          });

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
      stubPlatform.addResponse(
          name: queryPurchaseHistoryMethodName,
          value: <dynamic, dynamic>{
            'billingResult': buildBillingResultMap(expectedBillingResult),
            'purchaseHistoryRecordList': <dynamic>[],
          });

      final PurchasesHistoryResult response =
          await billingClient.queryPurchaseHistory(ProductType.inapp);

      expect(response.billingResult, equals(expectedBillingResult));
      expect(response.purchaseHistoryRecordList, isEmpty);
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: queryPurchaseHistoryMethodName,
      );
      final PurchasesHistoryResult response =
          await billingClient.queryPurchaseHistory(ProductType.inapp);

      expect(
          response.billingResult,
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
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
      stubPlatform.addResponse(
        name: BillingClient.getBillingConfigMethodString,
        value: buildBillingConfigMap(expected),
      );
      final BillingConfigWrapper result =
          await billingClient.getBillingConfig();
      expect(result.countryCode, 'US');
      expect(result, expected);
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: BillingClient.getBillingConfigMethodString,
      );
      final BillingConfigWrapper result =
          await billingClient.getBillingConfig();
      expect(
          result,
          equals(const BillingConfigWrapper(
            responseCode: BillingResponse.error,
            debugMessage: kInvalidBillingConfigErrorMessage,
          )));
    });
  });

  group('isAlternativeBillingOnlyAvailable', () {
    test('returns object', () async {
      const BillingResultWrapper expected = BillingResultWrapper(
          responseCode: BillingResponse.ok, debugMessage: 'message');
      when(mockApi.isAlternativeBillingOnlyAvailable()).thenAnswer((_) async =>
          PlatformBillingResult(
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
      stubPlatform.addResponse(
          name: BillingClient
              .createAlternativeBillingOnlyReportingDetailsMethodString,
          value: buildAlternativeBillingOnlyReportingDetailsMap(expected));
      final AlternativeBillingOnlyReportingDetailsWrapper result =
          await billingClient.createAlternativeBillingOnlyReportingDetails();
      expect(result, equals(expected));
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: BillingClient
            .createAlternativeBillingOnlyReportingDetailsMethodString,
      );
      final AlternativeBillingOnlyReportingDetailsWrapper result =
          await billingClient.createAlternativeBillingOnlyReportingDetails();
      expect(result.responseCode, BillingResponse.error);
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

Map<String, dynamic> buildBillingConfigMap(BillingConfigWrapper original) {
  return <String, dynamic>{
    'responseCode':
        const BillingResponseConverter().toJson(original.responseCode),
    'debugMessage': original.debugMessage,
    'countryCode': original.countryCode,
  };
}

Map<String, dynamic> buildAlternativeBillingOnlyReportingDetailsMap(
    AlternativeBillingOnlyReportingDetailsWrapper original) {
  return <String, dynamic>{
    'responseCode':
        const BillingResponseConverter().toJson(original.responseCode),
    'debugMessage': original.debugMessage,
    // from: io/flutter/plugins/inapppurchase/Translator.java
    'externalTransactionToken': original.externalTransactionToken,
  };
}
