// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@available(iOS 15.0, macOS 12.0, *)
extension InAppPurchasePlugin: InAppPurchase2API {
  // https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments
  func canMakePayments() throws -> Bool {
    return AppStore.canMakePayments
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

  // Raw storekit calls

  func rawProducts(identifiers: [String]) async throws -> [Product] {
    return try await Product.products(for: identifiers)
  }
}
