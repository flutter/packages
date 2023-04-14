// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../billing_client_wrappers.dart';

/// The class represents the information of a product as registered in at
/// Google Play store front.
class GooglePlayProductDetails extends ProductDetails {
  /// Creates a new Google Play specific product details object with the
  /// provided details.
  GooglePlayProductDetails({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.rawPrice,
    required super.currencyCode,
    required this.productDetails,
    required super.currencySymbol,
    this.subscriptionIndex,
  });

  /// Generate a [GooglePlayProductDetails] object based on an Android
  /// [ProductDetailsWrapper] object for an in-app product.
  factory GooglePlayProductDetails._fromOneTimePurchaseProductDetails(
    ProductDetailsWrapper productDetails,
  ) {
    assert(productDetails.productType == ProductType.inapp);
    assert(productDetails.oneTimePurchaseOfferDetails != null);

    final OneTimePurchaseOfferDetailsWrapper oneTimePurchaseOfferDetails =
        productDetails.oneTimePurchaseOfferDetails!;

    final String formattedPrice = oneTimePurchaseOfferDetails.formattedPrice;
    final double rawPrice =
        oneTimePurchaseOfferDetails.priceAmountMicros / 1000000.0;
    final String currencyCode = oneTimePurchaseOfferDetails.priceCurrencyCode;
    final String currencySymbol =
        formattedPrice.isEmpty ? currencyCode : formattedPrice[0];

    return GooglePlayProductDetails(
      id: productDetails.productId,
      title: productDetails.title,
      description: productDetails.description,
      price: formattedPrice,
      rawPrice: rawPrice,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      productDetails: productDetails,
    );
  }

  /// Generate a [GooglePlayProductDetails] object based on an Android
  /// [ProductDetailsWrapper] object for a subscription product.
  factory GooglePlayProductDetails._fromSubscription(
    ProductDetailsWrapper productDetails,
    int subscriptionIndex,
  ) {
    assert(productDetails.productType == ProductType.subs);
    assert(productDetails.subscriptionOfferDetails != null);
    assert(subscriptionIndex < productDetails.subscriptionOfferDetails!.length);

    final SubscriptionOfferDetailsWrapper subscriptionOfferDetails =
        productDetails.subscriptionOfferDetails![subscriptionIndex];

    final PricingPhaseWrapper firstPricingPhase =
        subscriptionOfferDetails.pricingPhases.first;
    final String formattedPrice = firstPricingPhase.formattedPrice;
    final double rawPrice = (firstPricingPhase.priceAmountMicros) / 1000000.0;
    final String currencyCode = firstPricingPhase.priceCurrencyCode;
    final String currencySymbol =
        formattedPrice.isEmpty ? currencyCode : formattedPrice[0];

    return GooglePlayProductDetails(
      id: productDetails.productId,
      title: productDetails.title,
      description: productDetails.description,
      price: formattedPrice,
      rawPrice: rawPrice,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      productDetails: productDetails,
      subscriptionIndex: subscriptionIndex,
    );
  }

  /// Generate a list of [GooglePlayProductDetails] based on an Android
  /// [ProductDetailsWrapper] object for a subscription product.
  ///
  /// Subscriptions can consist of multiple base plans, and base plans in turn
  /// can consist of multiple offers. This method generates a list where every
  /// element corresponds to a base plan or its offer.
  static List<GooglePlayProductDetails> fromProductDetails(
    ProductDetailsWrapper productDetails,
  ) {
    if (productDetails.productType == ProductType.inapp) {
      return <GooglePlayProductDetails>[
        GooglePlayProductDetails._fromOneTimePurchaseProductDetails(
            productDetails),
      ];
    } else {
      final List<GooglePlayProductDetails> productDetailList =
          <GooglePlayProductDetails>[];
      for (int subscriptionIndex = 0;
          subscriptionIndex < productDetails.subscriptionOfferDetails!.length;
          subscriptionIndex++) {
        productDetailList.add(GooglePlayProductDetails._fromSubscription(
          productDetails,
          subscriptionIndex,
        ));
      }

      return productDetailList;
    }
  }

  /// Points back to the [ProductDetailsWrapper] object that was used to
  /// generate this [GooglePlayProductDetails] object.
  final ProductDetailsWrapper productDetails;

  /// The index pointing to the subscription this [GooglePlayProductDetails]
  /// object was contructed for, or `null` if it was not a subscription.
  final int? subscriptionIndex;

  /// The offerToken of the subscription this [GooglePlayProductDetails]
  /// object was contructed for, or 'null' if it was not a subscription.
  String? get offerToken => subscriptionIndex != null &&
          productDetails.subscriptionOfferDetails != null
      ? productDetails.subscriptionOfferDetails![subscriptionIndex!].offerToken
      : null;
}
