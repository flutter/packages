// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../billing_client_wrappers.dart';

/// Data structure representing a successful purchase.
///
/// All purchase information should also be verified manually, with your
/// server if at all possible. See ["Verify a
/// purchase"](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
///
/// This wraps [`com.android.billlingclient.api.Purchase`](https://developer.android.com/reference/com/android/billingclient/api/Purchase)
@immutable
class PurchaseWrapper {
  /// Creates a purchase wrapper with the given purchase details.
  const PurchaseWrapper({
    required this.orderId,
    required this.packageName,
    required this.purchaseTime,
    required this.purchaseToken,
    required this.signature,
    required this.products,
    required this.isAutoRenewing,
    required this.originalJson,
    this.developerPayload,
    required this.isAcknowledged,
    required this.purchaseState,
    this.obfuscatedAccountId,
    this.obfuscatedProfileId,
    this.pendingPurchaseUpdate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchaseWrapper &&
        other.orderId == orderId &&
        other.packageName == packageName &&
        other.purchaseTime == purchaseTime &&
        other.purchaseToken == purchaseToken &&
        other.signature == signature &&
        listEquals(other.products, products) &&
        other.isAutoRenewing == isAutoRenewing &&
        other.originalJson == originalJson &&
        other.isAcknowledged == isAcknowledged &&
        other.purchaseState == purchaseState &&
        other.pendingPurchaseUpdate == pendingPurchaseUpdate;
  }

  @override
  int get hashCode => Object.hash(
      orderId,
      packageName,
      purchaseTime,
      purchaseToken,
      signature,
      products.hashCode,
      isAutoRenewing,
      originalJson,
      isAcknowledged,
      purchaseState,
      pendingPurchaseUpdate);

  /// The unique ID for this purchase. Corresponds to the Google Payments order
  /// ID.
  final String orderId;

  /// The package name the purchase was made from.
  final String packageName;

  /// When the purchase was made, as an epoch timestamp.
  final int purchaseTime;

  /// A unique ID for a given [ProductDetailsWrapper], user, and purchase.
  final String purchaseToken;

  /// Signature of purchase data, signed with the developer's private key. Uses
  /// RSASSA-PKCS1-v1_5.
  final String signature;

  /// The product IDs of this purchase.
  final List<String> products;

  /// True for subscriptions that renew automatically. Does not apply to
  /// [ProductType.inapp] products.
  ///
  /// For [ProductType.subs] this means that the subscription is canceled when it is
  /// false.
  ///
  /// The value is `false` for [ProductType.inapp] products.
  final bool isAutoRenewing;

  /// Details about this purchase, in JSON.
  ///
  /// This can be used verify a purchase. See ["Verify a purchase on a
  /// device"](https://developer.android.com/google/play/billing/billing_library_overview#Verify-purchase-device).
  /// Note though that verifying a purchase locally is inherently insecure (see
  /// the article for more details).
  final String originalJson;

  /// The payload specified by the developer when the purchase was acknowledged or consumed.
  ///
  /// The value is `null` if it wasn't specified when the purchase was acknowledged or consumed.
  /// The `developerPayload` is removed from [BillingClientWrapper.acknowledgePurchase], [BillingClientWrapper.consumeAsync], [InAppPurchaseConnection.completePurchase], [InAppPurchaseConnection.consumePurchase]
  /// after plugin version `0.5.0`. As a result, this will be `null` for new purchases that happen after updating to `0.5.0`.
  final String? developerPayload;

  /// Whether the purchase has been acknowledged.
  ///
  /// A successful purchase has to be acknowledged within 3 days after the purchase via [BillingClient.acknowledgePurchase].
  /// * See also [BillingClient.acknowledgePurchase] for more details on acknowledging purchases.
  final bool isAcknowledged;

  /// Determines the current state of the purchase.
  ///
  /// [BillingClient.acknowledgePurchase] should only be called when the `purchaseState` is [PurchaseStateWrapper.purchased].
  /// * See also [BillingClient.acknowledgePurchase] for more details on acknowledging purchases.
  final PurchaseStateWrapper purchaseState;

  /// The obfuscatedAccountId specified when making a purchase.
  ///
  /// The [obfuscatedAccountId] can either be set in
  /// [PurchaseParam.applicationUserName] when using the [InAppPurchasePlatform]
  /// or by setting the [accountId] in [BillingClient.launchBillingFlow].
  final String? obfuscatedAccountId;

  /// The obfuscatedProfileId can be used when there are multiple profiles
  /// withing one account. The obfuscatedProfileId should be specified when
  /// making a purchase. This property can only be set on a purchase by
  /// directly calling [BillingClient.launchBillingFlow] and is not available
  /// on the generic [InAppPurchasePlatform].
  final String? obfuscatedProfileId;

  /// The [PendingPurchaseUpdateWrapper] for an uncommitted transaction.
  ///
  /// A PendingPurchaseUpdate is normally generated from a pending transaction
  /// upgrading/downgrading an existing subscription.
  /// Returns null if this purchase does not have a pending transaction.
  final PendingPurchaseUpdateWrapper? pendingPurchaseUpdate;
}

@immutable

/// Represents a pending change/update to the existing purchase.
///
/// This wraps [`com.android.billingclient.api.Purchase.PendingPurchaseUpdate`](https://developer.android.com/reference/com/android/billingclient/api/Purchase.PendingPurchaseUpdate).
class PendingPurchaseUpdateWrapper {
  /// Creates a pending purchase wrapper update wrapper with the given purchase details.
  const PendingPurchaseUpdateWrapper({
    required this.purchaseToken,
    required this.products,
  });

