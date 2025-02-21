// Copyright 2013 The Flutter Authors. All rights reserved.
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

static NSDictionary<NSString *, id> *loadGoogleServiceInfo(void) {
  NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info"
                                                        ofType:@"plist"];
  if (plistPath) {
    return [[NSDictionary alloc] initWithContentsOfFile:plistPath];
  }
  return nil;
}

// These error codes must match with ones declared on Android and Dart sides.
static NSString *const kErrorReasonSignInRequired = @"sign_in_required";
static NSString *const kErrorReasonSignInCanceled = @"sign_in_canceled";
static NSString *const kErrorReasonNetworkError = @"network_error";
static NSString *const kErrorReasonSignInFailed = @"sign_in_failed";

static FlutterError *getFlutterError(NSError *error) {
  NSString *errorCode;
  if (error.code == kGIDSignInErrorCodeHasNoAuthInKeychain) {
    errorCode = kErrorReasonSignInRequired;
  } else if (error.code == kGIDSignInErrorCodeCanceled) {
    errorCode = kErrorReasonSignInCanceled;
  } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
    errorCode = kErrorReasonNetworkError;
  } else {
    errorCode = kErrorReasonSignInFailed;
  }
  return [FlutterError errorWithCode:errorCode
                             message:error.domain
                             details:error.localizedDescription];
}

@interface FLTGoogleSignInPlugin ()

// The contents of GoogleService-Info.plist, if it exists.
@property(strong, nullable) NSDictionary<NSString *, id> *googleServiceProperties;

// The plugin registrar, for querying views.
@property(strong, nonnull) id<FlutterPluginRegistrar> registrar;

@end

@implementation FLTGoogleSignInPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTGoogleSignInPlugin *instance = [[FLTGoogleSignInPlugin alloc] initWithRegistrar:registrar];
  [registrar addApplicationDelegate:instance];
  FSIGoogleSignInApiSetup(registrar.messenger, instance);
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  return [self initWithSignIn:GIDSignIn.sharedInstance registrar:registrar];
}

- (instancetype)initWithSignIn:(GIDSignIn *)signIn
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  return [self initWithSignIn:signIn
                    registrar:registrar
      googleServiceProperties:loadGoogleServiceInfo()];
}

- (instancetype)initWithSignIn:(GIDSignIn *)signIn
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar
       googleServiceProperties:(nullable NSDictionary<NSString *, id> *)googleServiceProperties {
  self = [super init];
  if (self) {
    _signIn = signIn;
    _registrar = registrar;
    _googleServiceProperties = googleServiceProperties;

    // On the iOS simulator, we get "Broken pipe" errors after sign-in for some
    // unknown reason. We can avoid crashing the app by ignoring them.
    signal(SIGPIPE, SIG_IGN);
    _requestedScopes = [[NSSet alloc] init];
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
    handled = handled || [self.signIn handleURL:url];
  }
  return handled;
}
#endif

#pragma mark - FSIGoogleSignInApi

- (void)initializeSignInWithParameters:(nonnull FSIInitParams *)params
                                 error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GIDConfiguration *configuration = [self configurationWithClientIdentifier:params.clientId
                                                     serverClientIdentifier:params.serverClientId
                                                               hostedDomain:params.hostedDomain];
  self.requestedScopes = [NSSet setWithArray:params.scopes];
  if (configuration != nil) {
    self.configuration = configuration;
  }
}

- (void)signInSilentlyWithCompletion:(nonnull void (^)(FSIUserData *_Nullable,
                                                       FlutterError *_Nullable))completion {
  [self.signIn restorePreviousSignInWithCompletion:^(GIDGoogleUser *_Nullable user,
                                                     NSError *_Nullable error) {
    if (user != nil) {
      [self didSignInForUser:user withServerAuthCode:nil completion:completion];
    } else {
      // Forward all errors and let Dart side decide how to handle.
      completion(nil, getFlutterError(error));
    }
  }];
}

- (nullable NSNumber *)isSignedInWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([self.signIn hasPreviousSignIn]);
}

- (void)signInWithCompletion:(nonnull void (^)(FSIUserData *_Nullable,
                                               FlutterError *_Nullable))completion {
  @try {
    // If the configuration settings are passed from the Dart API, use those.
    // Otherwise, use settings from the GoogleService-Info.plist if available.
    // If neither are available, do not set the configuration - GIDSignIn will automatically use
    // settings from the Info.plist (which is the recommended method).
    if (!self.configuration && self.googleServiceProperties) {
      self.configuration = [self configurationWithClientIdentifier:nil
                                            serverClientIdentifier:nil
                                                      hostedDomain:nil];
    }
    if (self.configuration) {
      self.signIn.configuration = self.configuration;
    }

    [self signInWithHint:nil
        additionalScopes:self.requestedScopes.allObjects
              completion:^(GIDSignInResult *_Nullable signInResult, NSError *_Nullable error) {
                if (signInResult) {
                  [self didSignInForUser:signInResult.user
                      withServerAuthCode:signInResult.serverAuthCode
                              completion:completion];
                } else {
                  // Forward all errors and let Dart side decide how to handle.
                  completion(nil, getFlutterError(error));
                }
              }];
  } @catch (NSException *e) {
    completion(nil, [FlutterError errorWithCode:@"google_sign_in" message:e.reason details:e.name]);
    [e raise];
  }
}

