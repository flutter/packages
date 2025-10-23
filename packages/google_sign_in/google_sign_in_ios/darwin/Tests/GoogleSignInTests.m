// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <TargetConditionals.h>
#if TARGET_OS_OSX
@import FlutterMacOS;
#else
@import Flutter;
#endif

@import XCTest;
@import google_sign_in_ios;
#if __has_include(<google_sign_in_ios/google_sign_in_ios-umbrella.h>)
@import google_sign_in_ios.Test;
#endif
@import GoogleSignIn;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

/// Test implementation of @c FSIGIDSignIn.
@interface TestSignIn : NSObject <FSIGIDSignIn>

// To cause methods to throw an exception.
@property(nonatomic, nullable) NSException *exception;

// Results to use in completion callbacks.
@property(nonatomic, nullable) NSObject<FSIGIDGoogleUser> *user;
@property(nonatomic, nullable) NSError *error;
@property(nonatomic, nullable) NSObject<FSIGIDSignInResult> *signInResult;

// Passed parameters.
@property(nonatomic, copy, nullable) NSString *hint;
@property(nonatomic, copy, nullable) NSArray<NSString *> *additionalScopes;
@property(nonatomic, copy, nullable) NSString *nonce;
#if TARGET_OS_IOS || TARGET_OS_MACCATALYST
@property(nonatomic, nullable) UIViewController *presentingViewController;
#else
@property(nonatomic, nullable) NSWindow *presentingWindow;
#endif

/// Whether @c signOut was called.
@property(nonatomic) BOOL signOutCalled;

@end

@implementation TestSignIn
@synthesize configuration;

- (BOOL)handleURL:(NSURL *)url {
  return YES;
}

- (void)restorePreviousSignInWithCompletion:
    (nullable void (^)(NSObject<FSIGIDGoogleUser> *_Nullable user,
                       NSError *_Nullable error))completion {
  if (self.exception) {
    @throw self.exception;
  }
  if (completion) {
    completion(self.user, self.user ? nil : self.error);
  }
}

- (void)signOut {
  self.signOutCalled = YES;
}

- (void)disconnectWithCompletion:(nullable void (^)(NSError *_Nullable error))completion {
  if (self.exception) {
    @throw self.exception;
  }
  if (completion) {
    completion(self.error);
  }
}

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST
- (void)signInWithPresentingViewController:(UIViewController *)presentingViewController
                                      hint:(nullable NSString *)hint
                          additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                                     nonce:(nullable NSString *)nonce
                                completion:(nullable void (^)(
                                               NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                               NSError *_Nullable error))completion {
  if (self.exception) {
    @throw self.exception;
  }
  self.presentingViewController = presentingViewController;
  self.hint = hint;
  self.additionalScopes = additionalScopes;
  self.nonce = nonce;
  if (completion) {
    completion(self.signInResult, self.signInResult ? nil : self.error);
  }
}
#else
- (void)signInWithPresentingWindow:(NSWindow *)presentingWindow
                              hint:(nullable NSString *)hint
                  additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                             nonce:(nullable NSString *)nonce
                        completion:
                            (nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                               NSError *_Nullable error))completion {
  if (self.exception) {
    @throw self.exception;
  }
  self.presentingWindow = presentingWindow;
  self.hint = hint;
  self.additionalScopes = additionalScopes;
  self.nonce = nonce;
  if (completion) {
    completion(self.signInResult, self.signInResult ? nil : self.error);
  }
}
#endif

@end

@interface FLTGoogleSignInPluginTest : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;
@property(strong, nonatomic) NSObject<FlutterPluginRegistrar> *mockPluginRegistrar;
@property(strong, nonatomic) FLTGoogleSignInPlugin *plugin;
@property(strong, nonatomic) TestSignIn *fakeSignIn;
@property(strong, nonatomic) NSDictionary<NSString *, id> *googleServiceInfo;

@end

@implementation FLTGoogleSignInPluginTest

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  self.mockPluginRegistrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  self.fakeSignIn = [[TestSignIn alloc] init];

  OCMStub(self.mockPluginRegistrar.messenger).andReturn(self.mockBinaryMessenger);
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.fakeSignIn
                                                    registrar:self.mockPluginRegistrar];
  [FLTGoogleSignInPlugin registerWithRegistrar:self.mockPluginRegistrar];

  NSString *plistPath =
      [[NSBundle bundleForClass:[self class]] pathForResource:@"GoogleService-Info"
                                                       ofType:@"plist"];
  if (plistPath) {
    self.googleServiceInfo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
  }
}

