// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit
import StoreKitTest

@testable import in_app_purchase_storekit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

@available(iOS 11.2, macOS 10.13.2, *)
class SKProductSubscriptionPeriodStub: SKProductSubscriptionPeriod {
  init(map: [String: Any]) {
    super.init()
    setValue(map["numberOfUnits"] ?? 0, forKey: "numberOfUnits")
    setValue(map["unit"] ?? 0, forKey: "unit")
  }
}

@available(iOS 11.2, macOS 10.13.2, *)
class SKProductDiscountStub: SKProductDiscount {
  init(map: [String: Any]?) {
    super.init()
    setValue(
      (map?["price"] as? String).flatMap { NSDecimalNumber(string: $0) } as Any, forKey: "price")
    setValue(NSLocale.system, forKey: "priceLocale")
    setValue(map?["numberOfPeriods"] ?? 0, forKey: "numberOfPeriods")
    let subscriptionPeriodSub = SKProductSubscriptionPeriodStub(
      map: map?["subscriptionPeriod"] as? [String: Any] ?? [:])
    setValue(subscriptionPeriodSub, forKey: "subscriptionPeriod")
    setValue(map?["paymentMode"] ?? 0, forKey: "paymentMode")
    setValue(map?["identifier"] as? String, forKey: "identifier")
    setValue(map?["type"] ?? 0, forKey: "type")
  }
}

class SKProductStub: SKProduct {
  init(map: [String: Any]) {
    super.init()
    setValue(map["productIdentifier"] as? String, forKey: "productIdentifier")
    setValue(map["localizedDescription"] as? String, forKey: "localizedDescription")
    setValue(map["localizedTitle"] as? String, forKey: "localizedTitle")
    setValue(map["downloadable"] ?? false, forKey: "downloadable")
    setValue(
      (map["price"] as? String).flatMap { NSDecimalNumber(string: $0) } as Any, forKey: "price")
    setValue(NSLocale.system, forKey: "priceLocale")
    setValue(map["downloadContentLengths"] ?? 0, forKey: "downloadContentLengths")
    if #available(iOS 11.2, macOS 10.13.2, *) {
      let period = SKProductSubscriptionPeriodStub(
        map: map["subscriptionPeriod"] as? [String: Any] ?? [:])
      setValue(period, forKey: "subscriptionPeriod")
      let discount = SKProductDiscountStub(map: map["introductoryPrice"] as? [String: Any])
      setValue(discount, forKey: "introductoryPrice")
    }
    setValue(map["subscriptionGroupIdentifier"] as? String, forKey: "subscriptionGroupIdentifier")
    if #available(iOS 11.2, macOS 10.13.2, *) {
      let discounts = (map["discounts"] as? [[String: Any]] ?? []).map {
        SKProductDiscountStub(map: $0)
      }
      setValue(discounts, forKey: "discounts")
    }
  }

  init(productID: String) {
    super.init()
    setValue(productID, forKey: "productIdentifier")
  }
}

class SKProductRequestStub: SKProductsRequest {
  private var identifiers: Set<String> = []
  private var requestError: Error?
  var returnError = false

  required override init() {
    super.init()
  }

  override init(productIdentifiers: Set<String>) {
    super.init(productIdentifiers: productIdentifiers)
    identifiers = productIdentifiers
  }

  init(failureError error: Error) {
    super.init()
    requestError = error
  }

  override func start() {
    let productArray = identifiers.map { ["productIdentifier": $0] }
    var response: SKProductsResponseStub?
    if returnError {
      response = nil
    } else {
      response = SKProductsResponseStub(map: ["products": productArray])
    }

    if let requestError = requestError {
      delegate?.request?(self, didFailWithError: requestError)
    } else if let response = response {
      delegate?.productsRequest(self, didReceive: response)
    }
  }
}

class SKProductsResponseStub: SKProductsResponse {
  init(map: [String: Any]) {
    super.init()
    let products = (map["products"] as? [[String: Any]] ?? []).map { SKProductStub(map: $0) }
    setValue(products, forKey: "products")
  }
}

