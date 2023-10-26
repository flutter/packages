// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

@import XCTest;
@import google_sign_in_ios;
@import google_sign_in_ios.Test;
@import GoogleSignIn;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

@interface FLTGoogleSignInPluginTest : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;
@property(strong, nonatomic) NSObject<FlutterPluginRegistrar> *mockPluginRegistrar;
@property(strong, nonatomic) FLTGoogleSignInPlugin *plugin;
@property(strong, nonatomic) id mockSignIn;

@end

@implementation FLTGoogleSignInPluginTest

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  self.mockPluginRegistrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  id mockSignIn = OCMClassMock([GIDSignIn class]);
  self.mockSignIn = mockSignIn;

  OCMStub(self.mockPluginRegistrar.messenger).andReturn(self.mockBinaryMessenger);
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:mockSignIn];
  [FLTGoogleSignInPlugin registerWithRegistrar:self.mockPluginRegistrar];
}

- (void)testSignOut {
  FlutterError *error;
  [self.plugin signOutWithError:&error];
  OCMVerify([self.mockSignIn signOut]);
  XCTAssertNil(error);
}

- (void)testDisconnect {
  [[self.mockSignIn stub] disconnectWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null], nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin disconnectWithCompletion:^(FlutterError *error) {
    XCTAssertNil(error);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testDisconnectIgnoresError {
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                   userInfo:nil];
  [[self.mockSignIn stub] disconnectWithCompletion:[OCMArg invokeBlockWithArgs:error, nil]];

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
                                  withGoogleServiceProperties:nil];

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
  FSIInitParams *params = [FSIInitParams makeWithScopes:@[]
                                           hostedDomain:@"example.com"
                                               clientId:nil
                                         serverClientId:nil];

  FlutterError *error;
  [self.plugin initializeSignInWithParameters:params error:&error];
  XCTAssertNil(error);

  // Initialization values used in the next sign in request.
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error){
  }];
  OCMVerify([self.mockSignIn
      signInWithPresentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                                    hint:nil
                        additionalScopes:OCMOCK_ANY
                              completion:OCMOCK_ANY]);

  XCTAssertEqualObjects(self.plugin.configuration.hostedDomain, @"example.com");
  XCTAssertEqualObjects(
      self.plugin.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");
  XCTAssertEqualObjects(self.plugin.configuration.serverClientID, @"YOUR_SERVER_CLIENT_ID");
}

- (void)testInitDynamicClientIdNullDomain {
  // Init plugin without GoogleService-Info.plist.
  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.mockSignIn
                                  withGoogleServiceProperties:nil];

  FSIInitParams *params = [FSIInitParams makeWithScopes:@[]
                                           hostedDomain:nil
                                               clientId:@"mockClientId"
                                         serverClientId:nil];

  FlutterError *error;
  [self.plugin initializeSignInWithParameters:params error:&error];
  XCTAssertNil(error);

  // Initialization values used in the next sign in request.
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error){
  }];
  OCMVerify([self.mockSignIn
      signInWithPresentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                                    hint:nil
                        additionalScopes:OCMOCK_ANY
                              completion:OCMOCK_ANY]);

  XCTAssertEqualObjects(self.plugin.configuration.hostedDomain, nil);
  XCTAssertEqualObjects(self.plugin.configuration.clientID, @"mockClientId");
  XCTAssertEqualObjects(self.plugin.configuration.serverClientID, nil);
}

