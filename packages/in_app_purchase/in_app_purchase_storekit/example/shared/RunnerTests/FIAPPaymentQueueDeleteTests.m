// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FIAObjectTranslator.h"
#import "FIAPaymentQueueHandler.h"
#import "Stubs.h"

@import in_app_purchase_storekit;

API_AVAILABLE(ios(13.0))
API_UNAVAILABLE(tvos, macos, watchos)
@interface FIAPPaymentQueueDelegateTests : XCTestCase

@property(nonatomic, strong) SKPaymentTransaction *transaction;
@property(nonatomic, strong) SKStorefront *storefront;

@end

@implementation FIAPPaymentQueueDelegateTests

- (void)setUp {
  NSDictionary *transactionMap = @{
    @"transactionIdentifier" : [NSNull null],
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
    @"originalTransaction" : [NSNull null],
  };
  self.transaction = [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];

  NSDictionary *storefrontMap = @{
    @"countryCode" : @"USA",
    @"identifier" : @"unique_identifier",
  };
  self.storefront = [[SKStorefrontStub alloc] initWithMap:storefrontMap];
}

- (void)tearDown {
}

- (void)testShouldContinueTransaction {
  if (@available(iOS 13.0, *)) {
    MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
    channelStub.invokeMethodChannelWithResultsStub =
        ^(NSString *_Nonnull method, id _Nonnull arguments, FlutterResult _Nullable result) {
          XCTAssertEqualObjects(method, @"shouldContinueTransaction");
          XCTAssertEqualObjects(arguments,
                                [FIAObjectTranslator getMapFromSKStorefront:self.storefront
                                                    andSKPaymentTransaction:self.transaction]);
          result(@NO);
        };

    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:channelStub];

    BOOL shouldContinue = [delegate paymentQueue:[[SKPaymentQueueStub alloc] init]
                       shouldContinueTransaction:self.transaction
                                    inStorefront:self.storefront];

    XCTAssertFalse(shouldContinue);
  }
}

- (void)testShouldContinueTransaction_should_default_to_yes {
  if (@available(iOS 13.0, *)) {
    MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:channelStub];

    channelStub.invokeMethodChannelWithResultsStub =
        ^(NSString *_Nonnull method, id _Nonnull arguments, FlutterResult _Nullable result) {
          XCTAssertEqualObjects(method, @"shouldContinueTransaction");
          XCTAssertEqualObjects(arguments,
                                [FIAObjectTranslator getMapFromSKStorefront:self.storefront
                                                    andSKPaymentTransaction:self.transaction]);
        };

    BOOL shouldContinue = [delegate paymentQueue:[[SKPaymentQueueStub alloc] init]
                       shouldContinueTransaction:self.transaction
                                    inStorefront:self.storefront];

    XCTAssertTrue(shouldContinue);
  }
}

#if TARGET_OS_IOS
- (void)testShouldShowPriceConsentIfNeeded {
  if (@available(iOS 13.4, *)) {
    MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:channelStub];

    channelStub.invokeMethodChannelWithResultsStub =
        ^(NSString *_Nonnull method, id _Nonnull arguments, FlutterResult _Nullable result) {
          XCTAssertEqualObjects(method, @"shouldShowPriceConsent");
          XCTAssertNil(arguments);
          result(@NO);
        };

    BOOL shouldShow =
        [delegate paymentQueueShouldShowPriceConsent:[[SKPaymentQueueStub alloc] init]];

    XCTAssertFalse(shouldShow);
  }
}
#endif

#if TARGET_OS_IOS
- (void)testShouldShowPriceConsentIfNeeded_should_default_to_yes {
  if (@available(iOS 13.4, *)) {
    MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:channelStub];

    channelStub.invokeMethodChannelWithResultsStub =
        ^(NSString *_Nonnull method, id _Nonnull arguments, FlutterResult _Nullable result) {
          XCTAssertEqualObjects(method, @"shouldShowPriceConsent");
          XCTAssertNil(arguments);
        };

    BOOL shouldShow =
        [delegate paymentQueueShouldShowPriceConsent:[[SKPaymentQueueStub alloc] init]];

    XCTAssertTrue(shouldShow);
  }
}
#endif

@end
