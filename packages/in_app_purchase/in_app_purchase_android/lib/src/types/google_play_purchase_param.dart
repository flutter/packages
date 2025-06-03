// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../in_app_purchase_android.dart';

/// Google Play specific parameter object for generating a purchase.
class GooglePlayPurchaseParam extends PurchaseParam {
  /// Creates a new [GooglePlayPurchaseParam] object with the given data.
  GooglePlayPurchaseParam({
    required super.productDetails,
    super.applicationUserName,
    this.changeSubscriptionParam,
    this.offerToken,
  });

  /// The 'changeSubscriptionParam' containing information for upgrading or
  /// downgrading an existing subscription.
  final ChangeSubscriptionParam? changeSubscriptionParam;

  /// For One-time product, "offerToken" shouldn't be filled.
  ///
  /// For subscriptions, to get the offer token corresponding to the selected
  /// offer call productDetails.subscriptionOfferDetails?.get(selectedOfferIndex)?.offerToken
  final String? offerToken;
}