- (void)getAccessTokenWithCompletion:(nonnull void (^)(FSITokenData *_Nullable,
                                                       FlutterError *_Nullable))completion {
  GIDGoogleUser *currentUser = self.signIn.currentUser;
  [currentUser refreshTokensIfNeededWithCompletion:^(GIDGoogleUser *_Nullable user,
                                                     NSError *_Nullable error) {
    if (error) {
      completion(nil, getFlutterError(error));
    } else {
      completion([FSITokenData makeWithIdToken:user.idToken.tokenString
                                   accessToken:user.accessToken.tokenString],
                 nil);
    }
  }];
}

- (void)signOutWithError:(FlutterError *_Nullable *_Nonnull)error {
  [self.signIn signOut];
}

- (void)disconnectWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  [self.signIn disconnectWithCompletion:^(NSError *_Nullable error) {
    // TODO(stuartmorgan): This preserves the pre-Pigeon-migration behavior, but it's unclear why
    // 'error' is being ignored here.
    completion(nil);
  }];
}

- (void)requestScopes:(nonnull NSArray<NSString *> *)scopes
           completion:(nonnull void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  self.requestedScopes = [self.requestedScopes setByAddingObjectsFromArray:scopes];
  NSSet<NSString *> *requestedScopes = self.requestedScopes;

  @try {
    GIDGoogleUser *currentUser = self.signIn.currentUser;
    if (currentUser == nil) {
      completion(nil, [FlutterError errorWithCode:@"sign_in_required"
                                          message:@"No account to grant scopes."
                                          details:nil]);
    }
    [self addScopes:requestedScopes.allObjects
         completion:^(GIDSignInResult *_Nullable signInResult, NSError *_Nullable addedScopeError) {
           BOOL granted = NO;
           FlutterError *error = nil;

           if ([addedScopeError.domain isEqualToString:kGIDSignInErrorDomain] &&
               addedScopeError.code == kGIDSignInErrorCodeMismatchWithCurrentUser) {
             error = [FlutterError errorWithCode:@"mismatch_user"
                                         message:@"There is an operation on a previous "
                                                 @"user. Try signing in again."
                                         details:nil];
           } else if ([addedScopeError.domain isEqualToString:kGIDSignInErrorDomain] &&
                      addedScopeError.code == kGIDSignInErrorCodeScopesAlreadyGranted) {
             // Scopes already granted, report success.
             granted = YES;
           } else if (signInResult.user) {
             NSSet<NSString *> *grantedScopes =
                 [NSSet setWithArray:signInResult.user.grantedScopes];
             granted = [requestedScopes isSubsetOfSet:grantedScopes];
           }
           completion(error == nil ? @(granted) : nil, error);
         }];
  } @catch (NSException *e) {
    completion(nil, [FlutterError errorWithCode:@"request_scopes" message:e.reason details:e.name]);
  }
}

#pragma mark - private methods

// Wraps the iOS and macOS sign in display methods.
- (void)signInWithHint:(nullable NSString *)hint
      additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
            completion:(nullable void (^)(GIDSignInResult *_Nullable signInResult,
                                          NSError *_Nullable error))completion {
#if TARGET_OS_OSX
  [self.signIn signInWithPresentingWindow:self.registrar.view.window
                                     hint:hint
                         additionalScopes:additionalScopes
                               completion:completion];
#else
  [self.signIn signInWithPresentingViewController:[self topViewController]
                                             hint:hint
                                 additionalScopes:additionalScopes
                                       completion:completion];
#endif
}

// Wraps the iOS and macOS scope addition methods.
- (void)addScopes:(NSArray<NSString *> *)scopes
       completion:(nullable void (^)(GIDSignInResult *_Nullable signInResult,
                                     NSError *_Nullable error))completion {
  GIDGoogleUser *currentUser = self.signIn.currentUser;
#if TARGET_OS_OSX
  [currentUser addScopes:scopes presentingWindow:self.registrar.view.window completion:completion];
#else
  [currentUser addScopes:scopes
      presentingViewController:[self topViewController]
                    completion:completion];
#endif
}

/// @return @c nil if GoogleService-Info.plist not found and runtimeClientIdentifier is not
/// provided.
- (GIDConfiguration *)configurationWithClientIdentifier:(NSString *)runtimeClientIdentifier
                                 serverClientIdentifier:(NSString *)runtimeServerClientIdentifier
                                           hostedDomain:(NSString *)hostedDomain {
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

- (void)didSignInForUser:(GIDGoogleUser *)user
      withServerAuthCode:(NSString *_Nullable)serverAuthCode
              completion:
                  (nonnull void (^)(FSIUserData *_Nullable, FlutterError *_Nullable))completion {
  NSURL *photoUrl;
  if (user.profile.hasImage) {
    // Placeholder that will be replaced by on the Dart side based on screen size.
    photoUrl = [user.profile imageURLWithDimension:1337];
  }

  completion([FSIUserData makeWithDisplayName:user.profile.name
                                        email:user.profile.email
                                       userId:user.userID
                                     photoUrl:photoUrl.absoluteString
                               serverAuthCode:serverAuthCode
                                      idToken:user.idToken.tokenString],
             nil);
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
