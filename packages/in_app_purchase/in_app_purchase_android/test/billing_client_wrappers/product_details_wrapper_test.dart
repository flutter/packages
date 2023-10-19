// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/types/google_play_product_details.dart';
import 'package:test/test.dart';

const ProductDetailsWrapper dummyOneTimeProductDetails = ProductDetailsWrapper(
  description: 'description',
  name: 'name',
  productId: 'productId',
  productType: ProductType.inapp,
  title: 'title',
  oneTimePurchaseOfferDetails: OneTimePurchaseOfferDetailsWrapper(
    formattedPrice: r'$100',
    priceAmountMicros: 100000000,
    priceCurrencyCode: 'USD',
  ),
);

const ProductDetailsWrapper dummySubscriptionProductDetails =
    ProductDetailsWrapper(
  description: 'description',
  name: 'name',
  productId: 'productId',
  productType: ProductType.subs,
  title: 'title',
  subscriptionOfferDetails: <SubscriptionOfferDetailsWrapper>[
    SubscriptionOfferDetailsWrapper(
      basePlanId: 'basePlanId',
      offerTags: <String>['offerTags'],
      offerId: 'offerId',
      offerIdToken: 'offerToken',
      pricingPhases: <PricingPhaseWrapper>[
        PricingPhaseWrapper(
          billingCycleCount: 4,
          billingPeriod: 'billingPeriod',
          formattedPrice: r'$100',
          priceAmountMicros: 100000000,
          priceCurrencyCode: 'USD',
          recurrenceMode: RecurrenceMode.finiteRecurring,
        ),
      ],
    ),
  ],
);