class SKPaymentQueueStub: SKPaymentQueue {
  var testState: SKPaymentTransactionState = .purchasing
  var observer: SKPaymentTransactionObserver?

  override func add(_ observer: SKPaymentTransactionObserver) {
    self.observer = observer
  }

  override func remove(_ observer: SKPaymentTransactionObserver) {
    self.observer = nil
  }

  override func add(_ payment: SKPayment) {
    let transaction = SKPaymentTransactionStub(state: testState, payment: payment)
    observer?.paymentQueue(self, updatedTransactions: [transaction])
  }

  override func restoreCompletedTransactions() {
    observer?.paymentQueueRestoreCompletedTransactionsFinished?(self)
  }

  override func finishTransaction(_ transaction: SKPaymentTransaction) {
    observer?.paymentQueue?(self, removedTransactions: [transaction])
  }
}

/// Finds the ivar backing `SKPaymentTransaction.payment`.
///
/// `payment` is not key-value-coding compliant for `setValue(_:forKey:)` (there is no
/// `setPayment:` and the underlying ivar isn't named `payment`/`_payment`), so a stub that
/// needs to provide a payment for a transaction it didn't get from the real payment queue has
/// to poke the ivar directly via the Objective-C runtime.
private let skPaymentTransactionPaymentIvar: Ivar? = {
  var count: UInt32 = 0
  guard let ivars = class_copyIvarList(SKPaymentTransaction.self, &count) else { return nil }
  defer { free(ivars) }
  for i in 0..<Int(count) {
    let ivar = ivars[i]
    guard let typeEncoding = ivar_getTypeEncoding(ivar) else { continue }
    if String(cString: typeEncoding).contains("SKPayment") {
      return ivar
    }
  }
  return nil
}()

class SKPaymentTransactionStub: SKPaymentTransaction {
  override init() {
    super.init()
  }

  init(id identifier: String) {
    super.init()
    setValue(identifier, forKey: "transactionIdentifier")
  }

  init(map: [String: Any]) {
    super.init()
    setValue(map["transactionIdentifier"] as? String, forKey: "transactionIdentifier")
    setValue(map["transactionState"] as Any, forKey: "transactionState")
    if let originalTransactionMap = map["originalTransaction"] as? [String: Any] {
      setValue(
        SKPaymentTransactionStub(map: originalTransactionMap), forKey: "originalTransaction")
    }
    if let errorMap = map["error"] as? [String: Any] {
      setValue(NSErrorStub(map: errorMap), forKey: "error")
    } else {
      setValue(nil, forKey: "error")
    }
    setValue(
      Date(timeIntervalSince1970: (map["transactionTimeStamp"] as? NSNumber)?.doubleValue ?? 0),
      forKey: "transactionDate")
  }

  init(state: SKPaymentTransactionState) {
    super.init()
    // Only purchased and restored transactions have transactionIdentifier:
    // https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc
    if state == .purchased || state == .restored {
      setValue("fakeID", forKey: "transactionIdentifier")
    }
    setValue(state.rawValue, forKey: "transactionState")
  }

  init(state: SKPaymentTransactionState, payment: SKPayment) {
    super.init()
    // Only purchased and restored transactions have transactionIdentifier:
    // https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc
    if state == .purchased || state == .restored {
      setValue("fakeID", forKey: "transactionIdentifier")
    }
    setValue(state.rawValue, forKey: "transactionState")
    if let ivar = skPaymentTransactionPaymentIvar {
      object_setIvar(self, ivar, payment)
    }
  }
}

class SKMutablePaymentStub: SKMutablePayment {
  init(map: [String: Any]) {
    super.init()
  }
}

class NSErrorStub: NSError {
  convenience init(map: [String: Any]) {
    self.init(
      domain: map["domain"] as? String ?? "",
      code: (map["code"] as? NSNumber)?.intValue ?? 0,
      userInfo: map["userInfo"] as? [String: Any])
  }
}

class FIAPReceiptManagerStub: FIAPReceiptManager {
  var returnError = false
  var returnNilURL = false

