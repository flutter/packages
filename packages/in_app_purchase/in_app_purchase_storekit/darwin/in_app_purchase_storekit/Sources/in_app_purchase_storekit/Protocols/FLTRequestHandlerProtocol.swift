// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

/// A protocol that wraps SKRequest.
@objc public protocol FLTRequestHandlerProtocol: NSObjectProtocol {
  /// Wrapper for SKRequest's start
  /// https://developer.apple.com/documentation/storekit/skrequest/1385534-start
  func startProductRequest(completionHandler: @escaping (SKProductsResponse?, Error?) -> Void)
}

/// The default request handler that wraps FIAPRequestHandler
public class DefaultRequestHandler: NSObject, FLTRequestHandlerProtocol {
  /// The wrapped FIAPRequestHandler
  private let handler: FIAPRequestHandler

  /// Initialize this wrapper with an instance of FIAPRequestHandler
  public init(requestHandler: FIAPRequestHandler) {
    self.handler = requestHandler
  }

  public func startProductRequest(
    completionHandler: @escaping (SKProductsResponse?, Error?) -> Void
  ) {
    handler.startProductRequest(completionHandler: completionHandler)
  }
}
