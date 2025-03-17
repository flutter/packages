// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../../billing_client_wrappers.dart';

/// This wraps [`com.android.billingclient.api.UserChoiceDetails`](https://developer.android.com/reference/com/android/billingclient/api/UserChoiceDetails)
// See https://docs.flutter.dev/data-and-backend/serialization/json#generating-code-for-nested-classes
// for explination for why this uses explicitToJson.
@immutable
class UserChoiceDetailsWrapper {
  /// Creates a purchase wrapper with the given purchase details.
  const UserChoiceDetailsWrapper({
    required this.originalExternalTransactionId,
    required this.externalTransactionToken,
    required this.products,
  });

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is UserChoiceDetailsWrapper &&
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

  /// Returns the external transaction Id of the originating subscription, if
  /// the purchase is a subscription upgrade/downgrade.
  final String originalExternalTransactionId;

  /// Returns a token that represents the user's prospective purchase via
  /// user choice alternative billing.
  final String externalTransactionToken;

  /// Returns a list of [UserChoiceDetailsProductWrapper] to be purchased in
  /// the user choice alternative billing flow.
  final List<UserChoiceDetailsProductWrapper> products;
}

/// Data structure representing a UserChoiceDetails product.
///
/// This wraps [`com.android.billingclient.api.UserChoiceDetails.Product`](https://developer.android.com/reference/com/android/billingclient/api/UserChoiceDetails.Product)
//
// See https://docs.flutter.dev/data-and-backend/serialization/json#generating-code-for-nested-classes
// for explination for why this uses explicitToJson.
@immutable
class UserChoiceDetailsProductWrapper {
  /// Creates a [UserChoiceDetailsProductWrapper] with the given record details.
  const UserChoiceDetailsProductWrapper({
    required this.id,
    required this.offerToken,
    required this.productType,
  });

  /// Returns the id of the product being purchased.
  final String id;

  /// Returns the offer token that was passed in launchBillingFlow to purchase the product.
  final String offerToken;

  /// Returns the [ProductType] of the product being purchased.
  final ProductType productType;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is UserChoiceDetailsProductWrapper &&
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
