// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../billing_client_wrappers.dart';
import '../in_app_purchase_android.dart';
import 'billing_client_wrappers/billing_config_wrapper.dart';
import 'types/translator.dart';

/// Contains InApp Purchase features that are only available on PlayStore.
class InAppPurchaseAndroidPlatformAddition
    extends InAppPurchasePlatformAddition {
  /// Creates a [InAppPurchaseAndroidPlatformAddition] which uses the supplied
  /// `BillingClientManager` to provide Android specific features.
  InAppPurchaseAndroidPlatformAddition(this._billingClientManager) {
    _billingClientManager.userChoiceDetailsStream
        .map(Translator.convertToUserChoiceDetails)
        .listen(_userChoiceDetailsStreamController.add);
  }

  final StreamController<GooglePlayUserChoiceDetails>
      _userChoiceDetailsStreamController =
      StreamController<GooglePlayUserChoiceDetails>.broadcast();

  /// [GooglePlayUserChoiceDetails] emits each time user selects alternative billing.
  late final Stream<GooglePlayUserChoiceDetails> userChoiceDetailsStream =
      _userChoiceDetailsStreamController.stream;

  final BillingClientManager _billingClientManager;

  /// Mark that the user has consumed a product.
  ///
  /// You are responsible for consuming all consumable purchases once they are
  /// delivered. The user won't be able to buy the same product again until the
  /// purchase of the product is consumed.
  Future<BillingResultWrapper> consumePurchase(PurchaseDetails purchase) {
    return _billingClientManager.runWithClient(
      (BillingClient client) =>
          client.consumeAsync(purchase.verificationData.serverVerificationData),
    );
  }

  /// Query all previous purchases.
  ///
  /// The `applicationUserName` should match whatever was sent in the initial
  /// `PurchaseParam`, if anything. If no `applicationUserName` was specified in
  /// the initial `PurchaseParam`, use `null`.
  ///
  /// This does not return consumed products. If you want to restore unused
  /// consumable products, you need to persist consumable product information
  /// for your user on your own server.
  ///
  /// See also:
  ///
  ///  * [refreshPurchaseVerificationData], for reloading failed
  ///    [PurchaseDetails.verificationData].
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String? applicationUserName}) async {
    List<PurchasesResultWrapper> responses;
    PlatformException? exception;

    try {
      responses = await Future.wait(<Future<PurchasesResultWrapper>>[
        _billingClientManager.runWithClient(
          (BillingClient client) => client.queryPurchases(ProductType.inapp),
        ),
        _billingClientManager.runWithClient(
          (BillingClient client) => client.queryPurchases(ProductType.subs),
        ),
      ]);
    } on PlatformException catch (e) {
      exception = e;
      responses = <PurchasesResultWrapper>[
        PurchasesResultWrapper(
          responseCode: BillingResponse.error,
          purchasesList: const <PurchaseWrapper>[],
          billingResult: BillingResultWrapper(
            responseCode: BillingResponse.error,
            debugMessage: e.details.toString(),
          ),
        ),
        PurchasesResultWrapper(
          responseCode: BillingResponse.error,
          purchasesList: const <PurchaseWrapper>[],
          billingResult: BillingResultWrapper(
            responseCode: BillingResponse.error,
            debugMessage: e.details.toString(),
          ),
        )
      ];
    }

    final Set<String> errorCodeSet = responses
        .where((PurchasesResultWrapper response) =>
            response.responseCode != BillingResponse.ok)
        .map((PurchasesResultWrapper response) =>
            response.responseCode.toString())
        .toSet();

    final String errorMessage =
        errorCodeSet.isNotEmpty ? errorCodeSet.join(', ') : '';

    final List<GooglePlayPurchaseDetails> pastPurchases = responses
        .expand((PurchasesResultWrapper response) => response.purchasesList)
        .expand((PurchaseWrapper purchaseWrapper) =>
            GooglePlayPurchaseDetails.fromPurchase(purchaseWrapper))
        .toList();

    IAPError? error;
    if (exception != null) {
      error = IAPError(
          source: kIAPSource,
          code: exception.code,
          message: exception.message ?? '',
          details: exception.details);
    } else if (errorMessage.isNotEmpty) {
      error = IAPError(
          source: kIAPSource,
          code: kRestoredPurchaseErrorCode,
          message: errorMessage);
    }

    return QueryPurchaseDetailsResponse(
        pastPurchases: pastPurchases, error: error);
  }

  /// Checks if the specified feature or capability is supported by the Play Store.
  /// Call this to check if a [BillingClientFeature] is supported by the device.
  Future<bool> isFeatureSupported(BillingClientFeature feature) async {
    return _billingClientManager.runWithClientNonRetryable(
      (BillingClient client) => client.isFeatureSupported(feature),
    );
  }

  /// Returns Play billing country code based on ISO-3166-1 alpha2 format.
  ///
  /// See: https://developer.android.com/reference/com/android/billingclient/api/BillingConfig
  /// See: https://unicode.org/cldr/charts/latest/supplemental/territory_containment_un_m_49.html
  @Deprecated('Use InAppPurchasePlatfrom.countryCode')
  Future<String> getCountryCode() async {
    final BillingConfigWrapper billingConfig = await _billingClientManager
        .runWithClient((BillingClient client) => client.getBillingConfig());
    return billingConfig.countryCode;
  }

  /// Returns if the caller can use alternative billing only without giving the
  /// user a choice to use Play billing.
  ///
  /// See: https://developer.android.com/reference/com/android/billingclient/api/BillingClient#isAlternativeBillingOnlyAvailableAsync(com.android.billingclient.api.AlternativeBillingOnlyAvailabilityListener)
  Future<BillingResultWrapper> isAlternativeBillingOnlyAvailable() async {
    final BillingResultWrapper wrapper =
        await _billingClientManager.runWithClient((BillingClient client) =>
            client.isAlternativeBillingOnlyAvailable());
    return wrapper;
  }

  /// Shows the alternative billing only information dialog on top of the calling app.
  ///
  /// See: https://developer.android.com/reference/com/android/billingclient/api/BillingClient#showAlternativeBillingOnlyInformationDialog(android.app.Activity,%20com.android.billingclient.api.AlternativeBillingOnlyInformationDialogListener)
  Future<BillingResultWrapper>
      showAlternativeBillingOnlyInformationDialog() async {
    final BillingResultWrapper wrapper =
        await _billingClientManager.runWithClient((BillingClient client) =>
            client.showAlternativeBillingOnlyInformationDialog());
    return wrapper;
  }

  /// The details used to report transactions made via alternative billing
  /// without user choice to use Google Play billing.
  ///
  /// See: https://developer.android.com/reference/com/android/billingclient/api/AlternativeBillingOnlyReportingDetails
  Future<AlternativeBillingOnlyReportingDetailsWrapper>
      createAlternativeBillingOnlyReportingDetails() async {
    final AlternativeBillingOnlyReportingDetailsWrapper wrapper =
        await _billingClientManager.runWithClient((BillingClient client) =>
            client.createAlternativeBillingOnlyReportingDetails());
    return wrapper;
  }

  /// Disconnects, sets AlternativeBillingOnly to true, and reconnects to
  /// the [BillingClient].
  ///
  /// [BillingChoiceMode.playBillingOnly] is the default state used.
  /// [BillingChoiceMode.alternativeBillingOnly] will enable alternative billing only.
  ///
  /// Play apis have requirements for when this method can be called.
  /// See: https://developer.android.com/google/play/billing/alternative/alternative-billing-without-user-choice-in-app
  Future<void> setBillingChoice(BillingChoiceMode billingChoiceMode) {
    return _billingClientManager
        .reconnectWithBillingChoiceMode(billingChoiceMode);
  }
}
