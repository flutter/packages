// Copyright 2013 The Flutter Authors
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
    var allOffers: [SK2SubscriptionOfferMessage] = []

    if #available(iOS 18.0, macOS 15.0, *) {
      allOffers.append(contentsOf: winBackOffers.map { $0.convertToPigeon })
    }

    allOffers.append(contentsOf: promotionalOffers.map { $0.convertToPigeon })

    if let introductory = introductoryOffer {
      allOffers.append(introductory.convertToPigeon)
    }

    return SK2SubscriptionInfoMessage(
      promotionalOffers: allOffers,
      subscriptionGroupID: subscriptionGroupID,
      subscriptionPeriod: subscriptionPeriod.convertToPigeon
    )
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

extension SK2SubscriptionOfferSignatureMessage {
  @available(iOS 17.4, macOS 14.4, *)
  var convertToSignature: Product.SubscriptionOffer.Signature {
    return Product.SubscriptionOffer.Signature(
      keyID: keyID,
      nonce: nonceAsUUID,
      timestamp: Int(timestamp),
      signature: signatureAsData
    )
  }

  var nonceAsUUID: UUID {
    guard let uuid = UUID(uuidString: nonce) else {
      fatalError("Invalid UUID format for nonce: \(nonce)")
    }
    return uuid
  }

  var signatureAsData: Data {
    guard let data = Data(base64Encoded: signature) else {
      fatalError("Invalid Base64 format for signature: \(signature)")
    }
    return data
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
      if #available(iOS 18.0, macOS 15.0, *) {
        if self == .winBack {
          return SK2SubscriptionOfferTypeMessage.winBack
        }
      }
      fatalError("An unknown or unsupported OfferType was passed in")
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

@available(iOS 15.0, macOS 12.0, *)
extension Product.PurchaseResult {
  func convertToPigeon() -> SK2ProductPurchaseResultMessage {
    return switch self {
    case .success(.verified): .success
    case .success(.unverified): .unverified
    case .userCancelled: .userCancelled
    case .pending: .pending
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
      receiptData: receipt,
      jsonRepresentation: String(decoding: jsonRepresentation, as: UTF8.self)
    )
  }
}
