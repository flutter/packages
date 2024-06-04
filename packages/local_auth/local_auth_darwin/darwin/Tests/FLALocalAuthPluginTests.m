// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import LocalAuthentication;
@import XCTest;
@import local_auth_darwin;

// Set a long timeout to avoid flake due to slow CI.
static const NSTimeInterval kTimeout = 30.0;

/**
 * A context factory that returns preset contexts.
 */
@interface StubAuthContextFactory : NSObject <FLADAuthContextFactory>
@property(copy, nonatomic) NSMutableArray<id<FLADAuthContext>> *contexts;
- (instancetype)initWithContexts:(NSArray<id<FLADAuthContext>> *)contexts;
@end

@implementation StubAuthContextFactory

- (instancetype)initWithContexts:(NSArray<id<FLADAuthContext>> *)contexts {
  self = [super init];
  if (self) {
    _contexts = [contexts mutableCopy];
  }
  return self;
}

- (id<FLADAuthContext>)createAuthContext {
  NSAssert(self.contexts.count > 0, @"Insufficient test contexts provided");
  id<FLADAuthContext> context = [self.contexts firstObject];
  [self.contexts removeObjectAtIndex:0];
  return context;
}

@end

@interface StubAuthContext : NSObject <FLADAuthContext>
/// Whether calls to this stub are expected to be for biometric authentication.
///
/// While this object could be set up to return different values for different policies, in
/// practice only one policy is needed by any given test, so this just allows asserting that the
/// code is calling with the intended policy.
@property(nonatomic) BOOL expectBiometrics;
/// The value to return from canEvaluatePolicy.
@property(nonatomic) BOOL canEvaluateResponse;
/// The error to return from canEvaluatePolicy.
@property(nonatomic) NSError *canEvaluateError;
/// The value to return from evaluatePolicy:error:.
@property(nonatomic) BOOL evaluateResponse;
/// The error to return from evaluatePolicy:error:.
@property(nonatomic) NSError *evaluateError;

// Overridden as read-write to allow stubbing.
@property(nonatomic, readwrite) LABiometryType biometryType;
@end

@implementation StubAuthContext
@synthesize localizedFallbackTitle;

- (BOOL)canEvaluatePolicy:(LAPolicy)policy
                    error:(NSError *__autoreleasing _Nullable *_Nullable)error {
  XCTAssertEqual(policy, self.expectBiometrics ? LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                               : LAPolicyDeviceOwnerAuthentication);
  if (error) {
    *error = self.canEvaluateError;
  }
  return self.canEvaluateResponse;
}

- (void)evaluatePolicy:(LAPolicy)policy
       localizedReason:(nonnull NSString *)localizedReason
                 reply:(nonnull void (^)(BOOL, NSError *_Nullable))reply {
  XCTAssertEqual(policy, self.expectBiometrics ? LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                               : LAPolicyDeviceOwnerAuthentication);
  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
    reply(self.evaluateResponse, self.evaluateError);
  });
}

@end

#pragma mark -

@interface FLALocalAuthPluginTests : XCTestCase
@end

@implementation FLALocalAuthPluginTests

- (void)setUp {
  self.continueAfterFailure = NO;
}

