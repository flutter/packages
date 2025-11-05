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

/// Test implementation of @c FSIViewProvider.
@interface TestViewProvider : NSObject <FSIViewProvider>
#if TARGET_OS_OSX
/// The view containing the Flutter content.
@property(nonatomic, nullable) NSView *view;
#else
/// The view controller containing the Flutter content.
@property(nonatomic, nullable) UIViewController *viewController;
#endif
@end

@implementation TestViewProvider
@end

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

/// Test implementation of @c FSIGIDProfileData.
@interface TestProfileData : NSObject <FSIGIDProfileData>
@property(nonatomic, readwrite) NSString *email;
@property(nonatomic, readwrite) NSString *name;
/// A URL to return from imageURLWithDimension:.
@property(nonatomic) NSURL *imageURL;
@end

@implementation TestProfileData {
}

- (BOOL)hasImage {
  return self.imageURL != nil;
}

- (NSURL *)imageURLWithDimension:(NSUInteger)dimension {
  return self.imageURL;
}
@end

/// Test implementation of @c FSIGIDToken.
@interface TestToken : NSObject <FSIGIDToken>
@property(nonatomic, readwrite) NSString *tokenString;
@property(nonatomic, readwrite) NSDate *expirationDate;
@end

@implementation TestToken
@end

/// Test implementation of @c FSIGIDSignInResult.
@interface TestSignInResult : NSObject <FSIGIDSignInResult>
@property(nonatomic, readwrite) NSObject<FSIGIDGoogleUser> *user;
@property(nonatomic, readwrite, nullable) NSString *serverAuthCode;
@end

@implementation TestSignInResult
@end

/// Test implementation of @c FSIGIDGoogleUser.
@interface TestGoogleUser : NSObject <FSIGIDGoogleUser>
@property(nonatomic, readwrite, nullable) NSString *userID;
@property(nonatomic, readwrite, nullable) NSObject<FSIGIDProfileData> *profile;
@property(nonatomic, readwrite, nullable) NSArray<NSString *> *grantedScopes;
@property(nonatomic, readwrite) NSObject<FSIGIDToken> *accessToken;
@property(nonatomic, readwrite) NSObject<FSIGIDToken> *refreshToken;
@property(nonatomic, readwrite, nullable) NSObject<FSIGIDToken> *idToken;

/// An exception to throw from methods.
@property(nonatomic, nullable) NSException *exception;

/// The result to return from addScopes:presentingViewController:completion:.
@property(nonatomic, nullable) NSObject<FSIGIDSignInResult> *result;

/// The error to return from methods.
@property(nonatomic, nullable) NSError *error;

// Values passed as parameters.
@property(nonatomic, copy, nullable) NSArray<NSString *> *requestedScopes;
#if TARGET_OS_IOS || TARGET_OS_MACCATALYST
@property(nonatomic, nullable) UIViewController *presentingViewController;
#else
@property(nonatomic, nullable) NSWindow *presentingWindow;
#endif
@end

@implementation TestGoogleUser

- (void)refreshTokensIfNeededWithCompletion:(void (^)(NSObject<FSIGIDGoogleUser> *_Nullable user,
                                                      NSError *_Nullable error))completion {
  if (self.exception) {
    @throw self.exception;
  }
  if (completion) {
    completion(self.error ? nil : self, self.error);
  }
}

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)addScopes:(NSArray<NSString *> *)scopes
    presentingViewController:(UIViewController *)presentingViewController
                  completion:(nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable result,
                                                NSError *_Nullable error))completion {
  self.requestedScopes = scopes;
  self.presentingViewController = presentingViewController;
  if (self.exception) {
    @throw self.exception;
  }
  if (completion) {
    completion(self.error ? nil : self.result, self.error);
  }
}

#elif TARGET_OS_OSX

- (void)addScopes:(NSArray<NSString *> *)scopes
    presentingWindow:(NSWindow *)presentingWindow
          completion:(nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable result,
                                        NSError *_Nullable error))completion {
  self.requestedScopes = scopes;
  self.presentingWindow = presentingWindow;
  if (self.exception) {
    @throw self.exception;
  }
  if (completion) {
    completion(self.error ? nil : self.result, self.error);
  }
}

