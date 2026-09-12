// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

#if canImport(in_app_purchase_storekit_objc)
  import in_app_purchase_storekit_objc
#endif

/// A Swift port of the legacy Objective-C `FIAPaymentQueueHandler`.
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
public class FIAPaymentQueueHandler: NSObject, SKPaymentTransactionObserver,
  FLTPaymentQueueHandlerProtocol
{

  /// The SKPaymentQueue (wrapper) instance connected to the App Store and
  /// responsible for processing transactions.
  private let queue: FLTPaymentQueueProtocol

  /// Callback method that is called each time the App Store indicates transactions are updated.
  private let transactionsUpdated: TransactionsUpdated?

  /// Callback method that is called each time the App Store indicates transactions are removed.
  private let transactionsRemoved: TransactionsRemoved?

  /// Callback method that is called each time the App Store indicates transactions failed to
  /// restore.
  private let restoreTransactionFailed: RestoreTransactionFailed?

  /// Callback method that is called each time the App Store indicates restoring of transactions
  /// has finished.
  private let paymentQueueRestoreCompletedTransactionsFinished:
    RestoreCompletedTransactionsFinished?

  /// Callback method that is called each time an in-app purchase has been initiated from the App
  /// Store.
  private let shouldAddStorePayment: ShouldAddStorePayment?

  /// Callback method that is called each time the App Store indicates downloads are updated.
  private let updatedDownloads: UpdatedDownloads?

  /// The transaction cache responsible for caching transactions.
  ///
  /// Keeps track of transactions that arrive when the Flutter client is not
  /// actively observing for transactions.
  private let transactionCache: FLTTransactionCacheProtocol

  /// Indicates if the Flutter client is observing transactions.
  ///
  /// When the client is not observing, transactions are cached and send to
  /// the client as soon as it starts observing. The Flutter client can start
  /// observing by sending a startObservingPaymentQueue message and stop by
  /// sending a stopObservingPaymentQueue message.
  private var observingTransactions = false

  /// An object that provides information needed to complete transactions.
  public weak var delegate: SKPaymentQueueDelegate?

  /// Creates a new FIAPaymentQueueHandler.
  ///
  /// - Parameters:
  ///   - queue: The SKPaymentQueue instance connected to the App Store and
  ///     responsible for processing transactions.
  ///   - transactionsUpdated: Callback method that is called each time the App
  ///     Store indicates transactions are updated.
  ///   - transactionRemoved: Callback method that is called each time the App
  ///     Store indicates transactions are removed.
  ///   - restoreTransactionFailed: Callback method that is called each time
  ///     the App Store indicates transactions failed to restore.
  ///   - restoreCompletedTransactionsFinished: Callback method that is called
  ///     each time the App Store indicates restoring of transactions has
  ///     finished.
  ///   - shouldAddStorePayment: Callback method that is called each time an
  ///     in-app purchase has been initiated from the App Store.
  ///   - updatedDownloads: Callback method that is called each time the App
  ///     Store indicates downloads are updated.
  ///   - transactionCache: An empty FIATransactionCache instance that is
  ///     responsible for keeping track of transactions that arrive when not
  ///     actively observing transactions.
  public required init(
    queue: FLTPaymentQueueProtocol,
    transactionsUpdated: TransactionsUpdated?,
    transactionRemoved: TransactionsRemoved?,
    restoreTransactionFailed: RestoreTransactionFailed?,
    restoreCompletedTransactionsFinished: RestoreCompletedTransactionsFinished?,
    shouldAddStorePayment: ShouldAddStorePayment?,
    updatedDownloads: UpdatedDownloads?,
    transactionCache: FLTTransactionCacheProtocol
  ) {
    self.queue = queue
    self.transactionsUpdated = transactionsUpdated
    self.transactionsRemoved = transactionRemoved
    self.restoreTransactionFailed = restoreTransactionFailed
    self.paymentQueueRestoreCompletedTransactionsFinished = restoreCompletedTransactionsFinished
    self.shouldAddStorePayment = shouldAddStorePayment
    self.updatedDownloads = updatedDownloads
    self.transactionCache = transactionCache
    super.init()

    self.queue.add(self)
    self.queue.delegate = self.delegate
  }

  public func startObservingPaymentQueue() {
    observingTransactions = true
    processCachedTransactions()
  }

  public func stopObservingPaymentQueue() {
    // When the client stops observing transaction, the transaction observer is
    // not removed from the SKPaymentQueue. The FIAPaymentQueueHandler will cache
    // transactions in memory when the client is not observing, allowing the app
    // to process these transactions if it starts observing again during the same
    // lifetime of the app.
    //
    // If the app is killed, cached transactions will be removed from memory;
    // however, the App Store will re-deliver the transactions as soon as the app
    // is started again, since the cached transactions have not been acknowledged
    // by the client (by sending the `finishTransaction` message).
    observingTransactions = false
  }

  private func processCachedTransactions() {
    var cachedObjects = transactionCache.getObjectsFor(.updatedTransactions)
    if cachedObjects.count != 0 {
      transactionsUpdated?(cachedObjects as! [SKPaymentTransaction])
    }

    cachedObjects = transactionCache.getObjectsFor(.updatedDownloads)
    if cachedObjects.count != 0 {
      updatedDownloads?(cachedObjects as! [SKDownload])
    }

    cachedObjects = transactionCache.getObjectsFor(.removedTransactions)
    if cachedObjects.count != 0 {
      transactionsRemoved?(cachedObjects as! [SKPaymentTransaction])
    }

    transactionCache.clear()
  }

  public func add(_ payment: SKPayment) -> Bool {
    for transaction in queue.transactions {
      if transaction.payment.productIdentifier == payment.productIdentifier {
        return false
      }
    }
    queue.add(payment)
    return true
  }

  public func finish(_ transaction: SKPaymentTransaction) {
    queue.finish(transaction)
  }

  public func restoreTransactions(_ applicationName: String?) {
    if let applicationName = applicationName {
      queue.restoreCompletedTransactions(withApplicationUsername: applicationName)
    } else {
      queue.restoreCompletedTransactions()
    }
  }

  #if os(iOS)
    public func presentCodeRedemptionSheet() {
      if #available(iOS 14, *) {
        queue.presentCodeRedemptionSheet()
      } else {
        NSLog("presentCodeRedemptionSheet is only available on iOS 14 or newer")
      }
    }
  #endif

  #if os(iOS)
    @available(iOS 13.4, *)
    public func showPriceConsentIfNeeded() {
      queue.showPriceConsentIfNeeded()
    }
  #endif

  // MARK: - observing

  // Sent when the transaction array has changed (additions or state changes).  Client should
  // check state of transactions and finish as appropriate.
  public func paymentQueue(
    _ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]
  ) {
    if !observingTransactions {
      transactionCache.add(transactions, for: .updatedTransactions)
      return
    }

    // notify dart through callbacks.
    transactionsUpdated?(transactions)
  }

  // Sent when transactions are removed from the queue (via finishTransaction:).
  public func paymentQueue(
    _ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]
  ) {
    if !observingTransactions {
      transactionCache.add(transactions, for: .removedTransactions)
      return
    }
    transactionsRemoved?(transactions)
  }

  // Sent when an error is encountered while adding transactions from the user's purchase history
  // back to the queue.
  public func paymentQueue(
    _ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error
  ) {
    restoreTransactionFailed?(error as NSError)
  }

  // Sent when all transactions from the user's purchase history have successfully been added
  // back to the queue.
  public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    paymentQueueRestoreCompletedTransactionsFinished?()
  }

  // Sent when the download state has changed.
  public func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
    if !observingTransactions {
      transactionCache.add(downloads, for: .updatedDownloads)
      return
    }
    updatedDownloads?(downloads)
  }

  // Sent when a user initiates an IAP buy from the App Store.
  public func paymentQueue(
    _ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct
  ) -> Bool {
    return shouldAddStorePayment?(payment, product) ?? false
  }

  public func getUnfinishedTransactions() -> [SKPaymentTransaction] {
    return queue.transactions
  }

  public var storefront: SKStorefront? {
    return queue.storefront
  }
}
