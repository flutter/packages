// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

@available(iOS 15.0, macOS 12.0, *)
extension Product {
  var convertToPigeon: SK2ProductMessage {

    return SK2ProductMessage(
      id: id,
      displayName: displayName,
      description: description,
      price: NSDecimalNumber(decimal: price).doubleValue,
      displayPrice: displayPrice,
      type: type.convertToPigeon,
      subscription: subscription?.convertToPigeon,
      priceLocale: priceFormatStyle.locale.convertToPigeon
    )
  }
}

extension SK2ProductMessage: Equatable {
  static func == (lhs: SK2ProductMessage, rhs: SK2ProductMessage) -> Bool {
    return lhs.id == rhs.id && lhs.displayName == rhs.displayName
      && lhs.description == rhs.description && lhs.price == rhs.price
      && lhs.displayPrice == rhs.displayPrice && lhs.type == rhs.type
      && lhs.subscription == rhs.subscription && lhs.priceLocale == rhs.priceLocale
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.ProductType {
  var convertToPigeon: SK2ProductTypeMessage {
    switch self {
    case Product.ProductType.autoRenewable:
      return SK2ProductTypeMessage.autoRenewable
    case Product.ProductType.consumable:
      return SK2ProductTypeMessage.consumable
    case Product.ProductType.nonConsumable:
      return SK2ProductTypeMessage.nonConsumable
    case Product.ProductType.nonRenewable:
      return SK2ProductTypeMessage.nonRenewable
    default:
      fatalError("An unknown ProductType was passed in")
    }
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionInfo {
  var convertToPigeon: SK2SubscriptionInfoMessage {
    return SK2SubscriptionInfoMessage(
      promotionalOffers: promotionalOffers.map({ $0.convertToPigeon }),
      subscriptionGroupID: subscriptionGroupID,
      subscriptionPeriod: subscriptionPeriod.convertToPigeon)
  }
}

extension SK2SubscriptionInfoMessage: Equatable {
  static func == (lhs: SK2SubscriptionInfoMessage, rhs: SK2SubscriptionInfoMessage) -> Bool {
    return lhs.promotionalOffers == rhs.promotionalOffers
      && lhs.subscriptionGroupID == rhs.subscriptionGroupID
      && lhs.subscriptionPeriod == rhs.subscriptionPeriod
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionOffer {
  var convertToPigeon: SK2SubscriptionOfferMessage {
    return SK2SubscriptionOfferMessage(
      /// ID is always `nil` for introductory offers and never `nil` for other offer types.
      id: id,
      price: NSDecimalNumber(decimal: price).doubleValue,
      type: type.convertToPigeon,
      period: period.convertToPigeon,
      periodCount: Int64(periodCount),
      paymentMode: paymentMode.convertToPigeon
    )
  }
}

extension SK2SubscriptionOfferMessage: Equatable {
  static func == (lhs: SK2SubscriptionOfferMessage, rhs: SK2SubscriptionOfferMessage) -> Bool {
    return lhs.id == rhs.id && lhs.price == rhs.price && lhs.type == rhs.type
      && lhs.period == rhs.period && lhs.periodCount == rhs.periodCount
      && lhs.paymentMode == rhs.paymentMode
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionOffer.OfferType {
  var convertToPigeon: SK2SubscriptionOfferTypeMessage {
    switch self {
    case .introductory:
      return SK2SubscriptionOfferTypeMessage.introductory
    case .promotional:
      return SK2SubscriptionOfferTypeMessage.promotional
    default:
      fatalError("An unknown OfferType was passed in")
    }
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionPeriod {
  var convertToPigeon: SK2SubscriptionPeriodMessage {
    return SK2SubscriptionPeriodMessage(
      value: Int64(value),
      unit: unit.convertToPigeon)
  }
}

extension SK2SubscriptionPeriodMessage: Equatable {
  static func == (lhs: SK2SubscriptionPeriodMessage, rhs: SK2SubscriptionPeriodMessage) -> Bool {
    return lhs.value == rhs.value && lhs.unit == rhs.unit
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionPeriod.Unit {
  var convertToPigeon: SK2SubscriptionPeriodUnitMessage {
    switch self {
    case .day:
      return SK2SubscriptionPeriodUnitMessage.day
    case .week:
      return SK2SubscriptionPeriodUnitMessage.week
    case .month:
      return SK2SubscriptionPeriodUnitMessage.month
    case .year:
      return SK2SubscriptionPeriodUnitMessage.year
    @unknown default:
      fatalError("unknown SubscriptionPeriodUnit encountered")
    }
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionOffer.PaymentMode {
  var convertToPigeon: SK2SubscriptionOfferPaymentModeMessage {
    switch self {
    case .freeTrial:
      return SK2SubscriptionOfferPaymentModeMessage.freeTrial
    case .payUpFront:
      return SK2SubscriptionOfferPaymentModeMessage.payUpFront
    case .payAsYouGo:
      return SK2SubscriptionOfferPaymentModeMessage.payAsYouGo
    default:
      fatalError("Encountered an unknown PaymentMode")
    }
  }
}

extension Locale {
  var convertToPigeon: SK2PriceLocaleMessage {
    return SK2PriceLocaleMessage(
      currencyCode: currencyCode ?? "",
      currencySymbol: currencySymbol ?? ""
    )
  }
}

extension SK2PriceLocaleMessage: Equatable {
  static func == (lhs: SK2PriceLocaleMessage, rhs: SK2PriceLocaleMessage) -> Bool {
    return lhs.currencyCode == rhs.currencyCode && lhs.currencySymbol == rhs.currencySymbol
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.PurchaseResult {
  func convertToPigeon() -> SK2ProductPurchaseResultMessage {
    switch self {
    case .success(_):
      return SK2ProductPurchaseResultMessage.success
    case .userCancelled:
      return SK2ProductPurchaseResultMessage.userCancelled
    case .pending:
      return SK2ProductPurchaseResultMessage.pending
    @unknown default:
      fatalError()
    }
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Transaction {
  func convertToPigeon(receipt: String?) -> SK2TransactionMessage {

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    return SK2TransactionMessage(
      id: Int64(id),
      originalId: Int64(originalID),
      productId: productID,
      purchaseDate: dateFormatter.string(from: purchaseDate),
      expirationDate: expirationDate.map { dateFormatter.string(from: $0) },
      purchasedQuantity: Int64(purchasedQuantity),
      appAccountToken: appAccountToken?.uuidString,
      restoring: receipt != nil,
      receiptData: receipt
    )
  }
}
