// Copyright 2013 The Flutter Authors. All rights reserved.
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

@interface FLTGoogleSignInPluginTest : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;
@property(strong, nonatomic) NSObject<FlutterPluginRegistrar> *mockPluginRegistrar;
@property(strong, nonatomic) FLTGoogleSignInPlugin *plugin;
@property(strong, nonatomic) id mockSignIn;
@property(strong, nonatomic) NSDictionary<NSString *, id> *googleServiceInfo;

@end

@implementation FLTGoogleSignInPluginTest

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  self.mockPluginRegistrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  id mockSignIn = OCMClassMock([GIDSignIn class]);
  self.mockSignIn = mockSignIn;

  OCMStub(self.mockPluginRegistrar.messenger).andReturn(self.mockBinaryMessenger);
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:mockSignIn
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
  OCMVerify([self.mockSignIn signOut]);
  XCTAssertNil(error);
}

- (void)testDisconnect {
  [(GIDSignIn *)[self.mockSignIn stub]
      disconnectWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin disconnectWithCompletion:^(FlutterError *error) {
    XCTAssertNil(error);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testDisconnectIgnoresError {
  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                      userInfo:nil];
  [(GIDSignIn *)[self.mockSignIn stub]
      disconnectWithCompletion:[OCMArg invokeBlockWithArgs:sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin disconnectWithCompletion:^(FlutterError *error) {
    XCTAssertNil(error);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Init

- (void)testInitNoClientIdNoError {
  // Init plugin without GoogleService-Info.plist.
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.mockSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:nil];

  // init call does not provide a clientId.
  FSIInitParams *params = [FSIInitParams makeWithScopes:@[]
                                           hostedDomain:nil
                                               clientId:nil
                                         serverClientId:nil];

  FlutterError *error;
  [self.plugin initializeSignInWithParameters:params error:&error];
  XCTAssertNil(error);
}

- (void)testInitGoogleServiceInfoPlist {
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.mockSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:self.googleServiceInfo];
  FSIInitParams *params = [FSIInitParams makeWithScopes:@[]
                                           hostedDomain:@"example.com"
                                               clientId:nil
                                         serverClientId:nil];

  FlutterError *initializationError;
  [self.plugin initializeSignInWithParameters:params error:&initializationError];
  XCTAssertNil(initializationError);

  // Initialization values used in the next sign in request.
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error){
  }];
  OCMVerify([self configureMock:self.mockSignIn
              forSignInWithHint:nil
               additionalScopes:OCMOCK_ANY
                     completion:OCMOCK_ANY]);

  XCTAssertEqualObjects(self.plugin.configuration.hostedDomain, @"example.com");
  // Set in example app GoogleService-Info.plist.
  XCTAssertEqualObjects(
      self.plugin.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");
  XCTAssertEqualObjects(self.plugin.configuration.serverClientID, @"YOUR_SERVER_CLIENT_ID");
}

- (void)testInitDynamicClientIdNullDomain {
  // Init plugin without GoogleService-Info.plist.
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.mockSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:nil];

  FSIInitParams *params = [FSIInitParams makeWithScopes:@[]
                                           hostedDomain:nil
                                               clientId:@"mockClientId"
                                         serverClientId:nil];

  FlutterError *initializationError;
  [self.plugin initializeSignInWithParameters:params error:&initializationError];
  XCTAssertNil(initializationError);

  // Initialization values used in the next sign in request.
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error){
  }];
  OCMVerify([self configureMock:self.mockSignIn
              forSignInWithHint:nil
               additionalScopes:OCMOCK_ANY
                     completion:OCMOCK_ANY]);

  XCTAssertEqualObjects(self.plugin.configuration.hostedDomain, nil);
  XCTAssertEqualObjects(self.plugin.configuration.clientID, @"mockClientId");
  XCTAssertEqualObjects(self.plugin.configuration.serverClientID, nil);
}

- (void)testInitDynamicServerClientIdNullDomain {
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.mockSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:self.googleServiceInfo];
  FSIInitParams *params = [FSIInitParams makeWithScopes:@[]
                                           hostedDomain:nil
                                               clientId:nil
                                         serverClientId:@"mockServerClientId"];
  FlutterError *initializationError;
  [self.plugin initializeSignInWithParameters:params error:&initializationError];
  XCTAssertNil(initializationError);

  // Initialization values used in the next sign in request.
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error){
  }];
  OCMVerify([self configureMock:self.mockSignIn
              forSignInWithHint:nil
               additionalScopes:OCMOCK_ANY
                     completion:OCMOCK_ANY]);

  XCTAssertEqualObjects(self.plugin.configuration.hostedDomain, nil);
  // Set in example app GoogleService-Info.plist.
  XCTAssertEqualObjects(
      self.plugin.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");
  XCTAssertEqualObjects(self.plugin.configuration.serverClientID, @"mockServerClientId");
}