- (void)testSuccessfullAuthWithBiometrics {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateResponse = YES;

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:YES
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertTrue([NSThread isMainThread]);
                         XCTAssertEqual(resultDetails.result, FLADAuthResultSuccess);
                         XCTAssertNil(error);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testSuccessfullAuthWithoutBiometrics {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateResponse = YES;

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:NO
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertTrue([NSThread isMainThread]);
                         XCTAssertEqual(resultDetails.result, FLADAuthResultSuccess);
                         XCTAssertNil(error);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testFailedAuthWithBiometrics {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateError = [NSError errorWithDomain:@"error"
                                                      code:LAErrorAuthenticationFailed
                                                  userInfo:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:YES
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertTrue([NSThread isMainThread]);
                         // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
                         // behavior, so is preserved as part of the migration, but a failed
                         // authentication should return failure, not an error that results in a
                         // PlatformException.
                         XCTAssertEqual(resultDetails.result, FLADAuthResultErrorNotAvailable);
                         XCTAssertNil(error);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testFailedWithUnknownErrorCode {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateError = [NSError errorWithDomain:@"error" code:99 userInfo:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:NO
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertTrue([NSThread isMainThread]);
                         XCTAssertEqual(resultDetails.result, FLADAuthResultErrorNotAvailable);
                         XCTAssertNil(error);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testSystemCancelledWithoutStickyAuth {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateError = [NSError errorWithDomain:@"error"
                                                      code:LAErrorSystemCancel
                                                  userInfo:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:NO
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertTrue([NSThread isMainThread]);
                         XCTAssertEqual(resultDetails.result, FLADAuthResultFailure);
                         XCTAssertNil(error);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testFailedAuthWithoutBiometrics {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateError = [NSError errorWithDomain:@"error"
                                                      code:LAErrorAuthenticationFailed
                                                  userInfo:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:NO
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertTrue([NSThread isMainThread]);
                         // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
                         // behavior, so is preserved as part of the migration, but a failed
                         // authentication should return failure, not an error that results in a
                         // PlatformException.
                         XCTAssertEqual(resultDetails.result, FLADAuthResultErrorNotAvailable);
                         XCTAssertNil(error);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testLocalizedFallbackTitle {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  strings.localizedFallbackTitle = @"a title";
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateResponse = YES;

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:NO
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertEqual(stubAuthContext.localizedFallbackTitle,
                                        strings.localizedFallbackTitle);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testSkippedLocalizedFallbackTitle {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FLADAuthStrings *strings = [self createAuthStrings];
  strings.localizedFallbackTitle = nil;
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.evaluateResponse = YES;

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result is called"];
  [plugin authenticateWithOptions:[FLADAuthOptions makeWithBiometricOnly:NO
                                                                  sticky:NO
                                                         useErrorDialogs:NO]
                          strings:strings
                       completion:^(FLADAuthResultDetails *_Nullable resultDetails,
                                    FlutterError *_Nullable error) {
                         XCTAssertNil(stubAuthContext.localizedFallbackTitle);
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:kTimeout handler:nil];
}

- (void)testDeviceSupportsBiometrics_withEnrolledHardware {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = YES;

  FlutterError *error;
  NSNumber *result = [plugin deviceCanSupportBiometricsWithError:&error];
  XCTAssertTrue([result boolValue]);
  XCTAssertNil(error);
}

- (void)testDeviceSupportsBiometrics_withNonEnrolledHardware {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = NO;
  stubAuthContext.canEvaluateError = [NSError errorWithDomain:@"error"
                                                         code:LAErrorBiometryNotEnrolled
                                                     userInfo:nil];

  FlutterError *error;
  NSNumber *result = [plugin deviceCanSupportBiometricsWithError:&error];
  XCTAssertTrue([result boolValue]);
  XCTAssertNil(error);
}

- (void)testDeviceSupportsBiometrics_withNoBiometricHardware {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = NO;
  stubAuthContext.canEvaluateError = [NSError errorWithDomain:@"error" code:0 userInfo:nil];

  FlutterError *error;
  NSNumber *result = [plugin deviceCanSupportBiometricsWithError:&error];
  XCTAssertFalse([result boolValue]);
  XCTAssertNil(error);
}

- (void)testGetEnrolledBiometricsWithFaceID {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.biometryType = LABiometryTypeFaceID;

  FlutterError *error;
  NSArray<FLADAuthBiometricWrapper *> *result = [plugin getEnrolledBiometricsWithError:&error];
  XCTAssertEqual([result count], 1);
  XCTAssertEqual(result[0].value, FLADAuthBiometricFace);
  XCTAssertNil(error);
}

- (void)testGetEnrolledBiometricsWithTouchID {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = YES;
  stubAuthContext.biometryType = LABiometryTypeTouchID;

  FlutterError *error;
  NSArray<FLADAuthBiometricWrapper *> *result = [plugin getEnrolledBiometricsWithError:&error];
  XCTAssertEqual([result count], 1);
  XCTAssertEqual(result[0].value, FLADAuthBiometricFingerprint);
  XCTAssertNil(error);
}

- (void)testGetEnrolledBiometricsWithoutEnrolledHardware {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  stubAuthContext.expectBiometrics = YES;
  stubAuthContext.canEvaluateResponse = NO;
  stubAuthContext.canEvaluateError = [NSError errorWithDomain:@"error"
                                                         code:LAErrorBiometryNotEnrolled
                                                     userInfo:nil];

  FlutterError *error;
  NSArray<FLADAuthBiometricWrapper *> *result = [plugin getEnrolledBiometricsWithError:&error];
  XCTAssertEqual([result count], 0);
  XCTAssertNil(error);
}

- (void)testIsDeviceSupportedHandlesSupported {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  stubAuthContext.canEvaluateResponse = YES;
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FlutterError *error;
  NSNumber *result = [plugin isDeviceSupportedWithError:&error];
  XCTAssertTrue([result boolValue]);
  XCTAssertNil(error);
}

- (void)testIsDeviceSupportedHandlesUnsupported {
  StubAuthContext *stubAuthContext = [[StubAuthContext alloc] init];
  stubAuthContext.canEvaluateResponse = NO;
  FLALocalAuthPlugin *plugin = [[FLALocalAuthPlugin alloc]
      initWithContextFactory:[[StubAuthContextFactory alloc]
                                 initWithContexts:@[ stubAuthContext ]]];

  FlutterError *error;
  NSNumber *result = [plugin isDeviceSupportedWithError:&error];
  XCTAssertFalse([result boolValue]);
  XCTAssertNil(error);
}

// Creates an FLADAuthStrings with placeholder values.
- (FLADAuthStrings *)createAuthStrings {
  return [FLADAuthStrings makeWithReason:@"a reason"
                                 lockOut:@"locked out"
                      goToSettingsButton:@"Go To Settings"
                 goToSettingsDescription:@"Settings"
                            cancelButton:@"Cancel"
                  localizedFallbackTitle:nil];
}
@end
