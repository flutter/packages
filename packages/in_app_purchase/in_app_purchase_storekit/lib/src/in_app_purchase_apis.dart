// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'messages.g.dart';
import 'sk2_pigeon.g.dart';

/// The instance of the host API used to communicate with the platform side for
/// the original StoreKit API.
///
/// This is a global to allow tests to override the host API with a mock, since
/// in practice the host API is a singleton, and there is no way to inject it
/// in the usual way since many uses aren't in objects.
InAppPurchaseAPI hostApi = InAppPurchaseAPI();

/// The instance of the host API used to communicate with the platform side
/// for StoreKit2.
///
/// This is a global to allow tests to override the host API with a mock, since
/// in practice the host API is a singleton, and there is no way to inject it
/// in the usual way since many uses aren't in objects.
InAppPurchase2API hostApi2 = InAppPurchase2API();

/// Set up pigeon API.
@visibleForTesting
void setInAppPurchaseHostApis({
  InAppPurchaseAPI? api,
  InAppPurchase2API? api2,
}) {
  if (api != null) {
    hostApi = api;
  }

  if (api2 != null) {
    hostApi2 = api2;
  }
}
