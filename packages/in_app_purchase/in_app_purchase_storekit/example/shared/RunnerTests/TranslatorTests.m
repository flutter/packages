// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "Stubs.h"

@import in_app_purchase_storekit;

@interface TranslatorTest : XCTestCase

@property(strong, nonatomic) NSDictionary *periodMap;
@property(strong, nonatomic) NSMutableDictionary *discountMap;
@property(strong, nonatomic) NSMutableDictionary *discountMissingIdentifierMap;
@property(strong, nonatomic) NSMutableDictionary *productMap;
@property(strong, nonatomic) NSDictionary *productResponseMap;
@property(strong, nonatomic) NSDictionary *paymentMap;
@property(copy, nonatomic) NSDictionary *paymentDiscountMap;
@property(strong, nonatomic) NSDictionary *transactionMap;
@property(strong, nonatomic) NSDictionary *errorMap;
@property(strong, nonatomic) NSDictionary *localeMap;
@property(strong, nonatomic) NSDictionary *storefrontMap;
@property(strong, nonatomic) NSDictionary *storefrontAndPaymentTransactionMap;
@end

@implementation TranslatorTest
- (void)setUp {
  self.periodMap = @{@"numberOfUnits" : @(0), @"unit" : @(0)};

  self.discountMap = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"price" : @"1",
    @"priceLocale" : [FIAObjectTranslator getMapFromNSLocale:NSLocale.systemLocale],
    @"numberOfPeriods" : @1,
    @"subscriptionPeriod" : self.periodMap,
    @"paymentMode" : @1,
  }];
  if (@available(iOS 12.2, *)) {
    self.discountMap[@"identifier"] = @"test offer id";
    self.discountMap[@"type"] = @(SKProductDiscountTypeIntroductory);
  }
  self.discountMissingIdentifierMap = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"price" : @"1",
    @"priceLocale" : [FIAObjectTranslator getMapFromNSLocale:NSLocale.systemLocale],
    @"numberOfPeriods" : @1,
    @"subscriptionPeriod" : self.periodMap,
    @"paymentMode" : @1,
    @"identifier" : [NSNull null],
    @"type" : @0,
  }];

  self.productMap = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"price" : @"1",
    @"priceLocale" : [FIAObjectTranslator getMapFromNSLocale:NSLocale.systemLocale],
    @"productIdentifier" : @"123",
    @"localizedTitle" : @"title",
    @"localizedDescription" : @"des",
  }];
  self.productMap[@"subscriptionPeriod"] = self.periodMap;
  self.productMap[@"introductoryPrice"] = self.discountMap;
  if (@available(iOS 12.2, *)) {
    self.productMap[@"discounts"] = @[ self.discountMap ];
  }
  self.productMap[@"subscriptionGroupIdentifier"] = @"com.group";

  self.productResponseMap =
      @{@"products" : @[ self.productMap ], @"invalidProductIdentifiers" : @[]};
  self.paymentMap = @{
    @"productIdentifier" : @"123",
    @"requestData" : @"abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
    @"quantity" : @(2),
    @"applicationUsername" : @"app user name",
    @"simulatesAskToBuyInSandbox" : @(NO)
  };
  self.paymentDiscountMap = @{
    @"identifier" : @"payment_discount_identifier",
    @"keyIdentifier" : @"payment_discount_key_identifier",
    @"nonce" : @"d18981e0-9003-4365-98a2-4b90e3b62c52",
    @"signature" : @"this is a encrypted signature",
    @"timestamp" : @([NSDate date].timeIntervalSince1970),
  };
  NSDictionary *originalTransactionMap = @{
    @"transactionIdentifier" : @"567",
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
    @"originalTransaction" : [NSNull null],
  };
  self.transactionMap = @{
    @"transactionIdentifier" : @"567",
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
    @"originalTransaction" : originalTransactionMap,
  };
  self.errorMap = @{
    @"code" : @(123),
    @"domain" : @"test_domain",
    @"userInfo" : @{
      @"key" : @"value",
    }
  };
  self.storefrontMap = @{
    @"countryCode" : @"USA",
    @"identifier" : @"unique_identifier",
  };

  self.storefrontAndPaymentTransactionMap = @{
    @"storefront" : self.storefrontMap,
    @"transaction" : self.transactionMap,
  };
}

