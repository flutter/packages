// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/google_sign_in_ios/FLTGoogleSignInPlugin.h"
#import "./include/google_sign_in_ios/FLTGoogleSignInPlugin_Test.h"

#import <GoogleSignIn/GoogleSignIn.h>

// The key within `GoogleService-Info.plist` used to hold the application's
// client id.  See https://developers.google.com/identity/sign-in/ios/start
// for more info.
static NSString *const kClientIdKey = @"CLIENT_ID";

static NSString *const kServerClientIdKey = @"SERVER_CLIENT_ID";

static NSDictionary<NSString *, id> *FSILoadGoogleServiceInfo(void) {
  NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info"
                                                        ofType:@"plist"];
  if (plistPath) {
    return [[NSDictionary alloc] initWithContentsOfFile:plistPath];
  }
  return nil;
}

/// Deep-converts values to something that can be safely encoded with the standard message codec,
/// for use in making NSError userInfo values safe to send as FlutterError details.
///
/// Unexpected types are converted to a
static id FSISanitizedUserInfo(id value) {
  if ([value isKindOfClass:[NSError class]]) {
    NSError *error = value;
    return @{
      @"domain" : error.domain,
      @"code" : [NSString stringWithFormat:@"%ld", (long)error.code],
      @"localizedDescription" : error.localizedDescription,
      @"userInfo" : FSISanitizedUserInfo(error.userInfo),
    };
  } else if ([value isKindOfClass:[NSString class]]) {
    return value;
  } else if ([value isKindOfClass:[NSURL class]]) {
    return [value absoluteString];
  } else if ([value isKindOfClass:[NSNumber class]]) {
    return value;
  } else if ([value isKindOfClass:[NSArray class]]) {
    NSArray *array = value;
    NSMutableArray *safeValues = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (id item in array) {
      [safeValues addObject:FSISanitizedUserInfo(item)];
    }
    return safeValues;
  } else if ([value isKindOfClass:[NSDictionary class]]) {
    NSDictionary *dict = value;
    NSMutableDictionary *safeValues = [[NSMutableDictionary alloc] initWithCapacity:dict.count];
    for (id key in dict) {
      safeValues[key] = FSISanitizedUserInfo(dict[key]);
    }
    return safeValues;
  } else {
    return [NSString stringWithFormat:@"[Unsupported type: %@]", NSStringFromClass([value class])];
  }
}

/// Maps an NSError to a corresponding FlutterError.
///
/// This should only be used when an error can't be recognized and mapped to a
/// GoogleSignInErrorCode.
static FlutterError *FSIFlutterErrorForNSError(NSError *error) {
  return [FlutterError
      errorWithCode:[NSString stringWithFormat:@"%@: %ld", error.domain, (long)error.code]
            message:error.localizedDescription
            details:FSISanitizedUserInfo(error.userInfo)];
}

/// Maps a GIDSignInErrorCode to the corresponding Pigeon GoogleSignInErrorCode
static FSIGoogleSignInErrorCode FSIPigeonErrorCodeForGIDSignInErrorCode(NSInteger code) {
  switch (code) {
    case kGIDSignInErrorCodeKeychain:
      return FSIGoogleSignInErrorCodeKeychainError;
    case kGIDSignInErrorCodeCanceled:
      return FSIGoogleSignInErrorCodeCanceled;
    case kGIDSignInErrorCodeHasNoAuthInKeychain:
      return FSIGoogleSignInErrorCodeNoAuthInKeychain;
    case kGIDSignInErrorCodeEMM:
      return FSIGoogleSignInErrorCodeEemError;
    case kGIDSignInErrorCodeScopesAlreadyGranted:
      return FSIGoogleSignInErrorCodeScopesAlreadyGranted;
    case kGIDSignInErrorCodeMismatchWithCurrentUser:
      return FSIGoogleSignInErrorCodeUserMismatch;
    case kGIDSignInErrorCodeUnknown:
    default:
      return FSIGoogleSignInErrorCodeUnknown;
  }
}

