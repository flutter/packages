// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_config_wrapper.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:in_app_purchase_android/src/types/translator.dart';
import 'package:mockito/mockito.dart';

import 'billing_client_wrappers/billing_client_wrapper_test.dart';
import 'billing_client_wrappers/billing_client_wrapper_test.mocks.dart';
import 'billing_client_wrappers/purchase_wrapper_test.dart';
import 'test_conversion_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInAppPurchaseApi mockApi;
  late InAppPurchaseAndroidPlatformAddition iapAndroidPlatformAddition;
  late BillingClientManager manager;

  setUp(() {
    widgets.WidgetsFlutterBinding.ensureInitialized();
    mockApi = MockInAppPurchaseApi();
    when(mockApi.startConnection(any, any, any)).thenAnswer((_) async =>
        PlatformBillingResult(
            responseCode: PlatformBillingResponse.ok, debugMessage: ''));
    manager = BillingClientManager(
        billingClientFactory: (PurchasesUpdatedListener listener,
                UserSelectedAlternativeBillingListener?
                    alternativeBillingListener) =>
            BillingClient(listener, alternativeBillingListener, api: mockApi));
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

      when(mockApi.getBillingConfigAsync())
          .thenAnswer((_) async => platformBillingConfigFromWrapper(expected));
      final String countryCode =
          await iapAndroidPlatformAddition.getCountryCode();

      expect(countryCode, equals(expectedCountryCode));
    });
  });

  group('setBillingChoice', () {
    test('setAlternativeBillingOnlyState', () async {
      clearInteractions(mockApi);
      await iapAndroidPlatformAddition
          .setBillingChoice(BillingChoiceMode.alternativeBillingOnly);

      // Fake the disconnect that we would expect from a endConnectionCall.
      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      // Verify that after connection ended reconnect was called.
      final VerificationResult result =
          verify(mockApi.startConnection(any, captureAny, any));
      expect(result.callCount, equals(2));
      expect(result.captured.last,
          PlatformBillingChoiceMode.alternativeBillingOnly);
    });

    test('setPlayBillingState', () async {
      clearInteractions(mockApi);
      await iapAndroidPlatformAddition
          .setBillingChoice(BillingChoiceMode.playBillingOnly);

      // Fake the disconnect that we would expect from a endConnectionCall.
      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      // Verify that after connection ended reconnect was called.
      final VerificationResult result =
          verify(mockApi.startConnection(any, captureAny, any));
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
              responseCode: PlatformBillingResponse.ok,
              debugMessage: expected.debugMessage!));

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
      test('returns ProductDetailsResponseWrapper', () async {
        const String debugMessage = 'dummy message';
        const PlatformBillingResponse responseCode = PlatformBillingResponse.ok;

        when(mockApi.queryPurchasesAsync(any))
            .thenAnswer((_) async => PlatformPurchasesResponse(
                  billingResult: PlatformBillingResult(
                      responseCode: responseCode, debugMessage: debugMessage),
                  purchases: <PlatformPurchase>[
                    convertToPigeonPurchase(dummyPurchase),
                  ],
                ));

        // Since queryPastPurchases makes 2 platform method calls (one for each ProductType), the result will contain 2 dummyWrapper instead
        // of 1.
        final QueryPurchaseDetailsResponse response =
            await iapAndroidPlatformAddition.queryPastPurchases();
        expect(response.error, isNull);
        expect(response.pastPurchases.first.purchaseID, dummyPurchase.orderId);
      });

      test('should store platform exception in the response', () async {
        when(mockApi.queryPurchasesAsync(any)).thenAnswer((_) async {
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
      when(mockApi
              .isFeatureSupported(PlatformBillingClientFeature.subscriptions))
          .thenAnswer((_) async => false);
      final bool isSupported = await iapAndroidPlatformAddition
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isFalse);
    });

    test('isFeatureSupported returns true', () async {
      when(mockApi
              .isFeatureSupported(PlatformBillingClientFeature.subscriptions))
          .thenAnswer((_) async => true);
      final bool isSupported = await iapAndroidPlatformAddition
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isTrue);
    });
  });

  group('userChoiceDetails', () {
    test('called', () async {
      final Future<GooglePlayUserChoiceDetails> futureDetails =
          iapAndroidPlatformAddition.userChoiceDetailsStream.first;
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
      manager.onUserChoiceAlternativeBilling(expected);
      expect(
          await futureDetails, Translator.convertToUserChoiceDetails(expected));
    });
  });
}
