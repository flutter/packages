// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

public class FIAPReceiptManager: NSObject {
  public override init() {}

  public func retrieveReceiptWithError(_ flutterError: inout FlutterError?) -> String? {
    guard let receiptURL = receiptURL else {
      return nil
    }
    var receiptError: NSError?
    let receipt = getReceiptData(receiptURL, error: &receiptError)
    guard let receipt = receipt, receiptError == nil else {
      let errorMap = FIAObjectTranslator.getMapFrom(receiptError ?? NSError())
      flutterError = FlutterError(
        code: "\(errorMap["code"] ?? "")",
        message: errorMap["domain"] as? String,
        details: errorMap["userInfo"])
      return nil
    }
    return receipt.base64EncodedString()
  }

  /// Gets the receipt file data from the location of the url. Can be nil if
  /// there is an error. This method is defined so it can be overridden for testing.
  @objc(getReceiptData:error:)
  public func getReceiptData(_ url: URL, error: NSErrorPointer) -> Data? {
    do {
      return try Data(contentsOf: url, options: .mappedIfSafe)
    } catch let dataError as NSError {
      error?.pointee = dataError
      return nil
    }
  }

  /// Gets the app store receipt url. Can be nil if
  /// there is an error. This property is defined so it can be overridden for testing.
  @objc public var receiptURL: URL? {
    return Bundle.main.appStoreReceiptURL
  }
}
