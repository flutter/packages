//
//  InAppPurchasePlugin.swift
//  in_app_purchase_storekit
//
//  Created by Louise Hsu on 3/12/24.
//

import Foundation
import StoreKit

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

extension FlutterError: Error {}

@objc
public class InAppPurchasePlugin: NSObject, FlutterPlugin, InAppPurchaseAPI {
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
          error.pointee = FlutterError(code: "storekit_missing_product_identifier",
                               message: "The `productIdentifier` is missing from the payment map.",
                               details: paymentMap)
        }

        guard let product = self.getProduct(productID: productID) else {
          error.pointee = FlutterError(code: "storekit_invalid_payment_object",
                               message: "You have requested a payment for an invalid product. Either the `productIdentifier` is not valid or the product has not been fetched before adding the payment to the payment queue.",
                               details: paymentMap)
        }

        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = paymentMap["applicationUsername"] as? String
        payment.quantity = paymentMap["quantity"] as? Int ?? 1
        payment.simulatesAskToBuyInSandbox = paymentMap["simulatesAskToBuyInSandbox"] as? Bool ?? false

        if #available(iOS 12.2, *) {
            if let paymentDiscountMap = paymentMap["paymentDiscount"] as? [String: Any], !paymentDiscountMap.isEmpty {
                var discount_error: NSString?
              if let paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(fromMap: paymentDiscountMap, withError: &discount_error) {
                    payment.paymentDiscount = paymentDiscount
                } else if let discount_error = discount_error {
                  error.pointee =  FlutterError(code: "storekit_invalid_payment_discount_object",
                                       message: "You have requested a payment and specified a payment discount with invalid properties: \(error)",
                                       details: paymentMap)
                }
            }
        }

        guard self.paymentQueueHandler?.add(payment) == true else {
          error.pointee = FlutterError(code: "storekit_duplicate_product_object",
                               message: "There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases.",
                               details: paymentMap)
        }
  }
  
  public func startProductRequestProductIdentifiers(_ productIdentifiers: [String]) async -> (SKProductsResponseMessage?, FlutterError?) {
    let request = getProductRequest(withIdentifiers: Set(productIdentifiers))
    let handler = handlerFactory!(request)
    requestHandlers.insert(handler)
    do {
      let response = try await handler.startProductRequest();

      if (response == nil) {
        
      }
    } catch {
      let platformError = FlutterError(code: "storekit_getproductrequest_platform_error", message: error.localizedDescription, details: error.localizedDescription);
      return (nil, platformError);
    }

//
//    handler.startProductRequest { 
//      response, startProductRequestError in
//      if let startProductRequestError = startProductRequestError {
//        let error = FlutterError(code: "storekit_getproductrequest_platform_error",
//                             message: startProductRequestError.localizedDescription,
//                             details: startProductRequestError.localizedDescription)
//        //          completion(.failure(error));
//        return(response, startProductRequestError)
//      }
//
//        guard let response = response else {
//            error = FlutterError(code: "storekit_platform_no_response",
//                                 message: "Failed to get SKProductResponse in startRequest call. Error occurred on iOS platform",
//                                 details: productIdentifiers)
////          completion(.failure(error));
//          return
//        }
//
//        response.products.forEach { product in
//            self.productsCache[product.productIdentifier] = product
//        }
//
//      if #available(iOS 12.2, *) {
//        if let responseMessage = FIAObjectTranslator.convertProductsResponse(toPigeon: response){
////          completion(.success(responseMessage ))
//        }
//      }
//        self.requestHandlers.remove(handler)
//    }
  }
  
  public func finishTransactionFinishMap(_ finishMap: [String : String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }
  
  public func restoreTransactionsApplicationUserName(_ applicationUserName: String?, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }
  
  public func presentCodeRedemptionSheetWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }
  
  public func retrieveReceiptDataWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String? {
    <#code#>
  }
  
  public func refreshReceiptReceiptProperties(_ receiptProperties: [String : Any]?) async -> FlutterError? {
    <#code#>
  }
  
  public func startObservingPaymentQueueWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }
  
  public func stopObservingPaymentQueueWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }
  
  public func registerPaymentQueueDelegateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }
  
  public func removePaymentQueueDelegateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }
  
  public func showPriceConsentIfNeededWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
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
  private var paymentQueueHandler: FIAPaymentQueueHandler?
  private var transactionObserverCallbackChannel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.flutter.io/in_app_purchase",
                                       binaryMessenger: registrar.messenger())
    let instance = InAppPurchasePlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
    SetUpInAppPurchaseAPI(registrar.messenger(), instance);
  }

  init(receiptManager: FIAPReceiptManager) {
    self.receiptManager = receiptManager
    self.requestHandlers = Set<FIAPRequestHandler>();
    self.productsCache = NSMutableDictionary()
    self.handlerFactory = { request in
        return FIAPRequestHandler(request: request)
    }
    super.init()
  }

  convenience init(receiptManager: FIAPReceiptManager, handlerFactory: @escaping (SKRequest) -> FIAPRequestHandler) {
    self.init(receiptManager: receiptManager)
    self.handlerFactory = handlerFactory;
  }

  convenience init(registrar: FlutterPluginRegistrar) {
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


  func handleTransactionsUpdated(_ transactions: [SKPaymentTransaction]) {
    var maps: [[AnyHashable: Any]] = []
    for transaction in transactions {
      let map = FIAObjectTranslator.getMapFrom(transaction);
      maps.append(map);
    }
    transactionObserverCallbackChannel!.invokeMethod("updatedTransactions", arguments: maps)
  }

  func handleTransactionsRemoved(_ transactions: [SKPaymentTransaction]) {
    var maps: [[AnyHashable: Any]] = []
    for transaction in transactions {
      let map = FIAObjectTranslator.getMapFrom(transaction);
      maps.append(map);
    }
    transactionObserverCallbackChannel!.invokeMethod("removedTransactions", arguments: maps)
  }

  func handleTransactionRestoreFailed(_ error: Error) {
    transactionObserverCallbackChannel!.invokeMethod("restoreCompletedTransactionsFailed", arguments: FIAObjectTranslator.getMapFrom(error));
  }

  func restoreCompletedTransactionsFinished() {
    transactionObserverCallbackChannel!.invokeMethod("paymentQueueRestoreCompletedTransactionsFinished", arguments:nil);
  }

  func shouldAddStorePayment(payment: SKPayment, product: SKProduct) -> Bool {
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

  func addPayment(paymentMap: [String: Any?]) throws {
      guard let productID = paymentMap["productIdentifier"] as? String else {
          throw FlutterError(code: "storekit_missing_product_identifier",
                             message: "The `productIdentifier` is missing from the payment map.",
                             details: paymentMap)
      }

      guard let product = self.getProduct(productID: productID) else {
          throw FlutterError(code: "storekit_invalid_payment_object",
                             message: "You have requested a payment for an invalid product. Either the `productIdentifier` is not valid or the product has not been fetched before adding the payment to the payment queue.",
                             details: paymentMap)
      }

      let payment = SKMutablePayment(product: product)
      payment.applicationUsername = paymentMap["applicationUsername"] as? String
      payment.quantity = paymentMap["quantity"] as? Int ?? 1
      payment.simulatesAskToBuyInSandbox = paymentMap["simulatesAskToBuyInSandbox"] as? Bool ?? false

      if #available(iOS 12.2, *) {
          if let paymentDiscountMap = paymentMap["paymentDiscount"] as? [String: Any], !paymentDiscountMap.isEmpty {
              var error: NSString?
            if let paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(fromMap: paymentDiscountMap, withError: &error) {
                  payment.paymentDiscount = paymentDiscount
              } else if let error = error {
                  throw FlutterError(code: "storekit_invalid_payment_discount_object",
                                     message: "You have requested a payment and specified a payment discount with invalid properties: \(error)",
                                     details: paymentMap)
              }
          }
      }

      guard self.paymentQueueHandler?.add(payment) == true else {
          throw FlutterError(code: "storekit_duplicate_product_object",
                             message: "There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases.",
                             details: paymentMap)
      }
  }

  func startProductRequest(productIdentifiers: [String], completion: @escaping (Result<SKProductsResponseMessage, Error>) -> Void) {
      let request = getProductRequest(withIdentifiers: Set(productIdentifiers))
      let handler = handlerFactory!(request)
      requestHandlers.insert(handler)

      handler.startProductRequest { response, startProductRequestError in
          var error: FlutterError;
          if let startProductRequestError = startProductRequestError {
              error = FlutterError(code: "storekit_getproductrequest_platform_error",
                                   message: startProductRequestError.localizedDescription,
                                   details: startProductRequestError.localizedDescription)
            completion(.failure(error));
            return
          }

          guard let response = response else {
              error = FlutterError(code: "storekit_platform_no_response",
                                   message: "Failed to get SKProductResponse in startRequest call. Error occurred on iOS platform",
                                   details: productIdentifiers)
            completion(.failure(error));
            return
          }

          response.products.forEach { product in
              self.productsCache[product.productIdentifier] = product
          }

        if #available(iOS 12.2, *) {
          if let responseMessage = MessageTranslator.convertProductsResponseToPigeon(productsResponse: response){
            completion(.success(responseMessage ))
          }
        }
          self.requestHandlers.remove(handler)
      }
  }

  func finishTransaction(finishMap: [String : String?]) throws {
    guard let transactionIdentifier = finishMap["transactionIdentifier"],
              let productIdentifier = finishMap["productIdentifier"] else {
            throw FlutterError(code: "missing_keys", message: "Transaction or product identifier is missing.", details: finishMap)
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

  func restoreTransactions(applicationUserName: String?) throws {
    paymentQueueHandler?.restoreTransactions(applicationUserName);
  }

  func presentCodeRedemptionSheet() throws {
    #if os(iOS)
        paymentQueueHandler!.presentCodeRedemptionSheet()
    #endif
  }

  func retrieveReceiptData() throws -> String? {
    var error : FlutterError? = nil;
    let receiptData : String? = receiptManager!.retrieveReceiptWithError(&error);
    if (receiptData == nil) {
      throw error!;
    }
    return receiptData;
  }

  func refreshReceipt(receiptProperties: [String : Any?]?, completion: @escaping (Result<Void, Error>) -> Void) {
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
                                              details: error.localizedDescription)
            completion(.failure(requestError));
              return
          }
        completion(.success(Void()));
        // that looks wrong ^
        self?.requestHandlers.remove(handler);
      }
  }

  func startObservingPaymentQueue() throws {
    paymentQueueHandler!.startObservingPaymentQueue();
  }

  func stopObservingPaymentQueue() throws {
    paymentQueueHandler!.stopObservingPaymentQueue();
  }

  func registerPaymentQueueDelegate() throws {
#if os(iOS)
    if #available(iOS 13.0, *) {
      paymentQueueDelegateCallbackChannel = FlutterMethodChannel(name: "plugins.flutter.io/in_app_purchase_payment_queue_delegate",
                                         binaryMessenger: registrar!.messenger())

      paymentQueueDelegate = FIAPPaymentQueueDelegate(methodChannel: paymentQueueDelegateCallbackChannel!)
      paymentQueueHandler!.delegate = (paymentQueueDelegate as! any SKPaymentQueueDelegate);
    }
#endif
  }

  func removePaymentQueueDelegate() throws {
#if os(iOS)
    if #available(iOS 13.0, *) {
      paymentQueueDelegateCallbackChannel = nil;
      paymentQueueHandler!.delegate = nil;
      paymentQueueDelegate = nil;
    }
#endif
  }

  func showPriceConsentIfNeeded() throws {
#if os(iOS)
    if #available(iOS 13.4, *) {
      paymentQueueHandler!.showPriceConsentIfNeeded();
    }
#endif
  }


  func getProduct(productID : String) -> SKProduct? {
    return self.productsCache[productID] as? SKProduct;
  }

  func getProductRequest(withIdentifiers productIdentifiers: Set<String>) -> SKProductsRequest {
    return SKProductsRequest(productIdentifiers: productIdentifiers);
  }

  func getNonNullValue(from dictionary: [String: Any], forKey key: String) -> Any? {
      let value = dictionary[key]
      return value is NSNull ? nil : value
  }

  func getRefreshReceiptRequest(properties: [String: Any]?) -> SKReceiptRefreshRequest {
    return SKReceiptRefreshRequest(receiptProperties: properties);
  }
}