  override func getReceiptData(_ url: URL, error: NSErrorPointer) -> Data? {
    if returnError {
      error?.pointee = NSError(
        domain: "test", code: 1,
        userInfo: [
          "name": "test",
          "houseNr": 5,
          "error": NSError(domain: "internalTestDomain", code: 99, userInfo: nil),
        ])
      return nil
    }
    let originalString = "test"
    return Data(base64Encoded: originalString)
  }

  override var receiptURL: URL? {
    if returnNilURL {
      return nil
    } else {
      return Bundle.main.appStoreReceiptURL
    }
  }
}

class SKReceiptRefreshRequestStub: SKReceiptRefreshRequest {
  private var _error: Error?

  required override init() {
    super.init()
  }

  override init(receiptProperties properties: [String: Any]?) {
    super.init(receiptProperties: properties)
  }

  init(failureError error: Error) {
    super.init()
    _error = error
  }

  override func start() {
    if let error = _error {
      delegate?.request?(self, didFailWithError: error)
    } else {
      delegate?.requestDidFinish?(self)
    }
  }
}

@available(iOS 13.0, macOS 10.15, *)
class SKStorefrontStub: SKStorefront {
  init(map: [String: Any]) {
    super.init()
    setValue(map["countryCode"] as? String, forKey: "countryCode")
    setValue(map["identifier"] as? String, forKey: "identifier")
  }
}

// An interface representing a stubbed DefaultPaymentQueue
class PaymentQueueStub: NSObject, FLTPaymentQueueProtocol {
  // FLTPaymentQueueProtocol properties
  var paymentState: SKPaymentTransactionState = .purchasing
  var observer: SKPaymentTransactionObserver?
  var storefront: SKStorefront?
  var transactions: [SKPaymentTransaction] = []
  weak var delegate: SKPaymentQueueDelegate?

  // Test Properties
  var testState: SKPaymentTransactionState = .purchasing
  var realQueue: SKPaymentQueue = .default()

  // Stubs
  var showPriceConsentIfNeededStub: (() -> Void)?
  var restoreTransactionsStub: ((String?) -> Void)?
  var startObservingPaymentQueueStub: (() -> Void)?
  var stopObservingPaymentQueueStub: (() -> Void)?
  var presentCodeRedemptionSheetStub: (() -> Void)?
  var getUnfinishedTransactionsStub: (() -> [SKPaymentTransaction])?

  func finish(_ transaction: SKPaymentTransaction) {
    observer?.paymentQueue?(realQueue, removedTransactions: [transaction])
  }

  @objc(addPayment:)
  func add(_ payment: SKPayment) {
    let transaction = SKPaymentTransactionStub(state: testState, payment: payment)
    observer?.paymentQueue(realQueue, updatedTransactions: [transaction])
  }

  @objc(addTransactionObserver:)
  func add(_ observer: SKPaymentTransactionObserver) {
    self.observer = observer
  }

  func removeTransactionObserver(_ observer: SKPaymentTransactionObserver) {
    self.observer = nil
  }

  func restoreCompletedTransactions() {
    observer?.paymentQueueRestoreCompletedTransactionsFinished?(realQueue)
  }

  func restoreCompletedTransactions(withApplicationUsername username: String?) {
    observer?.paymentQueueRestoreCompletedTransactionsFinished?(realQueue)
  }

  func getUnfinishedTransactions() -> [SKPaymentTransaction] {
    return getUnfinishedTransactionsStub?() ?? []
  }

  #if os(iOS)
    func presentCodeRedemptionSheet() {
      presentCodeRedemptionSheetStub?()
    }

    func showPriceConsentIfNeeded() {
      showPriceConsentIfNeededStub?()
    }
  #endif

  func restoreTransactions(_ applicationName: String?) {
    restoreTransactionsStub?(applicationName)
  }

  func startObservingPaymentQueue() {
    startObservingPaymentQueueStub?()
  }

  func stopObservingPaymentQueue() {
    stopObservingPaymentQueueStub?()
  }
}

// An interface representing a stubbed DefaultTransactionCache
class TransactionCacheStub: NSObject, FLTTransactionCacheProtocol {
  var getObjectsForKeyStub: ((TransactionCacheKey) -> [Any])?
  var clearStub: (() -> Void)?
  var addObjectsStub: (([Any], TransactionCacheKey) -> Void)?

