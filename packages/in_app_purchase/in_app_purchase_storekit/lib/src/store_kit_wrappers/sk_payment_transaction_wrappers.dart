// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../messages.g.dart';
import 'enum_converters.dart';
import 'sk_payment_queue_wrapper.dart';
import 'sk_product_wrapper.dart';

part 'sk_payment_transaction_wrappers.g.dart';

/// Callback handlers for transaction status changes.
///
/// Must be subclassed. Must be instantiated and added to the
/// [SKPaymentQueueWrapper] via [SKPaymentQueueWrapper.setTransactionObserver]
/// at app launch.
///
/// This class is a Dart wrapper around [SKTransactionObserver](https://developer.apple.com/documentation/storekit/skpaymenttransactionobserver?language=objc).
abstract class SKTransactionObserverWrapper {
  /// Triggered when any transactions are updated.
  void updatedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions});

  /// Triggered when any transactions are removed from the payment queue.
  void removedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions});

  /// Triggered when there is an error while restoring transactions.
  void restoreCompletedTransactionsFailed({required SKError error});

  /// Triggered when payment queue has finished sending restored transactions.
  void paymentQueueRestoreCompletedTransactionsFinished();

  /// Triggered when a user initiates an in-app purchase from App Store.
  ///
  /// Return `true` to continue the transaction in your app. If you have
  /// multiple [SKTransactionObserverWrapper]s, the transaction will continue if
  /// any [SKTransactionObserverWrapper] returns `true`. Return `false` to defer
  /// or cancel the transaction. For example, you may need to defer a
  /// transaction if the user is in the middle of onboarding. You can also
  /// continue the transaction later by calling [addPayment] with the
  /// `payment` param from this method.
  bool shouldAddStorePayment(
      {required SKPaymentWrapper payment, required SKProductWrapper product});
}

/// The state of a transaction.
///
/// Dart wrapper around StoreKit's
/// [SKPaymentTransactionState](https://developer.apple.com/documentation/storekit/skpaymenttransactionstate?language=objc).
enum SKPaymentTransactionStateWrapper {
  /// Indicates the transaction is being processed in App Store.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state. Never complete a transaction that
  /// is still in a purchasing state.
  @JsonValue(0)
  purchasing,

  /// The user's payment has been succesfully processed.
  ///
  /// You should provide the user the content that they purchased.
  @JsonValue(1)
  purchased,

  /// The transaction failed.
  ///
  /// Check the [SKPaymentTransactionWrapper.error] property from
  /// [SKPaymentTransactionWrapper] for details.
  @JsonValue(2)
  failed,

  /// This transaction is restoring content previously purchased by the user.
  ///
  /// The previous transaction information can be obtained in
  /// [SKPaymentTransactionWrapper.originalTransaction] from
  /// [SKPaymentTransactionWrapper].
  @JsonValue(3)
  restored,

  /// The transaction is in the queue but pending external action. Wait for
  /// another callback to get the final state.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state.
  @JsonValue(4)
  deferred,

  /// Indicates the transaction is in an unspecified state.
  @JsonValue(-1)
  unspecified;

  /// Converts [SKPaymentTransactionStateMessages] into the dart equivalent
  static SKPaymentTransactionStateWrapper convertFromPigeon(
      SKPaymentTransactionStateMessage msg) {
    switch (msg) {
      case SKPaymentTransactionStateMessage.purchased:
        return SKPaymentTransactionStateWrapper.purchased;
      case SKPaymentTransactionStateMessage.purchasing:
        return SKPaymentTransactionStateWrapper.purchasing;
      case SKPaymentTransactionStateMessage.failed:
        return SKPaymentTransactionStateWrapper.failed;
      case SKPaymentTransactionStateMessage.restored:
        return SKPaymentTransactionStateWrapper.restored;
      case SKPaymentTransactionStateMessage.deferred:
        return SKPaymentTransactionStateWrapper.deferred;
      case SKPaymentTransactionStateMessage.unspecified:
        return SKPaymentTransactionStateWrapper.unspecified;
    }
  }
}

