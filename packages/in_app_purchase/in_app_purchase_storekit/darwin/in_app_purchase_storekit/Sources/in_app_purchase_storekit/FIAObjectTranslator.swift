// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

#if canImport(in_app_purchase_storekit_objc)
  import in_app_purchase_storekit_objc
#endif

public class FIAObjectTranslator: NSObject {
  // MARK: - SKProduct Coders

  public static func getMapFrom(_ product: SKProduct) -> [String: Any] {
    return [
      "discounts": getMapArrayFrom(product.discounts),
      "introductoryPrice": product.introductoryPrice.map { getMapFrom($0) } as Any,
      "localizedDescription": product.localizedDescription,
      "localizedTitle": product.localizedTitle,
      "productIdentifier": product.productIdentifier,
      "price": product.price.description,
      "subscriptionGroupIdentifier": product.subscriptionGroupIdentifier as Any,
      "subscriptionPeriod": product.subscriptionPeriod.map { getMapFrom($0) } as Any,
      "priceLocale": getMapFrom(product.priceLocale),
    ]
  }

  public static func getMapFrom(_ period: SKProductSubscriptionPeriod) -> [String: Any] {
    return ["numberOfUnits": period.numberOfUnits, "unit": period.unit.rawValue]
  }

  static func getMapArrayFrom(_ productDiscounts: [SKProductDiscount]) -> [Any] {
    return productDiscounts.map { getMapFrom($0) }
  }

  public static func getMapFrom(_ discount: SKProductDiscount) -> [String: Any] {
    return [
      "identifier": discount.identifier as Any,
      "numberOfPeriods": discount.numberOfPeriods,
      "paymentMode": discount.paymentMode.rawValue,
      "price": discount.price.description,
      "subscriptionPeriod": getMapFrom(discount.subscriptionPeriod),
      "type": discount.type.rawValue,
      "priceLocale": getMapFrom(discount.priceLocale),
    ]
  }

  public static func getMapFrom(_ productResponse: SKProductsResponse) -> [String: Any] {
    let productsMapArray = productResponse.products.map { getMapFrom($0) }
    return [
      "products": productsMapArray,
      "invalidProductIdentifiers": productResponse.invalidProductIdentifiers,
    ]
  }

  public static func getMapFrom(_ payment: SKPayment) -> [String: Any] {
    return [
      "applicationUsername": payment.applicationUsername as Any,
      "productIdentifier": payment.productIdentifier as Any,
      "quantity": payment.quantity,
      "requestData": payment.requestData.flatMap { String(data: $0, encoding: .utf8) } as Any,
      "simulatesAskToBuyInSandbox": payment.simulatesAskToBuyInSandbox,
    ]
  }

  // This intentionally only exposes fields that there has been a demonstrated
  // need for; see discussion in https://github.com/flutter/plugins/pull/3897.
  public static func getMapFrom(_ locale: Locale) -> [String: Any] {
    let nsLocale = locale as NSLocale
    return [
      "currencySymbol": nsLocale.object(forKey: .currencySymbol) as Any,
      "currencyCode": nsLocale.object(forKey: .currencyCode) as Any,
      "countryCode": nsLocale.object(forKey: .countryCode) as Any,
    ]
  }

  public static func getSKMutablePayment(fromMap map: [String: Any]) -> SKMutablePayment {
    let payment = SKMutablePayment()
    payment.productIdentifier = map["productIdentifier"] as? String ?? ""
    if let utf8String = map["requestData"] as? String {
      payment.requestData = utf8String.data(using: .utf8)
    }
    payment.quantity = (map["quantity"] as? NSNumber)?.intValue ?? 0
    payment.applicationUsername = map["applicationUsername"] as? String
    payment.simulatesAskToBuyInSandbox =
      (map["simulatesAskToBuyInSandbox"] as? NSNumber)?.boolValue ?? false
    return payment
  }

  public static func getMapFrom(_ transaction: SKPaymentTransaction) -> [String: Any] {
    return [
      "error": transaction.error.map { getMapFrom($0 as NSError) } as Any,
      "payment": (transaction.value(forKey: "payment") as? SKPayment).map { getMapFrom($0) } as Any,
      "originalTransaction": transaction.original.map { getMapFrom($0) } as Any,
      "transactionTimeStamp": transaction.transactionDate?.timeIntervalSince1970 as Any,
      "transactionIdentifier": transaction.transactionIdentifier as Any,
      "transactionState": transaction.transactionState.rawValue,
    ]
  }

  public static func getMapFrom(_ error: NSError) -> [String: Any] {
    return [
      "code": error.code,
      "domain": error.domain,
      "userInfo": encodeNSErrorUserInfo(error.userInfo),
    ]
  }

