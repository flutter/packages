// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_storekit/src/types/app_store_product_details.dart';
import 'package:in_app_purchase_storekit/src/types/app_store_purchase_details.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:test/test.dart';

import 'sk_test_stub_objects.dart';

void main() {
  group('product related object wrapper test', () {
    test(
      'SKProductSubscriptionPeriodWrapper should have property values consistent with map',
      () {
        final wrapper = SKProductSubscriptionPeriodWrapper.fromJson(
          buildSubscriptionPeriodMap(dummySubscription),
        );
        expect(wrapper, equals(dummySubscription));
      },
    );

    test(
      'SKProductSubscriptionPeriodWrapper should have properties to be default values if map is empty',
      () {
        final wrapper = SKProductSubscriptionPeriodWrapper.fromJson(
          const <String, dynamic>{},
        );
        expect(wrapper.numberOfUnits, 0);
        expect(wrapper.unit, SKSubscriptionPeriodUnit.day);
      },
    );

    test(
      'SKProductDiscountWrapper should have property values consistent with map',
      () {
        final wrapper = SKProductDiscountWrapper.fromJson(
          buildDiscountMap(dummyDiscount),
        );
        expect(wrapper, equals(dummyDiscount));
      },
    );

    test('SKProductDiscountWrapper missing identifier and type should have '
        'property values consistent with map', () {
      final wrapper = SKProductDiscountWrapper.fromJson(
        buildDiscountMapMissingIdentifierAndType(
          dummyDiscountMissingIdentifierAndType,
        ),
      );
      expect(wrapper, equals(dummyDiscountMissingIdentifierAndType));
    });

    test(
      'SKProductDiscountWrapper should have properties to be default if map is empty',
      () {
        final wrapper = SKProductDiscountWrapper.fromJson(
          const <String, dynamic>{},
        );
        expect(wrapper.price, '');
        expect(
          wrapper.priceLocale,
          SKPriceLocaleWrapper(
            currencyCode: '',
            currencySymbol: '',
            countryCode: '',
          ),
        );
        expect(wrapper.numberOfPeriods, 0);
        expect(wrapper.paymentMode, SKProductDiscountPaymentMode.payAsYouGo);
        expect(
          wrapper.subscriptionPeriod,
          SKProductSubscriptionPeriodWrapper(
            numberOfUnits: 0,
            unit: SKSubscriptionPeriodUnit.day,
          ),
        );
      },
    );

    test(
      'SKProductWrapper should have property values consistent with map',
      () {
        final wrapper = SKProductWrapper.fromJson(
          buildProductMap(dummyProductWrapper),
        );
        expect(wrapper, equals(dummyProductWrapper));
      },
    );

    test(
      'SKProductWrapper should have properties to be default if map is empty',
      () {
        final wrapper = SKProductWrapper.fromJson(const <String, dynamic>{});
        expect(wrapper.productIdentifier, '');
        expect(wrapper.localizedTitle, '');
        expect(wrapper.localizedDescription, '');
        expect(
          wrapper.priceLocale,
          SKPriceLocaleWrapper(
            currencyCode: '',
            currencySymbol: '',
            countryCode: '',
          ),
        );
        expect(wrapper.subscriptionGroupIdentifier, null);
        expect(wrapper.price, '');
        expect(wrapper.subscriptionPeriod, null);
        expect(wrapper.discounts, <SKProductDiscountWrapper>[]);
      },
    );

    test('toProductDetails() should return correct Product object', () {
      final wrapper = SKProductWrapper.fromJson(
        buildProductMap(dummyProductWrapper),
      );
      final product = AppStoreProductDetails.fromSKProduct(wrapper);
      expect(product.title, wrapper.localizedTitle);
      expect(product.description, wrapper.localizedDescription);
      expect(product.id, wrapper.productIdentifier);
      expect(product.price, wrapper.priceLocale.currencySymbol + wrapper.price);
      expect(product.skProduct, wrapper);
    });

    test('SKProductResponse wrapper should match', () {
      final wrapper = SkProductResponseWrapper.fromJson(
        buildProductResponseMap(dummyProductResponseWrapper),
      );
      expect(wrapper, equals(dummyProductResponseWrapper));
    });
    test('SKProductResponse wrapper should default to empty list', () {
      final productResponseMapEmptyList = <String, List<dynamic>>{
        'products': <Map<String, dynamic>>[],
        'invalidProductIdentifiers': <String>[],
      };
      final wrapper = SkProductResponseWrapper.fromJson(
        productResponseMapEmptyList,
      );
      expect(wrapper.products.length, 0);
      expect(wrapper.invalidProductIdentifiers.length, 0);
    });

    test('LocaleWrapper should have property values consistent with map', () {
      final wrapper = SKPriceLocaleWrapper.fromJson(
        buildLocaleMap(dollarLocale),
      );
      expect(wrapper, equals(dollarLocale));
    });
  });

  group('Payment queue related object tests', () {
    test('Should construct correct SKPaymentWrapper from json', () {
      final payment = SKPaymentWrapper.fromJson(dummyPayment.toMap());
      expect(payment, equals(dummyPayment));
    });

    test(
      'SKPaymentWrapper should have propery values consistent with .toMap()',
      () {
        final Map<String, dynamic> mapResult = dummyPaymentWithDiscount.toMap();
        expect(
          mapResult['productIdentifier'],
          dummyPaymentWithDiscount.productIdentifier,
        );
        expect(
          mapResult['applicationUsername'],
          dummyPaymentWithDiscount.applicationUsername,
        );
        expect(mapResult['requestData'], dummyPaymentWithDiscount.requestData);
        expect(mapResult['quantity'], dummyPaymentWithDiscount.quantity);
        expect(
          mapResult['simulatesAskToBuyInSandbox'],
          dummyPaymentWithDiscount.simulatesAskToBuyInSandbox,
        );
        expect(
          mapResult['paymentDiscount'],
          equals(dummyPaymentWithDiscount.paymentDiscount?.toMap()),
        );
      },
    );

    test('Should construct correct SKError from json', () {
      final error = SKError.fromJson(buildErrorMap(dummyError));
      expect(error, equals(dummyError));
    });

    test('Should construct correct SKTransactionWrapper from json', () {
      final transaction = SKPaymentTransactionWrapper.fromJson(
        buildTransactionMap(dummyTransaction),
      );
      expect(transaction, equals(dummyTransaction));
    });

    test('toPurchaseDetails() should return correct PurchaseDetail object', () {
      final details = AppStorePurchaseDetails.fromSKTransaction(
        dummyTransaction,
        'receipt data',
      );
      expect(dummyTransaction.transactionIdentifier, details.purchaseID);
      expect(dummyTransaction.payment.productIdentifier, details.productID);
      expect(dummyTransaction.transactionTimeStamp, isNotNull);
      expect(
        (dummyTransaction.transactionTimeStamp! * 1000).toInt().toString(),
        details.transactionDate,
      );
      expect(details.verificationData.localVerificationData, 'receipt data');
      expect(details.verificationData.serverVerificationData, 'receipt data');
      expect(details.verificationData.source, 'app_store');
      expect(details.skPaymentTransaction, dummyTransaction);
      expect(details.pendingCompletePurchase, true);
    });

    test('SKPaymentTransactionWrapper.toFinishMap set correct value', () {
      final transactionWrapper = SKPaymentTransactionWrapper(
        payment: dummyPayment,
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionIdentifier: 'abcd',
      );
      final Map<String, String?> finishMap = transactionWrapper.toFinishMap();
      expect(finishMap['transactionIdentifier'], 'abcd');
      expect(finishMap['productIdentifier'], dummyPayment.productIdentifier);
    });

    test(
      'SKPaymentTransactionWrapper.toFinishMap should set transactionIdentifier to null when necessary',
      () {
        final transactionWrapper = SKPaymentTransactionWrapper(
          payment: dummyPayment,
          transactionState: SKPaymentTransactionStateWrapper.failed,
        );
        final Map<String, String?> finishMap = transactionWrapper.toFinishMap();
        expect(finishMap['transactionIdentifier'], null);
      },
    );

    test('Should generate correct map of the payment object', () {
      final Map<String, Object?> map = dummyPayment.toMap();
      expect(map['productIdentifier'], dummyPayment.productIdentifier);
      expect(map['applicationUsername'], dummyPayment.applicationUsername);

      expect(map['requestData'], dummyPayment.requestData);

      expect(map['quantity'], dummyPayment.quantity);

      expect(
        map['simulatesAskToBuyInSandbox'],
        dummyPayment.simulatesAskToBuyInSandbox,
      );
    });
  });
}
