// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_config_wrapper.dart';
import 'package:in_app_purchase_android/src/channel.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:mockito/mockito.dart';

import 'billing_client_wrappers/billing_client_wrapper_test.dart';
import 'billing_client_wrappers/billing_client_wrapper_test.mocks.dart';
import 'billing_client_wrappers/purchase_wrapper_test.dart';
import 'stub_in_app_purchase_platform.dart';
import 'test_conversion_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  late MockInAppPurchaseApi mockApi;
  late InAppPurchaseAndroidPlatformAddition iapAndroidPlatformAddition;
  const String onBillingServiceDisconnectedCallback =
      'BillingClientStateListener#onBillingServiceDisconnected()';
  late BillingClientManager manager;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, stubPlatform.fakeMethodCallHandler);
  });

  setUp(() {
    widgets.WidgetsFlutterBinding.ensureInitialized();
    mockApi = MockInAppPurchaseApi();
    when(mockApi.startConnection(any, any)).thenAnswer(
        (_) async => PlatformBillingResult(responseCode: 0, debugMessage: ''));
    manager = BillingClientManager(
        billingClientFactory: (PurchasesUpdatedListener listener) =>
            BillingClient(listener, api: mockApi));
    iapAndroidPlatformAddition = InAppPurchaseAndroidPlatformAddition(manager);
  });

  group('consume purchases', () {
    test('consume purchase async success', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.consumeAsync(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));
      final BillingResultWrapper billingResultWrapper =
          await iapAndroidPlatformAddition.consumePurchase(
              GooglePlayPurchaseDetails.fromPurchase(dummyPurchase).first);

      expect(billingResultWrapper, equals(expectedBillingResult));
    });
  });

  group('billingConfig', () {
    test('getCountryCode success', () async {
      const String expectedCountryCode = 'US';
      const BillingConfigWrapper expected = BillingConfigWrapper(
          countryCode: expectedCountryCode,
          responseCode: BillingResponse.ok,
          debugMessage: 'dummy message');

      stubPlatform.addResponse(
        name: BillingClient.getBillingConfigMethodString,
        value: buildBillingConfigMap(expected),
      );
      final String countryCode =
          await iapAndroidPlatformAddition.getCountryCode();

      expect(countryCode, equals(expectedCountryCode));
    });
  });

  group('setBillingChoice', () {
    test('setAlternativeBillingOnlyState', () async {
      stubPlatform.reset();
      clearInteractions(mockApi);
      await iapAndroidPlatformAddition
          .setBillingChoice(BillingChoiceMode.alternativeBillingOnly);

      // Fake the disconnect that we would expect from a endConnectionCall.
      await manager.client.callHandler(
        const MethodCall(onBillingServiceDisconnectedCallback,
            <String, dynamic>{'handle': 0}),
      );
      // Verify that after connection ended reconnect was called.
      final VerificationResult result =
          verify(mockApi.startConnection(any, captureAny));
      expect(result.callCount, equals(2));
      expect(result.captured.last,
          PlatformBillingChoiceMode.alternativeBillingOnly);
    });

    test('setPlayBillingState', () async {
      stubPlatform.reset();
      clearInteractions(mockApi);
      await iapAndroidPlatformAddition
          .setBillingChoice(BillingChoiceMode.playBillingOnly);

      // Fake the disconnect that we would expect from a endConnectionCall.
      await manager.client.callHandler(
        const MethodCall(onBillingServiceDisconnectedCallback,
            <String, dynamic>{'handle': 0}),
      );
      // Verify that after connection ended reconnect was called.
      final VerificationResult result =
          verify(mockApi.startConnection(any, captureAny));
      expect(result.callCount, equals(2));
      expect(result.captured.last, PlatformBillingChoiceMode.playBillingOnly);
    });
  });

  group('isAlternativeBillingOnlyAvailable', () {
    test('isAlternativeBillingOnlyAvailable success', () async {
      const BillingResultWrapper expected = BillingResultWrapper(
          responseCode: BillingResponse.ok, debugMessage: 'dummy message');
      when(mockApi.isAlternativeBillingOnlyAvailableAsync()).thenAnswer(
          (_) async => PlatformBillingResult(
              responseCode: 0, debugMessage: expected.debugMessage!));

      final BillingResultWrapper result =
          await iapAndroidPlatformAddition.isAlternativeBillingOnlyAvailable();

      expect(result, equals(expected));
    });
  });

  group('showAlternativeBillingOnlyInformationDialog', () {
    test('showAlternativeBillingOnlyInformationDialog success', () async {
      const BillingResultWrapper expected = BillingResultWrapper(
          responseCode: BillingResponse.ok, debugMessage: 'dummy message');

      when(mockApi.isAlternativeBillingOnlyAvailableAsync())
          .thenAnswer((_) async => convertToPigeonResult(expected));
      when(mockApi.showAlternativeBillingOnlyInformationDialog())
          .thenAnswer((_) async => convertToPigeonResult(expected));
      final BillingResultWrapper result =
          await iapAndroidPlatformAddition.isAlternativeBillingOnlyAvailable();

      expect(result, equals(expected));
    });
  });

  group('queryPastPurchase', () {
    group('queryPurchaseDetails', () {
      const String queryMethodName =
          'BillingClient#queryPurchasesAsync(QueryPurchaseParams, PurchaseResponseListener)';
      test('handles error', () async {
        const String debugMessage = 'dummy message';
        const BillingResponse responseCode = BillingResponse.developerError;
        const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
            responseCode: responseCode, debugMessage: debugMessage);

        stubPlatform
            .addResponse(name: queryMethodName, value: <dynamic, dynamic>{
          'billingResult': buildBillingResultMap(expectedBillingResult),
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'purchasesList': <Map<String, dynamic>>[]
        });
        final QueryPurchaseDetailsResponse response =
            await iapAndroidPlatformAddition.queryPastPurchases();
        expect(response.pastPurchases, isEmpty);
        expect(response.error, isNotNull);
        expect(
            response.error!.message, BillingResponse.developerError.toString());
        expect(response.error!.source, kIAPSource);
      });

      test('returns ProductDetailsResponseWrapper', () async {
        const String debugMessage = 'dummy message';
        const BillingResponse responseCode = BillingResponse.ok;
        const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
            responseCode: responseCode, debugMessage: debugMessage);

        stubPlatform
            .addResponse(name: queryMethodName, value: <String, dynamic>{
          'billingResult': buildBillingResultMap(expectedBillingResult),
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'purchasesList': <Map<String, dynamic>>[
            buildPurchaseMap(dummyPurchase),
          ]
        });

        // Since queryPastPurchases makes 2 platform method calls (one for each ProductType), the result will contain 2 dummyWrapper instead
        // of 1.
        final QueryPurchaseDetailsResponse response =
            await iapAndroidPlatformAddition.queryPastPurchases();
        expect(response.error, isNull);
        expect(response.pastPurchases.first.purchaseID, dummyPurchase.orderId);
      });

      test('should store platform exception in the response', () async {
        const String debugMessage = 'dummy message';

        const BillingResponse responseCode = BillingResponse.developerError;
        const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
            responseCode: responseCode, debugMessage: debugMessage);
        stubPlatform.addResponse(
            name: queryMethodName,
            value: <dynamic, dynamic>{
              'responseCode':
                  const BillingResponseConverter().toJson(responseCode),
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'purchasesList': <Map<String, dynamic>>[]
            },
            additionalStepBeforeReturn: (dynamic _) {
              throw PlatformException(
                code: 'error_code',
                message: 'error_message',
                details: <dynamic, dynamic>{'info': 'error_info'},
              );
            });
        final QueryPurchaseDetailsResponse response =
            await iapAndroidPlatformAddition.queryPastPurchases();
        expect(response.pastPurchases, isEmpty);
        expect(response.error, isNotNull);
        expect(response.error!.code, 'error_code');
        expect(response.error!.message, 'error_message');
        expect(
            response.error!.details, <String, dynamic>{'info': 'error_info'});
      });
    });
  });

  group('isFeatureSupported', () {
    test('isFeatureSupported returns false', () async {
      when(mockApi.isFeatureSupported('subscriptions'))
          .thenAnswer((_) async => false);
      final bool isSupported = await iapAndroidPlatformAddition
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isFalse);
    });

    test('isFeatureSupported returns true', () async {
      when(mockApi.isFeatureSupported('subscriptions'))
          .thenAnswer((_) async => true);
      final bool isSupported = await iapAndroidPlatformAddition
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isTrue);
    });
  });
}
