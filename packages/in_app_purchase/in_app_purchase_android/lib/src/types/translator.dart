// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../../billing_client_wrappers.dart';
import 'google_play_user_choice_details.dart';

/// Class used to convert cross process object into api expose objects.
class Translator {
  Translator._();

  /// Converts from [UserChoiceDetailsWrapper] to [GooglePlayUserChoiceDetails].
  static GooglePlayUserChoiceDetails convertToUserChoiceDetails(
      UserChoiceDetailsWrapper detailsWrapper) {
    return GooglePlayUserChoiceDetails(
        originalExternalTransactionId:
            detailsWrapper.originalExternalTransactionId,
        externalTransactionToken: detailsWrapper.externalTransactionToken,
        products: detailsWrapper.products
            .map((UserChoiceDetailsProductWrapper e) =>
                convertToUserChoiceDetailsProduct(e))
            .toList());
  }

  /// Converts from [UserChoiceDetailsProductWrapper] to [GooglePlayUserChoiceDetailsProduct].
  @visibleForTesting
  static GooglePlayUserChoiceDetailsProduct convertToUserChoiceDetailsProduct(
      UserChoiceDetailsProductWrapper productWrapper) {
    return GooglePlayUserChoiceDetailsProduct(
        id: productWrapper.id,
        offerToken: productWrapper.offerToken,
        productType: convertToPlayProductType(productWrapper.productType));
  }

  /// Coverts from [ProductType] to [GooglePlayProductType].
  @visibleForTesting
  static GooglePlayProductType convertToPlayProductType(ProductType type) {
    switch (type) {
      case ProductType.inapp:
        return GooglePlayProductType.inapp;
      case ProductType.subs:
        return GooglePlayProductType.subs;
    }
  }
}
