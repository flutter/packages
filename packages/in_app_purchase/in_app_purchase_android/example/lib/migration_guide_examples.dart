// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

// #docregion one-time-purchase-price
/// Handles the one time purchase price of a product.
void handleOneTimePurchasePrice(ProductDetails productDetails) {
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper product = productDetails.productDetails;
    if (product.productType == ProductType.inapp) {
      // Unwrapping is safe because the product is a one time purchase.
      final OneTimePurchaseOfferDetailsWrapper offer =
          product.oneTimePurchaseOfferDetails!;
      final String price = offer.formattedPrice;
    }
  }
}
// #enddocregion one-time-purchase-price

// #docregion subscription-free-trial
/// Handles the free trial period of a subscription.
void handleFreeTrialPeriod(ProductDetails productDetails) {
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper product = productDetails.productDetails;
    if (product.productType == ProductType.subs) {
      // Unwrapping is safe because the product is a subscription.
      final SubscriptionOfferDetailsWrapper offer =
          product.subscriptionOfferDetails![productDetails.subscriptionIndex!];
      final List<PricingPhaseWrapper> pricingPhases = offer.pricingPhases;
      if (pricingPhases.first.priceAmountMicros == 0) {
        // Free trial period logic.
      }
    }
  }
}
// #enddocregion subscription-free-trial

// #docregion subscription-introductory-price
/// Handles the introductory price period of a subscription.
void handleIntroductoryPricePeriod(ProductDetails productDetails) {
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper product = productDetails.productDetails;
    if (product.productType == ProductType.subs) {
      // Unwrapping is safe because the product is a subscription.
      final SubscriptionOfferDetailsWrapper offer =
          product.subscriptionOfferDetails![productDetails.subscriptionIndex!];
      final List<PricingPhaseWrapper> pricingPhases = offer.pricingPhases;
      if (pricingPhases.length >= 2 &&
          pricingPhases.first.priceAmountMicros <
              pricingPhases[1].priceAmountMicros) {
        // Introductory pricing period logic.
      }
    }
  }
}
// #enddocregion subscription-introductory-price
