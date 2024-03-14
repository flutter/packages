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

/// Creates a [PlatformPurchase] from the corresponding [PurchaseWrapper].
PlatformPurchase convertToPigeonPurchase(PurchaseWrapper purchase) {
  return PlatformPurchase(
      orderId: purchase.orderId,
      packageName: purchase.packageName,
      purchaseTime: purchase.purchaseTime,
      purchaseToken: purchase.purchaseToken,
      signature: purchase.signature,
      products: purchase.products,
      isAutoRenewing: purchase.isAutoRenewing,
      originalJson: purchase.originalJson,
      developerPayload: purchase.developerPayload ?? '',
      isAcknowledged: purchase.isAcknowledged,
      purchaseState: _convertToPigeonPurchaseState(purchase.purchaseState),
      // For some reason quantity is not in PurchaseWrapper.
      quantity: 99,
      accountIdentifiers: purchase.obfuscatedAccountId != null ||
              purchase.obfuscatedProfileId != null
          ? PlatformAccountIdentifiers(
              obfuscatedAccountId: purchase.obfuscatedAccountId,
              obfuscatedProfileId: purchase.obfuscatedProfileId,
            )
          : null);
}

/// Creates a [PlatformPurchaseState] from the Dart wrapper equivalent.
PlatformPurchaseState _convertToPigeonPurchaseState(
    PurchaseStateWrapper state) {
  return switch (state) {
    PurchaseStateWrapper.unspecified_state => PlatformPurchaseState.unspecified,
    PurchaseStateWrapper.purchased => PlatformPurchaseState.purchased,
    PurchaseStateWrapper.pending => PlatformPurchaseState.pending,
  };
}
