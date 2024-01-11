// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../billing_client_wrappers.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'product_details_wrapper.g.dart';

/// Dart wrapper around [`com.android.billingclient.api.ProductDetails`](https://developer.android.com/reference/com/android/billingclient/api/ProductDetails).
///
/// Contains the details of an available product in Google Play Billing.
/// Represents the details of a one-time or subscription product.
@JsonSerializable()
@ProductTypeConverter()
@immutable
class ProductDetailsWrapper {
  /// Creates a [ProductDetailsWrapper] with the given purchase details.
  @visibleForTesting
  const ProductDetailsWrapper({
    required this.description,
    required this.name,
    this.oneTimePurchaseOfferDetails,
    required this.productId,
    required this.productType,
    this.subscriptionOfferDetails,
    required this.title,
  });

  /// Factory for creating a [ProductDetailsWrapper] from a [Map] with the
  /// product details.
  factory ProductDetailsWrapper.fromJson(Map<String, dynamic> map) =>
      _$ProductDetailsWrapperFromJson(map);

  /// Textual description of the product.
  @JsonKey(defaultValue: '')
  final String description;

  /// The name of the product being sold.
  ///
  /// Similar to [title], but does not include the name of the app which owns
  /// the product. Example: 100 Gold Coins.
  @JsonKey(defaultValue: '')
  final String name;

  /// The offer details of a one-time purchase product.
  ///
  /// [oneTimePurchaseOfferDetails] is only set for [ProductType.inapp]. Returns
  /// null for [ProductType.subs].
  @JsonKey(defaultValue: null)
  final OneTimePurchaseOfferDetailsWrapper? oneTimePurchaseOfferDetails;

  /// The product's id.
  @JsonKey(defaultValue: '')
  final String productId;

  /// The [ProductType] of the product.
  @JsonKey(defaultValue: ProductType.subs)
  final ProductType productType;

  /// A list containing all available offers to purchase a subscription product.
  ///
  /// [subscriptionOfferDetails] is only set for [ProductType.subs]. Returns
  /// null for [ProductType.inapp].
  @JsonKey(defaultValue: null)
  final List<SubscriptionOfferDetailsWrapper>? subscriptionOfferDetails;

  /// The title of the product being sold.
  ///
  /// Similar to [name], but includes the name of the app which owns the
  /// product. Example: 100 Gold Coins (Coin selling app).
  @JsonKey(defaultValue: '')
  final String title;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is ProductDetailsWrapper &&
        other.description == description &&
        other.name == name &&
        other.oneTimePurchaseOfferDetails == oneTimePurchaseOfferDetails &&
        other.productId == productId &&
        other.productType == productType &&
        listEquals(other.subscriptionOfferDetails, subscriptionOfferDetails) &&
        other.title == title;
  }

  @override
  int get hashCode {
    return Object.hash(
      description.hashCode,
      name.hashCode,
      oneTimePurchaseOfferDetails.hashCode,
      productId.hashCode,
      productType.hashCode,
      subscriptionOfferDetails.hashCode,
      title.hashCode,
    );
  }
}

/// Translation of [`com.android.billingclient.api.ProductDetailsResponseListener`](https://developer.android.com/reference/com/android/billingclient/api/ProductDetailsResponseListener.html).
///
/// Returned by [BillingClient.queryProductDetails].
@JsonSerializable()
@immutable
class ProductDetailsResponseWrapper implements HasBillingResponse {
  /// Creates a [ProductDetailsResponseWrapper] with the given purchase details.
  const ProductDetailsResponseWrapper({
    required this.billingResult,
    required this.productDetailsList,
  });

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  factory ProductDetailsResponseWrapper.fromJson(Map<String, dynamic> map) =>
      _$ProductDetailsResponseWrapperFromJson(map);

  /// The final result of the [BillingClient.queryProductDetails] call.
  final BillingResultWrapper billingResult;

  /// A list of [ProductDetailsWrapper] matching the query to [BillingClient.queryProductDetails].
  @JsonKey(defaultValue: <ProductDetailsWrapper>[])
  final List<ProductDetailsWrapper> productDetailsList;

  @override
  BillingResponse get responseCode => billingResult.responseCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is ProductDetailsResponseWrapper &&
        other.billingResult == billingResult &&
        other.productDetailsList == productDetailsList;
  }

  @override
  int get hashCode => Object.hash(billingResult, productDetailsList);
}

/// Recurrence mode of the pricing phase.
@JsonEnum(alwaysCreate: true)
enum RecurrenceMode {
  /// The billing plan payment recurs for a fixed number of billing period set
  /// in billingCycleCount.
  @JsonValue(2)
  finiteRecurring,

  /// The billing plan payment recurs for infinite billing periods unless
  /// cancelled.
  @JsonValue(1)
  infiniteRecurring,

  /// The billing plan payment is a one time charge that does not repeat.
  @JsonValue(3)
  nonRecurring,
}

/// Serializer for [RecurrenceMode].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@RecurrenceModeConverter()`.
class RecurrenceModeConverter implements JsonConverter<RecurrenceMode, int?> {
  /// Default const constructor.
  const RecurrenceModeConverter();

  @override
  RecurrenceMode fromJson(int? json) {
    if (json == null) {
      return RecurrenceMode.nonRecurring;
    }
    return $enumDecode(_$RecurrenceModeEnumMap, json);
  }

  @override
  int toJson(RecurrenceMode object) => _$RecurrenceModeEnumMap[object]!;
}
