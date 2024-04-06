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
    // See TODOs in messages.dart for why this is currently JSON.
    purchaseHistoryRecordList: response.purchaseHistoryRecordJsonList
        .map((Object? json) => PurchaseHistoryRecordWrapper.fromJson(
            (json! as Map<Object?, Object?>).cast<String, Object?>()))
        .toList(),
  );
}

/// Creates a [PurchasesResultWrapper] from the Pigeon equivalent.
PurchasesResultWrapper purchasesResultWrapperFromPlatform(
    PlatformPurchasesResponse response,
    {bool forceOkResponseCode = false}) {
  return PurchasesResultWrapper(
    billingResult: resultWrapperFromPlatform(response.billingResult),
    // See TODOs in messages.dart for why this is currently JSON.
    purchasesList: response.purchasesJsonList
        .map((Object? json) => PurchaseWrapper.fromJson(
            (json! as Map<Object?, Object?>).cast<String, Object?>()))
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
PlatformProduct platformProductFromWrapper(ProductWrapper product) {
  return PlatformProduct(
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
