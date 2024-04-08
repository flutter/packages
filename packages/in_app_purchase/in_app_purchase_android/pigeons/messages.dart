// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.inapppurchase'),
  javaOut:
      'android/src/main/java/io/flutter/plugins/inapppurchase/Messages.java',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon version of Java QueryProductDetailsParams.Product.
class PlatformQueryProduct {
  PlatformQueryProduct({required this.productId, required this.productType});

  final String productId;
  final PlatformProductType productType;
}

/// Pigeon version of Java AccountIdentifiers.
class PlatformAccountIdentifiers {
  PlatformAccountIdentifiers({
    required this.obfuscatedAccountId,
    required this.obfuscatedProfileId,
  });

  final String? obfuscatedAccountId;
  final String? obfuscatedProfileId;
}

/// Pigeon version of Java BillingResult.
class PlatformBillingResult {
  PlatformBillingResult(
      {required this.responseCode, required this.debugMessage});
  final int responseCode;
  final String debugMessage;
}

/// Pigeon version of Java ProductDetails.OneTimePurchaseOfferDetails.
class PlatformOneTimePurchaseOfferDetails {
  PlatformOneTimePurchaseOfferDetails({
    required this.priceAmountMicros,
    required this.formattedPrice,
    required this.priceCurrencyCode,
  });

  final int priceAmountMicros;
  final String formattedPrice;
  final String priceCurrencyCode;
}

/// Pigeon version of Java ProductDetails.
class PlatformProductDetails {
  PlatformProductDetails({
    required this.description,
    required this.name,
    required this.productId,
    required this.productType,
    required this.title,
    required this.oneTimePurchaseOfferDetails,
    required this.subscriptionOfferDetails,
  });

  final String description;
  final String name;
  final String productId;
  final PlatformProductType productType;
  final String title;
  final PlatformOneTimePurchaseOfferDetails? oneTimePurchaseOfferDetails;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it (the entries, not the list itself) as
  // non-nullable.
  final List<PlatformSubscriptionOfferDetails?>? subscriptionOfferDetails;
}

/// Pigeon version of ProductDetailsResponseWrapper, which contains the
/// components of the Java ProductDetailsResponseListener callback.
class PlatformProductDetailsResponse {
  PlatformProductDetailsResponse({
    required this.billingResult,
    required this.productDetails,
  });

  final PlatformBillingResult billingResult;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<PlatformProductDetails?> productDetails;
}

/// Pigeon version of AlternativeBillingOnlyReportingDetailsWrapper, which
/// contains the components of the Java
/// AlternativeBillingOnlyReportingDetailsListener callback.
class PlatformAlternativeBillingOnlyReportingDetailsResponse {
  PlatformAlternativeBillingOnlyReportingDetailsResponse(
      {required this.billingResult, required this.externalTransactionToken});

  final PlatformBillingResult billingResult;
  final String externalTransactionToken;
}

/// Pigeon version of BillingConfigWrapper, which contains the components of the
/// Java BillingConfigResponseListener callback.
class PlatformBillingConfigResponse {
  PlatformBillingConfigResponse(
      {required this.billingResult, required this.countryCode});

  final PlatformBillingResult billingResult;
  final String countryCode;
}

/// Pigeon version of Java BillingFlowParams.
class PlatformBillingFlowParams {
  PlatformBillingFlowParams({
    required this.product,
    required this.prorationMode,
    required this.offerToken,
    required this.accountId,
    required this.obfuscatedProfileId,
    required this.oldProduct,
    required this.purchaseToken,
  });

  final String product;
  // Ideally this would be replaced with an enum on the dart side that maps
  // to constants on the Java side, but it's deprecated anyway so that will be
  // resolved during the update to the new API.
  final int prorationMode;
  final String? offerToken;
  final String? accountId;
  final String? obfuscatedProfileId;
  final String? oldProduct;
  final String? purchaseToken;
}

/// Pigeon version of Java ProductDetails.PricingPhase.
class PlatformPricingPhase {
  PlatformPricingPhase({
    required this.billingCycleCount,
    required this.recurrenceMode,
    required this.priceAmountMicros,
    required this.billingPeriod,
    required this.formattedPrice,
    required this.priceCurrencyCode,
  });