  func add(_ objects: [Any], for key: TransactionCacheKey) {
    addObjectsStub?(objects, key)
  }

  func clear() {
    clearStub?()
  }

  func getObjectsFor(_ key: TransactionCacheKey) -> [Any] {
    return getObjectsForKeyStub?(key) ?? []
  }
}

// An interface representing a stubbed DefaultMethodChannel
class MethodChannelStub: NSObject, FLTMethodChannelProtocol {
  var invokeMethodChannelStub: ((String, Any?) -> Void)?
  var invokeMethodChannelWithResultsStub: ((String, Any?, FlutterResult?) -> Void)?

  func invokeMethod(_ method: String, arguments: Any?) {
    invokeMethodChannelStub?(method, arguments)
  }

  func invokeMethod(_ method: String, arguments: Any?, result: FlutterResult?) {
    invokeMethodChannelWithResultsStub?(method, arguments, result)
  }
}

// An interface representing a stubbed DefaultPaymentQueueHandler
class PaymentQueueHandlerStub: NSObject, SKPaymentTransactionObserver,
  FLTPaymentQueueHandlerProtocol
{
  weak var delegate: SKPaymentQueueDelegate?
  var storefront: SKStorefront?

  var addPaymentStub: ((SKPayment) -> Bool)?
  var showPriceConsentIfNeededStub: (() -> Void)?
  var stopObservingPaymentQueueStub: (() -> Void)?
  var startObservingPaymentQueueStub: (() -> Void)?
  var presentCodeRedemptionSheetStub: (() -> Void)?
  var restoreTransactions: ((String?) -> Void)?
  var getUnfinishedTransactionsStub: (() -> [SKPaymentTransaction])?
  var finishTransactionStub: ((SKPaymentTransaction) -> Void)?
  var paymentQueueUpdatedTransactionsStub: ((SKPaymentQueue, [SKPaymentTransaction]) -> Void)?

  override init() {
    super.init()
  }

  required init(
    queue: FLTPaymentQueueProtocol,
    transactionsUpdated: TransactionsUpdated?,
    transactionRemoved: TransactionsRemoved?,
    restoreTransactionFailed: RestoreTransactionFailed?,
    restoreCompletedTransactionsFinished: RestoreCompletedTransactionsFinished?,
    shouldAddStorePayment: ShouldAddStorePayment?,
    updatedDownloads: UpdatedDownloads?,
    transactionCache: FLTTransactionCacheProtocol
  ) {
    super.init()
  }

  func paymentQueue(
    _ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]
  ) {
    paymentQueueUpdatedTransactionsStub?(queue, transactions)
  }

  #if os(iOS)
    func showPriceConsentIfNeeded() {
      showPriceConsentIfNeededStub?()
    }
  #endif

  func add(_ payment: SKPayment) -> Bool {
    return addPaymentStub?(payment) ?? false
  }

  func finish(_ transaction: SKPaymentTransaction) {
    finishTransactionStub?(transaction)
  }

  func getUnfinishedTransactions() -> [SKPaymentTransaction] {
    return getUnfinishedTransactionsStub?() ?? []
  }

  #if os(iOS)
    func presentCodeRedemptionSheet() {
      presentCodeRedemptionSheetStub?()
    }
  #endif

  func restoreTransactions(_ applicationName: String?) {
    restoreTransactions?(applicationName)
  }

  func startObservingPaymentQueue() {
    startObservingPaymentQueueStub?()
  }

  func stopObservingPaymentQueue() {
    stopObservingPaymentQueueStub?()
  }
}

// An interface representing a stubbed DefaultRequestHandler
class RequestHandlerStub: NSObject, FLTRequestHandlerProtocol {
  var startProductRequestWithCompletionHandlerStub:
    (((SKProductsResponse?, Error?) -> Void) -> Void)?

  func startProductRequest(completionHandler: @escaping (SKProductsResponse?, Error?) -> Void) {
    startProductRequestWithCompletionHandlerStub?(completionHandler)
  }
}