- (void)testSignOut {
  FlutterError *error;
  [self.plugin signOutWithError:&error];
  XCTAssertTrue(self.fakeSignIn.signOutCalled);
  XCTAssertNil(error);
}

- (void)testDisconnect {
  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin disconnectWithCompletion:^(FlutterError *error) {
    XCTAssertNil(error);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Configure

- (void)testInitNoClientIdNoError {
  // Init plugin without GoogleService-Info.plist.
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.fakeSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:nil];

  // init call does not provide a clientId.
  FSIPlatformConfigurationParams *params = [FSIPlatformConfigurationParams makeWithClientId:nil
                                                                             serverClientId:nil
                                                                               hostedDomain:nil];

  FlutterError *error;
  [self.plugin configureWithParameters:params error:&error];
  XCTAssertNil(error);
}

- (void)testInitGoogleServiceInfoPlist {
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.fakeSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:self.googleServiceInfo];
  FSIPlatformConfigurationParams *params =
      [FSIPlatformConfigurationParams makeWithClientId:nil
                                        serverClientId:nil
                                          hostedDomain:@"example.com"];

  FlutterError *error;
  [self.plugin configureWithParameters:params error:&error];
  XCTAssertNil(error);
  XCTAssertEqualObjects(self.fakeSignIn.configuration.hostedDomain, @"example.com");
  // Set in example app GoogleService-Info.plist.
  XCTAssertEqualObjects(
      self.fakeSignIn.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");
  XCTAssertEqualObjects(self.fakeSignIn.configuration.serverClientID, @"YOUR_SERVER_CLIENT_ID");
}

- (void)testInitDynamicClientIdNullDomain {
  // Init plugin without GoogleService-Info.plist.
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.fakeSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:nil];

  FSIPlatformConfigurationParams *params =
      [FSIPlatformConfigurationParams makeWithClientId:@"mockClientId"
                                        serverClientId:nil
                                          hostedDomain:nil];

  FlutterError *error;
  [self.plugin configureWithParameters:params error:&error];
  XCTAssertNil(error);
  XCTAssertNil(self.fakeSignIn.configuration.hostedDomain);
  XCTAssertEqualObjects(self.fakeSignIn.configuration.clientID, @"mockClientId");
  XCTAssertNil(self.fakeSignIn.configuration.serverClientID);
}

- (void)testInitDynamicServerClientIdNullDomain {
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.fakeSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:self.googleServiceInfo];
  FSIPlatformConfigurationParams *params =
      [FSIPlatformConfigurationParams makeWithClientId:nil
                                        serverClientId:@"mockServerClientId"
                                          hostedDomain:nil];

  FlutterError *error;
  [self.plugin configureWithParameters:params error:&error];
  XCTAssertNil(error);
  XCTAssertNil(self.fakeSignIn.configuration.hostedDomain);
  // Set in example app GoogleService-Info.plist.
  XCTAssertEqualObjects(
      self.fakeSignIn.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");
  // Overridden by params.
  XCTAssertEqualObjects(self.fakeSignIn.configuration.serverClientID, @"mockServerClientId");
}

- (void)testInitInfoPlist {
  FSIPlatformConfigurationParams *params =
      [FSIPlatformConfigurationParams makeWithClientId:nil
                                        serverClientId:nil
                                          hostedDomain:@"example.com"];

  FlutterError *error;
  [self.plugin configureWithParameters:params error:&error];
  XCTAssertNil(error);
  // No configuration should be set, allowing the SDK to use its default behavior
  // (which is to load configuration information from Info.plist).
  XCTAssertNil(self.fakeSignIn.configuration);
}

#pragma mark - restorePreviousSignIn

