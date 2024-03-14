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

/// Pigeon version of Java Product.
class PlatformProduct {
  PlatformProduct({required this.productId, required this.productType});

  final String productId;
  final PlatformProductType productType;
}

/// Pigeon version of Java BillingResult.
class PlatformBillingResult {
  PlatformBillingResult(
      {required this.responseCode, required this.debugMessage});
  final int responseCode;
  final String debugMessage;
}

/// Pigeon version of ProductDetailsResponseWrapper, which contains the
/// components of the Java ProductDetailsResponseListener callback.
class PlatformProductDetailsResponse {
  PlatformProductDetailsResponse({
    required this.billingResult,
    required this.productDetailsJsonList,
  });

  final PlatformBillingResult billingResult;

  /// A JSON-compatible list of details, where each entry in the list is a
  /// Map<String, Object?> JSON encoding of the product details.
  // TODO(stuartmorgan): Finish converting to Pigeon. This is still using the
  // old serialization system to allow conversion of all the method calls to
  // Pigeon without converting the entire object graph all at once. See
  // https://github.com/flutter/flutter/issues/117910. The list items are
  // currently untyped due to https://github.com/flutter/flutter/issues/116117.
  //
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<Object?> productDetailsJsonList;
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

/// Pigeon version of PurchasesHistoryResult, which contains the components of
/// the Java PurchaseHistoryResponseListener callback.
class PlatformPurchaseHistoryResponse {
  PlatformPurchaseHistoryResponse({
    required this.billingResult,
    required this.purchaseHistoryRecordJsonList,
  });

  final PlatformBillingResult billingResult;

  /// A JSON-compatible list of purchase history records, where each entry in
  /// the list is a Map<String, Object?> JSON encoding of the record.
  // TODO(stuartmorgan): Finish converting to Pigeon. This is still using the
  // old serialization system to allow conversion of all the method calls to
  // Pigeon without converting the entire object graph all at once. See
  // https://github.com/flutter/flutter/issues/117910. The list items are
  // currently untyped due to https://github.com/flutter/flutter/issues/116117.
  //
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<Object?> purchaseHistoryRecordJsonList;
}

/// Pigeon version of PurchasesResultWrapper, which contains the components of
/// the Java PurchasesResponseListener callback.
class PlatformPurchasesResponse {
  PlatformPurchasesResponse({
    required this.billingResult,
    required this.purchasesJsonList,
  });

  final PlatformBillingResult billingResult;

  /// A JSON-compatible list of purchases, where each entry in the list is a
  /// Map<String, Object?> JSON encoding of the product details.
  // TODO(stuartmorgan): Finish converting to Pigeon. This is still using the
  // old serialization system to allow conversion of all the method calls to
  // Pigeon without converting the entire object graph all at once. See
  // https://github.com/flutter/flutter/issues/117910. The list items are
  // currently untyped due to https://github.com/flutter/flutter/issues/116117.
  //
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<Object?> purchasesJsonList;
}

/// Pigeon version of UserChoiceDetailsWrapper and Java UserChoiceDetails.
class PlatformUserChoiceDetails {
  PlatformUserChoiceDetails({
    required this.originalExternalTransactionId,
    required this.externalTransactionToken,
    required this.productsJsonList,
  });

  final String? originalExternalTransactionId;
  final String externalTransactionToken;

  /// A JSON-compatible list of products, where each entry in the list is a
  /// Map<String, Object?> JSON encoding of the product.
  // TODO(stuartmorgan): Finish converting to Pigeon. This is still using the
  // old serialization system to allow conversion of all the method calls to
  // Pigeon without converting the entire object graph all at once. See
  // https://github.com/flutter/flutter/issues/117910. The list items are
  // currently untyped due to https://github.com/flutter/flutter/issues/116117.
  //
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  final List<Object?> productsJsonList;
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
      List<PlatformProduct> products);

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
