// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../store_kit_2_wrappers.dart';

InAppPurchase2API _hostApi = InAppPurchase2API();

/// Wrapper for StoreKit2's AppStore
/// (https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments)
final class AppStore {
  Future<bool> canMakePayments() {
    return _hostApi.canMakePayments();
  }
}