- (void)testInitInfoPlist {
  FSIInitParams *params = [FSIInitParams makeWithScopes:@[ @"scope1" ]
                                           hostedDomain:@"example.com"
                                               clientId:nil
                                         serverClientId:nil];

  FlutterError *error;
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithRegistrar:self.mockPluginRegistrar];
  [self.plugin initializeSignInWithParameters:params error:&error];
  XCTAssertNil(error);
  XCTAssertNil(self.plugin.configuration);
  XCTAssertNotNil(self.plugin.requestedScopes);
  // Set in example app Info.plist.
  XCTAssertEqualObjects(
      self.plugin.signIn.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");
  XCTAssertEqualObjects(self.plugin.signIn.configuration.serverClientID, @"YOUR_SERVER_CLIENT_ID");
}

#pragma mark - Is signed in

- (void)testIsNotSignedIn {
  OCMStub([self.mockSignIn hasPreviousSignIn]).andReturn(NO);

  FlutterError *error;
  NSNumber *result = [self.plugin isSignedInWithError:&error];
  XCTAssertNil(error);
  XCTAssertFalse(result.boolValue);
}

- (void)testIsSignedIn {
  OCMStub([self.mockSignIn hasPreviousSignIn]).andReturn(YES);

  FlutterError *error;
  NSNumber *result = [self.plugin isSignedInWithError:&error];
  XCTAssertNil(error);
  XCTAssertTrue(result.boolValue);
}

#pragma mark - Sign in silently

