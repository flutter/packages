// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';

/// Creates the [PlatformBillingResult] to return from a mock to get
/// [targetResult].
///
/// Since [PlatformBillingResult] returns a non-nullable debug string, the
/// target must have a non-null string as well.
PlatformBillingResult convertToPigeonResult(BillingResultWrapper targetResult) {
  return PlatformBillingResult(
    responseCode:
        const BillingResponseConverter().toJson(targetResult.responseCode),
    debugMessage: targetResult.debugMessage!,
  );
}
