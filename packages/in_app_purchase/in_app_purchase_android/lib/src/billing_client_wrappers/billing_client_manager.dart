// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'billing_client_wrapper.dart';
import 'pending_purchases_params_wrapper.dart';
import 'purchase_wrapper.dart';
import 'user_choice_details_wrapper.dart';

/// Abstraction of result of [BillingClient] operation that includes
/// a [BillingResponse].
abstract class HasBillingResponse {
  /// The status of the operation.
  abstract final BillingResponse responseCode;
}

/// Factory for creating BillingClient instances, to allow injection of
/// custom billing clients in tests.
@visibleForTesting
typedef BillingClientFactory = BillingClient Function(
    PurchasesUpdatedListener onPurchasesUpdated,
    UserSelectedAlternativeBillingListener? alternativeBillingListener);

/// Utility class that manages a [BillingClient] connection.
///
/// Connection is initialized on creation of [BillingClientManager].
/// If [BillingClient] sends `onBillingServiceDisconnected` event or any
/// operation returns [BillingResponse.serviceDisconnected], connection is
/// re-initialized.
///
/// [BillingClient] instance is not exposed directly. It can be accessed via
/// [runWithClient] and [runWithClientNonRetryable] methods that handle the
/// connection management.
///
/// Consider calling [dispose] after the [BillingClient] is no longer needed.
class BillingClientManager {
  /// Creates the [BillingClientManager].
  ///
  /// Immediately initializes connection to the underlying [BillingClient].
  BillingClientManager(
      {@visibleForTesting BillingClientFactory? billingClientFactory})
      : _billingChoiceMode = BillingChoiceMode.playBillingOnly,
        _pendingPurchasesParams =
            const PendingPurchasesParamsWrapper(enablePrepaidPlans: false),
        _billingClientFactory = billingClientFactory ?? _createBillingClient {
    _connect();
  }

  /// Stream of `userSelectedAlternativeBilling` events from the [BillingClient].
  ///
  /// This is a broadcast stream, so it can be listened to multiple times.
  /// A "done" event will be sent after [dispose] is called.
  late final Stream<UserChoiceDetailsWrapper> userChoiceDetailsStream =
      _userChoiceAlternativeBillingController.stream;

  /// Stream of `onPurchasesUpdated` events from the [BillingClient].
  ///
  /// This is a broadcast stream, so it can be listened to multiple times.
  /// A "done" event will be sent after [dispose] is called.
  late final Stream<PurchasesResultWrapper> purchasesUpdatedStream =
      _purchasesUpdatedController.stream;

  /// [BillingClient] instance managed by this [BillingClientManager].
  ///
  /// In order to access the [BillingClient], use [runWithClient]
  /// and [runWithClientNonRetryable] methods.
  @visibleForTesting
  late final BillingClient client = _billingClientFactory(
      _onPurchasesUpdated, onUserChoiceAlternativeBilling);

  // Default (non-test) implementation of _billingClientFactory.
  static BillingClient _createBillingClient(
      PurchasesUpdatedListener onPurchasesUpdated,
      UserSelectedAlternativeBillingListener? onUserChoiceAlternativeBilling) {
    return BillingClient(onPurchasesUpdated, onUserChoiceAlternativeBilling);
  }

  final StreamController<PurchasesResultWrapper> _purchasesUpdatedController =
      StreamController<PurchasesResultWrapper>.broadcast();
  final StreamController<UserChoiceDetailsWrapper>
      _userChoiceAlternativeBillingController =
      StreamController<UserChoiceDetailsWrapper>.broadcast();

  BillingChoiceMode _billingChoiceMode;
  final BillingClientFactory _billingClientFactory;
  PendingPurchasesParamsWrapper _pendingPurchasesParams;
  bool _isConnecting = false;
  bool _isDisposed = false;

  // Initialized immediately in the constructor, so it's always safe to access.
  late Future<void> _readyFuture;

