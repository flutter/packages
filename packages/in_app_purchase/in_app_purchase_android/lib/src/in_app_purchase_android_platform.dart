// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../billing_client_wrappers.dart';
import '../in_app_purchase_android.dart';
import 'billing_client_wrappers/billing_config_wrapper.dart';

/// [IAPError.code] code for failed purchases.
const String kPurchaseErrorCode = 'purchase_error';

/// [IAPError.code] code used when a consuming a purchased item fails.
const String kConsumptionFailedErrorCode = 'consume_purchase_failed';

/// [IAPError.code] code used when a query for previous transaction has failed.
const String kRestoredPurchaseErrorCode = 'restore_transactions_failed';

/// Indicates store front is Google Play
const String kIAPSource = 'google_play';

/// An [InAppPurchasePlatform] that wraps Android BillingClient.
///
/// This translates various `BillingClient` calls and responses into the
/// generic plugin API.
class InAppPurchaseAndroidPlatform extends InAppPurchasePlatform {
  /// Creates a new InAppPurchaseAndroidPlatform instance, and configures it
  /// for use.
  @visibleForTesting
  InAppPurchaseAndroidPlatform(
      {@visibleForTesting BillingClientManager? manager})
      : billingClientManager = manager ?? BillingClientManager() {
    // Register [InAppPurchaseAndroidPlatformAddition].
    InAppPurchasePlatformAddition.instance =
        InAppPurchaseAndroidPlatformAddition(billingClientManager);

    billingClientManager.purchasesUpdatedStream
        .asyncMap(_getPurchaseDetailsFromResult)
        .listen(_purchaseUpdatedController.add);
  }

  /// Registers this class as the default instance of [InAppPurchasePlatform].
  static void registerPlatform() {
    // Register the platform instance with the plugin platform
    // interface.
    InAppPurchasePlatform.instance = InAppPurchaseAndroidPlatform();
  }

  final StreamController<List<PurchaseDetails>> _purchaseUpdatedController =
      StreamController<List<PurchaseDetails>>.broadcast();

  @override
  late final Stream<List<PurchaseDetails>> purchaseStream =
      _purchaseUpdatedController.stream;

  /// The [BillingClient] that's abstracted by [GooglePlayConnection].
  ///
  /// This field should not be used out of test code.
  @visibleForTesting
  final BillingClientManager billingClientManager;

  static final Set<String> _productIdsToConsume = <String>{};

  @override
  Future<bool> isAvailable() async {
    return billingClientManager
        .runWithClientNonRetryable((BillingClient client) => client.isReady());
  }

  /// Performs a network query for the details of products available.
  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    List<ProductDetailsResponseWrapper>? productResponses;
    PlatformException? exception;

    try {
      productResponses = await Future.wait(
        <Future<ProductDetailsResponseWrapper>>[
          billingClientManager.runWithClient(
            (BillingClient client) => client.queryProductDetails(
              productList: identifiers
                  .map((String productId) => ProductWrapper(
                      productId: productId, productType: ProductType.inapp))
                  .toList(),
            ),
          ),
          billingClientManager.runWithClient(
            (BillingClient client) => client.queryProductDetails(
              productList: identifiers
                  .map((String productId) => ProductWrapper(
                      productId: productId, productType: ProductType.subs))
                  .toList(),
            ),
          ),
        ],
      );
    } on PlatformException catch (e) {
      exception = e;
      productResponses = <ProductDetailsResponseWrapper>[
        ProductDetailsResponseWrapper(
            billingResult: BillingResultWrapper(
                responseCode: BillingResponse.error, debugMessage: e.code),
            productDetailsList: const <ProductDetailsWrapper>[]),
        ProductDetailsResponseWrapper(
            billingResult: BillingResultWrapper(
                responseCode: BillingResponse.error, debugMessage: e.code),
            productDetailsList: const <ProductDetailsWrapper>[])
      ];
    }
    final List<ProductDetails> productDetailsList =
        productResponses.expand((ProductDetailsResponseWrapper response) {
      return response.productDetailsList;
    }).expand((ProductDetailsWrapper productDetailWrapper) {
      return GooglePlayProductDetails.fromProductDetails(productDetailWrapper);
    }).toList();

    final Set<String> successIDS = productDetailsList
        .map((ProductDetails productDetails) => productDetails.id)
        .toSet();
    final List<String> notFoundIDS =
        identifiers.difference(successIDS).toList();
    return ProductDetailsResponse(
        productDetails: productDetailsList,
        notFoundIDs: notFoundIDS,
        error: exception == null
            ? null
            : IAPError(
                source: kIAPSource,
                code: exception.code,
                message: exception.message ?? '',
                details: exception.details));
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    ChangeSubscriptionParam? changeSubscriptionParam;

    if (purchaseParam is GooglePlayPurchaseParam) {
      changeSubscriptionParam = purchaseParam.changeSubscriptionParam;
    }

    String? offerToken;
    if (purchaseParam.productDetails is GooglePlayProductDetails) {
      offerToken =
          (purchaseParam.productDetails as GooglePlayProductDetails).offerToken;
    }