#endif

@end

#pragma mark -

@interface FLTGoogleSignInPluginTest : XCTestCase

@property(nonatomic) TestViewProvider *viewProvider;
@property(nonatomic) FLTGoogleSignInPlugin *plugin;
@property(nonatomic) TestSignIn *fakeSignIn;
@property(nonatomic, copy) NSDictionary<NSString *, id> *googleServiceInfo;

@end

@implementation FLTGoogleSignInPluginTest

- (void)setUp {
  [super setUp];
  self.viewProvider = [[TestViewProvider alloc] init];

  self.fakeSignIn = [[TestSignIn alloc] init];

  self.plugin = [[FLTGoogleSignInPlugin alloc] initWithSignIn:self.fakeSignIn
                                                 viewProvider:self.viewProvider];

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
                                                 viewProvider:self.viewProvider
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
                                                 viewProvider:self.viewProvider
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
                                                 viewProvider:self.viewProvider
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
                                                 viewProvider:self.viewProvider
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
  TestGoogleUser *fakeUser = [[TestGoogleUser alloc] init];
  fakeUser.userID = @"mockID";
  self.fakeSignIn.user = fakeUser;

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
                                                 viewProvider:self.viewProvider
                                      googleServiceProperties:self.googleServiceInfo];
  TestGoogleUser *fakeUser = [[TestGoogleUser alloc] init];
  fakeUser.userID = @"mockID";
  TestProfileData *fakeUserProfile = [[TestProfileData alloc] init];
  fakeUserProfile.name = @"mockDisplay";
  fakeUserProfile.email = @"mock@example.com";
  fakeUserProfile.imageURL = [NSURL URLWithString:@"https://example.com/profile.png"];

  NSString *accessToken = @"mockAccessToken";
  NSString *serverAuthCode = @"mockAuthCode";
  fakeUser.profile = fakeUserProfile;
  TestToken *fakeAccessToken = [[TestToken alloc] init];
  fakeAccessToken.tokenString = accessToken;
  fakeUser.accessToken = fakeAccessToken;

  TestSignInResult *fakeSignInResult = [[TestSignInResult alloc] init];
  fakeSignInResult.user = fakeUser;
  fakeSignInResult.serverAuthCode = serverAuthCode;

  self.fakeSignIn.signInResult = fakeSignInResult;

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

  TestGoogleUser *fakeUser = [[TestGoogleUser alloc] init];
  fakeUser.userID = @"mockID";
  TestSignInResult *fakeSignInResult = [[TestSignInResult alloc] init];
  fakeSignInResult.user = fakeUser;

  NSArray<NSString *> *requestedScopes = @[ @"scope1", @"scope2" ];
  self.fakeSignIn.signInResult = fakeSignInResult;

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

  TestGoogleUser *fakeUser = [[TestGoogleUser alloc] init];
  fakeUser.userID = @"mockID";
  TestSignInResult *fakeSignInResult = [[TestSignInResult alloc] init];
  fakeSignInResult.user = fakeUser;

  NSString *nonce = @"A nonce";
  self.fakeSignIn.signInResult = fakeSignInResult;

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
  TestGoogleUser *fakeUser = [[TestGoogleUser alloc] init];
  fakeUser.userID = @"mockID";
  TestSignInResult *fakeSignInResult = [[TestSignInResult alloc] init];
  fakeSignInResult.user = fakeUser;

  self.fakeSignIn.signInResult = fakeSignInResult;

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
  TestGoogleUser *fakeUser = [self addSignedInUser];
  // TestGoogleUser passes itself as the result's user property, so set the
  // fake result data on this object.
  TestToken *fakeIDToken = [[TestToken alloc] init];
  fakeIDToken.tokenString = @"mockIdToken";
  fakeUser.idToken = fakeIDToken;

  TestToken *fakeAccessToken = [[TestToken alloc] init];
  fakeAccessToken.tokenString = @"mockAccessToken";
  fakeUser.accessToken = fakeAccessToken;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin
      refreshedAuthorizationTokensForUser:fakeUser.userID
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
  TestGoogleUser *fakeUser = [self addSignedInUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeHasNoAuthInKeychain
                                      userInfo:nil];
  fakeUser.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:fakeUser.userID
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
  TestGoogleUser *fakeUser = [self addSignedInUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeCanceled
                                      userInfo:nil];
  fakeUser.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:fakeUser.userID
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
  TestGoogleUser *fakeUser = [self addSignedInUser];

  NSError *sdkError = [NSError errorWithDomain:NSURLErrorDomain
                                          code:NSURLErrorTimedOut
                                      userInfo:nil];
  fakeUser.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:fakeUser.userID
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
  TestGoogleUser *fakeUser = [self addSignedInUser];

  NSError *sdkError = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  fakeUser.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin refreshedAuthorizationTokensForUser:fakeUser.userID
                                        completion:^(FSISignInResult *result, FlutterError *error) {
                                          XCTAssertNil(result.success);
                                          XCTAssertEqualObjects(error.code, @"BogusDomain: 42");
                                          [expectation fulfill];
                                        }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - addScopes

