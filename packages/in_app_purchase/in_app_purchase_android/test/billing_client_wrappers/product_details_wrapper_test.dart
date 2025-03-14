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

void main() {
  group('ProductDetailsResponseWrapper', () {
    test('toProductDetails() should return correct Product object', () {
      const ProductDetailsWrapper wrapper = dummyOneTimeProductDetails;
      final GooglePlayProductDetails product =
          GooglePlayProductDetails.fromProductDetails(
                  dummyOneTimeProductDetails)
              .first;
      expect(product.title, wrapper.title);
      expect(product.description, wrapper.description);
      expect(product.id, wrapper.productId);
      expect(
          product.price, wrapper.oneTimePurchaseOfferDetails?.formattedPrice);
      expect(product.productDetails, wrapper);
    });
  });

  group('BillingResultWrapper', () {
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
            installmentPlanDetails: InstallmentPlanDetailsWrapper(
              commitmentPaymentsCount: 1,
              subsequentCommitmentPaymentsCount: 2,
            ),
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
            installmentPlanDetails: InstallmentPlanDetailsWrapper(
              commitmentPaymentsCount: 1,
              subsequentCommitmentPaymentsCount: 2,
            ),
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
