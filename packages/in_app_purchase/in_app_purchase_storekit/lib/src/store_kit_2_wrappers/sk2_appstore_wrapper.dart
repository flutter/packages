// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../store_kit_2_wrappers.dart';

InAppPurchase2API _hostApi = InAppPurchase2API();

/// Wrapper for StoreKit2's AppStore
/// (https://developer.apple.com/documentation/storekit/appstore)
final class AppStore {
  /// Dart wrapper for StoreKit2's canMakePayments()
  /// Returns a bool that indicates whether the person can make purchases.
  /// https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments
  Future<bool> canMakePayments() {
    return _hostApi.canMakePayments();
  }

  /// Dart wrapper for StoreKit2's sync()
  /// Synchronizes your app’s transaction information and subscription status with information from the App Store.
  /// Will initiate an authentication pop up.
  /// https://developer.apple.com/documentation/storekit/appstore/sync()
  Future<void> sync() {
    return _hostApi.sync();
  }
}
