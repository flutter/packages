// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../billing_client_wrappers.dart';
import 'billing_client_wrappers/billing_config_wrapper.dart';
import 'messages.g.dart';

/// Converts a [BillingChoiceMode] to the Pigeon equivalent.
PlatformBillingChoiceMode platformBillingChoiceMode(BillingChoiceMode mode) {
  return switch (mode) {
    BillingChoiceMode.playBillingOnly =>
      PlatformBillingChoiceMode.playBillingOnly,
    BillingChoiceMode.alternativeBillingOnly =>
      PlatformBillingChoiceMode.alternativeBillingOnly,
    BillingChoiceMode.userChoiceBilling =>
      PlatformBillingChoiceMode.userChoiceBilling,
  };
}

/// Creates a [BillingResultWrapper] from the Pigeon equivalent.
BillingResultWrapper resultWrapperFromPlatform(PlatformBillingResult result) {
  return BillingResultWrapper(
      responseCode:
          const BillingResponseConverter().fromJson(result.responseCode),
      debugMessage: result.debugMessage);
}

/// Creates a [ProductDetailsResponseWrapper] from the Pigeon equivalent.
ProductDetailsResponseWrapper productDetailsResponseWrapperFromPlatform(
    PlatformProductDetailsResponse response) {
  return ProductDetailsResponseWrapper(
    billingResult: resultWrapperFromPlatform(response.billingResult),
    // See TODOs in messages.dart for why this is currently JSON.
    productDetailsList: response.productDetailsJsonList
        .map((Object? json) => ProductDetailsWrapper.fromJson(
            (json! as Map<Object?, Object?>).cast<String, Object?>()))
        .toList(),
  );
}

/// Creates a [PurchaseHistoryResult] from the Pigeon equivalent.
PurchasesHistoryResult purchaseHistoryResultFromPlatform(
    PlatformPurchaseHistoryResponse response) {
  return PurchasesHistoryResult(
    billingResult: resultWrapperFromPlatform(response.billingResult),
    purchaseHistoryRecordList: response.purchases
        // See comment in messages.dart for why casting away nullability is safe.
        .cast<PlatformPurchaseHistoryRecord>()
        .map(purchaseHistoryRecordWrapperFromPlatform)
        .toList(),
  );
}

/// Creates a [PurchaseHistoryRecordWrapper] from the Pigeon equivalent.
PurchaseHistoryRecordWrapper purchaseHistoryRecordWrapperFromPlatform(
    PlatformPurchaseHistoryRecord record) {
  return PurchaseHistoryRecordWrapper(
    purchaseTime: record.purchaseTime,
    purchaseToken: record.purchaseToken,
    signature: record.signature,
    // See comment in messages.dart for why casting away nullability is safe.
    products: record.products.cast<String>(),
    originalJson: record.originalJson,
    developerPayload: record.developerPayload,
  );
}

/// Creates a [PurchasesResultWrapper] from the Pigeon equivalent.
PurchasesResultWrapper purchasesResultWrapperFromPlatform(
    PlatformPurchasesResponse response,
    {bool forceOkResponseCode = false}) {
  return PurchasesResultWrapper(
    billingResult: resultWrapperFromPlatform(response.billingResult),
    purchasesList: response.purchases
        // See TODOs in messages.dart for why casting away nullability is safe.
        .cast<PlatformPurchase>()
        .map(purchaseWrapperFromPlatform)
        .toList(),
    responseCode: forceOkResponseCode
        ? BillingResponse.ok
        : const BillingResponseConverter()
            .fromJson(response.billingResult.responseCode),
  );
}

/// Creates an [AlternativeBillingOnlyReportingDetailsWrapper] from the Pigeon
/// equivalent.
AlternativeBillingOnlyReportingDetailsWrapper
    alternativeBillingOnlyReportingDetailsWrapperFromPlatform(
        PlatformAlternativeBillingOnlyReportingDetailsResponse response) {
  return AlternativeBillingOnlyReportingDetailsWrapper(
    responseCode: const BillingResponseConverter()
        .fromJson(response.billingResult.responseCode),
    debugMessage: response.billingResult.debugMessage,
    externalTransactionToken: response.externalTransactionToken,
  );
}

/// Creates a [BillingConfigWrapper] from the Pigeon equivalent.
BillingConfigWrapper billingConfigWrapperFromPlatform(
    PlatformBillingConfigResponse response) {
  return BillingConfigWrapper(
    responseCode: const BillingResponseConverter()
        .fromJson(response.billingResult.responseCode),
    debugMessage: response.billingResult.debugMessage,
    countryCode: response.countryCode,
  );
}

/// Creates a Pigeon [PlatformProduct] from a [ProductWrapper].
PlatformQueryProduct platformQueryProductFromWrapper(ProductWrapper product) {
  return PlatformQueryProduct(
    productId: product.productId,
    productType: platformProductTypeFromWrapper(product.productType),
  );
}

/// Converts a [ProductType] to its Pigeon equivalent.
PlatformProductType platformProductTypeFromWrapper(ProductType type) {
  return switch (type) {
    ProductType.inapp => PlatformProductType.inapp,
    ProductType.subs => PlatformProductType.subs,
  };
}

/// Creates a [PurchaseWrapper] from the Pigeon equivalent.
PurchaseWrapper purchaseWrapperFromPlatform(PlatformPurchase purchase) {
  return PurchaseWrapper(
    orderId: purchase.orderId ?? '',
    packageName: purchase.packageName,
    purchaseTime: purchase.purchaseTime,
    purchaseToken: purchase.purchaseToken,
    signature: purchase.signature,
    // See comment in messages.dart for why casting away nullability is safe.
    products: purchase.products.cast<String>(),
    isAutoRenewing: purchase.isAutoRenewing,
    originalJson: purchase.originalJson,
    isAcknowledged: purchase.isAcknowledged,
    purchaseState: purchaseStateWrapperFromPlatform(purchase.purchaseState),
    developerPayload: purchase.developerPayload,
    obfuscatedAccountId: purchase.accountIdentifiers?.obfuscatedAccountId,
    obfuscatedProfileId: purchase.accountIdentifiers?.obfuscatedProfileId,
  );
}

/// Creates a [PurchaseStateWrapper] from the Pigeon equivalent.
PurchaseStateWrapper purchaseStateWrapperFromPlatform(
    PlatformPurchaseState state) {
  return switch (state) {
    PlatformPurchaseState.unspecified => PurchaseStateWrapper.unspecified_state,
    PlatformPurchaseState.purchased => PurchaseStateWrapper.purchased,
    PlatformPurchaseState.pending => PurchaseStateWrapper.pending,
  };
}

/// Creates a [UserChoiceDetailsWrapper] from the Pigeon equivalent.
UserChoiceDetailsWrapper userChoiceDetailsFromPlatform(
    PlatformUserChoiceDetails details) {
  return UserChoiceDetailsWrapper(
    originalExternalTransactionId: details.originalExternalTransactionId ?? '',
    externalTransactionToken: details.externalTransactionToken,
    // See TODOs in messages.dart for why this is currently JSON.
    products: details.productsJsonList
        .map((Object? json) => UserChoiceDetailsProductWrapper.fromJson(
            (json! as Map<Object?, Object?>).cast<String, Object?>()))
        .toList(),
  );
}