  static func encodeNSErrorUserInfo(_ value: Any) -> Any {
    switch value {
    case let error as NSError:
      return getMapFrom(error)
    case let url as URL:
      return url.absoluteString
    case is NSNumber, is String:
      return value
    case let array as [Any]:
      return array.map { encodeNSErrorUserInfo($0) }
    case let dictionary as [AnyHashable: Any]:
      var errors: [AnyHashable: Any] = [:]
      for (key, dictValue) in dictionary {
        errors[key] = encodeNSErrorUserInfo(dictValue)
      }
      return errors
    default:
      return
        "Unable to encode native userInfo object of type \(type(of: value)) to map. Please submit an issue at "
        + "https://github.com/flutter/flutter/issues/new with the title "
        + "\"[in_app_purchase_storekit] "
        + "Unable to encode userInfo of type \(type(of: value))\" and add reproduction steps and the error "
        + "details in "
        + "the description field."
    }
  }

  public static func getMapFrom(_ storefront: SKStorefront) -> [String: Any] {
    return ["countryCode": storefront.countryCode, "identifier": storefront.identifier]
  }

  public static func getMapFrom(
    _ storefront: SKStorefront, andSKPaymentTransaction transaction: SKPaymentTransaction
  ) -> [String: Any] {
    return [
      "storefront": getMapFrom(storefront),
      "transaction": getMapFrom(transaction),
    ]
  }

  public static func getSKPaymentDiscount(
    fromMap map: [String: Any]?, withError error: inout NSString?
  )
    -> SKPaymentDiscount?
  {
    guard let map = map, !map.isEmpty else {
      return nil
    }

    let identifier = map["identifier"] as? String
    let keyIdentifier = map["keyIdentifier"] as? String
    let nonce = map["nonce"] as? String
    let signature = map["signature"] as? String
    let timestamp = map["timestamp"] as? NSNumber

    guard let identifier = identifier, !identifier.isEmpty else {
      error = "When specifying a payment discount the 'identifier' field is mandatory."
      return nil
    }

    guard let keyIdentifier = keyIdentifier, !keyIdentifier.isEmpty else {
      error = "When specifying a payment discount the 'keyIdentifier' field is mandatory."
      return nil
    }

    guard let nonce = nonce, !nonce.isEmpty else {
      error = "When specifying a payment discount the 'nonce' field is mandatory."
      return nil
    }

    guard let signature = signature, !signature.isEmpty else {
      error = "When specifying a payment discount the 'signature' field is mandatory."
      return nil
    }

    guard let timestamp = timestamp, timestamp.int64Value > 0 else {
      error = "When specifying a payment discount the 'timestamp' field is mandatory."
      return nil
    }

    guard let nonceUUID = UUID(uuidString: nonce) else {
      error = "When specifying a payment discount the 'nonce' field is mandatory."
      return nil
    }

    return SKPaymentDiscount(
      identifier: identifier, keyIdentifier: keyIdentifier, nonce: nonceUUID, signature: signature,
      timestamp: timestamp)
  }

  // MARK: - Pigeon message translators

  public static func convertTransaction(toPigeon transaction: SKPaymentTransaction?)
    -> FIASKPaymentTransactionMessage?
  {
    guard let transaction = transaction else {
      return nil
    }
    let paymentMessage =
      convertPayment(toPigeon: transaction.value(forKey: "payment") as? SKPayment)
      ?? FIASKPaymentMessage.make(
        withProductIdentifier: "", applicationUsername: nil, requestData: nil, quantity: 0,
        simulatesAskToBuyInSandbox: false, paymentDiscount: nil)
    return FIASKPaymentTransactionMessage.make(
      withPayment: paymentMessage,
      transactionState: convertTransactionStateToPigeon(transaction.transactionState),
      originalTransaction: transaction.original.flatMap {
        convertTransaction(toPigeon: $0)
      },
      transactionTimeStamp: NSNumber(
        value: transaction.transactionDate?.timeIntervalSince1970 ?? 0),
      transactionIdentifier: transaction.transactionIdentifier,
      error: convertSKError(toPigeon: transaction.error as NSError?))
  }

  public static func convertSKError(toPigeon error: NSError?) -> FIASKErrorMessage? {
    guard let error = error else {
      return nil
    }

    var userInfo: [String: Any] = [:]
    for (key, value) in error.userInfo {
      userInfo[key as? String ?? "\(key)"] = encodeNSErrorUserInfo(value)
    }

    return FIASKErrorMessage.make(withCode: error.code, domain: error.domain, userInfo: userInfo)
  }

  static func convertTransactionStateToPigeon(_ state: SKPaymentTransactionState)
    -> FIASKPaymentTransactionStateMessage
  {
    switch state {
    case .purchasing:
      return .purchasing
    case .purchased:
      return .purchased
    case .failed:
      return .failed
    case .restored:
      return .restored
    case .deferred:
      return .deferred
    @unknown default:
      return .purchasing
    }
  }

