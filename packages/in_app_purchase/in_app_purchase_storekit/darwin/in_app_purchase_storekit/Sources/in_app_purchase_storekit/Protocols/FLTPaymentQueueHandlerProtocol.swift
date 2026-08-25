// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

public typealias TransactionsUpdated = ([SKPaymentTransaction]) -> Void
public typealias TransactionsRemoved = ([SKPaymentTransaction]) -> Void
public typealias RestoreTransactionFailed = (NSError) -> Void
public typealias RestoreCompletedTransactionsFinished = () -> Void
public typealias ShouldAddStorePayment = (SKPayment, SKProduct) -> Bool
public typealias UpdatedDownloads = ([SKDownload]) -> Void

/// A protocol that conforms to SKPaymentTransactionObserver and handles SKPaymentQueue methods
@objc public protocol FLTPaymentQueueHandlerProtocol: NSObjectProtocol, SKPaymentTransactionObserver
{
  /// An object that provides information needed to complete transactions.
  @available(iOS 13.0, macOS 10.15, watchOS 6.2, *)
  weak var delegate: SKPaymentQueueDelegate? { get set }

  /// An object containing the location and unique identifier of an Apple App Store storefront.
  @available(iOS 13.0, macOS 10.15, watchOS 6.2, *)
  var storefront: SKStorefront? { get }

  /// Creates a new FIAPaymentQueueHandler.
  ///
  /// The "transactionsUpdated", "transactionsRemoved" and "updatedDownloads"
  /// callbacks are only called while actively observing transactions. To start
  /// observing transactions send the "startObservingPaymentQueue" message.
  /// Sending the "stopObservingPaymentQueue" message will stop actively
  /// observing transactions. When transactions are not observed they are cached
  /// to the "transactionCache" and will be delivered via the
  /// "transactionsUpdated", "transactionsRemoved" and "updatedDownloads"
  /// callbacks as soon as the "startObservingPaymentQueue" message arrives.
  ///
  /// Note: cached transactions that are not processed when the application is
  /// killed will be delivered again by the App Store as soon as the application
  /// starts again.
  init(
    queue: FLTPaymentQueueProtocol,
    transactionsUpdated: TransactionsUpdated?,
    transactionRemoved: TransactionsRemoved?,
    restoreTransactionFailed: RestoreTransactionFailed?,
    restoreCompletedTransactionsFinished: RestoreCompletedTransactionsFinished?,
    shouldAddStorePayment: ShouldAddStorePayment?,
    updatedDownloads: UpdatedDownloads?,
    transactionCache: FLTTransactionCacheProtocol
  )

  /// Can throw exceptions if the transaction type is purchasing, should always used in a try block.
  func finish(_ transaction: SKPaymentTransaction)

  /// Attempt to restore transactions. Require app store receipt url.
  func restoreTransactions(_ applicationName: String?)

  #if os(iOS)
    /// Displays a sheet that enables users to redeem subscription offer codes.
    func presentCodeRedemptionSheet()
  #endif

  /// Return all transactions that are not marked as complete.
  func getUnfinishedTransactions() -> [SKPaymentTransaction]

  /// This method needs to be called before any other methods.
  func startObservingPaymentQueue()

  /// Call this method when the Flutter app is no longer listening
  func stopObservingPaymentQueue()

  /// Appends a payment to the SKPaymentQueue.
  ///
  /// - Parameter payment: Payment object to be added to the payment queue.
  /// - Returns: whether "addPayment" was successful.
  func add(_ payment: SKPayment) -> Bool

  #if os(iOS)
    /// Displays the price consent sheet.
    ///
    /// The price consent sheet is only displayed when the following
    /// is true:
    /// - You have increased the price of the subscription in App Store Connect.
    /// - The subscriber has not yet responded to a price consent query.
    /// Otherwise the method has no effect.
    @available(iOS 13.4, *)
    func showPriceConsentIfNeeded()
  #endif
}
