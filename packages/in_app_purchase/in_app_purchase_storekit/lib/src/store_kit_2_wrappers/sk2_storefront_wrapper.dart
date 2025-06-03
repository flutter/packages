// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../store_kit_2_wrappers.dart';

InAppPurchase2API _hostApi = InAppPurchase2API();

/// Wrapper for StoreKit2's Storefront
/// (https://developer.apple.com/documentation/storekit/storefront)
final class Storefront {
  /// Dart wrapper for StoreKit2's countryCode()
  /// Returns the 3 letter code for a store's locale
  /// (https://developer.apple.com/documentation/storekit/storefront/countrycode)
  Future<String> countryCode() async {
    return _hostApi.countryCode();
  }
}
