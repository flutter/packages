//
//  MessageTranslator.swift
//  in_app_purchase_storekit
//
//  Created by Louise Hsu on 3/19/24.
//

import Foundation

public class MessageTranslator : NSObject {
  @available(iOS 12.2, *)
  static func convertTransactionToPigeon(transaction: SKPaymentTransaction?) -> SKPaymentTransactionMessage? {
    guard let transaction = transaction else { return nil }

    let msg = SKPaymentTransactionMessage(payment: convertPaymentToPigeon(payment: transaction.payment)!,
                                          transactionState: convertTransactionStateToPigeon(state: transaction.transactionState),
                                          originalTransaction: convertTransactionToPigeon(transaction: transaction.original),
                                          transactionTimeStamp: NSNumber(value: transaction.transactionDate?.timeIntervalSince1970 ?? 0) as? Double,
                                          transactionIdentifier: transaction.transactionIdentifier,
                                          error: convertSKErrorToPigeon(error: transaction.error as NSError?))
    return msg
  }

  static func convertSKErrorToPigeon(error: NSError?) -> SKErrorMessage? {
    guard let error = error else { return nil }

    var userInfo: [String: Any] = [:]
    for (key, value) in error.userInfo {
      userInfo[key as String] = FIAObjectTranslator.encodeNSErrorUserInfo(value);
    }

    let msg = SKErrorMessage(code: Int64(error.code),
                             domain: error.domain,
                             userInfo: userInfo)
    return msg
  }

  static func convertTransactionStateToPigeon(state: SKPaymentTransactionState) -> SKPaymentTransactionStateMessage {
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
      fatalError("Unknown SKPaymentTransactionState: \(state)")
    }
  }

  @available(iOS 12.2, *)
  static func convertPaymentToPigeon(payment: SKPayment?) -> SKPaymentMessage? {
    guard let payment = payment else {
      return nil
    }
    let msg = SKPaymentMessage(productIdentifier: payment.productIdentifier,
                               applicationUsername: payment.applicationUsername,
                               requestData: String(data: payment.requestData ?? Data(), encoding: .utf8),
                               quantity: Int64(payment.quantity),
                               simulatesAskToBuyInSandbox: payment.simulatesAskToBuyInSandbox,
                               paymentDiscount: convertPaymentDiscountToPigeon(discount: payment.paymentDiscount))
    return msg
  }

  @available(iOS 12.2, *)
  static func convertPaymentDiscountToPigeon(discount: SKPaymentDiscount?) -> SKPaymentDiscountMessage? {
    guard let discount = discount else {
      return nil
    }
    let msg = SKPaymentDiscountMessage(identifier: discount.identifier,
                                       keyIdentifier: discount.keyIdentifier,
                                       nonce: discount.nonce.uuidString,
                                       signature: discount.signature,
                                       timestamp: Int64(truncating: discount.timestamp))
    return msg
  }

  @available(iOS 13.0, *)
  static func convertStorefrontToPigeon(storefront: SKStorefront?) -> SKStorefrontMessage? {
    guard let storefront = storefront else {
      return nil
    }
    let msg = SKStorefrontMessage(countryCode: storefront.countryCode,
                                  identifier: storefront.identifier)
    return msg
  }

  @available(iOS 12.2, *)
  static func convertSKProductSubscriptionPeriodToPigeon(period: SKProductSubscriptionPeriod?) -> SKProductSubscriptionPeriodMessage? {
    guard let period = period else {
      return nil
    }

    let unit: SKSubscriptionPeriodUnitMessage
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
      fatalError("Unknown SKProductPeriodUnit: \(period.unit)")
    }

    let msg = SKProductSubscriptionPeriodMessage(numberOfUnits: Int64(period.numberOfUnits), unit: unit)
    return msg
  }

  @available(iOS 12.2, *)
  static func convertProductDiscountToPigeon(productDiscount: SKProductDiscount?) -> SKProductDiscountMessage? {
      guard let productDiscount = productDiscount else { return nil }

      let paymentMode: SKProductDiscountPaymentModeMessage
      switch productDiscount.paymentMode {
      case .freeTrial:
        paymentMode = .freeTrial
      case .payAsYouGo:
        paymentMode = .payAsYouGo
      case .payUpFront:
        paymentMode = .payUpFront
      @unknown default:
        fatalError("Unknown SKProductDiscountPaymentMode: \(productDiscount.paymentMode)")
      }

      let type: SKProductDiscountTypeMessage
      switch productDiscount.type {
      case .introductory:
        type = .introductory
      case .subscription:
        type = .subscription
      @unknown default:
        fatalError("Unknown SKProductDiscountType: \(productDiscount.type)")
      }

      let msg = SKProductDiscountMessage(price: productDiscount.price.stringValue,
                                         priceLocale: convertNSLocaleToPigeon(locale: productDiscount.priceLocale)!,
                                         numberOfPeriods: Int64(productDiscount.numberOfPeriods),
                                         paymentMode: paymentMode,
                                         subscriptionPeriod: convertSKProductSubscriptionPeriodToPigeon(period: productDiscount.subscriptionPeriod)!,
                                         identifier: productDiscount.identifier,
                                         type: type)
      return msg
    }

    static func convertNSLocaleToPigeon(locale: Locale?) -> SKPriceLocaleMessage? {
      guard let locale = locale else { return nil }
      let msg = SKPriceLocaleMessage(currencySymbol: locale.currencySymbol!,
                                     currencyCode: locale.currencyCode!,
                                     countryCode: locale.regionCode!)
      return msg
    }

  @available(iOS 12.2, *)
  static func convertProductToPigeon(product: SKProduct?) -> SKProductMessage? {
      guard let product = product else { return nil }

      let pigeonProductDiscounts = product.discounts.compactMap { convertProductDiscountToPigeon(productDiscount: $0) }

      let msg = SKProductMessage(productIdentifier: product.productIdentifier,
                                 localizedTitle: product.localizedTitle,
                                 localizedDescription: product.localizedDescription,
                                 priceLocale: convertNSLocaleToPigeon(locale: product.priceLocale as Locale?)!,
                                 subscriptionGroupIdentifier: product.subscriptionGroupIdentifier,
                                 price: product.price.stringValue,
                                 subscriptionPeriod: convertSKProductSubscriptionPeriodToPigeon(period: product.subscriptionPeriod),
                                 introductoryPrice: convertProductDiscountToPigeon(productDiscount: product.introductoryPrice),
                                 discounts: pigeonProductDiscounts)
      return msg
    }

  @available(iOS 12.2, *)
  static func convertProductsResponseToPigeon(productsResponse: SKProductsResponse?) -> SKProductsResponseMessage? {
      guard let productsResponse = productsResponse else { return nil }

      let pigeonProducts = productsResponse.products.compactMap { convertProductToPigeon(product: $0) }
      let msg = SKProductsResponseMessage(products: pigeonProducts,
                                          invalidProductIdentifiers: productsResponse.invalidProductIdentifiers)
      return msg
    }



}
