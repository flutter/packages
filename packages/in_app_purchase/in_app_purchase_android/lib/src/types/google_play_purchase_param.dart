// Copyright 2013 The Flutter Authors
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
    this.obfuscatedProfileId,
    this.changeSubscriptionParam,
    this.offerToken,
  });

  /// The obfuscated profile id specified when making a purchase.
  ///
  /// This is passed to Google Play as the obfuscated profile id. It should be
  /// an obfuscated identifier that is uniquely associated with the user's
  /// profile in your app, and must not contain personally identifiable
  /// information.
  final String? obfuscatedProfileId;

  /// The 'changeSubscriptionParam' containing information for upgrading or
  /// downgrading an existing subscription.
  final ChangeSubscriptionParam? changeSubscriptionParam;

  /// For One-time product, "offerToken" shouldn't be filled.
  ///
  /// For subscriptions, to get the offer token corresponding to the selected
  /// offer call productDetails.subscriptionOfferDetails?.get(selectedOfferIndex)?.offerToken
  final String? offerToken;
}
