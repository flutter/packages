// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../billing_client_wrappers.dart';
import '../in_app_purchase_android_platform.dart';
import '../pigeon_converters.dart';

/// The class represents the information of a purchase made using Google Play.
class GooglePlayPurchaseDetails extends PurchaseDetails {
  /// Creates a new Google Play specific purchase details object with the
  /// provided details.
  GooglePlayPurchaseDetails({
    super.purchaseID,
    required super.productID,
    required super.verificationData,
    required super.transactionDate,
    required this.billingClientPurchase,
    required super.status,
  }) {
    pendingCompletePurchase = !billingClientPurchase.isAcknowledged;
  }

  /// Generates a [List] of [PurchaseDetails] based on an Android [Purchase] object.
  ///
  /// The list contains one entry per product.
  static List<GooglePlayPurchaseDetails> fromPurchase(
      PurchaseWrapper purchase) {
    return purchase.products.map((String productId) {
      final GooglePlayPurchaseDetails purchaseDetails =
          GooglePlayPurchaseDetails(
        purchaseID: purchase.orderId,
        productID: productId,
        verificationData: PurchaseVerificationData(
            localVerificationData: purchase.originalJson,
            serverVerificationData: purchase.purchaseToken,
            source: kIAPSource),
        transactionDate: purchase.purchaseTime.toString(),
        billingClientPurchase: purchase,
        status: purchaseStatusFromWrapper(purchase.purchaseState),
      );

      if (purchaseDetails.status == PurchaseStatus.error) {
        purchaseDetails.error = IAPError(
          source: kIAPSource,
          code: kPurchaseErrorCode,
          message: '',
        );
      }

      return purchaseDetails;
    }).toList();
  }

  /// Points back to the [PurchaseWrapper] which was used to generate this
  /// [GooglePlayPurchaseDetails] object.
  final PurchaseWrapper billingClientPurchase;
}
