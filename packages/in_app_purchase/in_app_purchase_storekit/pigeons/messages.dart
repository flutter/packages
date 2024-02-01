// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  objcHeaderOut: 'darwin/Classes/messages.g.h',
  objcSourceOut: 'darwin/Classes/messages.g.m',
  copyrightHeader: 'pigeons/copyright.txt',
))
class SKPaymentTransactionMessage {
  SKPaymentTransactionMessage({
    required this.payment,
    required this.transactionState,
    this.originalTransaction,
    this.transactionTimeStamp,
    this.transactionIdentifier,
    this.error,
  });

  final SKPaymentMessage payment;

  final SKPaymentTransactionStateMessage transactionState;

  final SKPaymentTransactionMessage? originalTransaction;

  final double? transactionTimeStamp;

  final String? transactionIdentifier;

  final SKErrorMessage? error;
}

enum SKPaymentTransactionStateMessage {
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

class SKPaymentMessage {
  /// Creates a new [SKPaymentWrapper] with the provided information.
  const SKPaymentMessage({
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

  final int quantity;

  final bool simulatesAskToBuyInSandbox;

  final SKPaymentDiscountMessage? paymentDiscount;
}

class SKErrorMessage {
  const SKErrorMessage(
      {required this.code, required this.domain, required this.userInfo});

  final int code;
  final String domain;
  final Map<String?, Object?> userInfo;
}

class SKPaymentDiscountMessage {
  const SKPaymentDiscountMessage({
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

class SKStorefrontMessage {
  const SKStorefrontMessage({
    required this.countryCode,
    required this.identifier,
  });

  final String countryCode;
  final String identifier;
}

@HostApi(dartHostTestHandler: 'TestInAppPurchaseApi')
abstract class InAppPurchaseAPI {
  /// Returns if the current device is able to make payments
  bool canMakePayments();

  List<SKPaymentTransactionMessage> transactions();

  SKStorefrontMessage storefront();

  void addPayment(Map<String, Object?> paymentMap);
}
