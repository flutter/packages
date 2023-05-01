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
  GooglePlayProductDetails._({
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

  /// Generates a [GooglePlayProductDetails] object based on an Android
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
    final String? currencySymbol = _extractCurrencySymbol(formattedPrice);

    return GooglePlayProductDetails._(
      id: productDetails.productId,
      title: productDetails.title,
      description: productDetails.description,
      price: formattedPrice,
      rawPrice: rawPrice,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol ?? currencyCode,
      productDetails: productDetails,
    );
  }

  /// Generates a [GooglePlayProductDetails] object based on an Android
  /// [ProductDetailsWrapper] object for a subscription product.
  ///
  /// Subscriptions can consist of multiple base plans, and base plans in turn
  /// can consist of multiple offers. [subscriptionIndex] points to the index of
  /// [productDetails.subscriptionOfferDetails] for which the
  /// [GooglePlayProductDetails] is constructed.
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
    final double rawPrice = firstPricingPhase.priceAmountMicros / 1000000.0;
    final String currencyCode = firstPricingPhase.priceCurrencyCode;
    final String? currencySymbol = _extractCurrencySymbol(formattedPrice);

    return GooglePlayProductDetails._(
      id: productDetails.productId,
      title: productDetails.title,
      description: productDetails.description,
      price: formattedPrice,
      rawPrice: rawPrice,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol ?? currencyCode,
      productDetails: productDetails,
      subscriptionIndex: subscriptionIndex,
    );
  }

  /// Generates a list of [GooglePlayProductDetails] based on an Android
  /// [ProductDetailsWrapper] object.
  ///
  /// If [productDetails] is of type [ProductType.inapp], a single
  /// [GooglePlayProductDetails] will be constructed.
  /// If [productDetails] is of type [ProductType.subs], a list is returned
  /// where every element corresponds to a base plan or its offer in
  /// [productDetails.subscriptionOfferDetails].
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

  /// Extracts the currency symbol from [formattedPrice].
  ///
  /// Note that a currency symbol might consist of more than a single character.
  ///
  /// Just in case, we assume currency symbols can appear at the start or the
  /// end of [formattedPrice].
  ///
  /// The regex captures the characters from the start/end of the [String]
  /// until the first/last digit or space.
  static String? _extractCurrencySymbol(String formattedPrice) {
    return RegExp(r'^[^\d ]*|[^\d ]*$').firstMatch(formattedPrice)?.group(0);
  }

  /// Points back to the [ProductDetailsWrapper] object that was used to
  /// generate this [GooglePlayProductDetails] object.
  final ProductDetailsWrapper productDetails;

  /// The index pointing to the [SubscriptionOfferDetailsWrapper] this
  /// [GooglePlayProductDetails] object was contructed for, or `null` if it was
  /// not a subscription.
  ///
  /// The original subscription can be accessed using this index:
  ///
  /// ```dart
  /// SubscriptionOfferDetailWrapper subscription = productDetail
  ///   .subscriptionOfferDetails[subscriptionIndex];
  /// ```
  final int? subscriptionIndex;

  /// The offerToken of the subscription this [GooglePlayProductDetails]
  /// object was contructed for, or `null` if it was not a subscription.
  String? get offerToken => subscriptionIndex != null &&
          productDetails.subscriptionOfferDetails != null
      ? productDetails
          .subscriptionOfferDetails![subscriptionIndex!].offerIdToken
      : null;
}
