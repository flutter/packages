//
//  InAppPurchasePlugin.swift
//  in_app_purchase_storekit
//
//  Created by Louise Hsu on 3/12/24.
//

import Foundation
import Flutter
import StoreKit

extension FlutterError: Error {}


class InAppPurchasePlugin: NSObject, FlutterPlugin, InAppPurchaseAPI {

  // Properties
  private(set) var productsCache: NSMutableDictionary = [:]
  private(set) var paymentQueueDelegateCallbackChannel: FlutterMethodChannel?
  private(set) var registrar: FlutterPluginRegistrar?
  private(set) var receiptManager: FIAPReceiptManager?
  private var requestHandlers = Set<FIAPRequestHandler>()
  private var handlerFactory: ((SKRequest) -> FIAPRequestHandler)?
  private var paymentQueueHandler: FIAPaymentQueueHandler?
  private var transactionObserverCallbackChannel: FlutterMethodChannel?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.flutter.io/in_app_purchase",
                                       binaryMessenger: registrar.messenger())
    let instance = InAppPurchasePlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
    InAppPurchaseAPISetup.setUp(binaryMessenger: registrar.messenger(), api: instance);
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
  }

  func handleTransactionsRemoved(_ transactions: [SKPaymentTransaction]) {
  }

  func handleTransactionRestoreFailed(_ error: Error) {

  }

  func restoreCompletedTransactionsFinished() {

  }

  func shouldAddStorePayment(payment: SKPayment, product: SKProduct) -> Bool {

  }

  func updatedDownloads() {

  }

  func canMakePayments() throws -> Bool {
    return SKPaymentQueue.canMakePayments() as Bool;
  }

  func transactions() throws -> [SKPaymentTransactionMessage] {
    let transactions = self.paymentQueueHandler?.getUnfinishedTransactions() ?? [];
    var transactionMaps: [SKPaymentTransactionMessage] = []
    for transaction in transactions {
      if let map = FIAObjectTranslator.convertTransaction(toPigeon: transaction) {
        transactionMaps.append(map as! SKPaymentTransactionMessage)
        }
    }
    return transactionMaps
  }

  func storefront() throws -> SKStorefrontMessage? {
    if #available(iOS 13.0, *) {
      let storefront = self.paymentQueueHandler?.storefront
      if (storefront == nil) {
        return nil;
      }
      return FIAObjectTranslator.convertStorefront(toPigeon: storefront) as? SKStorefrontMessage;
    }
  }

  func addPayment(paymentMap: [String : Any?]) throws {
    let productID = paymentMap["productIdentifier"] as? NSString;
    let product = self.getProduct(productID: productID!);
    if (product == nil) {
      throw FlutterError(code: "storekit_invalid_payment_object", message: "You have requested a payment for an invalid product. Either the `productIdentifier` of the payment is not valid or the product has not been fetched before adding the payment to the payment queue.", details: paymentMap)
      return;
    }
    let payment = SKMutablePayment(product: product!);
    payment.applicationUsername = paymentMap["applicationUsername"] as? String;
    let quantity = paymentMap["quantity"] as? Int ?? 1;
    payment.quantity = quantity;

    if let simulatesAskToBuyInSandbox = paymentMap["simulatesAskToBuyInSandbox"] as? Bool {
        payment.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox
    } else {
        payment.simulatesAskToBuyInSandbox = false
    }

    if #available(iOS 12.2, *) {
      var paymentDiscountMap = self.getNonNullValue(from: paymentMap as [String : Any], forKey: "paymentDiscount");
      var errorMsg : AutoreleasingUnsafeMutablePointer<NSString?>? = nil;
      var paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(fromMap: paymentDiscountMap as! [AnyHashable : Any], withError: errorMsg);
      if (errorMsg != nil) {
        throw FlutterError(code: "storekit_invalid_payment_discount_object", message: "You have requested a payment and specified a payment discount with invalid properties.", details: paymentMap
        )
        return;
      }
      payment.paymentDiscount = paymentDiscount;

      if (!(self.paymentQueueHandler?.add(payment))!) {
           throw FlutterError(code: "storekit_duplicate_product_object",
                                message: "There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases.",
                                details: paymentMap)
       }
    }
  }

//    if (@available(iOS 12.2, *)) {
//      NSDictionary *paymentDiscountMap = [self getNonNullValueFromDictionary:paymentMap
//                                                                      forKey:@"paymentDiscount"];
//      NSString *errorMsg = nil;
//      SKPaymentDiscount *paymentDiscount =
//          [FIAObjectTranslator getSKPaymentDiscountFromMap:paymentDiscountMap withError:&errorMsg];
//
//      if (errorMsg) {
//        *error = [FlutterError
//            errorWithCode:@"storekit_invalid_payment_discount_object"
//                  message:[NSString stringWithFormat:@"You have requested a payment and specified a "
//                                                     @"payment discount with invalid properties. %@",
//                                                     errorMsg]
//                  details:paymentMap];
//        return;
//      }
//
//      payment.paymentDiscount = paymentDiscount;
//    }
//    if (![self.paymentQueueHandler addPayment:payment]) {
//      *error = [FlutterError
//          errorWithCode:@"storekit_duplicate_product_object"
//                message:@"There is a pending transaction for the same product identifier. Please "
//                        @"either wait for it to be finished or finish it manually using "
//                        @"`completePurchase` to avoid edge cases."
//
//                details:paymentMap];
//      return;
//    }
//  }

  func startProductRequest(productIdentifiers: [String], completion: @escaping (Result<SKProductsResponseMessage, Error>) -> Void) {
    <#code#>
  }

  func finishTransaction(finishMap: [String : String?]) throws {
    <#code#>
  }

  func restoreTransactions(applicationUserName: String?) throws {
    <#code#>
  }

  func presentCodeRedemptionSheet() throws {
    <#code#>
  }

  func retrieveReceiptData() throws -> String? {
    <#code#>
  }

  func refreshReceipt(receiptProperties: [String : Any?]?, completion: @escaping (Result<Void, Error>) -> Void) {
    <#code#>
  }

  func startObservingPaymentQueue() throws {
    <#code#>
  }

  func stopObservingPaymentQueue() throws {
    <#code#>
  }

  func registerPaymentQueueDelegate() throws {
    <#code#>
  }

  func removePaymentQueueDelegate() throws {
    <#code#>
  }

  func showPriceConsentIfNeeded() throws {
    <#code#>
  }


  func getProduct (productID : NSString) -> SKProduct? {
    return self.productsCache[productID] as? SKProduct;
  }

  func getNonNullValue(from dictionary: [String: Any], forKey key: String) -> Any? {
      let value = dictionary[key]
      return value is NSNull ? nil : value
  }

}