- (void)testSKProductSubscriptionPeriodStubToMap {
  SKProductSubscriptionPeriodStub *period =
      [[SKProductSubscriptionPeriodStub alloc] initWithMap:self.periodMap];
  NSDictionary *map = [FIAObjectTranslator getMapFromSKProductSubscriptionPeriod:period];
  XCTAssertEqualObjects(map, self.periodMap);
}

- (void)testSKProductDiscountStubToMap {
  SKProductDiscountStub *discount = [[SKProductDiscountStub alloc] initWithMap:self.discountMap];
  NSDictionary *map = [FIAObjectTranslator getMapFromSKProductDiscount:discount];
  XCTAssertEqualObjects(map, self.discountMap);
}

- (void)testProductToMap {
  SKProductStub *product = [[SKProductStub alloc] initWithMap:self.productMap];
  NSDictionary *map = [FIAObjectTranslator getMapFromSKProduct:product];
  XCTAssertEqualObjects(map, self.productMap);
}

- (void)testProductResponseToMap {
  SKProductsResponseStub *response =
      [[SKProductsResponseStub alloc] initWithMap:self.productResponseMap];
  NSDictionary *map = [FIAObjectTranslator getMapFromSKProductsResponse:response];
  XCTAssertEqualObjects(map, self.productResponseMap);
}

- (void)testPaymentToMap {
  SKMutablePayment *payment = [FIAObjectTranslator getSKMutablePaymentFromMap:self.paymentMap];
  NSDictionary *map = [FIAObjectTranslator getMapFromSKPayment:payment];
  XCTAssertEqualObjects(map, self.paymentMap);
}

- (void)testPaymentTransactionToMap {
  // payment is not KVC, cannot test payment field.
  SKPaymentTransactionStub *paymentTransaction =
      [[SKPaymentTransactionStub alloc] initWithMap:self.transactionMap];
  NSDictionary *map = [FIAObjectTranslator getMapFromSKPaymentTransaction:paymentTransaction];
  XCTAssertEqualObjects(map, self.transactionMap);
}

- (void)testError {
  NSErrorStub *error = [[NSErrorStub alloc] initWithMap:self.errorMap];
  NSDictionary *map = [FIAObjectTranslator getMapFromNSError:error];
  XCTAssertEqualObjects(map, self.errorMap);
}

- (void)testErrorWithNSNumberAsUserInfo {
  NSError *error = [NSError errorWithDomain:SKErrorDomain code:3 userInfo:@{@"key" : @42}];
  NSDictionary *expectedMap =
      @{@"domain" : SKErrorDomain, @"code" : @3, @"userInfo" : @{@"key" : @42}};
  NSDictionary *map = [FIAObjectTranslator getMapFromNSError:error];
  XCTAssertEqualObjects(expectedMap, map);
}

- (void)testErrorWithMultipleUnderlyingErrors {
  NSError *underlyingErrorOne = [NSError errorWithDomain:SKErrorDomain code:2 userInfo:nil];
  NSError *underlyingErrorTwo = [NSError errorWithDomain:SKErrorDomain code:1 userInfo:nil];
  NSError *mainError = [NSError
      errorWithDomain:SKErrorDomain
                 code:3
             userInfo:@{@"underlyingErrors" : @[ underlyingErrorOne, underlyingErrorTwo ]}];
  NSDictionary *expectedMap = @{
    @"domain" : SKErrorDomain,
    @"code" : @3,
    @"userInfo" : @{
      @"underlyingErrors" : @[
        @{@"domain" : SKErrorDomain, @"code" : @2, @"userInfo" : @{}},
        @{@"domain" : SKErrorDomain, @"code" : @1, @"userInfo" : @{}}
      ]
    }
  };
  NSDictionary *map = [FIAObjectTranslator getMapFromNSError:mainError];
  XCTAssertEqualObjects(expectedMap, map);
}