  final int billingCycleCount;
  final PlatformRecurrenceMode recurrenceMode;
  final int priceAmountMicros;
  final String billingPeriod;
  final String formattedPrice;
  final String priceCurrencyCode;
}

/// Pigeon version of Java Purchase.
///
/// See also PurchaseWrapper on the Dart side.
class PlatformPurchase {
  const PlatformPurchase({
    required this.orderId,
    required this.packageName,
    required this.purchaseTime,
    required this.purchaseToken,
    required this.signature,
    required this.products,
    required this.isAutoRenewing,
    required this.originalJson,
    required this.developerPayload,
    required this.isAcknowledged,
    required this.quantity,
    required this.purchaseState,
    required this.accountIdentifiers,
  });

  final String? orderId;
  final String packageName;
  final int purchaseTime;
  final String purchaseToken;
  final String signature;
  // TODO(stuartmorgan): Make the type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<String?> products;
  final bool isAutoRenewing;
  final String originalJson;
  final String developerPayload;
  final bool isAcknowledged;
  final int quantity;
  final PlatformPurchaseState purchaseState;
  final PlatformAccountIdentifiers? accountIdentifiers;
}

/// Pigeon version of PurchaseHistoryRecord.
///
/// See also PurchaseHistoryRecordWrapper on the Dart side.
class PlatformPurchaseHistoryRecord {
  PlatformPurchaseHistoryRecord({
    required this.quantity,
    required this.purchaseTime,
    required this.developerPayload,
    required this.originalJson,
    required this.purchaseToken,
    required this.signature,
    required this.products,
  });

  final int quantity;
  final int purchaseTime;
  final String? developerPayload;
  final String originalJson;
  final String purchaseToken;
  final String signature;
  // TODO(stuartmorgan): Make the type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<String?> products;
}

/// Pigeon version of PurchasesHistoryResult, which contains the components of
/// the Java PurchaseHistoryResponseListener callback.
class PlatformPurchaseHistoryResponse {
  PlatformPurchaseHistoryResponse({
    required this.billingResult,
    required this.purchases,
  });

  final PlatformBillingResult billingResult;
  // TODO(stuartmorgan): Make the type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<PlatformPurchaseHistoryRecord?> purchases;
}

/// Pigeon version of PurchasesResultWrapper, which contains the components of
/// the Java PurchasesResponseListener callback.
class PlatformPurchasesResponse {
  PlatformPurchasesResponse({
    required this.billingResult,
    required this.purchases,
  });

  final PlatformBillingResult billingResult;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<PlatformPurchase?> purchases;
}

/// Pigeon version of Java ProductDetails.SubscriptionOfferDetails.
class PlatformSubscriptionOfferDetails {
  PlatformSubscriptionOfferDetails({
    required this.basePlanId,
    required this.offerId,
    required this.offerToken,
    required this.offerTags,
    required this.pricingPhases,
  });

  final String basePlanId;
  final String? offerId;
  final String offerToken;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<String?> offerTags;
  // On the native side this is actually a class called PricingPhases,
  // which contains nothing but a List<PricingPhase>. Since this is an
  // internal API, we can always add that indirection later if we need it,
  // so for now this bypasses that unnecessary wrapper.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<PlatformPricingPhase?> pricingPhases;
}

/// Pigeon version of UserChoiceDetailsWrapper and Java UserChoiceDetails.
class PlatformUserChoiceDetails {
  PlatformUserChoiceDetails({
    required this.originalExternalTransactionId,
    required this.externalTransactionToken,
    required this.products,
  });

  final String? originalExternalTransactionId;
  final String externalTransactionToken;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<PlatformUserChoiceProduct?> products;
}

/// Pigeon version of UserChoiseDetails.Product.
class PlatformUserChoiceProduct {
  PlatformUserChoiceProduct({
    required this.id,
    required this.offerToken,
    required this.type,
  });

  final String id;
  final String? offerToken;
  final PlatformProductType type;
}

/// Pigeon version of Java BillingClient.ProductType.
enum PlatformProductType {
  inapp,
  subs,
}

