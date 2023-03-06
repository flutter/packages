// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "MockBinaryMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface MockHostSmallApi : NSObject <HostSmallApi>
@property(nonatomic, copy) NSString *output;
@property(nonatomic, retain) FlutterError *voidVoidError;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation MockHostSmallApi

- (void)echoString:(NSString *)value
        completion:(nonnull void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  if (self.output) {
    completion(self.output, nil);
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
      [[MockBinaryMessenger alloc] initWithCodec:FlutterIntegrationCoreApiGetCodec()];
  NSString *value = @"Test";
  binaryMessenger.result = value;
  FlutterIntegrationCoreApi *flutterApi =
      [[FlutterIntegrationCoreApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"echo callback"];
  [flutterApi echoAsyncString:value
                   completion:^(NSString *_Nonnull output, FlutterError *_Nullable error) {
                     XCTAssertEqualObjects(output, value);
                     [expectation fulfill];
                   }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostVoidVoid {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:HostSmallApiGetCodec()];
  MockHostSmallApi *mockHostSmallApi = [[MockHostSmallApi alloc] init];
  HostSmallApiSetup(binaryMessenger, mockHostSmallApi);
  NSString *channelName = @"dev.flutter.pigeon.HostSmallApi.voidVoid";
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
      [[MockBinaryMessenger alloc] initWithCodec:HostSmallApiGetCodec()];
  MockHostSmallApi *mockHostSmallApi = [[MockHostSmallApi alloc] init];
  mockHostSmallApi.voidVoidError = [FlutterError errorWithCode:@"code"
                                                       message:@"message"
                                                       details:nil];
  HostSmallApiSetup(binaryMessenger, mockHostSmallApi);
  NSString *channelName = @"dev.flutter.pigeon.HostSmallApi.voidVoid";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  XCTestExpectation *expectation = [self expectationWithDescription:@"voidvoid callback"];
  binaryMessenger.handlers[channelName](nil, ^(NSData *data) {
    NSArray *outputList = [binaryMessenger.codec decode:data];
    XCTAssertNotNil(outputList);
    XCTAssertEqualObjects(outputList[0], mockHostSmallApi.voidVoidError.code);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2Host {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:HostSmallApiGetCodec()];
  MockHostSmallApi *mockHostSmallApi = [[MockHostSmallApi alloc] init];
  NSString *value = @"Test";
  mockHostSmallApi.output = value;
  HostSmallApiSetup(binaryMessenger, mockHostSmallApi);
  NSString *channelName = @"dev.flutter.pigeon.HostSmallApi.echo";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  NSData *inputEncoded = [binaryMessenger.codec encode:@[ value ]];
  XCTestExpectation *expectation = [self expectationWithDescription:@"echo callback"];
  binaryMessenger.handlers[channelName](inputEncoded, ^(NSData *data) {
    NSArray *outputList = [binaryMessenger.codec decode:data];
    NSString *output = outputList[0];
    XCTAssertEqualObjects(output, value);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostError {
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:HostSmallApiGetCodec()];
  MockHostSmallApi *mockHostSmallApi = [[MockHostSmallApi alloc] init];
  HostSmallApiSetup(binaryMessenger, mockHostSmallApi);
  NSString *channelName = @"dev.flutter.pigeon.HostSmallApi.echo";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  NSData *inputEncoded = [binaryMessenger.codec encode:@[ @"Test" ]];
  XCTestExpectation *expectation = [self expectationWithDescription:@"echo callback"];
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
