// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  objcHeaderOut: 'darwin/Classes/messages.g.h',
  objcSourceOut: 'darwin/Classes/messages.g.m',
  copyrightHeader: 'pigeons/copyright.txt',
))

class StoreKitPaymentTransactionWrapper {
  StoreKitPaymentTransactionWrapper({
    required this.payment,
    required this.transactionState,
    this.originalTransaction,
    this.transactionTimeStamp,
    this.transactionIdentifier,
    this.error,
  });

  final PaymentWrapper payment;

  final PaymentTransactionStateWrapper transactionState;

  final StoreKitPaymentTransactionWrapper? originalTransaction;

  final double? transactionTimeStamp;

  final String? transactionIdentifier;

  final ErrorWrapper? error;
}

enum PaymentTransactionStateWrapper {
  /// Indicates the transaction is being processed in App Store.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state. Never complete a transaction that
  /// is still in a purchasing state.
  purchasing,

  /// The user's payment has been succesfully processed.
  ///
  /// You should provide the user the content that they purchased.
  purchased,

  /// The transaction failed.
  ///
  /// Check the [PaymentTransactionWrapper.error] property from
  /// [PaymentTransactionWrapper] for details.
  failed,

  /// This transaction is restoring content previously purchased by the user.
  ///
  /// The previous transaction information can be obtained in
  /// [PaymentTransactionWrapper.originalTransaction] from
  /// [PaymentTransactionWrapper].
  restored,

  /// The transaction is in the queue but pending external action. Wait for
  /// another callback to get the final state.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state.
  deferred,

  /// Indicates the transaction is in an unspecified state.
  unspecified,
}

class PaymentWrapper {
  /// Creates a new [SKPaymentWrapper] with the provided information.
  const PaymentWrapper({
    required this.productIdentifier,
    this.applicationUsername,
    this.requestData,
    this.quantity = 1,
    this.simulatesAskToBuyInSandbox = false,
    this.paymentDiscount,
  });

  final String productIdentifier;

  final String? applicationUsername;

  final String? requestData;

  // default value is 0?
  final int quantity;

  final bool simulatesAskToBuyInSandbox;

  final PaymentDiscountWrapper? paymentDiscount;
}

class ErrorWrapper {
  // a lot of comparison operators are overriden in this class - do i add them here?
  const ErrorWrapper(
      {required this.code, required this.domain, required this.userInfo});

  final int code;
  final String domain;
  final Map<String?, Object?> userInfo;
}

class PaymentDiscountWrapper {
  const PaymentDiscountWrapper({
    required this.identifier,
    required this.keyIdentifier,
    required this.nonce,
    required this.signature,
    required this.timestamp,
  });

  final String identifier;
  final String keyIdentifier;
  final String nonce;
  final String signature;
  final int timestamp;
}

class StoreKitStorefrontWrapper {
  const StoreKitStorefrontWrapper({
    required this.countryCode,
    required this.identifier,
  });

  final String countryCode;
  final String identifier;
}

@HostApi()
abstract class InAppPurchaseAPI {
  /// Returns if the current device is able to make payments
  // @ObjCSelector('canMakePayments')
  bool canMakePayments();

  // @ObjCSelector('transactions')
  List<StoreKitPaymentTransactionWrapper> transactions();

  // @ObjCSelector('storefront')
  StoreKitStorefrontWrapper storefront();
}


