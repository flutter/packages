// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <XCTest/XCTest.h>
#import "async_handlers.gen.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface Value ()
+ (Value*)fromMap:(NSDictionary*)dict;
- (NSDictionary*)toMap;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface MockBinaryMessenger : NSObject<FlutterBinaryMessenger>
@property(nonatomic, copy) NSNumber* result;
@property(nonatomic, retain) FlutterStandardMessageCodec* codec;
@property(nonatomic, retain) NSMutableDictionary<NSString*, FlutterBinaryMessageHandler>* handlers;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation MockBinaryMessenger

- (instancetype)init {
  self = [super init];
  if (self) {
    _codec = [FlutterStandardMessageCodec sharedInstance];
    _handlers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)cleanupConnection:(FlutterBinaryMessengerConnection)connection {
}

- (void)sendOnChannel:(nonnull NSString*)channel message:(NSData* _Nullable)message {
}

- (void)sendOnChannel:(nonnull NSString*)channel
              message:(NSData* _Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
  if (self.result) {
    Value* output = [[Value alloc] init];
    output.number = self.result;
    NSDictionary* outputDictionary = [output toMap];
    callback([_codec encode:outputDictionary]);
  }
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString*)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  _handlers[channel] = [handler copy];
  return _handlers.count;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface MockApi2Host : NSObject<Api2Host>
@property(nonatomic, copy) NSNumber* output;
@property(nonatomic, retain) FlutterError* voidVoidError;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation MockApi2Host

- (void)calculate:(Value* _Nullable)input
       completion:(nonnull void (^)(Value* _Nullable, FlutterError* _Nullable))completion {
  if (self.output) {
    Value* output = [[Value alloc] init];
    output.number = self.output;
    completion(output, nil);
  } else {
    completion(nil, [FlutterError errorWithCode:@"hey" message:@"ho" details:nil]);
  }
}

- (void)voidVoid:(nonnull void (^)(FlutterError* _Nullable))completion {
  completion(self.voidVoidError);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface AsyncHandlersTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation AsyncHandlersTest

- (void)testAsyncHost2Flutter {
  MockBinaryMessenger* binaryMessenger = [[MockBinaryMessenger alloc] init];
  binaryMessenger.result = @(2);
  Api2Flutter* api2Flutter = [[Api2Flutter alloc] initWithBinaryMessenger:binaryMessenger];
  Value* input = [[Value alloc] init];
  input.number = @(1);
  XCTestExpectation* expectation = [self expectationWithDescription:@"calculate callback"];
  [api2Flutter calculate:input
              completion:^(Value* _Nonnull output, NSError* _Nullable error) {
                XCTAssertEqual(output.number.intValue, 2);
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostVoidVoid {
  MockBinaryMessenger* binaryMessenger = [[MockBinaryMessenger alloc] init];
  MockApi2Host* mockApi2Host = [[MockApi2Host alloc] init];
  mockApi2Host.output = @(2);
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString* channelName = @"dev.flutter.pigeon.Api2Host.voidVoid";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  XCTestExpectation* expectation = [self expectationWithDescription:@"voidvoid callback"];
  binaryMessenger.handlers[channelName](nil, ^(NSData* data) {
    NSDictionary* outputMap = [binaryMessenger.codec decode:data];
    XCTAssertEqualObjects(outputMap[@"result"], [NSNull null]);
    XCTAssertEqualObjects(outputMap[@"error"], [NSNull null]);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostVoidVoidError {
  MockBinaryMessenger* binaryMessenger = [[MockBinaryMessenger alloc] init];
  MockApi2Host* mockApi2Host = [[MockApi2Host alloc] init];
  mockApi2Host.voidVoidError = [FlutterError errorWithCode:@"code" message:@"message" details:nil];
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString* channelName = @"dev.flutter.pigeon.Api2Host.voidVoid";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  XCTestExpectation* expectation = [self expectationWithDescription:@"voidvoid callback"];
  binaryMessenger.handlers[channelName](nil, ^(NSData* data) {
    NSDictionary* outputMap = [binaryMessenger.codec decode:data];
    XCTAssertNotNil(outputMap[@"error"]);
    XCTAssertEqualObjects(outputMap[@"error"][@"code"], mockApi2Host.voidVoidError.code);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2Host {
  MockBinaryMessenger* binaryMessenger = [[MockBinaryMessenger alloc] init];
  MockApi2Host* mockApi2Host = [[MockApi2Host alloc] init];
  mockApi2Host.output = @(2);
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString* channelName = @"dev.flutter.pigeon.Api2Host.calculate";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  Value* input = [[Value alloc] init];
  input.number = @(1);
  NSData* inputEncoded = [binaryMessenger.codec encode:[input toMap]];
  XCTestExpectation* expectation = [self expectationWithDescription:@"calculate callback"];
  binaryMessenger.handlers[channelName](inputEncoded, ^(NSData* data) {
    NSDictionary* outputMap = [binaryMessenger.codec decode:data];
    Value* output = [Value fromMap:outputMap[@"result"]];
    XCTAssertEqual(output.number.intValue, 2);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAsyncFlutter2HostError {
  MockBinaryMessenger* binaryMessenger = [[MockBinaryMessenger alloc] init];
  MockApi2Host* mockApi2Host = [[MockApi2Host alloc] init];
  Api2HostSetup(binaryMessenger, mockApi2Host);
  NSString* channelName = @"dev.flutter.pigeon.Api2Host.calculate";
  XCTAssertNotNil(binaryMessenger.handlers[channelName]);

  Value* input = [[Value alloc] init];
  input.number = @(1);
  NSData* inputEncoded = [binaryMessenger.codec encode:[input toMap]];
  XCTestExpectation* expectation = [self expectationWithDescription:@"calculate callback"];
  binaryMessenger.handlers[channelName](inputEncoded, ^(NSData* data) {
    NSDictionary* outputMap = [binaryMessenger.codec decode:data];
    XCTAssertNotNil(outputMap[@"error"]);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