  /// A token that uniquely identifies this pending transaction.
  final String purchaseToken;

  /// The product IDs of this pending purchase update.
  final List<String> products;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PendingPurchaseUpdateWrapper &&
        other.purchaseToken == purchaseToken &&
        listEquals(other.products, products);
  }

  @override
  int get hashCode => Object.hash(
        purchaseToken,
        products.hashCode,
      );
}

/// Data structure representing a purchase history record.
///
/// This class includes a subset of fields in [PurchaseWrapper].
///
/// This wraps [`com.android.billlingclient.api.PurchaseHistoryRecord`](https://developer.android.com/reference/com/android/billingclient/api/PurchaseHistoryRecord)
///
/// * See also: [BillingClient.queryPurchaseHistory] for obtaining a [PurchaseHistoryRecordWrapper].
// We can optionally make [PurchaseWrapper] extend or implement [PurchaseHistoryRecordWrapper].
// For now, we keep them separated classes to be consistent with Android's BillingClient implementation.
@immutable
class PurchaseHistoryRecordWrapper {
  /// Creates a [PurchaseHistoryRecordWrapper] with the given record details.
  const PurchaseHistoryRecordWrapper({
    required this.purchaseTime,
    required this.purchaseToken,
    required this.signature,
    required this.products,
    required this.originalJson,
    required this.developerPayload,
  });

  /// When the purchase was made, as an epoch timestamp.
  final int purchaseTime;

  /// A unique ID for a given [ProductDetailsWrapper], user, and purchase.
  final String purchaseToken;

  /// Signature of purchase data, signed with the developer's private key. Uses
  /// RSASSA-PKCS1-v1_5.
  final String signature;

  /// The product ID of this purchase.
  final List<String> products;

  /// Details about this purchase, in JSON.
  ///
  /// This can be used verify a purchase. See ["Verify a purchase on a
  /// device"](https://developer.android.com/google/play/billing/billing_library_overview#Verify-purchase-device).
  /// Note though that verifying a purchase locally is inherently insecure (see
  /// the article for more details).
  final String originalJson;