- (void)testSignInSilently {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");

  [[self.mockSignIn stub]
      restorePreviousSignInWithCompletion:[OCMArg
                                              invokeBlockWithArgs:mockUser, [NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInSilentlyWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertNotNil(user);
    XCTAssertNil(user.displayName);
    XCTAssertNil(user.email);
    XCTAssertEqualObjects(user.userId, @"mockID");
    XCTAssertNil(user.photoUrl);
    XCTAssertNil(user.serverAuthCode);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInSilentlyWithError {
  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                      userInfo:nil];

  [[self.mockSignIn stub]
      restorePreviousSignInWithCompletion:[OCMArg
                                              invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInSilentlyWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(user);
    XCTAssertEqualObjects(error.code, @"sign_in_required");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Sign in

- (void)testSignIn {
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.mockSignIn
                                                    registrar:self.mockPluginRegistrar
                                      googleServiceProperties:self.googleServiceInfo];
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  id mockUserProfile = OCMClassMock([GIDProfileData class]);
  OCMStub([mockUserProfile name]).andReturn(@"mockDisplay");
  OCMStub([mockUserProfile email]).andReturn(@"mock@example.com");
  OCMStub([mockUserProfile hasImage]).andReturn(YES);
  OCMStub([mockUserProfile imageURLWithDimension:1337])
      .andReturn([NSURL URLWithString:@"https://example.com/profile.png"]);

  OCMStub([mockUser profile]).andReturn(mockUserProfile);
  OCMStub([mockUser userID]).andReturn(@"mockID");

  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);
  OCMStub([mockSignInResult serverAuthCode]).andReturn(@"mockAuthCode");

  [self configureMock:[self.mockSignIn expect]
      forSignInWithHint:nil
       additionalScopes:@[]
             completion:[OCMArg invokeBlockWithArgs:mockSignInResult, [NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertEqualObjects(user.displayName, @"mockDisplay");
    XCTAssertEqualObjects(user.email, @"mock@example.com");
    XCTAssertEqualObjects(user.userId, @"mockID");
    XCTAssertEqualObjects(user.photoUrl, @"https://example.com/profile.png");
    XCTAssertEqualObjects(user.serverAuthCode, @"mockAuthCode");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];

  // Set in example app GoogleService-Info.plist.
  XCTAssertEqualObjects(
      self.plugin.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");

  OCMVerifyAll(self.mockSignIn);
}

- (void)testSignInWithInitializedScopes {
  FlutterError *initializationError;
  [self.plugin
      initializeSignInWithParameters:[FSIInitParams makeWithScopes:@[ @"initial1", @"initial2" ]
                                                      hostedDomain:nil
                                                          clientId:nil
                                                    serverClientId:nil]
                               error:&initializationError];

  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  [self configureMock:[self.mockSignIn expect]
      forSignInWithHint:nil
       additionalScopes:[OCMArg checkWithBlock:^BOOL(NSArray<NSString *> *scopes) {
         return [[NSSet setWithArray:scopes]
             isEqualToSet:[NSSet setWithObjects:@"initial1", @"initial2", nil]];
       }]
             completion:[OCMArg invokeBlockWithArgs:mockSignInResult, [NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertEqualObjects(user.userId, @"mockID");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];

  OCMVerifyAll(self.mockSignIn);
}

- (void)testSignInAlreadyGranted {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  [self configureMock:[self.mockSignIn stub]
      forSignInWithHint:nil
       additionalScopes:OCMOCK_ANY
             completion:[OCMArg invokeBlockWithArgs:mockSignInResult, [NSNull null], nil]];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeScopesAlreadyGranted
                                      userInfo:nil];
  [self configureMock:mockUser
         forAddScopes:OCMOCK_ANY
           completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertEqualObjects(user.userId, @"mockID");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInError {
  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeCanceled
                                      userInfo:nil];
  [self configureMock:[self.mockSignIn stub]
      forSignInWithHint:nil
       additionalScopes:OCMOCK_ANY
             completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(user);
    XCTAssertEqualObjects(error.code, @"sign_in_canceled");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInException {
  OCMExpect([self configureMock:self.mockSignIn
                forSignInWithHint:OCMOCK_ANY
                 additionalScopes:OCMOCK_ANY
                       completion:OCMOCK_ANY])
      .andThrow([NSException exceptionWithName:@"MockName" reason:@"MockReason" userInfo:nil]);

  __block FlutterError *error;
  XCTAssertThrows(
      [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *signInError) {
        XCTAssertNil(user);
        error = signInError;
      }]);

  XCTAssertEqualObjects(error.code, @"google_sign_in");
  XCTAssertEqualObjects(error.message, @"MockReason");
  XCTAssertEqualObjects(error.details, @"MockName");
}

#pragma mark - Get tokens

- (void)testGetTokens {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  id mockUserResponse = OCMClassMock([GIDGoogleUser class]);

  id mockIdToken = OCMClassMock([GIDToken class]);
  OCMStub([mockIdToken tokenString]).andReturn(@"mockIdToken");
  OCMStub([mockUserResponse idToken]).andReturn(mockIdToken);

  id mockAccessToken = OCMClassMock([GIDToken class]);
  OCMStub([mockAccessToken tokenString]).andReturn(@"mockAccessToken");
  OCMStub([mockUserResponse accessToken]).andReturn(mockAccessToken);

  [[mockUser stub]
      refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:mockUserResponse,
                                                                      [NSNull null], nil]];
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin getAccessTokenWithCompletion:^(FSITokenData *token, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertEqualObjects(token.idToken, @"mockIdToken");
    XCTAssertEqualObjects(token.accessToken, @"mockAccessToken");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensNoAuthKeychainError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                      userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin getAccessTokenWithCompletion:^(FSITokenData *token, FlutterError *error) {
    XCTAssertNil(token);
    XCTAssertEqualObjects(error.code, @"sign_in_required");
    XCTAssertEqualObjects(error.message, kGIDSignInErrorDomain);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensCancelledError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeCanceled
                                      userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin getAccessTokenWithCompletion:^(FSITokenData *token, FlutterError *error) {
    XCTAssertNil(token);
    XCTAssertEqualObjects(error.code, @"sign_in_canceled");
    XCTAssertEqualObjects(error.message, kGIDSignInErrorDomain);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensURLError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *sdkError = [NSError errorWithDomain:NSURLErrorDomain
                                          code:NSURLErrorTimedOut
                                      userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin getAccessTokenWithCompletion:^(FSITokenData *token, FlutterError *error) {
    XCTAssertNil(token);
    XCTAssertEqualObjects(error.code, @"network_error");
    XCTAssertEqualObjects(error.message, NSURLErrorDomain);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensUnknownError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *sdkError = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [[mockUser stub] refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                                   sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin getAccessTokenWithCompletion:^(FSITokenData *token, FlutterError *error) {
    XCTAssertNil(token);
    XCTAssertEqualObjects(error.code, @"sign_in_failed");
    XCTAssertEqualObjects(error.message, @"BogusDomain");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Request scopes

- (void)testRequestScopesResultErrorIfNotSignedIn {
  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:@[ @"mockScope1" ]
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(success);
                    XCTAssertEqualObjects(error.code, @"sign_in_required");
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesIfNoMissingScope {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeScopesAlreadyGranted
                                      userInfo:nil];
  [self configureMock:[mockUser stub]
         forAddScopes:@[ @"mockScope1" ]
           completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:@[ @"mockScope1" ]
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(error);
                    XCTAssertTrue(success.boolValue);
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesResultErrorIfMismatchingUser {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeMismatchWithCurrentUser
                                      userInfo:nil];
  [self configureMock:[mockUser stub]
         forAddScopes:@[ @"mockScope1" ]
           completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:@[ @"mockScope1" ]
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(success);
                    XCTAssertEqualObjects(error.code, @"mismatch_user");
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesWithUnknownError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *sdkError = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [self configureMock:[mockUser stub]
         forAddScopes:@[ @"mockScope1" ]
           completion:[OCMArg invokeBlockWithArgs:[NSNull null], sdkError, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:@[ @"mockScope1" ]
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(error);
                    XCTAssertFalse(success.boolValue);
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesException {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  OCMExpect([self configureMock:mockUser forAddScopes:@[] completion:OCMOCK_ANY])
      .andThrow([NSException exceptionWithName:@"MockName" reason:@"MockReason" userInfo:nil]);

  [self.plugin requestScopes:@[]
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(success);
                    XCTAssertEqualObjects(error.code, @"request_scopes");
                    XCTAssertEqualObjects(error.message, @"MockReason");
                    XCTAssertEqualObjects(error.details, @"MockName");
                  }];
}

- (void)testRequestScopesReturnsFalseIfOnlySubsetGranted {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);
  NSArray<NSString *> *requestedScopes = @[ @"mockScope1", @"mockScope2" ];

  // Only grant one of the two requested scopes.
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockUser grantedScopes]).andReturn(@[ @"mockScope1" ]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  [self configureMock:[mockUser stub]
         forAddScopes:requestedScopes
           completion:[OCMArg invokeBlockWithArgs:mockSignInResult, [NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:requestedScopes
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(error);
                    XCTAssertFalse(success.boolValue);
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestsInitializedScopes {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  FSIInitParams *params = [FSIInitParams makeWithScopes:@[ @"initial1", @"initial2" ]
                                           hostedDomain:nil
                                               clientId:nil
                                         serverClientId:nil];
  FlutterError *initializationError;
  [self.plugin initializeSignInWithParameters:params error:&initializationError];
  XCTAssertNil(initializationError);

  // Include one of the initially requested scopes.
  NSArray<NSString *> *addedScopes = @[ @"initial1", @"addScope1", @"addScope2" ];

  [self.plugin requestScopes:addedScopes
                  completion:^(NSNumber *success, FlutterError *error){
                  }];

  // All four scopes are requested.
  [self configureMock:[mockUser verify]
         forAddScopes:[OCMArg checkWithBlock:^BOOL(NSArray<NSString *> *scopes) {
           return [[NSSet setWithArray:scopes]
               isEqualToSet:[NSSet setWithObjects:@"initial1", @"initial2", @"addScope1",
                                                  @"addScope2", nil]];
         }]
           completion:OCMOCK_ANY];
}

- (void)testRequestScopesReturnsTrueIfGranted {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);
  NSArray<NSString *> *requestedScopes = @[ @"mockScope1", @"mockScope2" ];

  // Grant both of the requested scopes.
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockUser grantedScopes]).andReturn(requestedScopes);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  [self configureMock:[mockUser stub]
         forAddScopes:requestedScopes
           completion:[OCMArg invokeBlockWithArgs:mockSignInResult, [NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:requestedScopes
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(error);
                    XCTAssertTrue(success.boolValue);
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Utils

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
- (void)configureMock:(id)mock
    forSignInWithHint:(NSString *)hint
     additionalScopes:(NSArray<NSString *> *)additionalScopes
           completion:(nullable void (^)(GIDSignInResult *_Nullable signInResult,
                                         NSError *_Nullable error))completion {
#if TARGET_OS_OSX
  [mock signInWithPresentingWindow:OCMOCK_ANY
                              hint:hint
                  additionalScopes:additionalScopes
                        completion:completion];
#else
  [mock signInWithPresentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                                      hint:hint
                          additionalScopes:additionalScopes
                                completion:completion];
#endif
}

@end
