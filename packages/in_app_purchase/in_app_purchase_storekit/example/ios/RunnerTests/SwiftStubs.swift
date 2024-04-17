//
//  SwiftStubs.swift
//  RunnerTests
//
//  Created by Louise Hsu on 4/12/24.
//  Copyright © 2024 The Flutter Authors. All rights reserved.
//

import Foundation

@testable import in_app_purchase_storekit
import StoreKitTest

class InAppPurchasePluginStub : InAppPurchasePlugin {
  override func getProductRequest(withIdentifiers productIdentifiers: Set<String>) -> SKProductsRequest {
    return SKProductRequestStub.init(productIdentifiers: productIdentifiers);
  }

  override func getProduct(productID: String) -> SKProduct? {
    if (productID == "") {
      return nil;
    }
    return SKProductStub.init(productID: productID);
  }
  override func getRefreshReceiptRequest(properties: [String : Any]?) -> SKReceiptRefreshRequest {
    return SKReceiptRefreshRequest(receiptProperties: properties);
  }
}
