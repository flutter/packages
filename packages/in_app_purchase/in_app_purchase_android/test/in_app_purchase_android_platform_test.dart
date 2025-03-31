// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_config_wrapper.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:mockito/mockito.dart';

import 'billing_client_wrappers/billing_client_wrapper_test.dart';
import 'billing_client_wrappers/billing_client_wrapper_test.mocks.dart';
import 'billing_client_wrappers/product_details_wrapper_test.dart';
import 'billing_client_wrappers/purchase_wrapper_test.dart';
import 'test_conversion_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInAppPurchaseApi mockApi;
  late InAppPurchaseAndroidPlatform iapAndroidPlatform;

  setUp(() {
    widgets.WidgetsFlutterBinding.ensureInitialized();

    mockApi = MockInAppPurchaseApi();
    when(mockApi.startConnection(any, any, any)).thenAnswer((_) async =>
        PlatformBillingResult(
            responseCode: PlatformBillingResponse.ok, debugMessage: ''));
    iapAndroidPlatform = InAppPurchaseAndroidPlatform(
        manager: BillingClientManager(
            billingClientFactory: (PurchasesUpdatedListener listener,
                    UserSelectedAlternativeBillingListener?
                        alternativeBillingListener) =>
                BillingClient(listener, alternativeBillingListener,
                    api: mockApi)));
    InAppPurchasePlatform.instance = iapAndroidPlatform;
  });

  group('connection management', () {
    test('connects on initialization', () {
      //await iapAndroidPlatform.isAvailable();
      verify(mockApi.startConnection(any, any, any)).called(1);
    });

    test('re-connects when client sends onBillingServiceDisconnected', () {
      iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
          .onBillingServiceDisconnected(0);
      verify(mockApi.startConnection(any, any, any)).called(2);
    });

    test(
        're-connects when operation returns BillingResponse.clientDisconnected',
        () async {
      when(mockApi.acknowledgePurchase(any)).thenAnswer(
        (_) async => PlatformBillingResult(
            responseCode: PlatformBillingResponse.serviceDisconnected,
            debugMessage: 'disconnected'),
      );
      when(mockApi.startConnection(any, any, any)).thenAnswer((_) async {
        // Change the acknowledgePurchase response to success for the next call.
        when(mockApi.acknowledgePurchase(any)).thenAnswer(
          (_) async => PlatformBillingResult(
              responseCode: PlatformBillingResponse.ok,
              debugMessage: 'disconnected'),
        );
        return PlatformBillingResult(
            responseCode: PlatformBillingResponse.ok, debugMessage: '');
      });
      final PurchaseDetails purchase =
          GooglePlayPurchaseDetails.fromPurchase(dummyUnacknowledgedPurchase)
              .first;
      final BillingResultWrapper result =
          await iapAndroidPlatform.completePurchase(purchase);
      verify(mockApi.acknowledgePurchase(any)).called(2);
      verify(mockApi.startConnection(any, any, any)).called(2);
      expect(result.responseCode, equals(BillingResponse.ok));
    });
  });

  group('isAvailable', () {
    test('true', () async {
      when(mockApi.isReady()).thenAnswer((_) async => true);
      expect(await iapAndroidPlatform.isAvailable(), isTrue);
    });

    test('false', () async {
      when(mockApi.isReady()).thenAnswer((_) async => false);
      expect(await iapAndroidPlatform.isAvailable(), isFalse);
    });
  });

  group('queryProductDetails', () {
    test('handles empty productDetails', () async {
      const String debugMessage = 'dummy message';
      const PlatformBillingResponse responseCode = PlatformBillingResponse.ok;
      when(mockApi.queryProductDetailsAsync(any))
          .thenAnswer((_) async => PlatformProductDetailsResponse(
                billingResult: PlatformBillingResult(
                    responseCode: responseCode, debugMessage: debugMessage),
                productDetails: <PlatformProductDetails>[],
              ));

      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{''});
      expect(response.productDetails, isEmpty);
    });

    test('should get correct product details', () async {
      const String debugMessage = 'dummy message';
      const PlatformBillingResponse responseCode = PlatformBillingResponse.ok;
      when(mockApi.queryProductDetailsAsync(any))
          .thenAnswer((_) async => PlatformProductDetailsResponse(
                billingResult: PlatformBillingResult(
                    responseCode: responseCode, debugMessage: debugMessage),
                productDetails: <PlatformProductDetails>[
                  convertToPigeonProductDetails(dummyOneTimeProductDetails)
                ],
              ));
      // Since queryProductDetails makes 2 platform method calls (one for each ProductType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{'valid'});
      expect(response.productDetails.first.title,
          dummyOneTimeProductDetails.title);
      expect(response.productDetails.first.description,
          dummyOneTimeProductDetails.description);
      expect(
          response.productDetails.first.price,
          dummyOneTimeProductDetails
              .oneTimePurchaseOfferDetails?.formattedPrice);
      expect(response.productDetails.first.currencySymbol, r'$');
    });

    test('should get the correct notFoundIDs', () async {
      const String debugMessage = 'dummy message';
      const PlatformBillingResponse responseCode = PlatformBillingResponse.ok;
      when(mockApi.queryProductDetailsAsync(any))
          .thenAnswer((_) async => PlatformProductDetailsResponse(
                billingResult: PlatformBillingResult(
                    responseCode: responseCode, debugMessage: debugMessage),
                productDetails: <PlatformProductDetails>[
                  convertToPigeonProductDetails(dummyOneTimeProductDetails)
                ],
              ));
      // Since queryProductDetails makes 2 platform method calls (one for each ProductType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{'invalid'});
      expect(response.notFoundIDs.first, 'invalid');
    });

    test(
        'should have error stored in the response when platform exception is thrown',
        () async {
      when(mockApi.queryProductDetailsAsync(any)).thenAnswer((_) async {
        throw PlatformException(
          code: 'error_code',
          message: 'error_message',
          details: <dynamic, dynamic>{'info': 'error_info'},
        );
      });
      // Since queryProductDetails makes 2 platform method calls (one for each ProductType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{'invalid'});
      expect(response.notFoundIDs, <String>['invalid']);
      expect(response.productDetails, isEmpty);
      expect(response.error, isNotNull);
      expect(response.error!.source, kIAPSource);
      expect(response.error!.code, 'error_code');
      expect(response.error!.message, 'error_message');
      expect(response.error!.details, <String, dynamic>{'info': 'error_info'});
    });
  });

  group('restorePurchases', () {
    test('should store platform exception in the response', () async {
      when(mockApi.queryPurchasesAsync(any)).thenAnswer((_) async {
        throw PlatformException(
          code: 'error_code',
          message: 'error_message',
          details: <dynamic, dynamic>{'info': 'error_info'},
        );
      });

      expect(
        iapAndroidPlatform.restorePurchases(),
        throwsA(
          isA<PlatformException>()
              .having((PlatformException e) => e.code, 'code', 'error_code')
              .having((PlatformException e) => e.message, 'message',
                  'error_message')
              .having((PlatformException e) => e.details, 'details',
                  <String, dynamic>{'info': 'error_info'}),
        ),
      );
    });

    test('returns ProductDetailsResponseWrapper', () async {
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapAndroidPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });

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

      // Since queryPastPurchases makes 2 platform method calls (one for each
      // ProductType), the result will contain 2 dummyPurchase instances instead
      // of 1.
      await iapAndroidPlatform.restorePurchases();
      final List<PurchaseDetails> restoredPurchases = await completer.future;

      expect(restoredPurchases.length, 2);
      for (final PurchaseDetails element in restoredPurchases) {
        final GooglePlayPurchaseDetails purchase =
            element as GooglePlayPurchaseDetails;

        expect(purchase.productID, dummyPurchase.products.first);
        expect(purchase.purchaseID, dummyPurchase.orderId);
        expect(purchase.verificationData.localVerificationData,
            dummyPurchase.originalJson);
        expect(purchase.verificationData.serverVerificationData,
            dummyPurchase.purchaseToken);
        expect(purchase.verificationData.source, kIAPSource);
        expect(purchase.transactionDate, dummyPurchase.purchaseTime.toString());
        expect(purchase.billingClientPurchase, dummyPurchase);
        expect(purchase.status, PurchaseStatus.restored);
      }
    });
  });

  group('make payment', () {
    test('buy non consumable, serializes and deserializes data', () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      when(mockApi.launchBillingFlow(any)).thenAnswer((_) async {
        // Mock java update purchase callback.
        iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
            .onPurchasesUpdated(PlatformPurchasesResponse(
          billingResult: convertToPigeonResult(expectedBillingResult),
          purchases: <PlatformPurchase>[
            PlatformPurchase(
              orderId: 'orderID1',
              products: <String>[productDetails.productId],
              isAutoRenewing: false,
              packageName: 'package',
              purchaseTime: 1231231231,
              purchaseToken: 'token',
              signature: 'sign',
              originalJson: 'json',
              developerPayload: 'dummy payload',
              isAcknowledged: true,
              purchaseState: PlatformPurchaseState.purchased,
              quantity: 1,
            )
          ],
        ));

        return convertToPigeonResult(expectedBillingResult);
      });
      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((List<PurchaseDetails> details) {
        purchaseDetails = details.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails:
              GooglePlayProductDetails.fromProductDetails(productDetails).first,
          applicationUserName: accountId);
      final bool launchResult = await iapAndroidPlatform.buyNonConsumable(
          purchaseParam: purchaseParam);

      final PurchaseDetails result = await completer.future;
      expect(launchResult, isTrue);
      expect(result.purchaseID, 'orderID1');
      expect(result.status, PurchaseStatus.purchased);
      expect(result.productID, productDetails.productId);
    });

    test('handles an error with an empty purchases list', () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.error;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      when(mockApi.launchBillingFlow(any)).thenAnswer((_) async {
        // Mock java update purchase callback.
        iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
            .onPurchasesUpdated(PlatformPurchasesResponse(
          billingResult: convertToPigeonResult(expectedBillingResult),
          purchases: <PlatformPurchase>[],
        ));

        return convertToPigeonResult(expectedBillingResult);
      });
      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((List<PurchaseDetails> details) {
        purchaseDetails = details.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails:
              GooglePlayProductDetails.fromProductDetails(productDetails).first,
          applicationUserName: accountId);
      await iapAndroidPlatform.buyNonConsumable(purchaseParam: purchaseParam);
      final PurchaseDetails result = await completer.future;

      expect(result.error, isNotNull);
      expect(result.error!.source, kIAPSource);
      expect(result.status, PurchaseStatus.error);
      expect(result.purchaseID, isEmpty);
    });

    test('buy consumable with auto consume, serializes and deserializes data',
        () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      when(mockApi.launchBillingFlow(any)).thenAnswer((_) async {
        // Mock java update purchase callback.
        iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
            .onPurchasesUpdated(PlatformPurchasesResponse(
          billingResult: convertToPigeonResult(expectedBillingResult),
          purchases: <PlatformPurchase>[
            PlatformPurchase(
              orderId: 'orderID1',
              products: <String>[productDetails.productId],
              isAutoRenewing: false,
              packageName: 'package',
              purchaseTime: 1231231231,
              purchaseToken: 'token',
              signature: 'sign',
              originalJson: 'json',
              developerPayload: 'dummy payload',
              isAcknowledged: true,
              purchaseState: PlatformPurchaseState.purchased,
              quantity: 1,
            )
          ],
        ));

        return convertToPigeonResult(expectedBillingResult);
      });
      final Completer<String> consumeCompleter = Completer<String>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.consumeAsync(any)).thenAnswer((Invocation invocation) async {
        final String purchaseToken =
            invocation.positionalArguments.first as String;
        consumeCompleter.complete(purchaseToken);
        return convertToPigeonResult(expectedBillingResultForConsume);
      });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((List<PurchaseDetails> details) {
        purchaseDetails = details.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails:
              GooglePlayProductDetails.fromProductDetails(productDetails).first,
          applicationUserName: accountId);
      final bool launchResult =
          await iapAndroidPlatform.buyConsumable(purchaseParam: purchaseParam);

      // Verify that the result has succeeded
      final GooglePlayPurchaseDetails result =
          await completer.future as GooglePlayPurchaseDetails;
      expect(launchResult, isTrue);
      expect(result.billingClientPurchase, isNotNull);
      expect(result.billingClientPurchase.purchaseToken,
          await consumeCompleter.future);
      expect(result.status, PurchaseStatus.purchased);
      expect(result.error, isNull);
    });

    test('buyNonConsumable propagates failures to launch the billing flow',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.error;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));

      final bool result = await iapAndroidPlatform.buyNonConsumable(
          purchaseParam: GooglePlayPurchaseParam(
              productDetails: GooglePlayProductDetails.fromProductDetails(
                      dummyOneTimeProductDetails)
                  .first));

      // Verify that the failure has been converted and returned
      expect(result, isFalse);
    });

    test('buyConsumable propagates failures to launch the billing flow',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.developerError;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));

      final bool result = await iapAndroidPlatform.buyConsumable(
          purchaseParam: GooglePlayPurchaseParam(
              productDetails: GooglePlayProductDetails.fromProductDetails(
                      dummyOneTimeProductDetails)
                  .first));

      // Verify that the failure has been converted and returned
      expect(result, isFalse);
    });

    test('adds consumption failures to PurchaseDetails objects', () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer((_) async {
        // Mock java update purchase callback.
        iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
            .onPurchasesUpdated(PlatformPurchasesResponse(
          billingResult: convertToPigeonResult(expectedBillingResult),
          purchases: <PlatformPurchase>[
            PlatformPurchase(
              orderId: 'orderID1',
              products: <String>[productDetails.productId],
              isAutoRenewing: false,
              packageName: 'package',
              purchaseTime: 1231231231,
              purchaseToken: 'token',
              signature: 'sign',
              originalJson: 'json',
              developerPayload: 'dummy payload',
              isAcknowledged: true,
              purchaseState: PlatformPurchaseState.purchased,
              quantity: 1,
            )
          ],
        ));

        return convertToPigeonResult(expectedBillingResult);
      });
      final Completer<String> consumeCompleter = Completer<String>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.error;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.consumeAsync(any)).thenAnswer((Invocation invocation) async {
        final String purchaseToken =
            invocation.positionalArguments.first as String;
        consumeCompleter.complete(purchaseToken);
        return convertToPigeonResult(expectedBillingResultForConsume);
      });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((List<PurchaseDetails> details) {
        purchaseDetails = details.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails:
              GooglePlayProductDetails.fromProductDetails(productDetails).first,
          applicationUserName: accountId);
      await iapAndroidPlatform.buyConsumable(purchaseParam: purchaseParam);

      // Verify that the result has an error for the failed consumption
      final GooglePlayPurchaseDetails result =
          await completer.future as GooglePlayPurchaseDetails;
      expect(result.billingClientPurchase, isNotNull);
      expect(result.billingClientPurchase.purchaseToken,
          await consumeCompleter.future);
      expect(result.status, PurchaseStatus.error);
      expect(result.error, isNotNull);
      expect(result.error!.code, kConsumptionFailedErrorCode);
    });

    test(
        'buy consumable without auto consume, consume api should not receive calls',
        () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.developerError;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      when(mockApi.launchBillingFlow(any)).thenAnswer((_) async {
        // Mock java update purchase callback.
        iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
            .onPurchasesUpdated(PlatformPurchasesResponse(
          billingResult: convertToPigeonResult(expectedBillingResult),
          purchases: <PlatformPurchase>[
            PlatformPurchase(
              orderId: 'orderID1',
              products: <String>[productDetails.productId],
              isAutoRenewing: false,
              packageName: 'package',
              purchaseTime: 1231231231,
              purchaseToken: 'token',
              signature: 'sign',
              originalJson: 'json',
              developerPayload: 'dummy payload',
              isAcknowledged: true,
              purchaseState: PlatformPurchaseState.purchased,
              quantity: 1,
            )
          ],
        ));

        return convertToPigeonResult(expectedBillingResult);
      });
      final Completer<String?> consumeCompleter = Completer<String?>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.consumeAsync(any)).thenAnswer((Invocation invocation) async {
        final String purchaseToken =
            invocation.positionalArguments.first as String;
        consumeCompleter.complete(purchaseToken);
        return convertToPigeonResult(expectedBillingResultForConsume);
      });

      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        consumeCompleter.complete(null);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails:
              GooglePlayProductDetails.fromProductDetails(productDetails).first,
          applicationUserName: accountId);
      await iapAndroidPlatform.buyConsumable(
          purchaseParam: purchaseParam, autoConsume: false);
      expect(null, await consumeCompleter.future);
    });

    test(
        'should get canceled purchase status when response code is BillingResponse.userCanceled',
        () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.userCanceled;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer((_) async {
        // Mock java update purchase callback.
        iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
            .onPurchasesUpdated(PlatformPurchasesResponse(
          billingResult: convertToPigeonResult(expectedBillingResult),
          purchases: <PlatformPurchase>[
            PlatformPurchase(
              orderId: 'orderID1',
              products: <String>[productDetails.productId],
              isAutoRenewing: false,
              packageName: 'package',
              purchaseTime: 1231231231,
              purchaseToken: 'token',
              signature: 'sign',
              originalJson: 'json',
              developerPayload: 'dummy payload',
              isAcknowledged: true,
              purchaseState: PlatformPurchaseState.purchased,
              quantity: 1,
            )
          ],
        ));

        return convertToPigeonResult(expectedBillingResult);
      });
      final Completer<String> consumeCompleter = Completer<String>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.userCanceled;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.consumeAsync(any)).thenAnswer((Invocation invocation) async {
        final String purchaseToken =
            invocation.positionalArguments.first as String;
        consumeCompleter.complete(purchaseToken);
        return convertToPigeonResult(expectedBillingResultForConsume);
      });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((List<PurchaseDetails> details) {
        purchaseDetails = details.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails:
              GooglePlayProductDetails.fromProductDetails(productDetails).first,
          applicationUserName: accountId);
      await iapAndroidPlatform.buyConsumable(purchaseParam: purchaseParam);

      // Verify that the result has an error for the failed consumption
      final GooglePlayPurchaseDetails result =
          await completer.future as GooglePlayPurchaseDetails;
      expect(result.status, PurchaseStatus.canceled);
    });

    test(
        'should get purchased purchase status when upgrading subscription by deferred proration mode',
        () async {
      const ProductDetailsWrapper productDetails = dummyOneTimeProductDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      when(mockApi.launchBillingFlow(any)).thenAnswer((_) async {
        // Mock java update purchase callback.
        iapAndroidPlatform.billingClientManager.client.hostCallbackHandler
            .onPurchasesUpdated(PlatformPurchasesResponse(
          billingResult: convertToPigeonResult(expectedBillingResult),
          purchases: <PlatformPurchase>[],
        ));

        return convertToPigeonResult(expectedBillingResult);
      });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((List<PurchaseDetails> details) {
        purchaseDetails = details.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails:
              GooglePlayProductDetails.fromProductDetails(productDetails).first,
          applicationUserName: accountId,
          changeSubscriptionParam: ChangeSubscriptionParam(
            oldPurchaseDetails: GooglePlayPurchaseDetails.fromPurchase(
                    dummyUnacknowledgedPurchase)
                .first,
            replacementMode: ReplacementMode.deferred,
          ));
      await iapAndroidPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final PurchaseDetails result = await completer.future;
      expect(result.status, PurchaseStatus.purchased);
    });
  });

  group('complete purchase', () {
    test('complete purchase success', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      when(mockApi.acknowledgePurchase(any)).thenAnswer(
          (_) async => convertToPigeonResult(expectedBillingResult));
      final PurchaseDetails purchaseDetails =
          GooglePlayPurchaseDetails.fromPurchase(dummyUnacknowledgedPurchase)
              .first;
      final Completer<BillingResultWrapper> completer =
          Completer<BillingResultWrapper>();
      purchaseDetails.status = PurchaseStatus.purchased;
      if (purchaseDetails.pendingCompletePurchase) {
        final BillingResultWrapper billingResultWrapper =
            await iapAndroidPlatform.completePurchase(purchaseDetails);
        expect(billingResultWrapper, equals(expectedBillingResult));
        completer.complete(billingResultWrapper);
      }
      expect(await completer.future, equals(expectedBillingResult));
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
      final String countryCode = await iapAndroidPlatform.countryCode();

      expect(countryCode, equals(expectedCountryCode));
      // Ensure deprecated code keeps working until removed.
      expect(await iapAndroidPlatform.getCountryCode(),
          equals(expectedCountryCode));
    });
  });
}