@interface FLTGoogleSignInPlugin ()

// The contents of GoogleService-Info.plist, if it exists.
@property(nonatomic, nullable) NSDictionary<NSString *, id> *googleServiceProperties;

// The plugin registrar, for querying views.
@property(nonatomic, nonnull) id<FlutterPluginRegistrar> registrar;

@end

@implementation FLTGoogleSignInPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTGoogleSignInPlugin *instance = [[FLTGoogleSignInPlugin alloc] initWithRegistrar:registrar];
  [registrar addApplicationDelegate:instance];
  SetUpFSIGoogleSignInApi(registrar.messenger, instance);
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  return [self initWithSignIn:GIDSignIn.sharedInstance registrar:registrar];
}

- (instancetype)initWithSignIn:(GIDSignIn *)signIn
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  return [self initWithSignIn:signIn
                    registrar:registrar
      googleServiceProperties:FSILoadGoogleServiceInfo()];
}

- (instancetype)initWithSignIn:(GIDSignIn *)signIn
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar
       googleServiceProperties:(nullable NSDictionary<NSString *, id> *)googleServiceProperties {
  self = [super init];
  if (self) {
    _signIn = signIn;
    _registrar = registrar;
    _googleServiceProperties = googleServiceProperties;
    _usersByIdentifier = [[NSMutableDictionary alloc] init];

    // On the iOS simulator, we get "Broken pipe" errors after sign-in for some
    // unknown reason. We can avoid crashing the app by ignoring them.
    signal(SIGPIPE, SIG_IGN);
  }
  return self;
}

#pragma mark - <FlutterPlugin> protocol

#if TARGET_OS_IOS
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
  return [self.signIn handleURL:url];
}
#else
- (BOOL)handleOpenURLs:(NSArray<NSURL *> *)urls {
  BOOL handled = NO;
  for (NSURL *url in urls) {
    handled = [self.signIn handleURL:url] || handled;
  }
  return handled;
}
#endif

#pragma mark - FSIGoogleSignInApi

- (void)configureWithParameters:(FSIPlatformConfigurationParams *)params
                          error:(FlutterError *_Nullable *_Nonnull)error {
  // If configuration information was passed from Dart, or present in GoogleService-Info.plist,
  // use that. Otherwise, keep the default configuration, which GIDSignIn will automatically
  // populate from Info.plist values (the recommended configuration method).
  GIDConfiguration *configuration = [self configurationWithClientIdentifier:params.clientId
                                                     serverClientIdentifier:params.serverClientId
                                                               hostedDomain:params.hostedDomain];
  if (configuration) {
    self.signIn.configuration = configuration;
  }
}

