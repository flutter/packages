// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

@objcMembers
public class InAppPurchasePlugin: NSObject, FlutterPlugin, InAppPurchaseAPI {
  // Properties
  private let receiptManager: FIAPReceiptManager
  private var productsCache: NSMutableDictionary = [:]
  private var paymentQueueDelegateCallbackChannel: FlutterMethodChannel?
  private var paymentQueueDelegate: Any? = nil
  // note - the type should be FIAPPaymentQueueDelegate, but this is only available >= iOS 13,
  private var requestHandlers = Set<FIAPRequestHandler>()
  private var handlerFactory: ((SKRequest) -> FIAPRequestHandler)
  public var registrar: FlutterPluginRegistrar?
  public var paymentQueueHandler: FIAPaymentQueueHandler?
  public var transactionObserverCallbackChannel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #endif
    #if os(macOS)
      let messenger = registrar.messenger
    #endif
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/in_app_purchase",
      binaryMessenger: messenger)
    let instance = InAppPurchasePlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
    SetUpInAppPurchaseAPI(messenger, instance)
  }

  public init(receiptManager: FIAPReceiptManager) {
    self.receiptManager = receiptManager
    self.requestHandlers = Set<FIAPRequestHandler>()
    self.productsCache = NSMutableDictionary()
    self.handlerFactory = { request in
      return FIAPRequestHandler(request: request)
    }
    super.init()
  }

  public convenience init(
    receiptManager: FIAPReceiptManager,
    handlerFactory: @escaping (SKRequest) -> FIAPRequestHandler
  ) {
    self.init(receiptManager: receiptManager)
    self.handlerFactory = handlerFactory
  }

  public convenience init(registrar: FlutterPluginRegistrar) {
    self.init(receiptManager: FIAPReceiptManager())
    self.registrar = registrar

    self.paymentQueueHandler = FIAPaymentQueueHandler(
      queue: SKPaymentQueue.default(),
      transactionsUpdated: { [weak self] (transactions: [SKPaymentTransaction]) -> Void in
        self?.handleTransactionsUpdated(transactions)
      },
      transactionRemoved: { [weak self] (transactions: [SKPaymentTransaction]) -> Void in
        self?.handleTransactionsRemoved(transactions)
      },
      restoreTransactionFailed: { [weak self] error in
        self?.handleTransactionRestoreFailed(error as NSError)
      },
      restoreCompletedTransactionsFinished: { [weak self] () -> Void in
        self?.restoreCompletedTransactionsFinished()
      },
      shouldAddStorePayment: { [weak self] (payment: SKPayment, product: SKProduct) -> Bool in
        return self?.shouldAddStorePayment(payment: payment, product: product) ?? false
      },
      updatedDownloads: { [weak self] _ in
        self?.updatedDownloads()
      }, transactionCache: FIATransactionCache())
    #if os(iOS)
      let messenger = registrar.messenger()
    #endif
    #if os(macOS)
      let messenger = registrar.messenger
    #endif
    transactionObserverCallbackChannel = FlutterMethodChannel(
      name: "plugins.flutter.io/in_app_purchase", binaryMessenger: messenger)
  }

  public func canMakePaymentsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    return SKPaymentQueue.canMakePayments() as NSNumber
  }

  public func transactionsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> [SKPaymentTransactionMessage]?
  {
    let transactions = self.paymentQueueHandler!.getUnfinishedTransactions()
    var transactionMaps: [SKPaymentTransactionMessage] = []
    transactionMaps = transactions.compactMap {
      FIAObjectTranslator.convertTransaction(toPigeon: $0)
    }
    return transactionMaps
  }

  public func storefrontWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> SKStorefrontMessage?
  {
    if #available(iOS 13.0, *) {
      let storefront = self.paymentQueueHandler?.storefront
      guard let storefront else {
        return nil
      }
      return FIAObjectTranslator.convertStorefront(toPigeon: storefront)
    }
    return nil
  }

  public func startProductRequestProductIdentifiers(
    _ productIdentifiers: [String],
    completion: @escaping (SKProductsResponseMessage?, FlutterError?) -> Void
  ) {
    let request = getProductRequest(withIdentifiers: Set(productIdentifiers))
    let handler = handlerFactory(request)
    requestHandlers.insert(handler)

    handler.startProductRequest { [weak self] response, startProductRequestError in
      if let startProductRequestError = startProductRequestError {
        let error = FlutterError(
          code: "storekit_getproductrequest_platform_error",
          message: startProductRequestError.localizedDescription,
          details: startProductRequestError.localizedDescription)
        completion(nil, error)
        return
      }

      guard let response = response else {
        let error = FlutterError(
          code: "storekit_platform_no_response",
          message:
            "Failed to get SKProductResponse in startRequest call. Error occurred on iOS platform",
          details: productIdentifiers)
        completion(nil, error)
        return
      }

      for product in response.products {
        self?.productsCache[product.productIdentifier] = product
      }

      if #available(iOS 12.2, *) {
        if let responseMessage = FIAObjectTranslator.convertProductsResponse(toPigeon: response) {
          completion(responseMessage, nil)
        }
      }
      self?.requestHandlers.remove(handler)
    }
  }

  public func addPaymentPaymentMap(
    _ paymentMap: [String: Any], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    guard let productID = paymentMap["productIdentifier"] as? String else {
      error.pointee = FlutterError(
        code: "storekit_missing_product_identifier",
        message: "The `productIdentifier` is missing from the payment map.",
        details: paymentMap)
      return
    }

    guard let product = self.getProduct(productID: productID) else {
      error.pointee = FlutterError(
        code: "storekit_invalid_payment_object",
        message:
          "You have requested a payment for an invalid product. Either the `productIdentifier` of the payment is not valid or the product has not been fetched before adding the payment to the payment queue.",
        details: paymentMap)
      return
    }

    let payment = SKMutablePayment(product: product)
    payment.applicationUsername = paymentMap["applicationUsername"] as? String
    payment.quantity = paymentMap["quantity"] as? Int ?? 1
    payment.simulatesAskToBuyInSandbox = paymentMap["simulatesAskToBuyInSandbox"] as? Bool ?? false

    if #available(iOS 12.2, *) {
      if let paymentDiscountMap = paymentMap["paymentDiscount"] as? [String: Any],
        !paymentDiscountMap.isEmpty
      {
        var invalidError: NSString?
        if let paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(
          fromMap: paymentDiscountMap, withError: &invalidError)
        {
          payment.paymentDiscount = paymentDiscount
        } else if let invalidError = invalidError {
          error.pointee = FlutterError(
            code: "storekit_invalid_payment_discount_object",
            message:
              "You have requested a payment and specified a payment discount with invalid properties. \(invalidError)",
            details: paymentMap)
          return
        }
      }
    }

    if !self.paymentQueueHandler!.add(payment) {
      error.pointee = FlutterError(
        code: "storekit_duplicate_product_object",
        message:
          "There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases.",
        details: paymentMap)
      return
    }
  }

  public func finishTransactionFinishMap(
    _ finishMap: [String: Any], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    guard let transactionIdentifier = finishMap["transactionIdentifier"] as? String,
      let productIdentifier = finishMap["productIdentifier"] as? String
    else {
      return
    }

    let pendingTransactions = paymentQueueHandler!.getUnfinishedTransactions()

    for transaction in pendingTransactions {
      // Check if the current transaction's identifier matches the provided one,
      // or both identifiers are nil and the product identifiers match.
      if transaction.transactionIdentifier == transactionIdentifier
        || (transactionIdentifier == NSNull().description
          && transaction.transactionIdentifier == nil
          && transaction.payment.productIdentifier == productIdentifier)
      {
        paymentQueueHandler!.finish(transaction)
      }
    }
  }

  public func restoreTransactionsApplicationUserName(
    _ applicationUserName: String?, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    paymentQueueHandler?.restoreTransactions(applicationUserName)
  }

  public func presentCodeRedemptionSheetWithError(
    _ error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    #if os(iOS)
      paymentQueueHandler!.presentCodeRedemptionSheet()
    #endif
  }

  public func retrieveReceiptDataWithError(
    _ error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> String? {
    var flutterError: FlutterError? = nil
    let receiptData: String? = receiptManager.retrieveReceiptWithError(&flutterError)
    if receiptData == nil {
      error.pointee = flutterError
      return nil
    }
    return receiptData
  }

  public func refreshReceiptReceiptProperties(
    _ receiptProperties: [String: Any]?, completion: @escaping (FlutterError?) -> Void
  ) {
    var request: SKReceiptRefreshRequest
    if let receiptProperties = receiptProperties {
      // If receiptProperties is not nil, this call is for testing.
      let properties = [
        SKReceiptPropertyIsExpired: receiptProperties["isExpired"]!,
        SKReceiptPropertyIsRevoked: receiptProperties["isRevoked"]!,
        SKReceiptPropertyIsVolumePurchase: receiptProperties["isVolumePurchase"]!,
      ]
      request = getRefreshReceiptRequest(properties: properties)
    } else {
      request = getRefreshReceiptRequest(properties: nil)
    }

    let handler = handlerFactory(request)
    requestHandlers.insert(handler)
    handler.startProductRequest { [weak self] response, error in
      if let error = error {
        let requestError = FlutterError(
          code: "storekit_refreshreceiptrequest_platform_error",
          message: error.localizedDescription,
          details: error.localizedDescription)
        completion(requestError)
        return
      }
      completion(nil)
      self?.requestHandlers.remove(handler)
    }
  }

  public func startObservingPaymentQueueWithError(
    _ error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    paymentQueueHandler!.startObservingPaymentQueue()
  }

  public func stopObservingPaymentQueueWithError(
    _ error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    paymentQueueHandler!.stopObservingPaymentQueue()
  }

  public func registerPaymentQueueDelegateWithError(
    _ error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    #if os(iOS)
      if #available(iOS 13.0, *) {
        let messenger = registrar?.messenger()
        paymentQueueDelegateCallbackChannel = FlutterMethodChannel(
          name: "plugins.flutter.io/in_app_purchase_payment_queue_delegate",
          binaryMessenger: messenger!)

        paymentQueueDelegate = FIAPPaymentQueueDelegate(
          methodChannel: paymentQueueDelegateCallbackChannel!)
        paymentQueueHandler!.delegate = (paymentQueueDelegate as! any SKPaymentQueueDelegate)
      }
    #endif
  }

  public func removePaymentQueueDelegateWithError(
    _ error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    #if os(iOS)
      if #available(iOS 13.0, *) {
        paymentQueueDelegateCallbackChannel = nil
        paymentQueueHandler!.delegate = nil
        paymentQueueDelegate = nil
      }
    #endif
  }

  public func showPriceConsentIfNeededWithError(
    _ error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    #if os(iOS)
      if #available(iOS 13.4, *) {
        paymentQueueHandler!.showPriceConsentIfNeeded()
      }
    #endif
  }

  public func handleTransactionsUpdated(_ transactions: [SKPaymentTransaction]) {
    let maps = transactions.map { transaction in
      FIAObjectTranslator.getMapFrom(transaction)
    }
    transactionObserverCallbackChannel!.invokeMethod("updatedTransactions", arguments: maps)
  }

  public func handleTransactionsRemoved(_ transactions: [SKPaymentTransaction]) {
    let maps = transactions.map { transaction in
      FIAObjectTranslator.getMapFrom(transaction)
    }
    transactionObserverCallbackChannel!.invokeMethod("removedTransactions", arguments: maps)
  }

  public func handleTransactionRestoreFailed(_ error: NSError) {
    transactionObserverCallbackChannel!.invokeMethod(
      "restoreCompletedTransactionsFailed", arguments: FIAObjectTranslator.getMapFrom(error))
  }

  public func restoreCompletedTransactionsFinished() {
    transactionObserverCallbackChannel!.invokeMethod(
      "paymentQueueRestoreCompletedTransactionsFinished", arguments: nil)
  }

  public func shouldAddStorePayment(payment: SKPayment, product: SKProduct) -> Bool {
    productsCache[product.productIdentifier] = product
    transactionObserverCallbackChannel!
      .invokeMethod(
        "shouldAddStorePayment",
        arguments: [
          "payment": FIAObjectTranslator.getMapFrom(payment),
          "product": FIAObjectTranslator.getMapFrom(product),
        ])
    return false
  }

  func updatedDownloads() {
    NSLog("Received an updatedDownloads callback, but downloads are not supported.")
  }

  public func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments() as Bool
  }

  func getProduct(productID: String) -> SKProduct? {
    return self.productsCache[productID] as? SKProduct
  }

  func getProductRequest(withIdentifiers productIdentifiers: Set<String>) -> SKProductsRequest {
    return SKProductsRequest(productIdentifiers: productIdentifiers)
  }

  func getNonNullValue(from dictionary: [String: Any], forKey key: String) -> Any? {
    let value = dictionary[key]
    return value is NSNull ? nil : value
  }

  func getRefreshReceiptRequest(properties: [String: Any]?) -> SKReceiptRefreshRequest {
    return SKReceiptRefreshRequest(receiptProperties: properties)
  }
}