/// Created when a payment is added to the [SKPaymentQueueWrapper].
///
/// Transactions are delivered to your app when a payment is finished
/// processing. Completed transactions provide a receipt and a transaction
/// identifier that the app can use to save a permanent record of the processed
/// payment.
///
/// Dart wrapper around StoreKit's
/// [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction?language=objc).
@JsonSerializable(createToJson: true)
@immutable
class SKPaymentTransactionWrapper {
  /// Creates a new [SKPaymentTransactionWrapper] with the provided information.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SKPaymentTransactionWrapper({
    required this.payment,
    required this.transactionState,
    this.originalTransaction,
    this.transactionTimeStamp,
    this.transactionIdentifier,
    this.error,
  });

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class. The `map` parameter must not be
  /// null.
  factory SKPaymentTransactionWrapper.fromJson(Map<String, dynamic> map) {
    return _$SKPaymentTransactionWrapperFromJson(map);
  }

  /// Current transaction state.
  @SKTransactionStatusConverter()
  final SKPaymentTransactionStateWrapper transactionState;

  /// The payment that has been created and added to the payment queue which
  /// generated this transaction.
  final SKPaymentWrapper payment;

  /// The original Transaction.
  ///
  /// Only available if the [transactionState] is [SKPaymentTransactionStateWrapper.restored].
  /// Otherwise the value is `null`.
  ///
  /// When the [transactionState]
  /// is [SKPaymentTransactionStateWrapper.restored], the current transaction
  /// object holds a new [transactionIdentifier].
  final SKPaymentTransactionWrapper? originalTransaction;

  /// The timestamp of the transaction.
  ///
  /// Seconds since epoch. It is only defined when the [transactionState] is
  /// [SKPaymentTransactionStateWrapper.purchased] or
  /// [SKPaymentTransactionStateWrapper.restored].
  /// Otherwise, the value is `null`.
  final double? transactionTimeStamp;

  /// The unique string identifer of the transaction.
  ///
  /// It is only defined when the [transactionState] is
  /// [SKPaymentTransactionStateWrapper.purchased] or
  /// [SKPaymentTransactionStateWrapper.restored]. You may wish to record this
  /// string as part of an audit trail for App Store purchases. The value of
  /// this string corresponds to the same property in the receipt.
  ///
  /// The value is `null` if it is an unsuccessful transaction.
  final String? transactionIdentifier;

  /// The error object
  ///
  /// Only available if the [transactionState] is
  /// [SKPaymentTransactionStateWrapper.failed].
  final SKError? error;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKPaymentTransactionWrapper &&
        other.payment == payment &&
        other.transactionState == transactionState &&
        other.originalTransaction == originalTransaction &&
        other.transactionTimeStamp == transactionTimeStamp &&
        other.transactionIdentifier == transactionIdentifier &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(payment, transactionState,
      originalTransaction, transactionTimeStamp, transactionIdentifier, error);

  @override
  String toString() => _$SKPaymentTransactionWrapperToJson(this).toString();

  /// The payload that is used to finish this transaction.
  Map<String, String?> toFinishMap() => <String, String?>{
        'transactionIdentifier': transactionIdentifier,
        'productIdentifier': payment.productIdentifier,
      };

  /// Converts [SKPaymentTransactionMessages] into the dart equivalent
  static SKPaymentTransactionWrapper convertFromPigeon(
      SKPaymentTransactionMessage msg) {
    return SKPaymentTransactionWrapper(
        payment: SKPaymentWrapper.convertFromPigeon(msg.payment),
        transactionState: SKPaymentTransactionStateWrapper.convertFromPigeon(
            msg.transactionState),
        originalTransaction: msg.originalTransaction == null
            ? null
            : convertFromPigeon(msg.originalTransaction!),
        transactionTimeStamp: msg.transactionTimeStamp,
        transactionIdentifier: msg.transactionIdentifier,
        error:
            msg.error == null ? null : SKError.convertFromPigeon(msg.error!));
  }
}
