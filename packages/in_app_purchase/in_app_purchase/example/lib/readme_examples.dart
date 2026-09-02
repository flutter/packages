// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

/// Example app used for README excerpts.
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;

    // #docregion purchase-updates
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // handle error here.
      },
    );
    // #enddocregion purchase-updates
  }

  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// #docregion purchase-updates-handler
Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
  for (final purchaseDetails in purchaseDetailsList) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _showPendingUI();
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          await _deliverProduct(purchaseDetails);
        } else {
          _handleInvalidPurchase(purchaseDetails);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }
}
// #enddocregion purchase-updates-handler

void _showPendingUI() {}

void _handleError(IAPError error) {}

Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async => true;

Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {}

void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {}

// #docregion store-availability
Future<void> checkStoreAvailability() async {
  final bool available = await InAppPurchase.instance.isAvailable();
  if (!available) {
    // The store cannot be reached or accessed. Update the UI accordingly.
  }
}
// #enddocregion store-availability

// #docregion product-query
Future<void> loadProducts() async {
  const Set<String> productIds = <String>{'product1', 'product2'};
  final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(
    productIds,
  );
  if (response.notFoundIDs.isNotEmpty) {
    // Handle the error.
  }
  final List<ProductDetails> products = response.productDetails;
}
// #enddocregion product-query

// #docregion restore-purchases
Future<void> restorePurchases() async {
  await InAppPurchase.instance.restorePurchases();
}
// #enddocregion restore-purchases

// #docregion purchase-flow
void makePurchase(ProductDetails productDetails) {
  final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
  if (_isConsumable(productDetails)) {
    InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
  } else {
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }
  // From here the purchase flow will be handled by the underlying store.
  // Updates will be delivered to the `InAppPurchase.instance.purchaseStream`.
}

bool _isConsumable(ProductDetails productDetails) => productDetails.id == 'consumable';
// #enddocregion purchase-flow

// #docregion sk2-purchase
Future<void> makeStoreKit2Purchase(ProductDetails productDetails) async {
  // import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
  final Sk2PurchaseParam purchaseParamSk2 = Sk2PurchaseParam(
    productDetails: productDetails,
    winBackOfferId: 'your_win_back_offer_id',
  );

  await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParamSk2);
}
// #enddocregion sk2-purchase

// #docregion upgrade-subscription
void upgradeSubscription(
  ProductDetails productDetails,
  GooglePlayPurchaseDetails oldPurchaseDetails,
) {
  final PurchaseParam purchaseParam = GooglePlayPurchaseParam(
    productDetails: productDetails,
    changeSubscriptionParam: ChangeSubscriptionParam(
      oldPurchaseDetails: oldPurchaseDetails,
      replacementMode: ReplacementMode.withTimeProration,
    ),
  );
  InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
}
// #enddocregion upgrade-subscription

// #docregion price-consent-setup
Future<void> initStoreInfo() async {
  if (Platform.isIOS) {
    final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = InAppPurchase.instance
        .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
  }
}

Future<void> disposeStore() async {
  if (Platform.isIOS) {
    final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = InAppPurchase.instance
        .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    await iosPlatformAddition.setDelegate(null);
  }
}
// #enddocregion price-consent-setup

// #docregion price-consent-delegate
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
// #enddocregion price-consent-delegate

// #docregion price-consent-show
Future<void> showPriceConsent() async {
  final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition = InAppPurchase.instance
      .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
}
// #enddocregion price-consent-show

// #docregion android-product-details
void handleAndroidProductDetails(ProductDetails productDetails) {
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper product = productDetails.productDetails;
    print(product.subscriptionOfferDetails![productDetails.subscriptionIndex!].pricingPhases.first);
  }
}
// #enddocregion android-product-details

// #docregion ios-product-details
void handleIosProductDetails(ProductDetails productDetails) {
  if (productDetails is AppStoreProductDetails) {
    final SKProductWrapper skProduct = productDetails.skProduct;
    print(skProduct.subscriptionGroupIdentifier);
  }
}
// #enddocregion ios-product-details

// #docregion ios-product-details-storekit2
void handleIosProductDetailsSk2(ProductDetails productDetails) {
  if (productDetails is AppStoreProduct2Details) {
    final SK2Product product = productDetails.sk2Product;
    print(product.subscription?.subscriptionGroupID);
  }
}
// #enddocregion ios-product-details-storekit2

// #docregion android-purchase-details
void handleAndroidPurchaseDetails(PurchaseDetails purchaseDetails) {
  if (purchaseDetails is GooglePlayPurchaseDetails) {
    final PurchaseWrapper billingClientPurchase = purchaseDetails.billingClientPurchase;
    print(billingClientPurchase.originalJson);
  }
}
// #enddocregion android-purchase-details

// #docregion ios-purchase-details
void handleIosPurchaseDetails(PurchaseDetails purchaseDetails) {
  if (purchaseDetails is AppStorePurchaseDetails) {
    final SKPaymentTransactionWrapper skProduct = purchaseDetails.skPaymentTransaction;
    print(skProduct.transactionState);
  }
}
// #enddocregion ios-purchase-details

// #docregion sk2-transaction
Future<void> readSk2Transactions() async {
  final List<SK2Transaction> transactions = await SK2Transaction.transactions();
  print(transactions[0].jsonRepresentation);
}
// #enddocregion sk2-transaction

// #docregion code-redemption
Future<void> presentCodeRedemptionSheet() async {
  final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = InAppPurchase.instance
      .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  await iosPlatformAddition.presentCodeRedemptionSheet();
}

// #enddocregion code-redemption
