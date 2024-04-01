// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Data structure representing a UserChoiceDetails.
///
/// This wraps [`com.android.billingclient.api.UserChoiceDetails`](https://developer.android.com/reference/com/android/billingclient/api/UserChoiceDetails)
@immutable
class GooglePlayUserChoiceDetails {
  /// Creates a new Google Play specific user choice billing details object with
  /// the provided details.
  const GooglePlayUserChoiceDetails({
    required this.originalExternalTransactionId,
    required this.externalTransactionToken,
    required this.products,
  });

  /// Returns the external transaction Id of the originating subscription, if
  /// the purchase is a subscription upgrade/downgrade.
  final String originalExternalTransactionId;

  /// Returns a token that represents the user's prospective purchase via
  /// user choice alternative billing.
  final String externalTransactionToken;

  /// Returns a list of [GooglePlayUserChoiceDetailsProduct] to be purchased in
  /// the user choice alternative billing flow.
  final List<GooglePlayUserChoiceDetailsProduct> products;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GooglePlayUserChoiceDetails &&
        other.originalExternalTransactionId == originalExternalTransactionId &&
        other.externalTransactionToken == externalTransactionToken &&
        listEquals(other.products, products);
  }

  @override
  int get hashCode => Object.hash(
        originalExternalTransactionId,
        externalTransactionToken,
        products.hashCode,
      );
}

/// Data structure representing a UserChoiceDetails product.
///
/// This wraps [`com.android.billingclient.api.UserChoiceDetails.Product`](https://developer.android.com/reference/com/android/billingclient/api/UserChoiceDetails.Product)
@immutable
class GooglePlayUserChoiceDetailsProduct {
  /// Creates UserChoiceDetailsProduct.
  const GooglePlayUserChoiceDetailsProduct(
      {required this.id, required this.offerToken, required this.productType});

  /// Returns the id of the product being purchased.
  final String id;

  /// Returns the offer token that was passed in launchBillingFlow to purchase the product.
  final String offerToken;

  /// Returns the [GooglePlayProductType] of the product being purchased.
  final GooglePlayProductType productType;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GooglePlayUserChoiceDetailsProduct &&
        other.id == id &&
        other.offerToken == offerToken &&
        other.productType == productType;
  }

  @override
  int get hashCode => Object.hash(
        id,
        offerToken,
        productType,
      );
}

/// This wraps [`com.android.billingclient.api.BillingClient.ProductType`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.ProductType)
enum GooglePlayProductType {
  /// A Product type for Android apps in-app products.
  inapp,

  /// A Product type for Android apps subscriptions.
  subs
}