- (void)testRequestScopesPassesScopes {
  TestGoogleUser *fakeUser = [self addSignedInUser];
  // Create a different instance to return in the result, to avoid a retain cycle.
  TestGoogleUser *fakeResultUser = [[TestGoogleUser alloc] init];
  fakeResultUser.userID = fakeUser.userID;
  TestSignInResult *fakeSignInResult = [[TestSignInResult alloc] init];
  fakeSignInResult.user = fakeResultUser;
  fakeUser.result = fakeSignInResult;

  NSArray<NSString *> *scopes = @[ @"mockScope1" ];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:fakeUser.userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(error);
                XCTAssertNotNil(result.success);
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
  XCTAssertEqual(fakeUser.requestedScopes.firstObject, scopes.firstObject);
}

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
  TestGoogleUser *fakeUser = [self addSignedInUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeScopesAlreadyGranted
                                      userInfo:nil];
  fakeUser.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:fakeUser.userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(error);
                XCTAssertNil(result.success);
                XCTAssertEqual(result.error.type, FSIGoogleSignInErrorCodeScopesAlreadyGranted);
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesResultErrorIfMismatchingUser {
  TestGoogleUser *fakeUser = [self addSignedInUser];

  NSError *sdkError = [NSError errorWithDomain:kGIDSignInErrorDomain
                                          code:kGIDSignInErrorCodeMismatchWithCurrentUser
                                      userInfo:nil];
  fakeUser.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:fakeUser.userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(error);
                XCTAssertNil(result.success);
                XCTAssertEqual(result.error.type, FSIGoogleSignInErrorCodeUserMismatch);
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesWithUnknownError {
  TestGoogleUser *fakeUser = [self addSignedInUser];

  NSError *sdkError = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  fakeUser.error = sdkError;

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[ @"mockScope1" ]
                 forUser:fakeUser.userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(result);
                XCTAssertEqualObjects(error.code, @"BogusDomain: 42");
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesException {
  TestGoogleUser *fakeUser = [self addSignedInUser];

  fakeUser.exception = [NSException exceptionWithName:@"MockName"
                                               reason:@"MockReason"
                                             userInfo:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
  [self.plugin addScopes:@[]
                 forUser:fakeUser.userID
              completion:^(FSISignInResult *result, FlutterError *error) {
                XCTAssertNil(result);
                XCTAssertEqualObjects(error.code, @"request_scopes");
                XCTAssertEqualObjects(error.message, @"MockReason");
                XCTAssertEqualObjects(error.details, @"MockName");
                [expectation fulfill];
              }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Utils

- (TestGoogleUser *)addSignedInUser {
  NSString *identifier = @"fakeID";
  TestGoogleUser *user = [[TestGoogleUser alloc] init];
  user.userID = identifier;
  self.plugin.usersByIdentifier[identifier] = user;
  return user;
}

@end