- (void)testErrorWithNestedUnderlyingError {
  NSError *underlyingError = [NSError errorWithDomain:SKErrorDomain code:2 userInfo:nil];
  NSError *mainError =
      [NSError errorWithDomain:SKErrorDomain
                          code:3
                      userInfo:@{@"nesting" : @{@"underlyingError" : underlyingError}}];
  NSDictionary *expectedMap = @{
    @"domain" : SKErrorDomain,
    @"code" : @3,
    @"userInfo" : @{
      @"nesting" : @{
        @"underlyingError" : @{@"domain" : SKErrorDomain, @"code" : @2, @"userInfo" : @{}},

      }
    }
  };
  NSDictionary *map = [FIAObjectTranslator getMapFromNSError:mainError];
  XCTAssertEqualObjects(expectedMap, map);
}

- (void)testErrorWithUnsupportedUserInfo {
  NSError *error = [NSError errorWithDomain:SKErrorDomain
                                       code:3
                                   userInfo:@{@"user_info" : [[NSObject alloc] init]}];
  NSDictionary *expectedMap = @{
    @"domain" : SKErrorDomain,
    @"code" : @3,
    @"userInfo" : @{
      @"user_info" : [NSString
          stringWithFormat:
              @"Unable to encode native userInfo object of type %@ to map. Please submit an "
              @"issue at https://github.com/flutter/flutter/issues/new with the title "
              @"\"[in_app_purchase_storekit] Unable to encode userInfo of type %@\" and add "
              @"reproduction steps and the error details in the description field.",
              [NSObject class], [NSObject class]]
    }
  };
  NSDictionary *map = [FIAObjectTranslator getMapFromNSError:error];
  XCTAssertEqualObjects(expectedMap, map);
}

- (void)testLocaleToMap {
  NSLocale *system = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
  NSDictionary *map = [FIAObjectTranslator getMapFromNSLocale:system];
  XCTAssertEqualObjects(map[@"currencySymbol"], system.currencySymbol);
  XCTAssertEqualObjects(map[@"countryCode"], system.countryCode);
}

- (void)testSKStorefrontToMap {
  if (@available(iOS 13.0, *)) {
    SKStorefront *storefront = [[SKStorefrontStub alloc] initWithMap:self.storefrontMap];
    NSDictionary *map = [FIAObjectTranslator getMapFromSKStorefront:storefront];
    XCTAssertEqualObjects(map, self.storefrontMap);
  }
}

- (void)testSKStorefrontAndSKPaymentTransactionToMap {
  if (@available(iOS 13.0, *)) {
    SKStorefront *storefront = [[SKStorefrontStub alloc] initWithMap:self.storefrontMap];
    SKPaymentTransaction *transaction =
        [[SKPaymentTransactionStub alloc] initWithMap:self.transactionMap];
    NSDictionary *map = [FIAObjectTranslator getMapFromSKStorefront:storefront
                                            andSKPaymentTransaction:transaction];
    XCTAssertEqualObjects(map, self.storefrontAndPaymentTransactionMap);
  }
}

- (void)testSKPaymentDiscountFromMap {
  if (@available(iOS 12.2, *)) {
    NSString *error = nil;
    SKPaymentDiscount *paymentDiscount =
        [FIAObjectTranslator getSKPaymentDiscountFromMap:self.paymentDiscountMap withError:&error];

    XCTAssertEqual(paymentDiscount.identifier, self.paymentDiscountMap[@"identifier"]);
    XCTAssertEqual(paymentDiscount.keyIdentifier, self.paymentDiscountMap[@"keyIdentifier"]);
    XCTAssertEqualObjects(paymentDiscount.nonce,
                          [[NSUUID alloc] initWithUUIDString:self.paymentDiscountMap[@"nonce"]]);
    XCTAssertEqual(paymentDiscount.signature, self.paymentDiscountMap[@"signature"]);
    XCTAssertEqual(paymentDiscount.timestamp, self.paymentDiscountMap[@"timestamp"]);
  }
}

