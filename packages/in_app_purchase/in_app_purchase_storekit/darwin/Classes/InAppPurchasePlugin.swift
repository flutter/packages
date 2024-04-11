
import Foundation
import StoreKit

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

extension FlutterError: Error {}

public final class InAppPurchasePlugin: NSObject, FlutterPlugin, InAppPurchaseAPI {
  public func startProductRequestProductIdentifiers(_ productIdentifiers: [String], completion: @escaping (SKProductsResponseMessage?, FlutterError?) -> Void) {
    let request = getProductRequest(withIdentifiers: Set(productIdentifiers))
            let handler = handlerFactory!(request)
            requestHandlers.insert(handler)

            handler.startProductRequest { response, startProductRequestError in
                var error: FlutterError;
                if let startProductRequestError = startProductRequestError {
                    error = FlutterError(code: "storekit_getproductrequest_platform_error",
                                         message: startProductRequestError.localizedDescription,
                                         details: startProductRequestError.localizedDescription)
                  completion(nil, error);
                  return
                }

                guard let response = response else {
                    error = FlutterError(code: "storekit_platform_no_response",
                                         message: "Failed to get SKProductResponse in startRequest call. Error occurred on iOS platform",
                                         details: productIdentifiers)
                  completion(nil, error);
                  return
                }

                response.products.forEach { product in
                    self.productsCache[product.productIdentifier] = product
                }

              if #available(iOS 12.2, *) {
                if let responseMessage = FIAObjectTranslator.convertProductsResponse(toPigeon: response){
                  completion(responseMessage, nil);
                }
              }
                self.requestHandlers.remove(handler)
            }
  }

  

  // Properties
  private(set) var productsCache: NSMutableDictionary = [:]
  private(set) var paymentQueueDelegateCallbackChannel: FlutterMethodChannel?
  private(set) var registrar: FlutterPluginRegistrar?
  private(set) var receiptManager: FIAPReceiptManager?
  private(set) var paymentQueueDelegate: Any? = nil;
  // note - the type should be FIAPPaymentQueueDelegate, but this is only available >= iOS 13,
  private var requestHandlers = Set<FIAPRequestHandler>()
  private var handlerFactory: ((SKRequest) -> FIAPRequestHandler)?
  @objc
  public var paymentQueueHandler: FIAPaymentQueueHandler?
  private var transactionObserverCallbackChannel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.flutter.io/in_app_purchase",
                                       binaryMessenger: registrar.messenger())
    let instance = InAppPurchasePlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
//    InAppPurchaseAPISetup.setUp(binaryMessenger: registrar.messenger(), api: instance as InAppPurchaseAPI)
    SetUpInAppPurchaseAPI(registrar.messenger(), instance);
  }

  @objc
  public init(receiptManager: FIAPReceiptManager) {
    self.receiptManager = receiptManager
    self.requestHandlers = Set<FIAPRequestHandler>();
    self.productsCache = NSMutableDictionary()
    self.handlerFactory = { request in
        return FIAPRequestHandler(request: request)
    }
    super.init()
  }

  @objc
  public convenience init(receiptManager: FIAPReceiptManager, handlerFactory: @escaping (SKRequest) -> FIAPRequestHandler) {
    self.init(receiptManager: receiptManager)
    self.handlerFactory = handlerFactory;
  }

  @objc
  public convenience init(registrar: FlutterPluginRegistrar) {
    self.init(receiptManager: FIAPReceiptManager());
    self.registrar = registrar;

    self.paymentQueueHandler = FIAPaymentQueueHandler(queue: SKPaymentQueue.default(), transactionsUpdated: { (transactions: [SKPaymentTransaction]) -> () in
      self.handleTransactionsUpdated(transactions)
    }, transactionRemoved: { (transactions: [SKPaymentTransaction]) -> () in
      self.handleTransactionsRemoved(transactions)
    }, restoreTransactionFailed: { error in
      self.handleTransactionRestoreFailed(error)
    }, restoreCompletedTransactionsFinished: { () -> () in
      self.restoreCompletedTransactionsFinished()
    }, shouldAddStorePayment: { (payment: SKPayment, product: SKProduct) -> Bool in
      return self.shouldAddStorePayment(payment: payment, product: product)
    }, updatedDownloads: {_ in
      self.updatedDownloads()
    }, transactionCache: FIATransactionCache())

    self.transactionObserverCallbackChannel = FlutterMethodChannel(name: "plugins.flutter.io/in_app_purchase", binaryMessenger: registrar.messenger())
  }