  /// Executes the given [action] with access to the underlying [BillingClient].
  ///
  /// If necessary, waits for the underlying [BillingClient] to connect.
  /// If given [action] returns [BillingResponse.serviceDisconnected], it will
  /// be transparently retried after the connection is restored. Because
  /// of this, [action] may be called multiple times.
  ///
  /// A response with [BillingResponse.serviceDisconnected] may be returned
  /// in case of [dispose] being called during the operation.
  ///
  /// See [runWithClientNonRetryable] for operations that do not return
  /// a subclass of [HasBillingResponse].
  Future<R> runWithClient<R extends HasBillingResponse>(
    Future<R> Function(BillingClient client) action,
  ) async {
    _debugAssertNotDisposed();
    await _readyFuture;
    final R result = await action(client);
    if (result.responseCode == BillingResponse.serviceDisconnected &&
        !_isDisposed) {
      await _connect();
      return runWithClient(action);
    } else {
      return result;
    }
  }

  /// Executes the given [action] with access to the underlying [BillingClient].
  ///
  /// If necessary, waits for the underlying [BillingClient] to connect.
  /// Designed only for operations that do not return a subclass
  /// of [HasBillingResponse] (e.g. [BillingClient.isReady],
  /// [BillingClient.isFeatureSupported]).
  ///
  /// See [runWithClient] for operations that return a subclass
  /// of [HasBillingResponse].
  Future<R> runWithClientNonRetryable<R>(
    Future<R> Function(BillingClient client) action,
  ) async {
    _debugAssertNotDisposed();
    await _readyFuture;
    return action(client);
  }

  /// Ends connection to the [BillingClient].
  ///
  /// Consider calling [dispose] after you no longer need the [BillingClient]
  /// API to free up the resources.
  ///
  /// After calling [dispose]:
  /// - Further connection attempts will not be made.
  /// - [purchasesUpdatedStream] will be closed.
  /// - [userChoiceDetailsStream] will be closed.
  /// - Calls to [runWithClient] and [runWithClientNonRetryable] will throw.
  void dispose() {
    _debugAssertNotDisposed();
    _isDisposed = true;
    client.endConnection();
    _purchasesUpdatedController.close();
    _userChoiceAlternativeBillingController.close();
  }

  /// Ends connection to [BillingClient] and reconnects with [billingChoiceMode].
  ///
  /// Callers need to check if [BillingChoiceMode.alternativeBillingOnly] is
  /// available by calling [BillingClientWrapper.isAlternativeBillingOnlyAvailable]
  /// first.
  Future<void> reconnectWithBillingChoiceMode(
      BillingChoiceMode billingChoiceMode) async {
    _billingChoiceMode = billingChoiceMode;
    await _reconnect();
  }

  /// Ends connection to [BillingClient] and reconnects with [pendingPurchasesParams].
  Future<void> reconnectWithPendingPurchasesParams(
      PendingPurchasesParamsWrapper pendingPurchasesParams) async {
    _pendingPurchasesParams = pendingPurchasesParams;
    await _reconnect();
  }

  // If disposed, does nothing.
  // If currently connecting, waits for it to complete.
  // Otherwise, starts a new connection.
  Future<void> _connect() {
    if (_isDisposed) {
      return Future<void>.value();
    }
    if (_isConnecting) {
      return _readyFuture;
    }
    _isConnecting = true;
    _readyFuture = Future<void>.sync(() async {
      await client.startConnection(
        onBillingServiceDisconnected: _connect,
        billingChoiceMode: _billingChoiceMode,
        pendingPurchasesParams: _pendingPurchasesParams,
      );
      _isConnecting = false;
    });
    return _readyFuture;
  }

  Future<void> _reconnect() async {
    // Ends connection and triggers OnBillingServiceDisconnected, which causes reconnect.
    await client.endConnection();
    await _connect();
  }

  void _onPurchasesUpdated(PurchasesResultWrapper event) {
    if (_isDisposed) {
      return;
    }
    _purchasesUpdatedController.add(event);
  }

  void _debugAssertNotDisposed() {
    assert(
      !_isDisposed,
      'A BillingClientManager was used after being disposed. Once you have '
      'called dispose() on a BillingClientManager, it can no longer be used.',
    );
  }

  /// Callback passed to [BillingClient] to use when customer chooses
  /// alternative billing.
  @visibleForTesting
  void onUserChoiceAlternativeBilling(UserChoiceDetailsWrapper event) {
    if (_isDisposed) {
      return;
    }
    _userChoiceAlternativeBillingController.add(event);
  }
}