/// Pigeon version of billing_client_wrapper.dart's BillingChoiceMode.
enum PlatformBillingChoiceMode {
  /// Billing through google play.
  ///
  /// Default state.
  playBillingOnly,

  /// Billing through app provided flow.
  alternativeBillingOnly,

  /// Users can choose Play billing or alternative billing.
  userChoiceBilling,
}

/// Pigeon version of Java Purchase.PurchaseState.
enum PlatformPurchaseState {
  unspecified,
  purchased,
  pending,
}

/// Pigeon version of Java ProductDetails.RecurrenceMode.
enum PlatformRecurrenceMode {
  finiteRecurring,
  infiniteRecurring,
  nonRecurring,
}

@HostApi()
abstract class InAppPurchaseApi {
  /// Wraps BillingClient#isReady.
  bool isReady();

  /// Wraps BillingClient#startConnection(BillingClientStateListener).
  @async
  PlatformBillingResult startConnection(
      int callbackHandle, PlatformBillingChoiceMode billingMode);

  /// Wraps BillingClient#endConnection(BillingClientStateListener).
  void endConnection();

  /// Wraps BillingClient#getBillingConfigAsync(GetBillingConfigParams, BillingConfigResponseListener).
  @async
  PlatformBillingConfigResponse getBillingConfigAsync();

  /// Wraps BillingClient#launchBillingFlow(Activity, BillingFlowParams).
  PlatformBillingResult launchBillingFlow(PlatformBillingFlowParams params);

  /// Wraps BillingClient#acknowledgePurchase(AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener).
  @async
  PlatformBillingResult acknowledgePurchase(String purchaseToken);

  /// Wraps BillingClient#consumeAsync(ConsumeParams, ConsumeResponseListener).
  @async
  PlatformBillingResult consumeAsync(String purchaseToken);

  /// Wraps BillingClient#queryPurchasesAsync(QueryPurchaseParams, PurchaseResponseListener).
  @async
  PlatformPurchasesResponse queryPurchasesAsync(
      PlatformProductType productType);

  /// Wraps BillingClient#queryPurchaseHistoryAsync(QueryPurchaseHistoryParams, PurchaseHistoryResponseListener).
  @async
  PlatformPurchaseHistoryResponse queryPurchaseHistoryAsync(
      PlatformProductType productType);

  /// Wraps BillingClient#queryProductDetailsAsync(QueryProductDetailsParams, ProductDetailsResponseListener).
  @async
  PlatformProductDetailsResponse queryProductDetailsAsync(
      List<PlatformQueryProduct> products);

  /// Wraps BillingClient#isFeatureSupported(String).
  // TODO(stuartmorgan): Consider making this take a enum, and converting the
  // enum value to string constants on the native side, so that magic strings
  // from the Play Billing API aren't duplicated in Dart code.
  bool isFeatureSupported(String feature);

  /// Wraps BillingClient#isAlternativeBillingOnlyAvailableAsync().
  @async
  PlatformBillingResult isAlternativeBillingOnlyAvailableAsync();

  /// Wraps BillingClient#showAlternativeBillingOnlyInformationDialog().
  @async
  PlatformBillingResult showAlternativeBillingOnlyInformationDialog();

  /// Wraps BillingClient#createAlternativeBillingOnlyReportingDetailsAsync(AlternativeBillingOnlyReportingDetailsListener).
  @async
  PlatformAlternativeBillingOnlyReportingDetailsResponse
      createAlternativeBillingOnlyReportingDetailsAsync();
}

@FlutterApi()
abstract class InAppPurchaseCallbackApi {
  /// Called for BillingClientStateListener#onBillingServiceDisconnected().
  void onBillingServiceDisconnected(int callbackHandle);

  /// Called for PurchasesUpdatedListener#onPurchasesUpdated(BillingResult, List<Purchase>).
  void onPurchasesUpdated(PlatformPurchasesResponse update);

  /// Called for UserChoiceBillingListener#userSelectedAlternativeBilling(UserChoiceDetails).
  void userSelectedalternativeBilling(PlatformUserChoiceDetails details);
}
