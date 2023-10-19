// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:test/test.dart';

const ProductWrapper dummyProduct = ProductWrapper(
  productId: 'id',
  productType: ProductType.inapp,
);

void main() {
  group('ProductWrapper', () {
    test('converts product from map', () {
      const ProductWrapper expected = dummyProduct;
      final ProductWrapper parsed = productFromJson(expected.toJson());

      expect(parsed, equals(expected));
    });
  });
}

ProductWrapper productFromJson(Map<String, dynamic> serialized) {
  return ProductWrapper(
    productId: serialized['productId'] as String,
    productType: const ProductTypeConverter()
        .fromJson(serialized['productType'] as String),
  );
}