/// This mock is only used in iOS tests
#if os(iOS)

  // This FlutterPluginRegistrar is a protocol, so to make a stub it has to be implemented.
  class FlutterPluginRegistrarStub: NSObject, FlutterPluginRegistrar {
    weak var viewController: UIViewController?
    var addApplicationDelegateStub: ((FlutterPlugin) -> Void)?
    var addMethodCallDelegateStub: ((FlutterPlugin, FlutterMethodChannel) -> Void)?
    var lookupKeyForAssetStub: ((String) -> String)?
    var lookupKeyForAssetFromPackageStub: ((String, String) -> String)?
    var messengerStub: (() -> FlutterBinaryMessenger)?
    var publishStub: ((Any) -> Void)?
    var registerViewFactoryStub: ((FlutterPlatformViewFactory, String) -> Void)?
    var texturesStub: (() -> FlutterTextureRegistry)?
    var registerViewFactoryWithGestureRecognizersBlockingPolicyStub:
      (
        (FlutterPlatformViewFactory, String, FlutterPlatformViewGestureRecognizersBlockingPolicy) ->
          Void
      )?

    func addApplicationDelegate(_ delegate: FlutterPlugin) {
      addApplicationDelegateStub?(delegate)
    }

    func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {
      addMethodCallDelegateStub?(delegate, channel)
    }

    func lookupKey(forAsset asset: String) -> String {
      return lookupKeyForAssetStub?(asset) ?? ""
    }

    func lookupKey(forAsset asset: String, fromPackage package: String) -> String {
      return lookupKeyForAssetFromPackageStub?(asset, package) ?? ""
    }

    func messenger() -> FlutterBinaryMessenger {
      return messengerStub?() ?? FlutterBinaryMessengerStub()
    }

    func publish(_ value: Any) {
      publishStub?(value)
    }

    func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String) {
      registerViewFactoryStub?(factory, factoryId)
    }

    func textures() -> FlutterTextureRegistry {
      return texturesStub!()
    }

    func register(
      _ factory: FlutterPlatformViewFactory, withId factoryId: String,
      gestureRecognizersBlockingPolicy:
        FlutterPlatformViewGestureRecognizersBlockingPolicy
    ) {
      registerViewFactoryWithGestureRecognizersBlockingPolicyStub?(
        factory, factoryId, gestureRecognizersBlockingPolicy)
    }

    func addSceneDelegate(_ delegate: FlutterSceneLifeCycleDelegate) {}
  }

#endif

// This FlutterBinaryMessenger is a protocol, so to make a stub it has to be implemented.
class FlutterBinaryMessengerStub: NSObject, FlutterBinaryMessenger {
  var cleanUpConnectionStub: ((FlutterBinaryMessengerConnection) -> Void)?
  var sendOnChannelMessageStub: ((String, Data?) -> Void)?
  var sendOnChannelMessageBinaryReplyStub: ((String, Data?, FlutterBinaryReply?) -> Void)?
  var setMessageHandlerOnChannelBinaryMessageHandlerStub:
    ((String, FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection)?

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {
    cleanUpConnectionStub?(connection)
  }

  func send(onChannel channel: String, message: Data?) {
    sendOnChannelMessageStub?(channel, message)
  }

  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
    sendOnChannelMessageBinaryReplyStub?(channel, message, callback)
  }

  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?
  ) -> FlutterBinaryMessengerConnection {
    return setMessageHandlerOnChannelBinaryMessageHandlerStub?(channel, handler) ?? 0
  }
}

class InAppPurchasePluginStub: InAppPurchasePlugin {
  override func getProductRequest(withIdentifiers productIdentifiers: Set<String>)
    -> SKProductsRequest
  {
    return SKProductRequestStub(productIdentifiers: productIdentifiers)
  }

  override func getProduct(productID: String) -> SKProduct? {
    if productID == "" {
      return nil
    }
    return SKProductStub(productID: productID)
  }

  override func getRefreshReceiptRequest(properties: [String: Any]?) -> SKReceiptRefreshRequest {
    return SKReceiptRefreshRequest(receiptProperties: properties)
  }
}