- (void)testInitDynamicServerClientIdNullDomain {
  FSIInitParams *params = [FSIInitParams makeWithScopes:@[]
                                           hostedDomain:nil
                                               clientId:nil
                                         serverClientId:@"mockServerClientId"];
  FlutterError *error;
  [self.plugin initializeSignInWithParameters:params error:&error];
  XCTAssertNil(error);

  // Initialization values used in the next sign in request.
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error){
  }];
  OCMVerify([self.mockSignIn
      signInWithPresentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                                    hint:nil
                        additionalScopes:OCMOCK_ANY
                              completion:OCMOCK_ANY]);

  XCTAssertEqualObjects(self.plugin.configuration.hostedDomain, nil);
  XCTAssertEqualObjects(
      self.plugin.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");
  XCTAssertEqualObjects(self.plugin.configuration.serverClientID, @"mockServerClientId");
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
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                   userInfo:nil];

  [[self.mockSignIn stub]
      restorePreviousSignInWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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

  [[self.mockSignIn expect]
      signInWithPresentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                                    hint:nil
                        additionalScopes:@[]
                              completion:[OCMArg invokeBlockWithArgs:mockSignInResult,
                                                                     [NSNull null], nil]];

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

  XCTAssertEqualObjects(
      self.plugin.configuration.clientID,
      @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com");

  OCMVerifyAll(self.mockSignIn);
}

- (void)testSignInWithInitializedScopes {
  FlutterError *error;
  [self.plugin
      initializeSignInWithParameters:[FSIInitParams makeWithScopes:@[ @"initial1", @"initial2" ]
                                                      hostedDomain:nil
                                                          clientId:nil
                                                    serverClientId:nil]
                               error:&error];

  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([mockUser userID]).andReturn(@"mockID");
  id mockSignInResult = OCMClassMock([GIDSignInResult class]);
  OCMStub([mockSignInResult user]).andReturn(mockUser);

  [[self.mockSignIn expect]
      signInWithPresentingViewController:OCMOCK_ANY
                                    hint:nil
                        additionalScopes:[OCMArg checkWithBlock:^BOOL(NSArray<NSString *> *scopes) {
                          return [[NSSet setWithArray:scopes]
                              isEqualToSet:[NSSet setWithObjects:@"initial1", @"initial2", nil]];
                        }]
                              completion:[OCMArg invokeBlockWithArgs:mockSignInResult,
                                                                     [NSNull null], nil]];

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

  [[self.mockSignIn stub]
      signInWithPresentingViewController:OCMOCK_ANY
                                    hint:nil
                        additionalScopes:OCMOCK_ANY
                              completion:[OCMArg invokeBlockWithArgs:mockSignInResult,
                                                                     [NSNull null], nil]];

  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeScopesAlreadyGranted
                                   userInfo:nil];
  [[self.mockSignIn currentUser] addScopes:OCMOCK_ANY
                  presentingViewController:OCMOCK_ANY
                                completion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(error);
    XCTAssertEqualObjects(user.userId, @"mockID");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInError {
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeCanceled
                                   userInfo:nil];
  [[self.mockSignIn stub]
      signInWithPresentingViewController:OCMOCK_ANY
                                    hint:nil
                        additionalScopes:OCMOCK_ANY
                              completion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(user);
    XCTAssertEqualObjects(error.code, @"sign_in_canceled");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInException {
  OCMExpect([self.mockSignIn signInWithPresentingViewController:OCMOCK_ANY
                                                           hint:OCMOCK_ANY
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

  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                   userInfo:nil];
  [[mockUser stub]
      refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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

  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeCanceled
                                   userInfo:nil];
  [[mockUser stub]
      refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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

  NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
  [[mockUser stub]
      refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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

  NSError *error = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [[mockUser stub]
      refreshTokensIfNeededWithCompletion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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

  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeScopesAlreadyGranted
                                   userInfo:nil];
  [[mockUser stub] addScopes:@[ @"mockScope1" ]
      presentingViewController:OCMOCK_ANY
                    completion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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

  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeMismatchWithCurrentUser
                                   userInfo:nil];
  [[mockUser stub] addScopes:@[ @"mockScope1" ]
      presentingViewController:OCMOCK_ANY
                    completion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:@[ @"mockScope1" ]
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(success);
                    XCTAssertEqualObjects(error.code, @"request_scopes");
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesWithUnknownError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  NSError *error = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [[mockUser stub] addScopes:@[ @"mockScope1" ]
      presentingViewController:OCMOCK_ANY
                    completion:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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

  OCMExpect([mockUser addScopes:@[] presentingViewController:OCMOCK_ANY completion:OCMOCK_ANY])
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

  [[mockUser stub] addScopes:requestedScopes
      presentingViewController:OCMOCK_ANY
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
  FlutterError *error;
  [self.plugin initializeSignInWithParameters:params error:&error];
  XCTAssertNil(error);

  // Include one of the initially requested scopes.
  NSArray<NSString *> *addedScopes = @[ @"initial1", @"addScope1", @"addScope2" ];

  [self.plugin requestScopes:addedScopes
                  completion:^(NSNumber *success, FlutterError *error){
                  }];

  // All four scopes are requested.
  [[mockUser verify] addScopes:[OCMArg checkWithBlock:^BOOL(NSArray<NSString *> *scopes) {
                       return [[NSSet setWithArray:scopes]
                           isEqualToSet:[NSSet setWithObjects:@"initial1", @"initial2",
                                                              @"addScope1", @"addScope2", nil]];
                     }]
      presentingViewController:OCMOCK_ANY
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

  [[mockUser stub] addScopes:requestedScopes
      presentingViewController:OCMOCK_ANY
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

@end
