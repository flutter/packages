// Copyright 2013 The Flutter Authors
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
      localizedDescription: "A lower level subscription.",
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
    var pigeonMessage = product.convertToPigeon
    // Billing plans depend on the OS version rather than on the configuration
    // file, and are covered by `testPigeonConversionForPricingTerms`.
    pigeonMessage.subscription?.pricingTerms = nil
    XCTAssertEqual(pigeonMessage, productMessage)
  }

  func testPigeonConversionForSubscriptionInfo() async throws {
    guard let subscription = product.subscription else {
      XCTFail("SubscriptionInfo should not be nil")
      return
    }
    var pigeonMessage = subscription.convertToPigeon
    // Billing plans depend on the OS version rather than on the configuration
    // file, and are covered by `testPigeonConversionForPricingTerms`.
    pigeonMessage.pricingTerms = nil
    XCTAssertEqual(pigeonMessage, productMessage.subscription)
  }

  func testPigeonConversionForPricingTerms() async throws {
    guard #available(iOS 26.4, macOS 26.4, *) else {
      throw XCTSkip("Billing plans require iOS 26.4 or macOS 26.4.")
    }
    guard let subscription = product.subscription else {
      XCTFail("SubscriptionInfo should not be nil")
      return
    }

    let pricingTerms = subscription.pricingTerms
    guard let converted = subscription.convertToPigeon.pricingTerms else {
      XCTFail("Pricing terms should not be nil on an OS that supports billing plans")
      return
    }

    // Every auto-renewable subscription has at least an up-front billing plan,
    // so an empty array would mean the assertions below never run.
    XCTAssertFalse(pricingTerms.isEmpty)
    XCTAssertEqual(converted.count, pricingTerms.count)

    for (terms, message) in zip(pricingTerms, converted) {
      // Compare against the StoreKit value rather than against
      // `terms.billingPlanType.convertToPigeon`, which is the code under test.
      let isMonthly = terms.billingPlanType == .monthly
      XCTAssertEqual(message.billingPlanType, isMonthly ? .monthly : .upFront)
      XCTAssertEqual(message.billingDisplayPrice, terms.billingDisplayPrice)
      XCTAssertEqual(message.billingPrice, NSDecimalNumber(decimal: terms.billingPrice).doubleValue)
      if isMonthly {
        XCTAssertEqual(message.commitmentInfo?.displayPrice, terms.commitmentInfo.displayPrice)
        XCTAssertEqual(
          message.commitmentInfo?.price,
          NSDecimalNumber(decimal: terms.commitmentInfo.price).doubleValue)
      } else {
        XCTAssertNil(message.commitmentInfo)
      }
    }

    // The up-front plan bills the subscription's regular price, so its
    // converted prices can be checked against the product itself instead of
    // against the conversion that produced them.
    guard
      let upFront = zip(pricingTerms, converted).first(where: {
        $0.0.billingPlanType == .upFront
      })?.1
    else {
      XCTFail("Every subscription should offer an up-front billing plan")
      return
    }
    XCTAssertEqual(upFront.billingPrice, NSDecimalNumber(decimal: product.price).doubleValue)
    XCTAssertEqual(upFront.billingDisplayPrice, product.displayPrice)
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

  func testPigeonConversionForPurchaseResult() {
    // Unfortunately the .success case is not testable because the Transaction
    // type has no visible initializers.
    XCTAssertEqual(Product.PurchaseResult.pending.convertToPigeon(), .pending)
    XCTAssertEqual(Product.PurchaseResult.userCancelled.convertToPigeon(), .userCancelled)
  }
}