- (void)testSKPaymentDiscountFromMapMissingIdentifier {
  if (@available(iOS 12.2, *)) {
    NSArray *invalidValues = @[ [NSNull null], @(1), @"" ];

    for (id value in invalidValues) {
      NSDictionary *discountMap = @{
        @"identifier" : value,
        @"keyIdentifier" : @"payment_discount_key_identifier",
        @"nonce" : @"d18981e0-9003-4365-98a2-4b90e3b62c52",
        @"signature" : @"this is a encrypted signature",
        @"timestamp" : @([NSDate date].timeIntervalSince1970),
      };

      NSString *error = nil;
      [FIAObjectTranslator getSKPaymentDiscountFromMap:discountMap withError:&error];

      XCTAssertNotNil(error);
      XCTAssertEqualObjects(
          error, @"When specifying a payment discount the 'identifier' field is mandatory.");
    }
  }
}

- (void)testGetMapFromSKProductDiscountMissingIdentifier {
  if (@available(iOS 12.2, *)) {
    SKProductDiscountStub *discount =
        [[SKProductDiscountStub alloc] initWithMap:self.discountMissingIdentifierMap];
    NSDictionary *map = [FIAObjectTranslator getMapFromSKProductDiscount:discount];
    XCTAssertEqualObjects(map, self.discountMissingIdentifierMap);
  }
}

- (void)testSKPaymentDiscountFromMapMissingKeyIdentifier {
  if (@available(iOS 12.2, *)) {
    NSArray *invalidValues = @[ [NSNull null], @(1), @"" ];

    for (id value in invalidValues) {
      NSDictionary *discountMap = @{
        @"identifier" : @"payment_discount_identifier",
        @"keyIdentifier" : value,
        @"nonce" : @"d18981e0-9003-4365-98a2-4b90e3b62c52",
        @"signature" : @"this is a encrypted signature",
        @"timestamp" : @([NSDate date].timeIntervalSince1970),
      };

      NSString *error = nil;
      [FIAObjectTranslator getSKPaymentDiscountFromMap:discountMap withError:&error];

      XCTAssertNotNil(error);
      XCTAssertEqualObjects(
          error, @"When specifying a payment discount the 'keyIdentifier' field is mandatory.");
    }
  }
}

- (void)testSKPaymentDiscountFromMapMissingNonce {
  if (@available(iOS 12.2, *)) {
    NSArray *invalidValues = @[ [NSNull null], @(1), @"" ];

    for (id value in invalidValues) {
      NSDictionary *discountMap = @{
        @"identifier" : @"payment_discount_identifier",
        @"keyIdentifier" : @"payment_discount_key_identifier",
        @"nonce" : value,
        @"signature" : @"this is a encrypted signature",
        @"timestamp" : @([NSDate date].timeIntervalSince1970),
      };

      NSString *error = nil;
      [FIAObjectTranslator getSKPaymentDiscountFromMap:discountMap withError:&error];

      XCTAssertNotNil(error);
      XCTAssertEqualObjects(error,
                            @"When specifying a payment discount the 'nonce' field is mandatory.");
    }
  }
}

- (void)testSKPaymentDiscountFromMapMissingSignature {
  if (@available(iOS 12.2, *)) {
    NSArray *invalidValues = @[ [NSNull null], @(1), @"" ];

    for (id value in invalidValues) {
      NSDictionary *discountMap = @{
        @"identifier" : @"payment_discount_identifier",
        @"keyIdentifier" : @"payment_discount_key_identifier",
        @"nonce" : @"d18981e0-9003-4365-98a2-4b90e3b62c52",
        @"signature" : value,
        @"timestamp" : @([NSDate date].timeIntervalSince1970),
      };

      NSString *error = nil;
      [FIAObjectTranslator getSKPaymentDiscountFromMap:discountMap withError:&error];

      XCTAssertNotNil(error);
      XCTAssertEqualObjects(
          error, @"When specifying a payment discount the 'signature' field is mandatory.");
    }
  }
}