- (void)restorePreviousSignInWithCompletion:(nonnull void (^)(FSISignInResult *_Nullable,
                                                              FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  [self.signIn restorePreviousSignInWithCompletion:^(GIDGoogleUser *_Nullable user,
                                                     NSError *_Nullable error) {
    [weakSelf handleAuthResultWithUser:user serverAuthCode:nil error:error completion:completion];
  }];
}

- (void)signInWithScopeHint:(NSArray<NSString *> *)scopeHint
                      nonce:(nullable NSString *)nonce
                 completion:(nonnull void (^)(FSISignInResult *_Nullable,
                                              FlutterError *_Nullable))completion {
  @try {
    __weak typeof(self) weakSelf = self;
    [self signInWithHint:nil
        additionalScopes:scopeHint
                   nonce:nonce
              completion:^(GIDSignInResult *_Nullable signInResult, NSError *_Nullable error) {
                [weakSelf handleAuthResultWithUser:signInResult.user
                                    serverAuthCode:signInResult.serverAuthCode
                                             error:error
                                        completion:completion];
              }];
  } @catch (NSException *e) {
    completion(nil, [FlutterError errorWithCode:@"google_sign_in" message:e.reason details:e.name]);
  }
}

- (void)refreshedAuthorizationTokensForUser:(NSString *)userId
                                 completion:(nonnull void (^)(FSISignInResult *_Nullable,
                                                              FlutterError *_Nullable))completion {
  GIDGoogleUser *user = self.usersByIdentifier[userId];
  if (user == nil) {
    completion(
        [FSISignInResult
            makeWithSuccess:nil
                      error:[FSISignInFailure makeWithType:FSIGoogleSignInErrorCodeUserMismatch
                                                   message:@"The user is no longer signed in."
                                                   details:nil]],
        nil);
    return;
  }

  __weak typeof(self) weakSelf = self;
  [user refreshTokensIfNeededWithCompletion:^(GIDGoogleUser *_Nullable refreshedUser,
                                              NSError *_Nullable error) {
    [weakSelf handleAuthResultWithUser:refreshedUser
                        serverAuthCode:nil
                                 error:error
                            completion:completion];
  }];
}

- (void)addScopes:(nonnull NSArray<NSString *> *)scopes
          forUser:(nonnull NSString *)userId
       completion:
           (nonnull void (^)(FSISignInResult *_Nullable, FlutterError *_Nullable))completion {
  GIDGoogleUser *user = self.usersByIdentifier[userId];
  if (user == nil) {
    completion(
        [FSISignInResult
            makeWithSuccess:nil
                      error:[FSISignInFailure makeWithType:FSIGoogleSignInErrorCodeUserMismatch
                                                   message:@"The user is no longer signed in."
                                                   details:nil]],
        nil);
    return;
  }

  @try {
    __weak typeof(self) weakSelf = self;
    [self addScopes:scopes
        forGoogleSignInUser:user
                 completion:^(GIDSignInResult *_Nullable signInResult, NSError *_Nullable error) {
                   [weakSelf handleAuthResultWithUser:signInResult.user
                                       serverAuthCode:signInResult.serverAuthCode
                                                error:error
                                           completion:completion];
                 }];
  } @catch (NSException *e) {
    completion(nil, [FlutterError errorWithCode:@"request_scopes" message:e.reason details:e.name]);
  }
}

- (void)signOutWithError:(FlutterError *_Nullable *_Nonnull)error {
  [self.signIn signOut];
  // usersByIdentifier is left populated, because the SDK may still support some operations on the
  // GIDGoogleUser object (e.g., returning existing, non-expired tokens). Operations that the SDK
  // doesn't support will return SDK errors that we can handle as normal.
}

- (void)disconnectWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  [self.signIn disconnectWithCompletion:^(NSError *_Nullable error) {
    completion(error ? FSIFlutterErrorForNSError(error) : nil);
  }];
}

#pragma mark - private methods

// Wraps the iOS and macOS sign in display methods.
- (void)signInWithHint:(nullable NSString *)hint
      additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                 nonce:(nullable NSString *)nonce
            completion:(void (^)(GIDSignInResult *_Nullable signInResult,
                                 NSError *_Nullable error))completion {
#if TARGET_OS_OSX
  [self.signIn signInWithPresentingWindow:self.registrar.view.window
                                     hint:hint
                         additionalScopes:additionalScopes
                                    nonce:nonce
                               completion:completion];
#else
  [self.signIn signInWithPresentingViewController:[self topViewController]
                                             hint:hint
                                 additionalScopes:additionalScopes
                                            nonce:nonce
                                       completion:completion];
#endif
}

// Wraps the iOS and macOS scope addition methods.
- (void)addScopes:(nonnull NSArray<NSString *> *)scopes
    forGoogleSignInUser:(nonnull GIDGoogleUser *)user
             completion:(void (^)(GIDSignInResult *_Nullable signInResult,
                                  NSError *_Nullable error))completion {
#if TARGET_OS_OSX
  [user addScopes:scopes presentingWindow:self.registrar.view.window completion:completion];
#else
  [user addScopes:scopes presentingViewController:[self topViewController] completion:completion];
#endif
}

