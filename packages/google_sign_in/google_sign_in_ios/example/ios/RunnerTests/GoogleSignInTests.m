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
  [[self.mockSignIn stub] disconnectWithCallback:[OCMArg invokeBlockWithArgs:[NSNull null], nil]];

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
  [[self.mockSignIn stub] disconnectWithCallback:[OCMArg invokeBlockWithArgs:error, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin disconnectWithCompletion:^(FlutterError *error) {
    XCTAssertNil(error);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Init

- (void)testInitNoClientIdError {
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
  XCTAssertEqualObjects(error.code, @"missing-config");
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
       signInWithConfiguration:[OCMArg checkWithBlock:^BOOL(GIDConfiguration *configuration) {
         // Set in example app GoogleService-Info.plist.
         return
             [configuration.hostedDomain isEqualToString:@"example.com"] &&
             [configuration.clientID
                 isEqualToString:
                     @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com"] &&
             [configuration.serverClientID isEqualToString:@"YOUR_SERVER_CLIENT_ID"];
       }]
      presentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                          hint:nil
              additionalScopes:OCMOCK_ANY
                      callback:OCMOCK_ANY]);
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
       signInWithConfiguration:[OCMArg checkWithBlock:^BOOL(GIDConfiguration *configuration) {
         return configuration.hostedDomain == nil &&
                [configuration.clientID isEqualToString:@"mockClientId"];
       }]
      presentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                          hint:nil
              additionalScopes:OCMOCK_ANY
                      callback:OCMOCK_ANY]);
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
       signInWithConfiguration:[OCMArg checkWithBlock:^BOOL(GIDConfiguration *configuration) {
         return configuration.hostedDomain == nil &&
                [configuration.serverClientID isEqualToString:@"mockServerClientId"];
       }]
      presentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                          hint:nil
              additionalScopes:OCMOCK_ANY
                      callback:OCMOCK_ANY]);
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
      restorePreviousSignInWithCallback:[OCMArg invokeBlockWithArgs:mockUser, [NSNull null], nil]];

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
      restorePreviousSignInWithCallback:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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
  OCMStub([mockUser serverAuthCode]).andReturn(@"mockAuthCode");

  [[self.mockSignIn expect]
       signInWithConfiguration:[OCMArg checkWithBlock:^BOOL(GIDConfiguration *configuration) {
         return [configuration.clientID
             isEqualToString:
                 @"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com"];
       }]
      presentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]
                          hint:nil
              additionalScopes:@[]
                      callback:[OCMArg invokeBlockWithArgs:mockUser, [NSNull null], nil]];

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

  [[self.mockSignIn expect]
       signInWithConfiguration:OCMOCK_ANY
      presentingViewController:OCMOCK_ANY
                          hint:nil
              additionalScopes:[OCMArg checkWithBlock:^BOOL(NSArray<NSString *> *scopes) {
                return [[NSSet setWithArray:scopes]
                    isEqualToSet:[NSSet setWithObjects:@"initial1", @"initial2", nil]];
              }]
                      callback:[OCMArg invokeBlockWithArgs:mockUser, [NSNull null], nil]];

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

  [[self.mockSignIn stub]
       signInWithConfiguration:OCMOCK_ANY
      presentingViewController:OCMOCK_ANY
                          hint:nil
              additionalScopes:OCMOCK_ANY
                      callback:[OCMArg invokeBlockWithArgs:mockUser, [NSNull null], nil]];

  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeScopesAlreadyGranted
                                   userInfo:nil];
  [[self.mockSignIn stub] addScopes:OCMOCK_ANY
           presentingViewController:OCMOCK_ANY
                           callback:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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
       signInWithConfiguration:OCMOCK_ANY
      presentingViewController:OCMOCK_ANY
                          hint:nil
              additionalScopes:OCMOCK_ANY
                      callback:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin signInWithCompletion:^(FSIUserData *user, FlutterError *error) {
    XCTAssertNil(user);
    XCTAssertEqualObjects(error.code, @"sign_in_canceled");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignInException {
  OCMExpect([self.mockSignIn signInWithConfiguration:OCMOCK_ANY
                            presentingViewController:OCMOCK_ANY
                                                hint:OCMOCK_ANY
                                    additionalScopes:OCMOCK_ANY
                                            callback:OCMOCK_ANY])
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
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  OCMStub([mockAuthentication idToken]).andReturn(@"mockIdToken");
  OCMStub([mockAuthentication accessToken]).andReturn(@"mockAccessToken");
  [[mockAuthentication stub]
      doWithFreshTokens:[OCMArg invokeBlockWithArgs:mockAuthentication, [NSNull null], nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

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

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                   userInfo:nil];
  [[mockAuthentication stub]
      doWithFreshTokens:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

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

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeCanceled
                                   userInfo:nil];
  [[mockAuthentication stub]
      doWithFreshTokens:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

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

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
  [[mockAuthentication stub]
      doWithFreshTokens:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

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

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [[mockAuthentication stub]
      doWithFreshTokens:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

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
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeNoCurrentUser
                                   userInfo:nil];
  [[self.mockSignIn stub] addScopes:@[ @"mockScope1" ]
           presentingViewController:OCMOCK_ANY
                           callback:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain
                                       code:kGIDSignInErrorCodeScopesAlreadyGranted
                                   userInfo:nil];
  [[self.mockSignIn stub] addScopes:@[ @"mockScope1" ]
           presentingViewController:OCMOCK_ANY
                           callback:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin requestScopes:@[ @"mockScope1" ]
                  completion:^(NSNumber *success, FlutterError *error) {
                    XCTAssertNil(error);
                    XCTAssertTrue(success.boolValue);
                    [expectation fulfill];
                  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesWithUnknownError {
  NSError *error = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [[self.mockSignIn stub] addScopes:@[ @"mockScope1" ]
           presentingViewController:OCMOCK_ANY
                           callback:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];

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
  OCMExpect([self.mockSignIn addScopes:@[] presentingViewController:OCMOCK_ANY callback:OCMOCK_ANY])
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
  GIDGoogleUser *mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);
  NSArray<NSString *> *requestedScopes = @[ @"mockScope1", @"mockScope2" ];

  // Only grant one of the two requested scopes.
  OCMStub(mockUser.grantedScopes).andReturn(@[ @"mockScope1" ]);

  [[self.mockSignIn stub] addScopes:requestedScopes
           presentingViewController:OCMOCK_ANY
                           callback:[OCMArg invokeBlockWithArgs:mockUser, [NSNull null], nil]];

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
  [[self.mockSignIn verify]
                     addScopes:[OCMArg checkWithBlock:^BOOL(NSArray<NSString *> *scopes) {
                       return [[NSSet setWithArray:scopes]
                           isEqualToSet:[NSSet setWithObjects:@"initial1", @"initial2",
                                                              @"addScope1", @"addScope2", nil]];
                     }]
      presentingViewController:OCMOCK_ANY
                      callback:OCMOCK_ANY];
}

- (void)testRequestScopesReturnsTrueIfGranted {
  GIDGoogleUser *mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSignIn currentUser]).andReturn(mockUser);
  NSArray<NSString *> *requestedScopes = @[ @"mockScope1", @"mockScope2" ];

  // Grant both of the requested scopes.
  OCMStub(mockUser.grantedScopes).andReturn(requestedScopes);

  [[self.mockSignIn stub] addScopes:requestedScopes
           presentingViewController:OCMOCK_ANY
                           callback:[OCMArg invokeBlockWithArgs:mockUser, [NSNull null], nil]];

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