- (void)testSKPaymentDiscountFromMapMissingTimestamp {
  if (@available(iOS 12.2, *)) {
    NSArray *invalidValues = @[ [NSNull null], @"", @(-1) ];

    for (id value in invalidValues) {
      NSDictionary *discountMap = @{
        @"identifier" : @"payment_discount_identifier",
        @"keyIdentifier" : @"payment_discount_key_identifier",
        @"nonce" : @"d18981e0-9003-4365-98a2-4b90e3b62c52",
        @"signature" : @"this is a encrypted signature",
        @"timestamp" : value,
      };

      NSString *error = nil;
      [FIAObjectTranslator getSKPaymentDiscountFromMap:discountMap withError:&error];

      XCTAssertNotNil(error);
      XCTAssertEqualObjects(
          error, @"When specifying a payment discount the 'timestamp' field is mandatory.");
    }
  }
}

- (void)testSKPaymentDiscountFromMapOverflowingTimestamp {
  if (@available(iOS 12.2, *)) {
    NSDictionary *discountMap = @{
      @"identifier" : @"payment_discount_identifier",
      @"keyIdentifier" : @"payment_discount_key_identifier",
      @"nonce" : @"d18981e0-9003-4365-98a2-4b90e3b62c52",
      @"signature" : @"this is a encrypted signature",
      @"timestamp" : @1665044583595,  // timestamp 2022 Oct
    };
    NSString *error = nil;
    SKPaymentDiscount *paymentDiscount =
        [FIAObjectTranslator getSKPaymentDiscountFromMap:discountMap withError:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(paymentDiscount);
    XCTAssertEqual(paymentDiscount.identifier, discountMap[@"identifier"]);
    XCTAssertEqual(paymentDiscount.keyIdentifier, discountMap[@"keyIdentifier"]);
    XCTAssertEqualObjects(paymentDiscount.nonce,
                          [[NSUUID alloc] initWithUUIDString:discountMap[@"nonce"]]);
    XCTAssertEqual(paymentDiscount.signature, discountMap[@"signature"]);
    XCTAssertEqual(paymentDiscount.timestamp, discountMap[@"timestamp"]);
  }
}

- (void)testSKPaymentDiscountConvertToPigeon {
  if (@available(iOS 12.2, *)) {
    NSString *error = nil;
    SKPaymentDiscount *paymentDiscount =
        [FIAObjectTranslator getSKPaymentDiscountFromMap:self.paymentDiscountMap withError:&error];
    SKPaymentDiscountMessage *paymentDiscountPigeon =
        [FIAObjectTranslator convertPaymentDiscountToPigeon:paymentDiscount];

    XCTAssertNotNil(paymentDiscountPigeon);
    XCTAssertEqual(paymentDiscount.identifier, paymentDiscountPigeon.identifier);
    XCTAssertEqual(paymentDiscount.keyIdentifier, paymentDiscount.keyIdentifier);
    XCTAssertEqualObjects(paymentDiscount.nonce,
                          [[NSUUID alloc] initWithUUIDString:paymentDiscountPigeon.nonce]);
    XCTAssertEqual(paymentDiscount.signature, paymentDiscountPigeon.signature);
    XCTAssertEqual([paymentDiscount.timestamp intValue], paymentDiscountPigeon.timestamp);
  }
}

- (void)testSKErrorConvertToPigeon {
  NSError *error = [NSError errorWithDomain:SKErrorDomain code:3 userInfo:@{@"key" : @42}];
  SKErrorMessage *msg = [SKErrorMessage makeWithCode:3
                                              domain:SKErrorDomain
                                            userInfo:@{@"key" : @42}];

  SKErrorMessage *skerror = [FIAObjectTranslator convertSKErrorToPigeon:error];
  XCTAssertEqual(skerror.domain, msg.domain);
  XCTAssertEqual(skerror.code, msg.code);
  XCTAssertEqualObjects(skerror.userInfo, msg.userInfo);
}

- (void)testSKPaymentConvertToPigeon {
  if (@available(iOS 12.2, *)) {
    SKMutablePayment *payment = [FIAObjectTranslator getSKMutablePaymentFromMap:self.paymentMap];
    SKPaymentMessage *msg = [FIAObjectTranslator convertPaymentToPigeon:payment];

    XCTAssertEqual(payment.productIdentifier, msg.productIdentifier);
    XCTAssertEqualObjects(payment.requestData,
                          [msg.requestData dataUsingEncoding:NSUTF8StringEncoding]);
    XCTAssertEqual(payment.quantity, msg.quantity);
    XCTAssertEqual(payment.applicationUsername, msg.applicationUsername);
    XCTAssertEqual(payment.simulatesAskToBuyInSandbox, msg.simulatesAskToBuyInSandbox);
  }
}

- (void)testSKPaymentTransactionConvertToPigeon {
  SKPaymentTransactionStub *paymentTransaction =
      [[SKPaymentTransactionStub alloc] initWithMap:self.transactionMap];

  SKPaymentTransactionMessage *msg =
      [FIAObjectTranslator convertTransactionToPigeon:paymentTransaction];

  XCTAssertEqual(msg.payment, NULL);
  XCTAssertEqual(msg.transactionState, SKPaymentTransactionStateMessagePurchasing);
  XCTAssertEqual(paymentTransaction.transactionDate,
                 [NSDate dateWithTimeIntervalSince1970:[msg.transactionTimeStamp doubleValue]]);
  XCTAssertEqual(paymentTransaction.transactionIdentifier, msg.transactionIdentifier);
}

- (void)testSKProductResponseCovertToPigeon {
  SKProductsResponseStub *response =
      [[SKProductsResponseStub alloc] initWithMap:self.productResponseMap];
  SKProductsResponseMessage *responseMsg =
      [FIAObjectTranslator convertProductsResponseToPigeon:response];

  XCTAssertEqual(responseMsg.products.count, 1);
  XCTAssertEqual(responseMsg.invalidProductIdentifiers.count, 0);

  SKProductMessage *productMsg = responseMsg.products[0];

  // These values are being set in productResponseMap in setUp()
  XCTAssertEqualObjects(productMsg.price, @"1");
  XCTAssertEqualObjects(productMsg.productIdentifier, @"123");
  XCTAssertEqualObjects(productMsg.localizedTitle, @"title");
  XCTAssertEqualObjects(productMsg.localizedDescription, @"des");
  XCTAssertEqualObjects(productMsg.subscriptionGroupIdentifier, @"com.group");

  SKPriceLocaleMessage *localeMsg = productMsg.priceLocale;
  SKProductSubscriptionPeriodMessage *subPeriod = productMsg.subscriptionPeriod;
  SKProductDiscountMessage *introDiscount = productMsg.introductoryPrice;
  NSArray<SKProductDiscountMessage *> *discounts = productMsg.discounts;

  XCTAssertEqualObjects(localeMsg.countryCode, nil);
  XCTAssertEqualObjects(localeMsg.currencyCode, nil);
  XCTAssertEqualObjects(localeMsg.currencySymbol, @"\u00a4");

  XCTAssertEqual(subPeriod.unit, SKSubscriptionPeriodUnitMessageDay);
  XCTAssertEqual(subPeriod.numberOfUnits, 0);

  XCTAssertEqualObjects(introDiscount.price, @"1");
  XCTAssertEqual(introDiscount.numberOfPeriods, 1);
  XCTAssertEqual(introDiscount.paymentMode, SKProductDiscountPaymentModeMessagePayUpFront);

  XCTAssertEqual(discounts.count, 1);
}

@end
