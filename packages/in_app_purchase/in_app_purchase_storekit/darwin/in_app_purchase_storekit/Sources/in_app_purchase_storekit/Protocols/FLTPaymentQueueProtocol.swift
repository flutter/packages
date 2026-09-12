// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

/// A protocol that wraps SKPaymentQueue
@objc public protocol FLTPaymentQueueProtocol: NSObjectProtocol {
  /// An object containing the location and unique identifier of an Apple App Store storefront.
  @available(iOS 13.0, *)
  var storefront: SKStorefront? { get set }

  /// A list of SKPaymentTransactions, which each represents a single transaction
  var transactions: [SKPaymentTransaction] { get set }

  /// An object that provides information needed to complete transactions.
  @available(iOS 13.0, macOS 10.15, watchOS 6.2, *)
  weak var delegate: SKPaymentQueueDelegate? { get set }

  /// Remove a finished (i.e. failed or completed) transaction from the queue.  Attempting to finish a
  /// purchasing transaction will throw an exception.
  func finish(_ transaction: SKPaymentTransaction)

  /// Observers are not retained.  The transactions array will only be synchronized with the server
  /// while the queue has observers.  This may require that the user authenticate.
  @objc(addTransactionObserver:)
  func add(_ observer: SKPaymentTransactionObserver)

  /// Add a payment to the server queue.  The payment is copied to add an SKPaymentTransaction to the
  /// transactions array.  The same payment can be added multiple times to create multiple
  /// transactions.
  @objc(addPayment:)
  func add(_ payment: SKPayment)

  /// Will add completed transactions for the current user back to the queue to be re-completed.
  func restoreCompletedTransactions()

  /// Will add completed transactions for the current user back to the queue to be re-completed. This
  /// version requires an identifier to the user's account.
  func restoreCompletedTransactions(withApplicationUsername username: String?)

  #if os(iOS)
    /// Call this method to have StoreKit present a sheet enabling the user to redeem codes provided by
    /// your app. Only for iOS.
    @available(iOS 14.0, *)
    func presentCodeRedemptionSheet()

    /// If StoreKit has called your SKPaymentQueueDelegate's "paymentQueueShouldShowPriceConsent:"
    /// method and you returned NO, you can use this method to show the price consent UI at a later time
    /// that is more appropriate for your app. If there is no pending price consent, this method will do
    /// nothing.
    @available(iOS 13.4, *)
    func showPriceConsentIfNeeded()
  #endif
}

/// The default PaymentQueue that wraps SKPaymentQueue
public class DefaultPaymentQueue: NSObject, FLTPaymentQueueProtocol {
  /// The wrapped SKPaymentQueue
  private let queue: SKPaymentQueue

  private weak var _delegate: SKPaymentQueueDelegate?

  /// Initialize this wrapper with an SKPaymentQueue
  public init(queue: SKPaymentQueue) {
    self.queue = queue
  }

  @objc(addPayment:)
  public func add(_ payment: SKPayment) {
    queue.add(payment)
  }

  public func finish(_ transaction: SKPaymentTransaction) {
    queue.finishTransaction(transaction)
  }

  @objc(addTransactionObserver:)
  public func add(_ observer: SKPaymentTransactionObserver) {
    queue.add(observer)
  }

  public func restoreCompletedTransactions() {
    queue.restoreCompletedTransactions()
  }

  public func restoreCompletedTransactions(withApplicationUsername username: String?) {
    queue.restoreCompletedTransactions(withApplicationUsername: username)
  }

  @available(iOS 13.0, macOS 10.15, watchOS 6.2, *)
  public var delegate: SKPaymentQueueDelegate? {
    get { queue.delegate }
    set { _delegate = newValue }
  }

  public var transactions: [SKPaymentTransaction] {
    get { queue.transactions }
    set {}
  }

  @available(iOS 13.0, *)
  public var storefront: SKStorefront? {
    get { queue.storefront }
    set {}
  }

  #if os(iOS)
    @available(iOS 14.0, *)
    public func presentCodeRedemptionSheet() {
      queue.presentCodeRedemptionSheet()
    }

    @available(iOS 13.4, *)
    public func showPriceConsentIfNeeded() {
      queue.showPriceConsentIfNeeded()
    }
  #endif
}
