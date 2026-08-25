// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

public class FIAPRequestHandler: NSObject, FLTRequestHandlerProtocol {
  private var completion: ((SKProductsResponse?, Error?) -> Void)?
  private let request: SKRequest

  public init(request: SKRequest) {
    self.request = request
    super.init()
    request.delegate = self
  }

  public func startProductRequest(
    completionHandler: @escaping (SKProductsResponse?, Error?) -> Void
  ) {
    completion = completionHandler
    request.start()
  }
}

extension FIAPRequestHandler: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
  {
    if let completion = completion {
      completion(response, nil)
      // set the completion to nil here so completion won't be triggered again in
      // requestDidFinish for SKProductRequest.
      self.completion = nil
    }
  }
}

extension FIAPRequestHandler: SKRequestDelegate {
  public func requestDidFinish(_ request: SKRequest) {
    completion?(nil, nil)
  }

  public func request(_ request: SKRequest, didFailWithError error: Error) {
    completion?(nil, error)
  }
}