//  public func startProductRequestProductIdentifiers(_ productIdentifiers: [String]) async -> (SKProductsResponseMessage?, FlutterError?) {
//        let request = getProductRequest(withIdentifiers: Set(productIdentifiers))
//        let handler = handlerFactory!(request)
//        requestHandlers.insert(handler)
//
//    if #available(iOS 13.0, *) {
//      let result: (SKProductsResponseMessage?, FlutterError?) = await withCheckedContinuation { continuation in
//        handler.startProductRequest { [weak self] response, startProductRequestError in
//          guard let self = self else {
//            continuation.resume(returning: (nil, FlutterError(code: "internal_error", message: "Self is nil", details: nil)))
//            return
//          }
//
//          if let startProductRequestError = startProductRequestError {
//            let error = FlutterError(code: "storekit_getproductrequest_platform_error",
//                                     message: startProductRequestError.localizedDescription,
//                                     details: startProductRequestError.localizedDescription)
//            continuation.resume(returning: (nil, error))
//            return
//          }
//
//          guard let response = response else {
//            let error = FlutterError(code: "storekit_platform_no_response",
//                                     message: "Failed to get SKProductResponse in startRequest call. Error occurred on iOS platform",
//                                     details: productIdentifiers)
//            continuation.resume(returning: (nil, error))
//            return
//          }
//
//          response.products.forEach { product in
//            self.productsCache[product.productIdentifier] = product
//          }
//
//          let responseMessage = FIAObjectTranslator.convertProductsResponse(toPigeon: response);
//          continuation.resume(returning: (responseMessage, nil));
//
//          self.requestHandlers.remove(handler)
//        }
//      }
//    } else {
//      // Fallback on earlier versions
//    }
//    return (nil, nil);
//  }

  public func refreshReceiptReceiptProperties(_ receiptProperties: [String : Any]?, completion: @escaping (FlutterError?) -> Void) {
    var request: SKReceiptRefreshRequest
    if let receiptProperties = receiptProperties {
        // If receiptProperties is not nil, this call is for testing.
        var properties: [String: Any] = [:]
      properties[SKReceiptPropertyIsExpired] = receiptProperties["isExpired"]!
      properties[SKReceiptPropertyIsRevoked] = receiptProperties["isRevoked"]!
      properties[SKReceiptPropertyIsVolumePurchase] = receiptProperties["isVolumePurchase"]!
      request = getRefreshReceiptRequest(properties: properties);
    } else {
      request = getRefreshReceiptRequest(properties: nil);
    }

    let handler = handlerFactory!(request)
    requestHandlers.insert(handler)
    handler.startProductRequest { [weak self] response, error in
        if let error = error {
            let requestError = FlutterError(code: "storekit_refreshreceiptrequest_platform_error",
                                            message: error.localizedDescription,
                                            details: error.localizedDescription);
          completion(requestError);
            return
        }
      completion(nil);
      self?.requestHandlers.remove(handler);
    }
  }
