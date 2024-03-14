//
//  InAppPurchasePlugin.swift
//  in_app_purchase_storekit
//
//  Created by Louise Hsu on 3/12/24.
//

import Foundation
import Flutter
import StoreKit

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
    SetUpInAppPurchaseAPI(registrar.messenger(), instance)
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

  func canMakePaymentsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
    return SKPaymentQueue.canMakePayments() as NSNumber;
  }

  func transactionsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> [SKPaymentTransactionMessage]? {
    let transactions = self.paymentQueueHandler?.getUnfinishedTransactions() ?? [];
    var transactionMaps: [SKPaymentTransactionMessage] = []
    for transaction in transactions {
      if let map = FIAObjectTranslator.convertTransaction(toPigeon: transaction) {
            transactionMaps.append(map)
        }
    }
    return transactionMaps
  }

  func storefrontWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SKStorefrontMessage? {
    if #available(iOS 13.0, *) {
      let storefront = self.paymentQueueHandler?.storefront
      if ((storefront == nil)) {
        return nil;
      }
      return FIAObjectTranslator.convertStorefront(toPigeon: storefront);
    }
  }

  func addPaymentPaymentMap(_ paymentMap: [String : Any], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    let productID = paymentMap["productIdentifier"];
    let product = self.getProduct(productID: <#T##NSString#>)
    if (product == nil) {
//      error = FlutterError(code: "storekit_invalid_payment_object", message: <#T##String?#>, details: <#T##Any?#>)
    }
  }
//
//  - (void)addPaymentPaymentMap:(nonnull NSDictionary *)paymentMap
//                         error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
//    NSString *productID = [paymentMap objectForKey:@"productIdentifier"];
//    // When a product is already fetched, we create a payment object with
//    // the product to process the payment.
//    SKProduct *product = [self getProduct:productID];
//    if (!product) {
//      *error = [FlutterError
//          errorWithCode:@"storekit_invalid_payment_object"
//                message:
//                    @"You have requested a payment for an invalid product. Either the "
//                    @"`productIdentifier` of the payment is not valid or the product has not been "
//                    @"fetched before adding the payment to the payment queue."
//                details:paymentMap];
//      return;
//    }
//
//    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
//    payment.applicationUsername = [paymentMap objectForKey:@"applicationUsername"];
//    NSNumber *quantity = [paymentMap objectForKey:@"quantity"];
//    payment.quantity = (quantity != nil) ? quantity.integerValue : 1;
//    NSNumber *simulatesAskToBuyInSandbox = [paymentMap objectForKey:@"simulatesAskToBuyInSandbox"];
//    payment.simulatesAskToBuyInSandbox = (id)simulatesAskToBuyInSandbox == (id)[NSNull null]
//                                             ? NO
//                                             : [simulatesAskToBuyInSandbox boolValue];
//
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

  func startProductRequestProductIdentifiers(_ productIdentifiers: [String]) async -> (SKProductsResponseMessage?, FlutterError?) {
    <#code#>
  }

  func finishTransactionFinishMap(_ finishMap: [String : String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func restoreTransactionsApplicationUserName(_ applicationUserName: String?, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func presentCodeRedemptionSheetWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func retrieveReceiptDataWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String? {
    <#code#>
  }

  func refreshReceiptReceiptProperties(_ receiptProperties: [String : Any]?, completion: @escaping (FlutterError?) -> Void) {
    <#code#>
  }

  func startObservingPaymentQueueWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func stopObservingPaymentQueueWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func registerPaymentQueueDelegateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func removePaymentQueueDelegateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func showPriceConsentIfNeededWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    <#code#>
  }

  func getProduct (productID : NSString) -> SKProduct? {
    return self.productsCache[productID] as? SKProduct;
  }

}

