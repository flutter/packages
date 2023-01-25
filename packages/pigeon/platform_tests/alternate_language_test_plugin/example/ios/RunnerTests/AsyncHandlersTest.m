// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

#ifdef LEGACY_HARNESS
#import "AsyncHandlers.gen.h"
#else
@import alternate_language_test_plugin;
#endif

#import "MockBinaryMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface Value ()
+ (Value *)fromList:(NSArray *)list;
- (NSArray *)toList;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface MockApi2Host : NSObject <Api2Host>
@property(nonatomic, copy) NSNumber *output;
@property(nonatomic, retain) FlutterError *voidVoidError;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation MockApi2Host

- (void)calculateValue:(Value *)input
            completion:(nonnull void (^)(Value *_Nullable, FlutterError *_Nullable))completion {
  if (self.output) {
    Value *output = [[Value alloc] init];
    output.number = self.output;
    completion(output, nil);
  } else {
    completion(nil, [FlutterError errorWithCode:@"hey" message:@"ho" details:nil]);
  }
}

- (void)voidVoidWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  completion(self.voidVoidError);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface AsyncHandlersTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation AsyncHandlersTest

- (void)testAsyncHost2Flutter {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:Api2FlutterGetCodec()];
  binaryMessenger.result = [Value makeWithNumber:@(2)];
  Api2Flutter *api2Flutter = [[Api2Flutter alloc] initWithBinaryMessenger:binaryMessenger];
  Value *input = [[Value alloc] init];
  input.number = @(1);
  XCTestExpectation *expectation = [self expectationWithDescription:@"calculate callback"];
  [api2Flutter calculateValue:input
                   completion:^(Value *_Nonnull output, NSError *_Nullable error) {
                     XCTAssertEqual(output.number.intValue, 2);
                     [expectation fulfill];
                   }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostVoidVoid {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:Api2HostGetCodec()];
  MockApi2Host *mockApi2Host = [[MockApi2Host alloc] init];
  mockApi2Host.output = @(2);
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString *channelName = @"dev.flutter.pigeon.Api2Host.voidVoid";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  XCTestExpectation *expectation = [self expectationWithDescription:@"voidvoid callback"];
  binaryMessenger.handlers[channelName](nil, ^(NSData *data) {
    NSArray *outputList = [binaryMessenger.codec decode:data];
    XCTAssertEqualObjects(outputList[0], [NSNull null]);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostVoidVoidError {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:Api2HostGetCodec()];
  MockApi2Host *mockApi2Host = [[MockApi2Host alloc] init];
  mockApi2Host.voidVoidError = [FlutterError errorWithCode:@"code" message:@"message" details:nil];
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString *channelName = @"dev.flutter.pigeon.Api2Host.voidVoid";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  XCTestExpectation *expectation = [self expectationWithDescription:@"voidvoid callback"];
  binaryMessenger.handlers[channelName](nil, ^(NSData *data) {
    NSArray *outputList = [binaryMessenger.codec decode:data];
    XCTAssertNotNil(outputList);
    XCTAssertEqualObjects(outputList[0], mockApi2Host.voidVoidError.code);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2Host {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:Api2HostGetCodec()];
  MockApi2Host *mockApi2Host = [[MockApi2Host alloc] init];
  mockApi2Host.output = @(2);
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString *channelName = @"dev.flutter.pigeon.Api2Host.calculate";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  Value *input = [[Value alloc] init];
  input.number = @(1);
  NSData *inputEncoded = [binaryMessenger.codec encode:@[ input ]];
  XCTestExpectation *expectation = [self expectationWithDescription:@"calculate callback"];
  binaryMessenger.handlers[channelName](inputEncoded, ^(NSData *data) {
    NSArray *outputList = [binaryMessenger.codec decode:data];
    Value *output = outputList[0];
    XCTAssertEqual(output.number.intValue, 2);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostError {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:Api2HostGetCodec()];
  MockApi2Host *mockApi2Host = [[MockApi2Host alloc] init];
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString *channelName = @"dev.flutter.pigeon.Api2Host.calculate";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  Value *input = [[Value alloc] init];
  input.number = @(1);
  NSData *inputEncoded = [binaryMessenger.codec encode:@[ [input toList] ]];
  XCTestExpectation *expectation = [self expectationWithDescription:@"calculate callback"];
  binaryMessenger.handlers[channelName](inputEncoded, ^(NSData *data) {
    NSArray *outputList = [binaryMessenger.codec decode:data];
    XCTAssertNotNil(outputList);
    XCTAssertEqualObjects(outputList[0], @"hey");
    XCTAssertEqualObjects(outputList[1], @"ho");
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