void main() {
  group('ProductDetailsWrapper', () {
    test('converts one-time purchase from map', () {
      const ProductDetailsWrapper expected = dummyOneTimeProductDetails;
      final ProductDetailsWrapper parsed =
          ProductDetailsWrapper.fromJson(buildProductMap(expected));

      expect(parsed, equals(expected));
    });

    test('converts subscription from map', () {
      const ProductDetailsWrapper expected = dummySubscriptionProductDetails;
      final ProductDetailsWrapper parsed =
          ProductDetailsWrapper.fromJson(buildProductMap(expected));

      expect(parsed, equals(expected));
    });
  });

  group('ProductDetailsResponseWrapper', () {
    test('parsed from map', () {
      const BillingResponse responseCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      final List<ProductDetailsWrapper> productsDetails =
          <ProductDetailsWrapper>[
        dummyOneTimeProductDetails,
        dummyOneTimeProductDetails,
      ];
      const BillingResultWrapper result = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      final ProductDetailsResponseWrapper expected =
          ProductDetailsResponseWrapper(
              billingResult: result, productDetailsList: productsDetails);

      final ProductDetailsResponseWrapper parsed =
          ProductDetailsResponseWrapper.fromJson(<String, dynamic>{
        'billingResult': <String, dynamic>{
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
        'productDetailsList': <Map<String, dynamic>>[
          buildProductMap(dummyOneTimeProductDetails),
          buildProductMap(dummyOneTimeProductDetails),
        ],
      });

      expect(parsed.billingResult, equals(expected.billingResult));
      expect(
          parsed.productDetailsList, containsAll(expected.productDetailsList));
    });

    test('toProductDetails() should return correct Product object', () {
      final ProductDetailsWrapper wrapper = ProductDetailsWrapper.fromJson(
          buildProductMap(dummyOneTimeProductDetails));
      final GooglePlayProductDetails product =
          GooglePlayProductDetails.fromProductDetails(wrapper).first;
      expect(product.title, wrapper.title);
      expect(product.description, wrapper.description);
      expect(product.id, wrapper.productId);
      expect(
          product.price, wrapper.oneTimePurchaseOfferDetails?.formattedPrice);
      expect(product.productDetails, wrapper);
    });

    test('handles empty list of productDetails', () {
      const BillingResponse responseCode = BillingResponse.error;
      const String debugMessage = 'dummy message';
      final List<ProductDetailsWrapper> productsDetails =
          <ProductDetailsWrapper>[];
      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      final ProductDetailsResponseWrapper expected =
          ProductDetailsResponseWrapper(
              billingResult: billingResult,
              productDetailsList: productsDetails);

      final ProductDetailsResponseWrapper parsed =
          ProductDetailsResponseWrapper.fromJson(<String, dynamic>{
        'billingResult': <String, dynamic>{
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
        'productDetailsList': const <Map<String, dynamic>>[]
      });

      expect(parsed.billingResult, equals(expected.billingResult));
      expect(
          parsed.productDetailsList, containsAll(expected.productDetailsList));
    });

    test('fromJson creates an object with default values', () {
      final ProductDetailsResponseWrapper productDetails =
          ProductDetailsResponseWrapper.fromJson(const <String, dynamic>{});
      expect(
          productDetails.billingResult,
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
      expect(productDetails.productDetailsList, isEmpty);
    });
  });

  group('BillingResultWrapper', () {
    test('fromJson on empty map creates an object with default values', () {
      final BillingResultWrapper billingResult =
          BillingResultWrapper.fromJson(const <String, dynamic>{});
      expect(billingResult.debugMessage, kInvalidBillingResultErrorMessage);
      expect(billingResult.responseCode, BillingResponse.error);
    });

    test('fromJson on null creates an object with default values', () {
      final BillingResultWrapper billingResult =
          BillingResultWrapper.fromJson(null);
      expect(billingResult.debugMessage, kInvalidBillingResultErrorMessage);
      expect(billingResult.responseCode, BillingResponse.error);
    });

    test('operator == of ProductDetailsWrapper works fine', () {
      const ProductDetailsWrapper firstProductDetailsInstance =
          ProductDetailsWrapper(
        description: 'description',
        title: 'title',
        productType: ProductType.inapp,
        name: 'name',
        productId: 'productId',
        oneTimePurchaseOfferDetails: OneTimePurchaseOfferDetailsWrapper(
          formattedPrice: 'formattedPrice',
          priceAmountMicros: 10,
          priceCurrencyCode: 'priceCurrencyCode',
        ),
        subscriptionOfferDetails: <SubscriptionOfferDetailsWrapper>[
          SubscriptionOfferDetailsWrapper(
            basePlanId: 'basePlanId',
            offerTags: <String>['offerTags'],
            offerIdToken: 'offerToken',
            pricingPhases: <PricingPhaseWrapper>[
              PricingPhaseWrapper(
                billingCycleCount: 4,
                billingPeriod: 'billingPeriod',
                formattedPrice: 'formattedPrice',
                priceAmountMicros: 10,
                priceCurrencyCode: 'priceCurrencyCode',
                recurrenceMode: RecurrenceMode.finiteRecurring,
              ),
            ],
          ),
        ],
      );
      const ProductDetailsWrapper secondProductDetailsInstance =
          ProductDetailsWrapper(
        description: 'description',
        title: 'title',
        productType: ProductType.inapp,
        name: 'name',
        productId: 'productId',
        oneTimePurchaseOfferDetails: OneTimePurchaseOfferDetailsWrapper(
          formattedPrice: 'formattedPrice',
          priceAmountMicros: 10,
          priceCurrencyCode: 'priceCurrencyCode',
        ),
        subscriptionOfferDetails: <SubscriptionOfferDetailsWrapper>[
          SubscriptionOfferDetailsWrapper(
            basePlanId: 'basePlanId',
            offerTags: <String>['offerTags'],
            offerIdToken: 'offerToken',
            pricingPhases: <PricingPhaseWrapper>[
              PricingPhaseWrapper(
                billingCycleCount: 4,
                billingPeriod: 'billingPeriod',
                formattedPrice: 'formattedPrice',
                priceAmountMicros: 10,
                priceCurrencyCode: 'priceCurrencyCode',
                recurrenceMode: RecurrenceMode.finiteRecurring,
              ),
            ],
          ),
        ],
      );
      expect(
          firstProductDetailsInstance == secondProductDetailsInstance, isTrue);
    });

    test('operator == of BillingResultWrapper works fine', () {
      const BillingResultWrapper firstBillingResultInstance =
          BillingResultWrapper(
        responseCode: BillingResponse.ok,
        debugMessage: 'debugMessage',
      );
      const BillingResultWrapper secondBillingResultInstance =
          BillingResultWrapper(
        responseCode: BillingResponse.ok,
        debugMessage: 'debugMessage',
      );
      expect(firstBillingResultInstance == secondBillingResultInstance, isTrue);
    });
  });
}

Map<String, dynamic> buildProductMap(ProductDetailsWrapper original) {
  final Map<String, dynamic> map = <String, dynamic>{
    'title': original.title,
    'description': original.description,
    'productId': original.productId,
    'productType': const ProductTypeConverter().toJson(original.productType),
    'name': original.name,
  };

  if (original.oneTimePurchaseOfferDetails != null) {
    map.putIfAbsent('oneTimePurchaseOfferDetails',
        () => buildOneTimePurchaseMap(original.oneTimePurchaseOfferDetails!));
  }

  if (original.subscriptionOfferDetails != null) {
    map.putIfAbsent('subscriptionOfferDetails',
        () => buildSubscriptionMapList(original.subscriptionOfferDetails!));
  }

  return map;
}

Map<String, dynamic> buildOneTimePurchaseMap(
    OneTimePurchaseOfferDetailsWrapper original) {
  return <String, dynamic>{
    'priceAmountMicros': original.priceAmountMicros,
    'priceCurrencyCode': original.priceCurrencyCode,
    'formattedPrice': original.formattedPrice,
  };
}

List<Map<String, dynamic>> buildSubscriptionMapList(
    List<SubscriptionOfferDetailsWrapper> original) {
  return original
      .map((SubscriptionOfferDetailsWrapper subscriptionOfferDetails) =>
          buildSubscriptionMap(subscriptionOfferDetails))
      .toList();
}

Map<String, dynamic> buildSubscriptionMap(
    SubscriptionOfferDetailsWrapper original) {
  return <String, dynamic>{
    'offerId': original.offerId,
    'basePlanId': original.basePlanId,
    'offerTags': original.offerTags,
    'offerIdToken': original.offerIdToken,
    'pricingPhases': buildPricingPhaseMapList(original.pricingPhases),
  };
}

List<Map<String, dynamic>> buildPricingPhaseMapList(
    List<PricingPhaseWrapper> original) {
  return original
      .map((PricingPhaseWrapper pricingPhase) =>
          buildPricingPhaseMap(pricingPhase))
      .toList();
}

Map<String, dynamic> buildPricingPhaseMap(PricingPhaseWrapper original) {
  return <String, dynamic>{
    'formattedPrice': original.formattedPrice,
    'priceCurrencyCode': original.priceCurrencyCode,
    'priceAmountMicros': original.priceAmountMicros,
    'billingCycleCount': original.billingCycleCount,
    'billingPeriod': original.billingPeriod,
    'recurrenceMode':
        const RecurrenceModeConverter().toJson(original.recurrenceMode),
  };
}
