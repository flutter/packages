// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Note that in StoreKit2, a Transaction encompasses the data contained by
/// SKPayment and SKTransaction in StoreKit1
/// Dart wrapper around StoreKit2's [Transaction](https://developer.apple.com/documentation/storekit/transaction)
///
class SK2Transaction {
  SK2Transaction({
    required this.id,
    required this.originalId,
    required this.productId,
    required this.purchaseDate,
    this.quantity = 1,
    required this.appAccountToken,
    required this.subscriptionGroupID,
    required this.price,
  });

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
  final String subscriptionGroupID;
  final double price;
}
