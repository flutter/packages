// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../store_kit_wrappers.dart';
import '../messages2.g.dart';
import 'platform_types/sk2_purchase_details.dart';

InAppPurchase2API _hostapi = InAppPurchase2API();

/// Note that in StoreKit2, a Transaction encompasses the data contained by
/// SKPayment and SKTransaction in StoreKit1
/// Dart wrapper around StoreKit2's [Transaction](https://developer.apple.com/documentation/storekit/transaction)
///
class SK2Transaction {
  SK2Transaction(
      {required this.id,
      required this.originalId,
      required this.productId,
      required this.purchaseDate,
      this.quantity = 1,
      required this.appAccountToken,
      this.subscriptionGroupID,
      this.price,
      this.error});

  // SKTransaction
  final String id;

// The original transaction identifier, originalID, is identical to id except
// when the user restores a purchase or renews a transaction.
  final String originalId;

// SKPayment
  final String productId;
  final String purchaseDate;
  final int quantity;
  final String? appAccountToken;
  final String? subscriptionGroupID;
  final double? price;

  final SKError? error;

  static Future<void> finish(int id) async {
    await _hostapi.finish(id);
  }

  static Future<List<SK2Transaction>> transactions() async {
    List<SK2TransactionMessage?> msgs = await _hostapi.transactions();
    List<SK2Transaction> transactions = msgs
        .map((SK2TransactionMessage? e) => e?.convertFromPigeon())
        .cast<SK2Transaction>()
        .toList();
    return transactions;
  }

  static void startListeningToTransactions() {
    _hostapi.startListeningToTransactions();
  }

  static void stopListeningToTransactions() {
    _hostapi.stopListeningToTransactions();
  }
}

extension on SK2TransactionMessage {
  SK2Transaction convertFromPigeon() {
    return SK2Transaction(
        id: id.toString(),
        originalId: originalId.toString(),
        productId: productId,
        purchaseDate: purchaseDate,
        appAccountToken: appAccountToken);
  }

  PurchaseDetails convertToDetails() {
    print("converting to details");
    return PurchaseDetails(
      productID: productId,
      verificationData: PurchaseVerificationData(
          localVerificationData: "", serverVerificationData: "", source: ""),
      transactionDate: "",
      // Note that with sk2, any transactions that *can* be returned will require to be finished. So set this
      // as pending for all transactions initially.
      status: PurchaseStatus.purchased,
      purchaseID: id.toString(),
    );
  }
}

class SK2TransactionObserver implements InAppPurchase2CallbackAPI {
  SK2TransactionObserver({required this.purchaseUpdatedController});

  final StreamController<List<PurchaseDetails>> purchaseUpdatedController;

  @override
  void onTransactionsUpdated(SK2TransactionMessage newTransaction) {
    purchaseUpdatedController.add([newTransaction.convertToDetails()]);
    print(purchaseUpdatedController);
  }
}