- (void)testSignInSilently {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  self.fakeSignIn.user = mockUser;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin restorePreviousSignInWithCompletion:^(FSISignInResult *result, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertNil(result.error);
    XCTAssertNotNil(result.success);
    FSIUserData *user = result.success.user;
    XCTAssertNil(user.displayName);
    XCTAssertNil(user.email);
    XCTAssertEqualObjects(user.userId, @"mockID");
    XCTAssertNil(user.photoUrl);
    XCTAssertNil(result.success.accessToken);
    XCTAssertNil(result.success.serverAuthCode);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRestorePreviousSignInWithError {
  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                      userInfo:nil];
  self.fakeSignIn.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin restorePreviousSignInWithCompletion:^(FSISignInResult *result, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertNil(result.success);
    XCTAssertEqual(result.error.type, FSIGoogleSignInErrorCodeNoAuthInKeychain);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - signIn

- (void)testSignIn {
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.fakeSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:self.googleServiceInfo];
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  id mockUserProfile = OCMClassMock([GIDProfileData class]);
  OCMStub([mockUserProfile name]).andReturn(@"mockDisplay");
  OCMStub([mockUserProfile email]).andReturn(@"mock@example.com");
  OCMStub([mockUserProfile hasImage]).andReturn(YES);
  OCMStub([mockUserProfile imageURLWithDimension:1337])
      .andReturn([NSURL URLWithString:@"https://example.com/profile.png"]);

  NSString *accessToken = @"mockAccessToken";
  NSString *serverAuthCode = @"mockAuthCode";
  OCMStub([mockUser profile]).andReturn(mockUserProfile);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  id mockAccessToken = OCMClassMock([GIDToken class]);
  OCMStub([mockAccessToken tokenString]).andReturn(accessToken);
  OCMStub([mockUser accessToken]).andReturn(mockAccessToken);

  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);
  OCMStub([mockSignInResult serverAuthCode]).andReturn(serverAuthCode);

  self.fakeSignIn.signInResult = mockSignInResult;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithScopeHint:@[]
                             nonce:nil
                        completion:^(FSISignInResult *result, FlutterError *error) {
                          XCTAssertNil(error);
                          FSIUserData *user = result.success.user;
                          XCTAssertEqualObjects(user.displayName, @"mockDisplay");
                          XCTAssertEqualObjects(user.email, @"mock@example.com");
                          XCTAssertEqualObjects(user.userId, @"mockID");
                          XCTAssertEqualObjects(user.photoUrl, @"https://example.com/profile.png");
                          XCTAssertEqualObjects(result.success.accessToken, accessToken);
                          XCTAssertEqualObjects(result.success.serverAuthCode, serverAuthCode);
                          [expectation fulfill];
                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInWithScopeHint {
  FlutterError *initializationError;
  [self.plugin configureWithParameters:[FSIPlatformConfigurationParams makeWithClientId:nil
                                                                         serverClientId:nil
                                                                           hostedDomain:nil]
                                 error:&initializationError];
  XCTAssertNil(initializationError);

  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  NSArray<NSString *> *requestedScopes = @[ @"scope1", @"scope2" ];
  self.fakeSignIn.signInResult = mockSignInResult;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithScopeHint:requestedScopes
                             nonce:nil
                        completion:^(FSISignInResult *result, FlutterError *error) {
                          XCTAssertNil(error);
                          XCTAssertNil(result.error);
                          XCTAssertEqualObjects(result.success.user.userId, @"mockID");
                          [expectation fulfill];
                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];

  XCTAssertTrue([[NSSet setWithArray:self.fakeSignIn.additionalScopes]
      isEqualToSet:[NSSet setWithArray:requestedScopes]]);
}

- (void)testSignInWithNonce {
  FlutterError *initializationError;
  [self.plugin configureWithParameters:[FSIPlatformConfigurationParams makeWithClientId:nil
                                                                         serverClientId:nil
                                                                           hostedDomain:nil]
                                 error:&initializationError];
  XCTAssertNil(initializationError);

  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  NSString *nonce = @"A nonce";
  self.fakeSignIn.signInResult = mockSignInResult;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithScopeHint:@[]
                             nonce:nonce
                        completion:^(FSISignInResult *result, FlutterError *error) {
                          XCTAssertNil(error);
                          XCTAssertNil(result.error);
                          XCTAssertEqualObjects(result.success.user.userId, @"mockID");
                          [expectation fulfill];
                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];

  XCTAssertEqualObjects(self.fakeSignIn.nonce, nonce);
}

- (void)testSignInAlreadyGranted {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  self.fakeSignIn.signInResult = mockSignInResult;

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeScopesAlreadyGranted
                                      userInfo:nil];
  self.fakeSignIn.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithScopeHint:@[]
                             nonce:nil
                        completion:^(FSISignInResult *result, FlutterError *error) {
                          XCTAssertNil(error);
                          XCTAssertNil(result.error);
                          XCTAssertEqualObjects(result.success.user.userId, @"mockID");
                          [expectation fulfill];
                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInError {
  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeCanceled
                                      userInfo:nil];
  self.fakeSignIn.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithScopeHint:@[]
                             nonce:nil
                        completion:^(FSISignInResult *result, FlutterError *error) {
                          // Known errors from the SDK are returned as structured data, not
                          // FlutterError.
                          XCTAssertNil(error);
                          XCTAssertNil(result.success);
                          XCTAssertEqual(result.error.type, FSIGoogleSignInErrorCodeCanceled);
                          [expectation fulfill];
                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInExceptionReturnsError {
  self.fakeSignIn.exception = [NSException exceptionWithName:@"MockName"
                                                      reason:@"MockReason"
                                                    userInfo:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithScopeHint:@[]
                             nonce:nil
                        completion:^(FSISignInResult *result, FlutterError *error) {
                          // Unexpected errors, such as runtime exceptions, are returned as
                          // FlutterError.
                          XCTAssertNil(result);
                          XCTAssertEqualObjects(error.code, @"google_sign_in");
                          XCTAssertEqualObjects(error.message, @"MockReason");
                          XCTAssertEqualObjects(error.details, @"MockName");
                          [expectation fulfill];
                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - refreshedAuthorizationTokens

- (void)testRefreshTokens {
  id mockUser = [self signedInMockUser];
  NSString *userIdentifier = ((GIDGoogleUser *)mockUser).userID;
  id mockUserResponse = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUserResponse userID]).andReturn(userIdentifier);

  id mockIdToken = OCMClassMock([GIDToken class]);
  OCMStub([mockIdToken tokenString]).andReturn(@"mockIdToken");
  OCMStub([mockUserResponse idToken]).andReturn(mockIdToken);

  id mockAccessToken = OCMClassMock([GIDToken class]);
  OCMStub([mockAccessToken tokenString]).andReturn(@"mockAccessToken");
  OCMStub([mockUserResponse accessToken]).andReturn(mockAccessToken);

  [[mockUser stub]
      refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:mockUserResponse,
                                                                      [NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin
      refreshedAuthorizationTokensForUser:userIdentifier
                               completion:^(FSISignInResult *result, FlutterError *error) {
                                 XCTAssertNil(error);
                                 XCTAssertNil(result.error);
                                 XCTAssertEqualObjects(result.success.user.idToken, @"mockIdToken");
                                 XCTAssertEqualObjects(result.success.accessToken,
                                                       @"mockAccessToken");
                                 [expectation fulfill];
                               }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRefreshTokensUnkownUser {
  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin
      refreshedAuthorizationTokensForUser:@"unknownUser"
                               completion:^(FSISignInResult *result, FlutterError *error) {
                                 XCTAssertNil(error);
                                 XCTAssertNil(result.success);
                                 XCTAssertEqual(result.error.type,
                                                FSIGoogleSignInErrorCodeUserMismatch);
                                 XCTAssertEqualObjects(result.error.message,
                                                       @"The user is no longer signed in.");
                                 [expectation fulfill];
                               }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRefreshTokensNoAuthKeychainError {
  id mockUser = [self signedInMockUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                      userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:((GIDGoogleUser *)mockUser).userID
                                        completion:^(FSISignInResult *result, FlutterError *error) {
                                          XCTAssertNil(error);
                                          XCTAssertNil(result.success);
                                          XCTAssertEqual(result.error.type,
                                                         FSIGoogleSignInErrorCodeNoAuthInKeychain);
                                          [expectation fulfill];
                                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRefreshTokensCancelledError {
  id mockUser = [self signedInMockUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeCanceled
                                      userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:((GIDGoogleUser *)mockUser).userID
                                        completion:^(FSISignInResult *result, FlutterError *error) {
                                          XCTAssertNil(error);
                                          XCTAssertNil(result.success);
                                          XCTAssertEqual(result.error.type,
                                                         FSIGoogleSignInErrorCodeCanceled);
                                          [expectation fulfill];
                                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRefreshTokensURLError {
  id mockUser = [self signedInMockUser];

  NSError *sdkError = [NSError errorWithDomain:NSURLErrorDomain
                                          code:NSURLErrorTimedOut
                                      userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:((GIDGoogleUser *)mockUser).userID
                                        completion:^(FSISignInResult *result, FlutterError *error) {
                                          XCTAssertNil(result.error);
                                          XCTAssertNil(result.success);
                                          NSString *expectedCode = [NSString
                                              stringWithFormat:@"%@: %ld", NSURLErrorDomain,
                                                               NSURLErrorTimedOut];
                                          XCTAssertEqualObjects(error.code, expectedCode);
                                          [expectation fulfill];
                                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRefreshTokensUnknownError {
  id mockUser = [self signedInMockUser];

  NSError *sdkError = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:((GIDGoogleUser *)mockUser).userID
                                        completion:^(FSISignInResult *result, FlutterError *error) {
                                          XCTAssertNil(result.success);
                                          XCTAssertEqualObjects(error.code, @"BogusDomain: 42");
                                          [expectation fulfill];
                                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - addScopes

- (void)testRequestScopesResultErrorIfNotSignedIn {
  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:@"unknownUser"
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(error);
                XCTAssertNil(result.success);
                XCTAssertEqual(result.error.type, FSIGoogleSignInErrorCodeUserMismatch);
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesIfNoMissingScope {
  id mockUser = [self signedInMockUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeScopesAlreadyGranted
                                      userInfo:nil];
  [self configureMock:[mockUser stub]
         forAddScopes:@[ @"mockScope1" ]
           completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:((GIDGoogleUser *)mockUser).userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(error);
                XCTAssertNil(result.success);
                XCTAssertEqual(result.error.type, FSIGoogleSignInErrorCodeScopesAlreadyGranted);
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesResultErrorIfMismatchingUser {
  id mockUser = [self signedInMockUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeMismatchWithCurrentUser
                                      userInfo:nil];
  [self configureMock:[mockUser stub]
         forAddScopes:@[ @"mockScope1" ]
           completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:((GIDGoogleUser *)mockUser).userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(error);
                XCTAssertNil(result.success);
                XCTAssertEqual(result.error.type, FSIGoogleSignInErrorCodeUserMismatch);
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesWithUnknownError {
  id mockUser = [self signedInMockUser];

  NSError *sdkError = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [self configureMock:[mockUser stub]
         forAddScopes:@[ @"mockScope1" ]
           completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:((GIDGoogleUser *)mockUser).userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(result);
                XCTAssertEqualObjects(error.code, @"BogusDomain: 42");
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesException {
  id mockUser = [self signedInMockUser];

  OCMExpect([self configureMock:mockUser forAddScopes:@[] completion:OCMOCK_ANY])
      .andThrow([NSException exceptionWithName:@"MockName" reason:@"MockReason" userInfo:nil]);

  [self.plugin addScopes:@[]
                 forUser:((GIDGoogleUser *)mockUser).userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(result);
                XCTAssertEqualObjects(error.code, @"request_scopes");
                XCTAssertEqualObjects(error.message, @"MockReason");
                XCTAssertEqualObjects(error.details, @"MockName");
              }];
}

#pragma mark - Utils

- (id)signedInMockUser {
  NSString *identifier = @"mockID";
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(identifier);
  self.plugin.usersByIdentifier[identifier] = mockUser;
  return mockUser;
}

- (void)configureMock:(id)mock
         forAddScopes:(NSArray<NSString *> *)scopes
           completion:(nullable void (^)(GIDSignInResult *_Nullable signInResult,
                                         NSError *_Nullable error))completion {
#if TARGET_OS_OSX
  [mock addScopes:scopes presentingWindow:OCMOCK_ANY completion:completion];
#else
  [mock addScopes:scopes presentingViewController:OCMOCK_ANY completion:completion];
#endif
}

@end
