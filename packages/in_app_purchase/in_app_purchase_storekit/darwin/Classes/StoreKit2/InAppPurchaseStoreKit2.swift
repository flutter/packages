// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@available(iOS 15.0, macOS 12.0, *)
extension InAppPurchasePlugin: InAppPurchase2API {
  // MARK: - Pigeon Functions

  // Wrapper method around StoreKit2's canMakePayments() method
  // https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments
  func canMakePayments() throws -> Bool {
    return AppStore.canMakePayments
  }

  // Wrapper method around StoreKit2's products() method
  // https://developer.apple.com/documentation/storekit/product/3851116-products
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
}
