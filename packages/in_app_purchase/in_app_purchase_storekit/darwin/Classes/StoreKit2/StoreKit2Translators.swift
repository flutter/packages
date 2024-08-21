// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit

@available(iOS 15.0, macOS 12.0, *)
extension Product {
  func convertToPigeon() -> SK2ProductMessage {

    return SK2ProductMessage(
      id: id,
      displayName: displayName,
      description: description,
      price: NSDecimalNumber(decimal: price).doubleValue,
      displayPrice: displayPrice,
      type: type.convertToPigeon(),
      subscription: subscription?.convertToPigeon(),
      priceLocale: priceFormatStyle.locale.convertToPigeon()
    )
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.ProductType {
  func convertToPigeon() -> SK2ProductTypeMessage {
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
  func convertToPigeon() -> SK2SubscriptionInfoMessage {
    return SK2SubscriptionInfoMessage(
      promotionalOffers: promotionalOffers.map({ $0.convertToPigeon() }),
      subscriptionGroupID: subscriptionGroupID,
      subscriptionPeriod: subscriptionPeriod.convertToPigeon())
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionOffer {
  func convertToPigeon() -> SK2SubscriptionOfferMessage {
    return SK2SubscriptionOfferMessage(
      /// ID is always `nil` for introductory offers and never `nil` for other offer types.
      id: id,
      price: NSDecimalNumber(decimal: price).doubleValue,
      type: type.convertToPigeon(),
      period: period.convertToPigeon(),
      periodCount: Int64(periodCount),
      paymentMode: paymentMode.convertToPigeon()
    )
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionOffer.OfferType {
  func convertToPigeon() -> SK2SubscriptionOfferTypeMessage {
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
  func convertToPigeon() -> SK2SubscriptionPeriodMessage {
    return SK2SubscriptionPeriodMessage(
      value: Int64(value),
      unit: unit.convertToPigeon())
  }
}

@available(iOS 15.0, macOS 12.0, *)
extension Product.SubscriptionPeriod.Unit {
  func convertToPigeon() -> SK2SubscriptionPeriodUnitMessage {
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
  func convertToPigeon() -> SK2SubscriptionOfferPaymentModeMessage {
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
  func convertToPigeon() -> SK2PriceLocaleMessage {
    return SK2PriceLocaleMessage(
      currencyCode: currencyCode ?? "",
      currencySymbol: currencySymbol ?? ""
    )
  }
}

