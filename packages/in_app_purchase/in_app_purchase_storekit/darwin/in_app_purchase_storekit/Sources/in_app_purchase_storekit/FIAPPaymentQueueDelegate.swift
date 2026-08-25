// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

@available(iOS 13, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public class FIAPPaymentQueueDelegate: NSObject, SKPaymentQueueDelegate {
  /// The designated Flutter method channel that handles if a transaction should be continued
  private let callbackChannel: FLTMethodChannelProtocol

  public init(methodChannel: FLTMethodChannelProtocol) {
    self.callbackChannel = methodChannel
  }

  public func paymentQueue(
    _ paymentQueue: SKPaymentQueue, shouldContinue transaction: SKPaymentTransaction,
    in storefront: SKStorefront
  ) -> Bool {
    // Default return value for this method is true (see
    // https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate/3521328-paymentqueueshouldshowpriceconse?language=objc)
    var shouldContinue = true
    let semaphore = DispatchSemaphore(value: 0)
    callbackChannel.invokeMethod(
      "shouldContinueTransaction",
      arguments: FIAObjectTranslator.getMapFrom(storefront, andSKPaymentTransaction: transaction),
      result: { result in
        // When result is a valid instance of NSNumber use it to determine
        // if the transaction should continue. Otherwise use the default
        // value.
        if let result = result as? NSNumber {
          shouldContinue = result.boolValue
        }

        semaphore.signal()
      })

    // The client should respond within 1 second otherwise continue
    // with default value.
    _ = semaphore.wait(timeout: .now() + 1)

    return shouldContinue
  }

  #if os(iOS)
    public func paymentQueueShouldShowPriceConsent(_ paymentQueue: SKPaymentQueue) -> Bool {
      // Default return value for this method is true (see
      // https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate/3521328-paymentqueueshouldshowpriceconse?language=objc)
      var shouldShowPriceConsent = true
      let semaphore = DispatchSemaphore(value: 0)
      callbackChannel.invokeMethod(
        "shouldShowPriceConsent", arguments: nil,
        result: { result in
          // When result is a valid instance of NSNumber use it to determine
          // if the transaction should continue. Otherwise use the default
          // value.
          if let result = result as? NSNumber {
            shouldShowPriceConsent = result.boolValue
          }

          semaphore.signal()
        })

      // The client should respond within 1 second otherwise continue
      // with default value.
      _ = semaphore.wait(timeout: .now() + 1)

      return shouldShowPriceConsent
    }
  #endif
}