    final BillingResultWrapper billingResultWrapper =
        await billingClientManager.runWithClient(
      (BillingClient client) => client.launchBillingFlow(
          product: purchaseParam.productDetails.id,
          offerToken: offerToken,
          accountId: purchaseParam.applicationUserName,
          oldProduct: changeSubscriptionParam?.oldPurchaseDetails.productID,
          purchaseToken: changeSubscriptionParam
              ?.oldPurchaseDetails.verificationData.serverVerificationData,
          prorationMode: changeSubscriptionParam?.prorationMode,
          replacementMode: changeSubscriptionParam?.replacementMode),
    );
    return billingResultWrapper.responseCode == BillingResponse.ok;
  }

  @override
  Future<bool> buyConsumable(
      {required PurchaseParam purchaseParam, bool autoConsume = true}) {
    if (autoConsume) {
      _productIdsToConsume.add(purchaseParam.productDetails.id);
    }
    return buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<BillingResultWrapper> completePurchase(
      PurchaseDetails purchase) async {
    assert(
      purchase is GooglePlayPurchaseDetails,
      'On Android, the `purchase` should always be of type `GooglePlayPurchaseDetails`.',
    );

    final GooglePlayPurchaseDetails googlePurchase =
        purchase as GooglePlayPurchaseDetails;

    if (googlePurchase.billingClientPurchase.isAcknowledged) {
      return const BillingResultWrapper(responseCode: BillingResponse.ok);
    }

    return billingClientManager.runWithClient(
      (BillingClient client) => client.acknowledgePurchase(
          purchase.verificationData.serverVerificationData),
    );
  }

  @override
  Future<void> restorePurchases({
    String? applicationUserName,
  }) async {
    List<PurchasesResultWrapper> responses;

    responses = await Future.wait(<Future<PurchasesResultWrapper>>[
      billingClientManager.runWithClient(
        (BillingClient client) => client.queryPurchases(ProductType.inapp),
      ),
      billingClientManager.runWithClient(
        (BillingClient client) => client.queryPurchases(ProductType.subs),
      ),
    ]);

    final Set<String> errorCodeSet = responses
        .where((PurchasesResultWrapper response) =>
            response.responseCode != BillingResponse.ok)
        .map((PurchasesResultWrapper response) =>
            response.responseCode.toString())
        .toSet();

    final String errorMessage =
        errorCodeSet.isNotEmpty ? errorCodeSet.join(', ') : '';

    final List<PurchaseDetails> pastPurchases = responses
        .expand((PurchasesResultWrapper response) => response.purchasesList)
        .expand((PurchaseWrapper purchaseWrapper) =>
            GooglePlayPurchaseDetails.fromPurchase(purchaseWrapper))
        .map((GooglePlayPurchaseDetails details) =>
            details..status = PurchaseStatus.restored)
        .toList();

    if (errorMessage.isNotEmpty) {
      throw InAppPurchaseException(
        source: kIAPSource,
        code: kRestoredPurchaseErrorCode,
        message: errorMessage,
      );
    }

    _purchaseUpdatedController.add(pastPurchases);
  }

  Future<PurchaseDetails> _maybeAutoConsumePurchase(
      PurchaseDetails purchaseDetails) async {
    if (!(purchaseDetails.status == PurchaseStatus.purchased &&
        _productIdsToConsume.contains(purchaseDetails.productID))) {
      return purchaseDetails;
    }

    final BillingResultWrapper billingResult =
        await (InAppPurchasePlatformAddition.instance!
                as InAppPurchaseAndroidPlatformAddition)
            .consumePurchase(purchaseDetails);
    final BillingResponse consumedResponse = billingResult.responseCode;
    if (consumedResponse != BillingResponse.ok) {
      purchaseDetails.status = PurchaseStatus.error;
      purchaseDetails.error = IAPError(
        source: kIAPSource,
        code: kConsumptionFailedErrorCode,
        message: consumedResponse.toString(),
        details: billingResult.debugMessage,
      );
    }
    _productIdsToConsume.remove(purchaseDetails.productID);

    return purchaseDetails;
  }

  Future<List<PurchaseDetails>> _getPurchaseDetailsFromResult(
      PurchasesResultWrapper resultWrapper) async {
    IAPError? error;
    if (resultWrapper.responseCode != BillingResponse.ok) {
      error = IAPError(
        source: kIAPSource,
        code: kPurchaseErrorCode,
        message: resultWrapper.responseCode.toString(),
        details: resultWrapper.billingResult.debugMessage,
      );
    }
    final List<Future<PurchaseDetails>> purchases = resultWrapper.purchasesList
        .expand((PurchaseWrapper purchase) =>
            GooglePlayPurchaseDetails.fromPurchase(purchase))
        .map((GooglePlayPurchaseDetails purchaseDetails) {
      purchaseDetails.error = error;
      if (resultWrapper.responseCode == BillingResponse.userCanceled) {
        purchaseDetails.status = PurchaseStatus.canceled;
      }
      return _maybeAutoConsumePurchase(purchaseDetails);
    }).toList();
    if (purchases.isNotEmpty) {
      return Future.wait(purchases);
    } else {
      PurchaseStatus status = PurchaseStatus.error;
      if (resultWrapper.responseCode == BillingResponse.userCanceled) {
        status = PurchaseStatus.canceled;
      } else if (resultWrapper.responseCode == BillingResponse.ok) {
        status = PurchaseStatus.purchased;
      }
      return <PurchaseDetails>[
        PurchaseDetails(
          purchaseID: '',
          productID: '',
          status: status,
          transactionDate: null,
          verificationData: PurchaseVerificationData(
            localVerificationData: '',
            serverVerificationData: '',
            source: kIAPSource,
          ),
        )..error = error
      ];
    }
  }

  /// Returns Play billing country code based on ISO-3166-1 alpha2 format.
  ///
  /// See: https://developer.android.com/reference/com/android/billingclient/api/BillingConfig
  /// See: https://unicode.org/cldr/charts/latest/supplemental/territory_containment_un_m_49.html
  @override
  Future<String> countryCode() async {
    final BillingConfigWrapper billingConfig = await billingClientManager
        .runWithClient((BillingClient client) => client.getBillingConfig());
    return billingConfig.countryCode;
  }

  /// Use countryCode instead.
  @Deprecated('Use countryCode')
  Future<String> getCountryCode() => countryCode();
}
