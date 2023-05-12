// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import LocalAuthentication;
@import XCTest;
@import local_auth_ios;

#import <OCMock/OCMock.h>

// Set a long timeout to avoid flake due to slow CI.
static const NSTimeInterval kTimeout = 30.0;

/**
 * A context factory that returns preset contexts.
 */
@interface StubAuthContextFactory : NSObject <FLAAuthContextFactory>
@property(copy, nonatomic) NSMutableArray *contexts;
- (instancetype)initWithContexts:(NSArray *)contexts;
@end

@implementation StubAuthContextFactory

- (instancetype)initWithContexts:(NSArray *)contexts {
  self = [super init];
  if (self) {
    _contexts = [contexts mutableCopy];
  }
  return self;
}

- (LAContext *)createAuthContext {
  NSAssert(self.contexts.count > 0, @"Insufficient test contexts provided");
  LAContext *context = [self.contexts firstObject];
  [self.contexts removeObjectAtIndex:0];
  return context;
}

@end

#pragma mark -

@interface FLTLocalAuthPluginTests : XCTestCase
@end

@implementation FLTLocalAuthPluginTests

- (void)setUp {
  self.continueAfterFailure = NO;
}

- (void)testSuccessfullAuthWithBiometrics {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  NSString *reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(YES, nil);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(YES),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertTrue([result boolValue]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testSuccessfullAuthWithoutBiometrics {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString *reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(YES, nil);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(NO),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertTrue([result boolValue]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testFailedAuthWithBiometrics {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  NSString *reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(NO, [NSError errorWithDomain:@"error" code:LAErrorAuthenticationFailed userInfo:nil]);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(YES),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[FlutterError class]]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testFailedWithUnknownErrorCode {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString *reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(NO, [NSError errorWithDomain:@"error" code:99 userInfo:nil]);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(NO),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[FlutterError class]]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testSystemCancelledWithoutStickyAuth {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString *reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(NO, [NSError errorWithDomain:@"error" code:LAErrorSystemCancel userInfo:nil]);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(NO),
                                                                @"localizedReason" : reason,
                                                                @"stickyAuth" : @(NO)
                                                              }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertFalse([result boolValue]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testFailedAuthWithoutBiometrics {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString *reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(NO, [NSError errorWithDomain:@"error" code:LAErrorAuthenticationFailed userInfo:nil]);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(NO),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[FlutterError class]]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testLocalizedFallbackTitle {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString *reason = @"a reason";
  NSString *localizedFallbackTitle = @"a title";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(YES, nil);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                        arguments:@{
                                          @"biometricOnly" : @(NO),
                                          @"localizedReason" : reason,
                                          @"localizedFallbackTitle" : localizedFallbackTitle,
                                        }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      OCMVerify([mockAuthContext setLocalizedFallbackTitle:localizedFallbackTitle]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testSkippedLocalizedFallbackTitle {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString *reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation *) = ^(NSInvocation *invocation) {
    void (^reply)(BOOL, NSError *);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(YES, nil);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(NO),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      OCMVerify([mockAuthContext setLocalizedFallbackTitle:nil]);
                      [expectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testDeviceSupportsBiometrics_withEnrolledHardware {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"deviceSupportsBiometrics"
                                                              arguments:@{}];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertTrue([result boolValue]);
                      [expectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testDeviceSupportsBiometrics_withNonEnrolledHardware {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  void (^canEvaluatePolicyHandler)(NSInvocation *) = ^(NSInvocation *invocation) {
    // Write error
    NSError *__autoreleasing *authError;
    [invocation getArgument:&authError atIndex:3];
    *authError = [NSError errorWithDomain:@"error" code:LAErrorBiometryNotEnrolled userInfo:nil];
    // Write return value
    BOOL returnValue = NO;
    NSValue *nsReturnValue = [NSValue valueWithBytes:&returnValue objCType:@encode(BOOL)];
    [invocation setReturnValue:&nsReturnValue];
  };
  OCMStub([mockAuthContext canEvaluatePolicy:policy
                                       error:(NSError * __autoreleasing *)[OCMArg anyPointer]])
      .andDo(canEvaluatePolicyHandler);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"deviceSupportsBiometrics"
                                                              arguments:@{}];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertTrue([result boolValue]);
                      [expectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testDeviceSupportsBiometrics_withNoBiometricHardware {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  void (^canEvaluatePolicyHandler)(NSInvocation *) = ^(NSInvocation *invocation) {
    // Write error
    NSError *__autoreleasing *authError;
    [invocation getArgument:&authError atIndex:3];
    *authError = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
    // Write return value
    BOOL returnValue = NO;
    NSValue *nsReturnValue = [NSValue valueWithBytes:&returnValue objCType:@encode(BOOL)];
    [invocation setReturnValue:&nsReturnValue];
  };
  OCMStub([mockAuthContext canEvaluatePolicy:policy
                                       error:(NSError * __autoreleasing *)[OCMArg anyPointer]])
      .andDo(canEvaluatePolicyHandler);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"deviceSupportsBiometrics"
                                                              arguments:@{}];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertFalse([result boolValue]);
                      [expectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testGetEnrolledBiometrics_withFaceID {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);
  OCMStub([mockAuthContext biometryType]).andReturn(LABiometryTypeFaceID);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"getEnrolledBiometrics"
                                                              arguments:@{}];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSArray class]]);
                      XCTAssertEqual([result count], 1);
                      XCTAssertEqualObjects(result[0], @"face");
                      [expectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testGetEnrolledBiometrics_withTouchID {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);
  OCMStub([mockAuthContext biometryType]).andReturn(LABiometryTypeTouchID);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"getEnrolledBiometrics"
                                                              arguments:@{}];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSArray class]]);
                      XCTAssertEqual([result count], 1);
                      XCTAssertEqualObjects(result[0], @"fingerprint");
                      [expectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testGetEnrolledBiometrics_withoutEnrolledHardware {
  id mockAuthContext = OCMClassMock([LAContext class]);
  FLTLocalAuthPlugin *plugin = [[FLTLocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ mockAuthContext ]]];

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  void (^canEvaluatePolicyHandler)(NSInvocation *) = ^(NSInvocation *invocation) {
    // Write error
    NSError *__autoreleasing *authError;
    [invocation getArgument:&authError atIndex:3];
    *authError = [NSError errorWithDomain:@"error" code:LAErrorBiometryNotEnrolled userInfo:nil];
    // Write return value
    BOOL returnValue = NO;
    NSValue *nsReturnValue = [NSValue valueWithBytes:&returnValue objCType:@encode(BOOL)];
    [invocation setReturnValue:&nsReturnValue];
  };
  OCMStub([mockAuthContext canEvaluatePolicy:policy
                                       error:(NSError * __autoreleasing *)[OCMArg anyPointer]])
      .andDo(canEvaluatePolicyHandler);

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"getEnrolledBiometrics"
                                                              arguments:@{}];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      XCTAssertTrue([result isKindOfClass:[NSArray class]]);
                      XCTAssertEqual([result count], 0);
                      [expectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}
@end
