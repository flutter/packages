// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@available(iOS 15.0, macOS 12.0, *)
extension InAppPurchasePlugin: InAppPurchase2API {
  // https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments
  func canMakePayments() throws -> Bool {
    return AppStore.canMakePayments
  }

  // Gets the appropriate product, then calls purchase on it.
  // https://developer.apple.com/documentation/storekit/product/3791971-purchase
  func purchase(
    id: String, options: SK2ProductPurchaseOptionsMessage?,
    completion: @escaping (Result<SK2ProductPurchaseResultMessage, any Error>) -> Void
  ) {
    Task {
      do {
        let product = try await rawProducts(identifiers: [id]).first
        guard let product = product else {
          throw PigeonError(
            code: "storekit2_failed_to_fetch_product", message: "failed to make purchase",
            details: "")
        }
        print("native purchase")
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
          switch verification {
          case .verified(let transaction):
            TransactionCache.shared.add(transaction: transaction)
            print("purchase \(transaction)")
            self.transactionListenerAPI?.transactionUpdated(updatedTransactions: transaction)
            completion(.success(result.convertToPigeon()))
          case .unverified(_, let error):
            completion(.failure(error))
          }
        case .pending:
          completion(
            .failure(
              PigeonError(
                code: "storekit2_purchase_pending", message: "this transaction is still pending",
                details: "")))
        case .userCancelled:
          completion(
            .failure(
              PigeonError(
                code: "storekit2_purchase_cancelled",
                message: "this transaction has been cancelled", details: "")))
        @unknown default:
          fatalError()
        }
      } catch {
        completion(.failure(error))
      }

    }
  }

  // Pigeon method
  func products(
    identifiers: [String], completion: @escaping (Result<[SK2ProductMessage], any Error>) -> Void
  ) {
    Task {
      do {
        let products = try await rawProducts(identifiers: identifiers)
        let productMessages = products.map { product in
          product.convertToPigeon()
        }
        completion(.success(productMessages))
      } catch {
        completion(.failure(error))
      }
    }

  }

  func transactions(
    completion: @escaping (Result<[SK2TransactionMessage], any Error>) -> Void
  ) {
    Task {
      do {
        let transactionsMsgs = await rawTransactions().map {
          $0.convertToPigeon()
        }
        completion(.success(transactionsMsgs))
      }
    }
  }

  func finish(id: Int64, completion: @escaping (Result<Void, any Error>) -> Void) {
    Task {
      print("native finish")
      let transaction = TransactionCache.shared.get(id: Int(id))
      if let transaction = transaction {
        await transaction.finish()
        TransactionCache.shared.remove(id: Int(id))
      }

    }
  }

  func startListeningToTransactions() throws {
    self.updateListenerTask = self.listenForTransactions()
  }

  func stopListeningToTransactions() throws {
    self.updateListenerTask = nil
  }

  func listenForTransactions() -> Task<Void, Error> {
    return Task.detached {
      for await verificationResult in Transaction.updates {
        switch verificationResult {
        case .verified(let transaction):
          print("listened \(transaction.productID)")
          TransactionCache.shared.add(transaction: transaction)
          self.transactionListenerAPI?.transactionUpdated(updatedTransactions: transaction)
        case .unverified(let transaction, _):
          print("unverified", transaction.id)
          break
        }
      }
    }

  }
  func countryCode(completion: @escaping (Result<String, any Error>) -> Void) {
    Task {
      return await Storefront.current?.countryCode
    }
  }

  func restorePurchases(completion: @escaping (Result<Void, any Error>) -> Void) {
    Task {
      for await completedPurchase in Transaction.currentEntitlements {
        switch completedPurchase {
        case .verified(let purchase):
          print("restoring \(purchase)");
          self.transactionListenerAPI?.transactionUpdated(
            updatedTransactions: purchase, restoring: true)
        case .unverified(_, _):
          fatalError()
        }
      }

    }
  }

  // Raw storekit calls

  func rawProducts(identifiers: [String]) async throws -> [Product] {
    return try await Product.products(for: identifiers)
  }

  func rawTransactions() async -> [Transaction] {
    var transactions: [Transaction] = []

    for await verificationResult in Transaction.all {
      switch verificationResult {
      case .verified(let transaction):
        transactions.append(transaction)
      case .unverified(_, _):
        // Handle unverified transactions if necessary
        break
      }
    }
    return transactions
  }
}
