// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, unused_local_variable

import 'package:in_app_purchase/in_app_purchase.dart';
// #docregion AndroidProduct
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// #enddocregion AndroidProduct

// #docregion IOSProduct
// #docregion RedeemOffer
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// #enddocregion RedeemOffer
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// #enddocregion IOSProduct

/// Demonstrates getting platform-specific attributes from product
/// and purchase details, for the README.
void platformSpecific() {
  const List<ProductDetails> productDetails = <ProductDetails>[];
  const List<PurchaseDetails> purchaseDetails = <PurchaseDetails>[];

// #docregion AndroidProduct
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper skuDetails =
        (productDetails as GooglePlayProductDetails).productDetails;
    print(skuDetails.oneTimePurchaseOfferDetails);
  }
// #enddocregion AndroidProduct

// #docregion IOSProduct
  if (productDetails is AppStoreProductDetails) {
    final SKProductWrapper skProduct =
        (productDetails as AppStoreProductDetails).skProduct;
    print(skProduct.subscriptionGroupIdentifier);
  }
// #enddocregion IOSProduct

// #docregion AndroidPurchase
  if (purchaseDetails is GooglePlayPurchaseDetails) {
    final PurchaseWrapper billingClientPurchase =
        (purchaseDetails as GooglePlayPurchaseDetails).billingClientPurchase;
    print(billingClientPurchase.originalJson);
  }
// #enddocregion AndroidPurchase

// #docregion IOSPurchase
  if (purchaseDetails is AppStorePurchaseDetails) {
    final SKPaymentTransactionWrapper skProduct =
        (purchaseDetails as AppStorePurchaseDetails).skPaymentTransaction;
    print(skProduct.transactionState);
  }
// #enddocregion IOSPurchase

// #docregion RedeemOffer
  final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  iosPlatformAddition.presentCodeRedemptionSheet();
// #enddocregion RedeemOffer
}

/// Demonstrate loading product details for the README
Future<void> loadProducts() async {
  // #docregion LoadProducts
  // Set literals require Dart 2.2. Alternatively, use
// `Set<String> _kIds = <String>['product1', 'product2'].toSet()`.
  const Set<String> kIds = <String>{'product1', 'product2'};
  final ProductDetailsResponse response =
      await InAppPurchase.instance.queryProductDetails(kIds);
  if (response.notFoundIDs.isNotEmpty) {
    // Handle the error.
  }

  final List<ProductDetails> products = response.productDetails;
  // #enddocregion LoadProducts
}