/// @return @c nil if GoogleService-Info.plist not found and runtimeClientIdentifier is not
/// provided.
- (GIDConfiguration *)configurationWithClientIdentifier:(nullable NSString *)runtimeClientIdentifier
                                 serverClientIdentifier:
                                     (nullable NSString *)runtimeServerClientIdentifier
                                           hostedDomain:(nullable NSString *)hostedDomain {
  NSString *clientID = runtimeClientIdentifier ?: self.googleServiceProperties[kClientIdKey];
  if (!clientID) {
    // Creating a GIDConfiguration requires a client identifier.
    return nil;
  }
  NSString *serverClientID =
      runtimeServerClientIdentifier ?: self.googleServiceProperties[kServerClientIdKey];

  return [[GIDConfiguration alloc] initWithClientID:clientID
                                     serverClientID:serverClientID
                                       hostedDomain:hostedDomain
                                        openIDRealm:nil];
}

- (void)handleAuthResultWithUser:(nullable GIDGoogleUser *)user
                  serverAuthCode:(nullable NSString *)serverAuthCode
                           error:(nullable NSError *)error
                      completion:(void (^)(FSISignInResult *_Nullable,
                                           FlutterError *_Nullable))completion {
  if (user) {
    [self didSignInForUser:user withServerAuthCode:serverAuthCode completion:completion];
  } else {
    // Convert expected errors into structured failure return, and everything else
    // into a generic error.
    if (error.domain == kGIDSignInErrorDomain) {
      completion(
          [FSISignInResult
              makeWithSuccess:nil
                        error:[FSISignInFailure
                                  makeWithType:FSIPigeonErrorCodeForGIDSignInErrorCode(error.code)
                                       message:error.localizedDescription
                                       details:FSISanitizedUserInfo(error.userInfo)]],
          nil);
    } else {
      completion(nil, FSIFlutterErrorForNSError(error));
    }
  }
}

- (void)didSignInForUser:(nonnull GIDGoogleUser *)user
      withServerAuthCode:(nullable NSString *)serverAuthCode
              completion:(void (^)(FSISignInResult *_Nullable, FlutterError *_Nullable))completion {
  self.usersByIdentifier[user.userID] = user;

  NSURL *photoURL;
  if (user.profile.hasImage) {
    // Placeholder that will be replaced by on the Dart side based on screen size.
    photoURL = [user.profile imageURLWithDimension:1337];
  }

  FSIUserData *userData = [FSIUserData makeWithDisplayName:user.profile.name
                                                     email:user.profile.email
                                                    userId:user.userID
                                                  photoUrl:photoURL.absoluteString
                                                   idToken:user.idToken.tokenString];
  FSISignInResult *result =
      [FSISignInResult makeWithSuccess:[FSISignInSuccess makeWithUser:userData
                                                          accessToken:user.accessToken.tokenString
                                                        grantedScopes:user.grantedScopes
                                                       serverAuthCode:serverAuthCode]
                                 error:nil];
  completion(result, nil);
}

#if TARGET_OS_IOS

- (UIViewController *)topViewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan) Provide a non-deprecated codepath. See
  // https://github.com/flutter/flutter/issues/104117
  return [self topViewControllerFromViewController:[UIApplication sharedApplication]
                                                       .keyWindow.rootViewController];
#pragma clang diagnostic pop
}

/// This method recursively iterate through the view hierarchy
/// to return the top most view controller.
///
/// It supports the following scenarios:
///
/// - The view controller is presenting another view.
/// - The view controller is a UINavigationController.
/// - The view controller is a UITabBarController.
///
/// @return The top most view controller.
- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    return [self
        topViewControllerFromViewController:[navigationController.viewControllers lastObject]];
  }
  if ([viewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabController = (UITabBarController *)viewController;
    return [self topViewControllerFromViewController:tabController.selectedViewController];
  }
  if (viewController.presentedViewController) {
    return [self topViewControllerFromViewController:viewController.presentedViewController];
  }
  return viewController;
}

#endif

@end