  public static func convertPayment(toPigeon payment: SKPayment?) -> FIASKPaymentMessage? {
    guard let payment = payment else {
      return nil
    }
    return FIASKPaymentMessage.make(
      withProductIdentifier: payment.productIdentifier,
      applicationUsername: payment.applicationUsername,
      requestData: payment.requestData.flatMap { String(data: $0, encoding: .utf8) },
      quantity: payment.quantity,
      simulatesAskToBuyInSandbox: payment.simulatesAskToBuyInSandbox,
      paymentDiscount: convertPaymentDiscount(toPigeon: payment.paymentDiscount))
  }

  public static func convertPaymentDiscount(toPigeon discount: SKPaymentDiscount?)
    -> FIASKPaymentDiscountMessage?
  {
    guard let discount = discount else {
      return nil
    }
    return FIASKPaymentDiscountMessage.make(
      withIdentifier: discount.identifier, keyIdentifier: discount.keyIdentifier,
      nonce: discount.nonce.uuidString, signature: discount.signature,
      timestamp: discount.timestamp.intValue)
  }

  public static func convertStorefront(toPigeon storefront: SKStorefront?)
    -> FIASKStorefrontMessage?
  {
    guard let storefront = storefront else {
      return nil
    }
    return FIASKStorefrontMessage.make(
      withCountryCode: storefront.countryCode, identifier: storefront.identifier)
  }

  public static func convertSKProductSubscriptionPeriod(
    toPigeon period: SKProductSubscriptionPeriod?
  ) -> FIASKProductSubscriptionPeriodMessage? {
    guard let period = period else {
      return nil
    }

    let unit: FIASKSubscriptionPeriodUnitMessage
    switch period.unit {
    case .day:
      unit = .day
    case .week:
      unit = .week
    case .month:
      unit = .month
    case .year:
      unit = .year
    @unknown default:
      unit = .day
    }

    return FIASKProductSubscriptionPeriodMessage.make(
      withNumberOfUnits: period.numberOfUnits, unit: unit)
  }

  public static func convertProductDiscount(toPigeon productDiscount: SKProductDiscount?)
    -> FIASKProductDiscountMessage?
  {
    guard let productDiscount = productDiscount else {
      return nil
    }

    let paymentMode: FIASKProductDiscountPaymentModeMessage
    switch productDiscount.paymentMode {
    case .freeTrial:
      paymentMode = .freeTrial
    case .payAsYouGo:
      paymentMode = .payAsYouGo
    case .payUpFront:
      paymentMode = .payUpFront
    @unknown default:
      paymentMode = .payAsYouGo
    }

    let type: FIASKProductDiscountTypeMessage
    switch productDiscount.type {
    case .introductory:
      type = .introductory
    case .subscription:
      type = .subscription
    @unknown default:
      type = .introductory
    }

    return FIASKProductDiscountMessage.make(
      withPrice: productDiscount.price.description,
      priceLocale: convertNSLocale(toPigeon: productDiscount.priceLocale)!,
      numberOfPeriods: productDiscount.numberOfPeriods,
      paymentMode: paymentMode,
      subscriptionPeriod: convertSKProductSubscriptionPeriod(
        toPigeon: productDiscount.subscriptionPeriod)!,
      identifier: productDiscount.identifier,
      type: type)
  }

  public static func convertNSLocale(toPigeon locale: Locale?) -> FIASKPriceLocaleMessage? {
    guard let locale = locale else {
      return nil
    }
    let nsLocale = locale as NSLocale
    return FIASKPriceLocaleMessage.make(
      withCurrencySymbol: nsLocale.object(forKey: .currencySymbol) as? String ?? "",
      currencyCode: nsLocale.object(forKey: .currencyCode) as? String ?? "",
      countryCode: nsLocale.object(forKey: .countryCode) as? String ?? "")
  }

  public static func convertProduct(toPigeon product: SKProduct?) -> FIASKProductMessage? {
    guard let product = product else {
      return nil
    }

    let pigeonProductDiscounts = product.discounts.map { convertProductDiscount(toPigeon: $0)! }

    return FIASKProductMessage.make(
      withProductIdentifier: product.productIdentifier,
      localizedTitle: product.localizedTitle,
      localizedDescription: product.localizedDescription,
      priceLocale: convertNSLocale(toPigeon: product.priceLocale)!,
      subscriptionGroupIdentifier: product.subscriptionGroupIdentifier,
      price: product.price.description,
      subscriptionPeriod: convertSKProductSubscriptionPeriod(toPigeon: product.subscriptionPeriod),
      introductoryPrice: convertProductDiscount(toPigeon: product.introductoryPrice),
      discounts: pigeonProductDiscounts)
  }

  public static func convertProductsResponse(toPigeon productsResponse: SKProductsResponse?)
    -> FIASKProductsResponseMessage?
  {
    guard let productsResponse = productsResponse else {
      return nil
    }

    let pigeonProducts = productsResponse.products.map { convertProduct(toPigeon: $0)! }

    return FIASKProductsResponseMessage.make(
      withProducts: pigeonProducts,
      invalidProductIdentifiers: productsResponse.invalidProductIdentifiers)
  }
}
