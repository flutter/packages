// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@available(iOS 15.0, macOS 12.0, *)
extension InAppPurchasePlugin: InAppPurchase2API {

  // MARK: - Pigeon Functions

  /// Wrapper method around StoreKit2's canMakePayments() method
  /// https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments
  func canMakePayments() throws -> Bool {
    return AppStore.canMakePayments
  }

  /// Wrapper method around StoreKit2's products() method
  /// https://developer.apple.com/documentation/storekit/product/3851116-products
  func products(
    identifiers: [String], completion: @escaping (Result<[SK2ProductMessage], Error>) -> Void
  ) {
    Task {
      do {
        let products = try await Product.products(for: identifiers)
        let productMessages = products.map {
          $0.convertToPigeon
        }
        completion(.success(productMessages))
      } catch {
        completion(
          .failure(
            PigeonError(
              code: "storekit2_products_error",
              message: error.localizedDescription,
              details: error.localizedDescription)))
      }
    }
  }

  /// Gets the appropriate product, then calls purchase on it.
  /// https://developer.apple.com/documentation/storekit/product/3791971-purchase
  func purchase(
    id: String, options: SK2ProductPurchaseOptionsMessage?,
    completion: @escaping (Result<SK2ProductPurchaseResultMessage, Error>) -> Void
  ) {
    Task { @MainActor in
      do {
        guard let product = try await Product.products(for: [id]).first else {
          let error = PigeonError(
            code: "storekit2_failed_to_fetch_product",
            message: "Storekit has failed to fetch this product.",
            details: "Product ID : \(id)")
          return completion(.failure(error))
        }

        let result = try await product.purchase(options: [])

        switch result {
        case .success(let verification):
          switch verification {
          case .verified(let transaction):
            self.sendTransactionUpdate(transaction: transaction)
            completion(.success(result.convertToPigeon()))
          case .unverified(_, let error):
            completion(.failure(error))
          }
        case .pending:
          completion(
            .failure(
              PigeonError(
                code: "storekit2_purchase_pending",
                message:
                  "This transaction is still pending and but may complete in the future. If it completes, it will be delivered via `purchaseStream`",
                details: "Product ID : \(id)")))
        case .userCancelled:
          completion(
            .failure(
              PigeonError(
                code: "storekit2_purchase_cancelled",
                message: "This transaction has been cancelled by the user.",
                details: "Product ID : \(id)")))
        @unknown default:
          fatalError("An unknown StoreKit PurchaseResult has been encountered.")
        }
      } catch {
        completion(.failure(error))
      }
    }
  }

  /// Wrapper method around StoreKit2's transactions() method
  /// https://developer.apple.com/documentation/storekit/product/3851116-products
  func transactions(
    completion: @escaping (Result<[SK2TransactionMessage], Error>) -> Void
  ) {
    Task {
      @MainActor in
      do {
        let transactionsMsgs = await rawTransactions().map {
          $0.convertToPigeon(receipt: nil)
        }
        completion(.success(transactionsMsgs))
      }
    }
  }

  func restorePurchases(completion: @escaping (Result<Void, Error>) -> Void) {
    Task { [weak self] in
      guard let self = self else { return }
      do {
        var unverifiedPurchases: [UInt64: (receipt: String, error: Error?)] = [:]
        for await completedPurchase in Transaction.currentEntitlements {
          switch completedPurchase {
          case .verified(let purchase):
            self.sendTransactionUpdate(
              transaction: purchase, receipt: "\(completedPurchase.jwsRepresentation)")
          case .unverified(let failedPurchase, let error):
            unverifiedPurchases[failedPurchase.id] = (
              receipt: completedPurchase.jwsRepresentation, error: error
            )
          }
        }
        if !unverifiedPurchases.isEmpty {
          completion(
            .failure(
              PigeonError(
                code: "storekit2_restore_failed",
                message:
                  "This purchase could not be restored.",
                details: unverifiedPurchases)))
        }
        completion(.success(Void()))
      }
    }
  }

  /// Wrapper method around StoreKit2's finish() method https://developer.apple.com/documentation/storekit/transaction/3749694-finish
  func finish(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    Task {
      let transaction = try await fetchTransaction(by: UInt64(id))
      if let transaction = transaction {
        await transaction.finish()
      }
    }
  }

  /// This Task listens  to Transation.updates as shown here
  /// https://developer.apple.com/documentation/storekit/transaction/3851206-updates
  /// This function should be called as soon as the app starts to avoid missing any Transactions done outside of the app.
  func startListeningToTransactions() throws {
    self.setListenerTaskAsTask(
      task: Task { [weak self] in
        for await verificationResult in Transaction.updates {
          switch verificationResult {
          case .verified(let transaction):
            self?.sendTransactionUpdate(transaction: transaction)
          case .unverified:
            break
          }
        }
      })
  }

  /// Stop subscribing to Transaction.updates
  func stopListeningToTransactions() throws {
    updateListenerTask.cancel()
  }

  /// Sends an transaction back to Dart. Access these transactions with `purchaseStream`
  private func sendTransactionUpdate(transaction: Transaction, receipt: String? = nil) {
    let transactionMessage = transaction.convertToPigeon(receipt: receipt)
    self.transactionCallbackAPI?.onTransactionsUpdated(newTransactions: [transactionMessage]) {
      result in
      switch result {
      case .success: break
      case .failure(let error):
        print("Failed to send transaction updates: \(error)")
      }
    }
  }

  // MARK: - Convenience Functions

  /// Helper function that fetches and unwraps all verified transactions
  private func rawTransactions() async -> [Transaction] {
    var transactions: [Transaction] = []
    for await verificationResult in Transaction.all {
      switch verificationResult {
      case .verified(let transaction):
        transactions.append(transaction)
      case .unverified:
        break
      }
    }
    return transactions
  }

  /// Helper function to fetch specific transaction
  private func fetchTransaction(by id: UInt64) async throws -> Transaction? {
    for await result in Transaction.all {
      switch result {
      case .verified(let transaction):
        if transaction.id == id {
          return transaction
        }
      case .unverified:
        continue
      }
    }
    return nil
  }
}
