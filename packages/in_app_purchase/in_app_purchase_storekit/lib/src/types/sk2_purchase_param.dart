// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../store_kit_2_wrappers.dart';
import 'sk2_promotional_offer.dart';

/// Apple StoreKit2's AppStore specific parameter object for generating a purchase.
class Sk2PurchaseParam extends PurchaseParam {
  /// Creates a new [Sk2PurchaseParam] object with the given data.
  Sk2PurchaseParam({
    required super.productDetails,
    super.applicationUserName,
    this.quantity = 1,
    this.winBackOfferId,
    this.promotionalOffer,
  });

  /// Creates a [Sk2PurchaseParam] from a [ProductDetails] and a [SK2SubscriptionOffer].
  ///
  /// Depending on the [offer.type], this factory will:
  /// - For [SK2SubscriptionOfferType.winBack]: set [winBackOfferId] to [offer.id].
  /// - For [SK2SubscriptionOfferType.promotional]: set [promotionalOffer] using [offer.id] and [signature].
  /// - For [SK2SubscriptionOfferType.introductory]: create a default [Sk2PurchaseParam].
  ///
  /// [productDetails]: The details of the product to purchase.
  /// [offer]: The subscription offer to apply.
  /// [signature]: The promotional offer signature, required for promotional offers.
  factory Sk2PurchaseParam.fromOffer({
    required ProductDetails productDetails,
    required SK2SubscriptionOffer offer,
    SK2SubscriptionOfferSignature? signature,
  }) {
    switch (offer.type) {
      case SK2SubscriptionOfferType.winBack:
        return Sk2PurchaseParam(
          productDetails: productDetails,
          winBackOfferId: offer.id,
        );
      case SK2SubscriptionOfferType.promotional:
        return Sk2PurchaseParam(
          productDetails: productDetails,
          promotionalOffer: SK2PromotionalOffer(
            offerId: offer.id ?? '',
            signature: signature!,
          ),
        );
      case SK2SubscriptionOfferType.introductory:
        return Sk2PurchaseParam(
          productDetails: productDetails,
        );
    }
  }

  /// Quantity of the product user requested to buy.
  final int quantity;

  /// The win back offer identifier to apply to the purchase.
  final String? winBackOfferId;

  /// The promotional offer identifier to apply to the purchase.
  final SK2PromotionalOffer? promotionalOffer;
}
