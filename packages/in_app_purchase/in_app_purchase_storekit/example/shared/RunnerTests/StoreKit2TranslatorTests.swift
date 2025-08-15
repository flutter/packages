// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKitTest
import XCTest

@testable import in_app_purchase_storekit

@available(iOS 15.0, macOS 12.0, *)
final class StoreKit2TranslatorTests: XCTestCase {
  private var session: SKTestSession!
  private var plugin: InAppPurchasePlugin!
  private var product: Product!

  // This is transcribed from the Configuration.storekit file.
  private var productMessage: SK2ProductMessage!

  override func setUp() async throws {
    try await super.setUp()

    var promotionalOffers: [SK2SubscriptionOfferMessage] = [
      SK2SubscriptionOfferMessage(
        id: "subscription_silver_big_promo",
        price: 0.99,
        type: .promotional,
        period: SK2SubscriptionPeriodMessage(value: 1, unit: .week),
        periodCount: 1,
        paymentMode: .payAsYouGo)
    ]

    if #available(iOS 18.0, macOS 15.0, *) {
      promotionalOffers.insert(
        SK2SubscriptionOfferMessage(
          id: "subscription_silver_winback_offer",
          price: 0.99,
          type: .winBack,
          period: SK2SubscriptionPeriodMessage(value: 1, unit: .week),
          periodCount: 1,
          paymentMode: .payAsYouGo),
        at: 0
      )
    }

    productMessage = SK2ProductMessage(
      id: "subscription_silver",
      displayName: "Subscription Silver",
      description: "A lower level subscription.",
      price: 4.99,
      displayPrice: "$4.99",
      type: SK2ProductTypeMessage.autoRenewable,
      subscription: SK2SubscriptionInfoMessage(
        promotionalOffers: promotionalOffers,
        subscriptionGroupID: "D0FEE8D8",
        subscriptionPeriod: SK2SubscriptionPeriodMessage(
          value: 1,
          unit: SK2SubscriptionPeriodUnitMessage.week
        )
      ),
      priceLocale: SK2PriceLocaleMessage(currencyCode: "USD", currencySymbol: "$"))

    self.session = try! SKTestSession(configurationFileNamed: "Configuration")
    self.session.clearTransactions()
    let receiptManagerStub = FIAPReceiptManagerStub()
    plugin = InAppPurchasePluginStub(receiptManager: receiptManagerStub) { request in
      DefaultRequestHandler(requestHandler: FIAPRequestHandler(request: request))
    }
    product = try await Product.products(for: ["subscription_silver"]).first!

  }

  func testPigeonConversionForProduct() async throws {
    XCTAssertNotNil(product)
    let pigeonMessage = product.convertToPigeon
    XCTAssertEqual(pigeonMessage, productMessage)
  }

  func testPigeonConversionForSubscriptionInfo() async throws {
    guard let subscription = product.subscription else {
      XCTFail("SubscriptionInfo should not be nil")
      return
    }
    let pigeonMessage = subscription.convertToPigeon
    XCTAssertEqual(pigeonMessage, productMessage.subscription)
  }

  func testPigeonConversionForProductType() async throws {
    let type = product.type
    let pigeonMessage = type.convertToPigeon
    XCTAssertEqual(pigeonMessage, productMessage.type)
  }

  func testPigeonConversionForSubscriptionPeriod() async throws {
    guard let period = product.subscription?.subscriptionPeriod else {
      XCTFail("SubscriptionPeriod should not be nil")
      return
    }
    let pigeonMessage = period.convertToPigeon
    XCTAssertEqual(pigeonMessage, productMessage.subscription?.subscriptionPeriod)
  }

  func testPigeonConversionForPriceLocale() async throws {
    let locale = product.priceFormatStyle.locale
    let pigeonMessage = locale.convertToPigeon
    XCTAssertEqual(pigeonMessage, productMessage.priceLocale)
  }
}
