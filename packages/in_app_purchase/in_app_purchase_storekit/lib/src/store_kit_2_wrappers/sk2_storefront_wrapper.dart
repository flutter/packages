// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../in_app_purchase_apis.dart';

/// Wrapper for StoreKit2's Storefront
/// (https://developer.apple.com/documentation/storekit/storefront)
final class Storefront {
  /// Dart wrapper for StoreKit2's countryCode()
  /// Returns the 3 letter code for a store's locale
  /// (https://developer.apple.com/documentation/storekit/storefront/countrycode)
  Future<String> countryCode() async {
    return hostApi2.countryCode();
  }
}
