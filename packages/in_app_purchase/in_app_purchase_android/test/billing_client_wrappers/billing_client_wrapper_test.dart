// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/channel.dart';

import '../stub_in_app_purchase_platform.dart';
import 'product_details_wrapper_test.dart';
import 'purchase_wrapper_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  late BillingClient billingClient;

  setUpAll(() => _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
      .defaultBinaryMessenger
      .setMockMethodCallHandler(channel, stubPlatform.fakeMethodCallHandler));

  setUp(() {
    billingClient = BillingClient((PurchasesResultWrapper _) {});
    stubPlatform.reset();
  });

  group('isReady', () {
    test('true', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: true);
      expect(await billingClient.isReady(), isTrue);
    });

    test('false', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: false);
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
  });

  group('startConnection', () {
    const String methodName =
        'BillingClient#startConnection(BillingClientStateListener)';
    test('returns BillingResultWrapper', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.developerError;
      stubPlatform.addResponse(
        name: methodName,
        value: <String, dynamic>{
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
      );

      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      expect(
          await billingClient.startConnection(
              onBillingServiceDisconnected: () {}),
          equals(billingResult));
    });

    test('passes handle to onBillingServiceDisconnected', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.developerError;
      stubPlatform.addResponse(
        name: methodName,
        value: <String, dynamic>{
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
      );
      await billingClient.startConnection(onBillingServiceDisconnected: () {});
      final MethodCall call = stubPlatform.previousCallMatching(methodName);
      expect(call.arguments, equals(<dynamic, dynamic>{'handle': 0}));
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: methodName,
      );

      expect(
          await billingClient.startConnection(
              onBillingServiceDisconnected: () {}),
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
    });
  });

  test('endConnection', () async {
    const String endConnectionName = 'BillingClient#endConnection()';
    expect(stubPlatform.countPreviousCalls(endConnectionName), equals(0));
    stubPlatform.addResponse(name: endConnectionName);
    await billingClient.endConnection();
    expect(stubPlatform.countPreviousCalls(endConnectionName), equals(1));
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
    const String consumeMethodName =
        'BillingClient#consumeAsync(ConsumeParams, ConsumeResponseListener)';
    test('consume purchase async success', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: consumeMethodName,
          value: buildBillingResultMap(expectedBillingResult));

      final BillingResultWrapper billingResult =
          await billingClient.consumeAsync('dummy token');

      expect(billingResult, equals(expectedBillingResult));
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: consumeMethodName,
      );
      final BillingResultWrapper billingResult =
          await billingClient.consumeAsync('dummy token');

      expect(
          billingResult,
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
    });
  });

  group('acknowledge purchases', () {
    const String acknowledgeMethodName =
        'BillingClient#acknowledgePurchase(AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener)';
    test('acknowledge purchase success', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: acknowledgeMethodName,
          value: buildBillingResultMap(expectedBillingResult));

      final BillingResultWrapper billingResult =
          await billingClient.acknowledgePurchase('dummy token');

      expect(billingResult, equals(expectedBillingResult));
    });

    test('handles method channel returning null', () async {
      stubPlatform.addResponse(
        name: acknowledgeMethodName,
      );
      final BillingResultWrapper billingResult =
          await billingClient.acknowledgePurchase('dummy token');

      expect(
          billingResult,
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
    });
  });

  group('isFeatureSupported', () {
    const String isFeatureSupportedMethodName =
        'BillingClient#isFeatureSupported(String)';
    test('isFeatureSupported returns false', () async {
      late Map<Object?, Object?> arguments;
      stubPlatform.addResponse(
        name: isFeatureSupportedMethodName,
        value: false,
        additionalStepBeforeReturn: (dynamic value) =>
            arguments = value as Map<dynamic, dynamic>,
      );
      final bool isSupported = await billingClient
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isFalse);
      expect(arguments['feature'], equals('subscriptions'));
    });

    test('isFeatureSupported returns true', () async {
      late Map<Object?, Object?> arguments;
      stubPlatform.addResponse(
        name: isFeatureSupportedMethodName,
        value: true,
        additionalStepBeforeReturn: (dynamic value) =>
            arguments = value as Map<dynamic, dynamic>,
      );
      final bool isSupported = await billingClient
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isTrue);
      expect(arguments['feature'], equals('subscriptions'));
    });
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
