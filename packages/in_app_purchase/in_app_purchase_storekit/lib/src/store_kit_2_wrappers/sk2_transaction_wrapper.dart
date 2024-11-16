// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../in_app_purchase_storekit.dart';
import '../../store_kit_wrappers.dart';
import '../sk2_pigeon.g.dart';

InAppPurchase2API _hostApi = InAppPurchase2API();

/// Dart wrapper around StoreKit2's [Transaction](https://developer.apple.com/documentation/storekit/transaction)
/// Note that in StoreKit2, a Transaction encompasses the data contained by
/// SKPayment and SKTransaction in StoreKit1
class SK2Transaction {
  /// Creates a new instance of [SK2Transaction]
  SK2Transaction(
      {required this.id,
      required this.originalId,
      required this.productId,
      required this.purchaseDate,
      this.expirationDate,
      this.quantity = 1,
      required this.appAccountToken,
      this.subscriptionGroupID,
      this.price,
      this.error});

  /// The unique identifier for the transaction.
  final String id;

  /// The original transaction identifier of a purchase.
  /// The original transaction identifier, originalID, is identical to id except
  /// when the user restores a purchase or renews a transaction.
  final String originalId;

  /// The product identifier of the in-app purchase.
  final String productId;

  /// The date that the App Store charged the user’s account for a purchased or
  /// restored product, or for a subscription purchase or renewal after a lapse.
  final String purchaseDate;

  /// The date the subscription expires or renews.
  final String? expirationDate;

  /// The number of consumable products purchased.
  final int quantity;

  /// A UUID that associates the transaction with a user on your own service.
  final String? appAccountToken;

  /// The identifier of the subscription group that the subscription belongs to.
  final String? subscriptionGroupID;

  /// The price of the in-app purchase that the system records in the transaction.
  final double? price;

  /// Any error returned from StoreKit
  final SKError? error;

  /// Wrapper around [Transaction.finish]
  /// https://developer.apple.com/documentation/storekit/transaction/3749694-finish
  /// Indicates to the App Store that the app delivered the purchased content
  /// or enabled the service to finish the transaction.
  static Future<void> finish(int id) async {
    await _hostApi.finish(id);
  }

  /// A wrapper around [Transaction.all]
  /// https://developer.apple.com/documentation/storekit/transaction/3851203-all
  /// A sequence that emits all the customer’s transactions for your app.
  static Future<List<SK2Transaction>> transactions() async {
    final List<SK2TransactionMessage> msgs = await _hostApi.transactions();
    final List<SK2Transaction> transactions =
        msgs.map((SK2TransactionMessage e) => e.convertFromPigeon()).toList();
    return transactions;
  }

  /// Start listening to transactions.
  /// Call this as soon as you can your app to avoid missing transactions.
  static void startListeningToTransactions() {
    _hostApi.startListeningToTransactions();
  }

  /// Stop listening to transactions.
  static void stopListeningToTransactions() {
    _hostApi.stopListeningToTransactions();
  }

  /// Restore previously completed purchases.
  static Future<void> restorePurchases() async {
    await _hostApi.restorePurchases();
  }
}

extension on SK2TransactionMessage {
  SK2Transaction convertFromPigeon() {
    return SK2Transaction(
        id: id.toString(),
        originalId: originalId.toString(),
        productId: productId,
        purchaseDate: purchaseDate,
        expirationDate: expirationDate,
        appAccountToken: appAccountToken);
  }

  PurchaseDetails convertToDetails() {
    return SK2PurchaseDetails(
      productID: productId,
      // in SK2, as per Apple
      // https://developer.apple.com/documentation/foundation/nsbundle/1407276-appstorereceipturl
      // receipt isn’t necessary with SK2 as a Transaction can only be returned
      // from validated purchases.
      verificationData: PurchaseVerificationData(
          localVerificationData: '', serverVerificationData: '', source: ''),
      transactionDate: purchaseDate,
      // Note that with SK2, any transactions that *can* be returned will
      // require to be finished, and are already purchased.
      // So set this as purchased for all transactions initially.
      // Any failed transaction will simply not be returned.
      status: restoring ? PurchaseStatus.restored : PurchaseStatus.purchased,
      purchaseID: id.toString(),
    );
  }
}

/// An observer that listens to all transactions created
class SK2TransactionObserverWrapper implements InAppPurchase2CallbackAPI {
  /// Creates a new instance of [SK2TransactionObserverWrapper]
  SK2TransactionObserverWrapper({required this.transactionsCreatedController});

  /// The transactions stream to listen to
  final StreamController<List<PurchaseDetails>> transactionsCreatedController;

  @override
  void onTransactionsUpdated(List<SK2TransactionMessage> newTransactions) {
    transactionsCreatedController.add(newTransactions
        .map((SK2TransactionMessage e) => e.convertToDetails())
        .toList());
  }
}