//
//  public func refreshReceiptReceiptProperties(_ receiptProperties: [String : Any]?) async -> FlutterError? {
//        var request: SKReceiptRefreshRequest
//        if let receiptProperties = receiptProperties {
//            // If receiptProperties is not nil, this call is for testing.
//            var properties: [String: Any] = [:]
//          properties[SKReceiptPropertyIsExpired] = receiptProperties["isExpired"]!
//          properties[SKReceiptPropertyIsRevoked] = receiptProperties["isRevoked"]!
//          properties[SKReceiptPropertyIsVolumePurchase] = receiptProperties["isVolumePurchase"]!
//          request = getRefreshReceiptRequest(properties: properties);
//        } else {
//          request = getRefreshReceiptRequest(properties: nil);
//        }
//
//        let handler = handlerFactory!(request)
//        requestHandlers.insert(handler)
//
//        if #available(iOS 13.0, *) {
//          return await withCheckedContinuation { continuation in
//            handler.startProductRequest { response, error in
//              if let error = error {
//                let requestError = FlutterError(code: "storekit_refreshreceiptrequest_platform_error",
//                                                message: error.localizedDescription,
//                                                details: nil)
//                continuation.resume(returning: requestError)
//              } else {
//                continuation.resume(returning: nil)
//              }
//              self.requestHandlers.remove(handler)
//            }
//          }
//        } else {
//          // TODO:
//        }
//    return nil;
//  }

  public func canMakePaymentsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
    return SKPaymentQueue.canMakePayments() as NSNumber;
  }

  public func transactionsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> [SKPaymentTransactionMessage]? {
      let transactions = self.paymentQueueHandler?.getUnfinishedTransactions() ?? [];
      var transactionMaps: [SKPaymentTransactionMessage] = []
      for transaction in transactions {
        if #available(iOS 12.2, *) {
          if let map = FIAObjectTranslator.convertTransaction(toPigeon: transaction) {
            transactionMaps.append(map )
          }
        } else {
          // throw version error?
        }
      }
      return transactionMaps
    }

  public func storefrontWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SKStorefrontMessage? {
      if #available(iOS 13.0, *) {
        let storefront = self.paymentQueueHandler?.storefront
        if (storefront == nil) {
          return nil;
        }
        return FIAObjectTranslator.convertStorefront(toPigeon: storefront);
      }
      return nil;
    }


  public func addPaymentPaymentMap(_ paymentMap: [String : Any], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let productID = paymentMap["productIdentifier"] as? String else {
          error.pointee =  FlutterError(code: "storekit_missing_product_identifier",
                               message: "The `productIdentifier` is missing from the payment map.",
                               details: paymentMap)
          return;
        }

        guard let product = self.getProduct(productID: productID) else {
          error.pointee = FlutterError(code: "storekit_invalid_payment_object",
                               message: "You have requested a payment for an invalid product. Either the `productIdentifier` is not valid or the product has not been fetched before adding the payment to the payment queue.",
                               details: paymentMap)
          return;
        }

        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = paymentMap["applicationUsername"] as? String
        payment.quantity = paymentMap["quantity"] as? Int ?? 1
        payment.simulatesAskToBuyInSandbox = paymentMap["simulatesAskToBuyInSandbox"] as? Bool ?? false

        if #available(iOS 12.2, *) {
            if let paymentDiscountMap = paymentMap["paymentDiscount"] as? [String: Any], !paymentDiscountMap.isEmpty {
                var invalidError: NSString?
              if let paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(fromMap: paymentDiscountMap, withError: &invalidError) {
                    payment.paymentDiscount = paymentDiscount
                } else if let invalidError = invalidError {
                  error.pointee = FlutterError(code: "storekit_invalid_payment_discount_object",
                                       message: "You have requested a payment and specified a payment discount with invalid properties: \(invalidError)",
                                       details: paymentMap)
                }
            }
        }

        guard self.paymentQueueHandler?.add(payment) == true else {
          error.pointee = FlutterError(code: "storekit_duplicate_product_object",
                               message: "There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases.",
                               details: paymentMap)
          return;
        };
  }

  public func finishTransactionFinishMap(_ finishMap: [String : String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
      guard let transactionIdentifier = finishMap["transactionIdentifier"],
                let productIdentifier = finishMap["productIdentifier"] else {
        error.pointee = FlutterError(code: "missing_keys", message: "Transaction or product identifier is missing.", details: finishMap)
        return;
          }

          let pendingTransactions = paymentQueueHandler!.getUnfinishedTransactions()

          for transaction in pendingTransactions {
              // If the user cancels the purchase dialog we won't have a transactionIdentifier.
              // So if it is nil AND a transaction in the pendingTransactions list has
              // also a nil transactionIdentifier we check for equal product identifiers.
              if transaction.transactionIdentifier == transactionIdentifier ||
                 (transaction.transactionIdentifier == nil && transaction.payment.productIdentifier == productIdentifier) {
                paymentQueueHandler!.finish(transaction)
                /// The obj c method possibly sets an error, but im not sure how to handle it here
                /// How can i specify the error that is thrown?
              }
          }
  }

  public func restoreTransactionsApplicationUserName(_ applicationUserName: String?, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    paymentQueueHandler?.restoreTransactions(applicationUserName);
  }

  public func presentCodeRedemptionSheetWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
#if os(iOS)
    paymentQueueHandler!.presentCodeRedemptionSheet()
#endif
  }

  public func retrieveReceiptDataWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String? {
    var flutterError : FlutterError? = nil;
    let receiptData : String? = receiptManager!.retrieveReceiptWithError(error);
    if (receiptData == nil) {
      error.pointee = flutterError;
    }
    return receiptData;
  }

  public func startObservingPaymentQueueWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    paymentQueueHandler!.startObservingPaymentQueue();
  }

  public func stopObservingPaymentQueueWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    paymentQueueHandler!.stopObservingPaymentQueue();
  }

  public func registerPaymentQueueDelegateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
