// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKitTest

@testable import in_app_purchase_storekit

class InAppPurchasePluginStub: InAppPurchasePlugin {
  override func getProductRequest(withIdentifiers productIdentifiers: Set<String>)
    -> SKProductsRequest
  {
    return SKProductRequestStub.init(productIdentifiers: productIdentifiers)
  }

  override func getProduct(productID: String) -> SKProduct? {
    if productID == "" {
      return nil
    }
    return SKProductStub.init(productID: productID)
  }
  override func getRefreshReceiptRequest(properties: [String: Any]?) -> SKReceiptRefreshRequest {
    return SKReceiptRefreshRequest(receiptProperties: properties)
  }
}