  /// The payload specified by the developer when the purchase was acknowledged or consumed.
  ///
  /// The value is `null` if it wasn't specified when the purchase was acknowledged or consumed.
  final String? developerPayload;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchaseHistoryRecordWrapper &&
        other.purchaseTime == purchaseTime &&
        other.purchaseToken == purchaseToken &&
        other.signature == signature &&
        listEquals(other.products, products) &&
        other.originalJson == originalJson &&
        other.developerPayload == developerPayload;
  }

  @override
  int get hashCode => Object.hash(
        purchaseTime,
        purchaseToken,
        signature,
        products.hashCode,
        originalJson,
        developerPayload,
      );
}

/// A data struct representing the result of a transaction.
///
/// Contains a potentially empty list of [PurchaseWrapper]s, a [BillingResultWrapper]
/// that contains a detailed description of the status and a
/// [BillingResponse] to signify the overall state of the transaction.
///
/// Wraps [`com.android.billingclient.api.Purchase.PurchasesResult`](https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchasesResult).
@immutable
class PurchasesResultWrapper implements HasBillingResponse {
  /// Creates a [PurchasesResultWrapper] with the given purchase result details.
  const PurchasesResultWrapper(
      {required this.responseCode,
      required this.billingResult,
      required this.purchasesList});

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchasesResultWrapper &&
        other.responseCode == responseCode &&
        other.purchasesList == purchasesList &&
        other.billingResult == billingResult;
  }

  @override
  int get hashCode => Object.hash(billingResult, responseCode, purchasesList);

  /// The detailed description of the status of the operation.
  final BillingResultWrapper billingResult;

  /// The status of the operation.
  ///
  /// This can represent either the status of the "query purchase history" half
  /// of the operation and the "user made purchases" transaction itself.
  @override
  final BillingResponse responseCode;

  /// The list of successful purchases made in this transaction.
  ///
  /// May be empty, especially if [responseCode] is not [BillingResponse.ok].
  final List<PurchaseWrapper> purchasesList;
}

/// A data struct representing the result of a purchase history.
///
/// Contains a potentially empty list of [PurchaseHistoryRecordWrapper]s and a [BillingResultWrapper]
/// that contains a detailed description of the status.
@immutable
class PurchasesHistoryResult implements HasBillingResponse {
  /// Creates a [PurchasesHistoryResult] with the provided history.
  const PurchasesHistoryResult(
      {required this.billingResult, required this.purchaseHistoryRecordList});

  @override
  BillingResponse get responseCode => billingResult.responseCode;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchasesHistoryResult &&
        other.purchaseHistoryRecordList == purchaseHistoryRecordList &&
        other.billingResult == billingResult;
  }

  @override
  int get hashCode => Object.hash(billingResult, purchaseHistoryRecordList);

  /// The detailed description of the status of the [BillingClient.queryPurchaseHistory].
  final BillingResultWrapper billingResult;

  /// The list of queried purchase history records.
  ///
  /// May be empty, especially if [billingResult.responseCode] is not [BillingResponse.ok].
  final List<PurchaseHistoryRecordWrapper> purchaseHistoryRecordList;
}

/// Possible state of a [PurchaseWrapper].
///
/// Wraps
/// [`BillingClient.api.Purchase.PurchaseState`](https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState.html).
/// * See also: [PurchaseWrapper].
enum PurchaseStateWrapper {
  /// The state is unspecified.
  ///
  /// No actions on the [PurchaseWrapper] should be performed on this state.
  /// This is a catch-all. It should never be returned by the Play Billing Library.
  unspecified_state,

  /// The user has completed the purchase process.
  ///
  /// The production should be delivered and then the purchase should be acknowledged.
  /// * See also [BillingClient.acknowledgePurchase] for more details on acknowledging purchases.
  purchased,

  /// The user has started the purchase process.
  ///
  /// The user should follow the instructions that were given to them by the Play
  /// Billing Library to complete the purchase.
  ///
  /// You can also choose to remind the user to complete the purchase if you detected a
  /// [PurchaseWrapper] is still in the `pending` state in the future while calling [BillingClient.queryPurchases].
  pending,
}