#if os(iOS)
    if #available(iOS 13.0, *) {
      paymentQueueDelegateCallbackChannel = FlutterMethodChannel(name: "plugins.flutter.io/in_app_purchase_payment_queue_delegate",
                                         binaryMessenger: registrar!.messenger())

      paymentQueueDelegate = FIAPPaymentQueueDelegate(methodChannel: paymentQueueDelegateCallbackChannel!)
      paymentQueueHandler!.delegate = (paymentQueueDelegate as! any SKPaymentQueueDelegate);
    }
#endif
  }

  public func removePaymentQueueDelegateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
#if os(iOS)
    if #available(iOS 13.0, *) {
      paymentQueueDelegateCallbackChannel = nil;
      paymentQueueHandler!.delegate = nil;
      paymentQueueDelegate = nil;
    }
#endif
  }

  public func showPriceConsentIfNeededWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
#if os(iOS)
    if #available(iOS 13.4, *) {
      paymentQueueHandler!.showPriceConsentIfNeeded();
    }
#endif
  }

  @objc
  public func handleTransactionsUpdated(_ transactions: [SKPaymentTransaction]) {
    var maps: [[AnyHashable: Any]] = []
    for transaction in transactions {
      let map = FIAObjectTranslator.getMapFrom(transaction);
      maps.append(map);
    }
    transactionObserverCallbackChannel!.invokeMethod("updatedTransactions", arguments: maps)
  }

  public func handleTransactionsRemoved(_ transactions: [SKPaymentTransaction]) {
    var maps: [[AnyHashable: Any]] = []
    for transaction in transactions {
      let map = FIAObjectTranslator.getMapFrom(transaction);
      maps.append(map);
    }
    transactionObserverCallbackChannel!.invokeMethod("removedTransactions", arguments: maps)
  }

  public func handleTransactionRestoreFailed(_ error: Error) {
    transactionObserverCallbackChannel!.invokeMethod("restoreCompletedTransactionsFailed", arguments: FIAObjectTranslator.getMapFrom(error));
  }

  public func restoreCompletedTransactionsFinished() {
    transactionObserverCallbackChannel!.invokeMethod("paymentQueueRestoreCompletedTransactionsFinished", arguments:nil);
  }

  public func shouldAddStorePayment(payment: SKPayment, product: SKProduct) -> Bool {
    productsCache[product.productIdentifier] = product;
    transactionObserverCallbackChannel!
      .invokeMethod("shouldAddStorePayment", arguments: [
        "payment": FIAObjectTranslator.getMapFrom(payment),
        "product": FIAObjectTranslator.getMapFrom(product)
      ]);
    return false;
  }

  func updatedDownloads() {
    NSLog("Received an updatedDownloads callback, but downloads are not supported.");
  }

  @objc
  public func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments() as Bool;
  }

  @objc
  func getProduct(productID : String) -> SKProduct? {
    return self.productsCache[productID] as? SKProduct;
  }

  @objc
  func getProductRequest(withIdentifiers productIdentifiers: Set<String>) -> SKProductsRequest {
    return SKProductsRequest(productIdentifiers: productIdentifiers);
  }

  @objc
  func getNonNullValue(from dictionary: [String: Any], forKey key: String) -> Any? {
      let value = dictionary[key]
      return value is NSNull ? nil : value
  }

  @objc
  func getRefreshReceiptRequest(properties: [String: Any]?) -> SKReceiptRefreshRequest {
    return SKReceiptRefreshRequest(receiptProperties: properties);
  }
}

