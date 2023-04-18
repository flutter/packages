// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../billing_client_wrappers.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'product_wrapper.g.dart';

/// Dart wrapper around [`com.android.billingclient.api.Product`](https://developer.android.com/reference/com/android/billingclient/api/QueryProductDetailsParams.Product).
@JsonSerializable(createToJson: true)
@immutable
class ProductWrapper {
  /// Creates a new [ProductWrapper].
  const ProductWrapper({
    required this.productId,
    required this.productType,
  });

  /// Creates a JSON representation of this product.
  Map<String, dynamic> toJson() => _$ProductWrapperToJson(this);

  /// The product identifier.
  @JsonKey(defaultValue: '')
  final String productId;

  /// The product type.
  final ProductType productType;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ProductWrapper &&
        other.productId == productId &&
        other.productType == productType;
  }

  @override
  int get hashCode => Object.hash(productId, productType);
}
