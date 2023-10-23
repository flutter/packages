// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleSignInPlugin.h"
#import "FLTGoogleSignInPlugin_Test.h"

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

// Configuration wrapping Google Cloud Console, Google Apps, OpenID,
// and other initialization metadata.
@property(strong) GIDConfiguration *configuration;

// Permissions requested during at sign in "init" method call
// unioned with scopes requested later with incremental authorization
// "requestScopes" method call.
// The "email" and "profile" base scopes are always implicitly requested.
@property(copy) NSSet<NSString *> *requestedScopes;

// Instance used to manage Google Sign In authentication including
// sign in, sign out, and requesting additional scopes.
@property(strong, readonly) GIDSignIn *signIn;

// The contents of GoogleService-Info.plist, if it exists.
@property(strong, nullable) NSDictionary<NSString *, id> *googleServiceProperties;

// Redeclared as not a designated initializer.
- (instancetype)init;

@end

@implementation FLTGoogleSignInPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTGoogleSignInPlugin *instance = [[FLTGoogleSignInPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
  FSIGoogleSignInApiSetup(registrar.messenger, instance);
}

- (instancetype)init {
  return [self initWithSignIn:GIDSignIn.sharedInstance];
}

- (instancetype)initWithSignIn:(GIDSignIn *)signIn {
  return [self initWithSignIn:signIn withGoogleServiceProperties:loadGoogleServiceInfo()];
}

- (instancetype)initWithSignIn:(GIDSignIn *)signIn
    withGoogleServiceProperties:(nullable NSDictionary<NSString *, id> *)googleServiceProperties {
  self = [super init];
  if (self) {
    _signIn = signIn;
    _googleServiceProperties = googleServiceProperties;

    // On the iOS simulator, we get "Broken pipe" errors after sign-in for some
    // unknown reason. We can avoid crashing the app by ignoring them.
    signal(SIGPIPE, SIG_IGN);
    _requestedScopes = [[NSSet alloc] init];
  }
  return self;
}

#pragma mark - <FlutterPlugin> protocol

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
  return [self.signIn handleURL:url];
}

#pragma mark - FSIGoogleSignInApi

- (void)initializeSignInWithParameters:(nonnull FSIInitParams *)params
                                 error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GIDConfiguration *configuration = [self configurationWithClientIdArgument:params.clientId
                                                     serverClientIdArgument:params.serverClientId
                                                       hostedDomainArgument:params.hostedDomain];
  if (configuration != nil) {
    self.requestedScopes = [NSSet setWithArray:params.scopes];
    self.configuration = configuration;
  } else {
    *error = [FlutterError errorWithCode:@"missing-config"
                                 message:@"GoogleService-Info.plist file not found and clientId "
                                         @"was not provided programmatically."
                                 details:nil];
  }
}

- (void)signInSilentlyWithCompletion:(nonnull void (^)(FSIUserData *_Nullable,
                                                       FlutterError *_Nullable))completion {
  [self.signIn restorePreviousSignInWithCallback:^(GIDGoogleUser *user, NSError *error) {
    [self didSignInForUser:user withCompletion:completion error:error];
  }];
}

- (nullable NSNumber *)isSignedInWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([self.signIn hasPreviousSignIn]);
}

- (void)signInWithCompletion:(nonnull void (^)(FSIUserData *_Nullable,
                                               FlutterError *_Nullable))completion {
  @try {
    GIDConfiguration *configuration = self.configuration
                                          ?: [self configurationWithClientIdArgument:nil
                                                              serverClientIdArgument:nil
                                                                hostedDomainArgument:nil];
    [self.signIn signInWithConfiguration:configuration
                presentingViewController:[self topViewController]
                                    hint:nil
                        additionalScopes:self.requestedScopes.allObjects
                                callback:^(GIDGoogleUser *user, NSError *error) {
                                  [self didSignInForUser:user
                                          withCompletion:completion
                                                   error:error];
                                }];
  } @catch (NSException *e) {
    completion(nil, [FlutterError errorWithCode:@"google_sign_in" message:e.reason details:e.name]);
    [e raise];
  }
}

- (void)getAccessTokenWithCompletion:(nonnull void (^)(FSITokenData *_Nullable,
                                                       FlutterError *_Nullable))completion {
  GIDGoogleUser *currentUser = self.signIn.currentUser;
  GIDAuthentication *auth = currentUser.authentication;
  [auth doWithFreshTokens:^void(GIDAuthentication *authentication, NSError *error) {
    if (error) {
      completion(nil, getFlutterError(error));
    } else {
      completion([FSITokenData makeWithIdToken:authentication.idToken
                                   accessToken:authentication.accessToken],
                 nil);
    }
  }];
}

- (void)signOutWithError:(FlutterError *_Nullable *_Nonnull)error;
{ [self.signIn signOut]; }

- (void)disconnectWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  [self.signIn disconnectWithCallback:^(NSError *error) {
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
    [self.signIn addScopes:requestedScopes.allObjects
        presentingViewController:[self topViewController]
                        callback:^(GIDGoogleUser *addedScopeUser, NSError *addedScopeError) {
                          BOOL granted = NO;
                          FlutterError *error = nil;
                          if ([addedScopeError.domain isEqualToString:kGIDSignInErrorDomain] &&
                              addedScopeError.code == kGIDSignInErrorCodeNoCurrentUser) {
                            error = [FlutterError errorWithCode:@"sign_in_required"
                                                        message:@"No account to grant scopes."
                                                        details:nil];
                          } else if ([addedScopeError.domain
                                         isEqualToString:kGIDSignInErrorDomain] &&
                                     addedScopeError.code ==
                                         kGIDSignInErrorCodeScopesAlreadyGranted) {
                            // Scopes already granted, report success.
                            granted = YES;
                          } else if (addedScopeUser == nil) {
                            granted = NO;
                          } else {
                            NSSet<NSString *> *grantedScopes =
                                [NSSet setWithArray:addedScopeUser.grantedScopes];
                            granted = [requestedScopes isSubsetOfSet:grantedScopes];
                          }
                          completion(error == nil ? @(granted) : nil, error);
                        }];
  } @catch (NSException *e) {
    completion(nil, [FlutterError errorWithCode:@"request_scopes" message:e.reason details:e.name]);
  }
}

#pragma mark - <GIDSignInUIDelegate> protocol

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
  UIViewController *rootViewController =
      [UIApplication sharedApplication].delegate.window.rootViewController;
  [rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
  [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

/// @return @c nil if GoogleService-Info.plist not found and clientId is not provided.
- (GIDConfiguration *)configurationWithClientIdArgument:(id)clientIDArg
                                 serverClientIdArgument:(id)serverClientIDArg
                                   hostedDomainArgument:(id)hostedDomainArg {
  NSString *clientID;
  BOOL hasDynamicClientId = [clientIDArg isKindOfClass:[NSString class]];
  if (hasDynamicClientId) {
    clientID = clientIDArg;
  } else if (self.googleServiceProperties) {
    clientID = self.googleServiceProperties[kClientIdKey];
  } else {
    // We couldn't resolve a clientId, without which we cannot create a GIDConfiguration.
    return nil;
  }

  BOOL hasDynamicServerClientId = [serverClientIDArg isKindOfClass:[NSString class]];
  NSString *serverClientID = hasDynamicServerClientId
                                 ? serverClientIDArg
                                 : self.googleServiceProperties[kServerClientIdKey];

  NSString *hostedDomain = nil;
  if (hostedDomainArg != [NSNull null]) {
    hostedDomain = hostedDomainArg;
  }
  return [[GIDConfiguration alloc] initWithClientID:clientID
                                     serverClientID:serverClientID
                                       hostedDomain:hostedDomain
                                        openIDRealm:nil];
}

- (void)didSignInForUser:(GIDGoogleUser *)user
          withCompletion:(nonnull void (^)(FSIUserData *_Nullable,
                                           FlutterError *_Nullable))completion
                   error:(NSError *)error {
  if (error != nil) {
    // Forward all errors and let Dart side decide how to handle.
    completion(nil, getFlutterError(error));
  } else {
    NSURL *photoUrl;
    if (user.profile.hasImage) {
      // Placeholder that will be replaced by on the Dart side based on screen size.
      photoUrl = [user.profile imageURLWithDimension:1337];
    }
    completion([FSIUserData makeWithDisplayName:user.profile.name
                                          email:user.profile.email
                                         userId:user.userID
                                       photoUrl:[photoUrl absoluteString]
                                 serverAuthCode:user.serverAuthCode],
               nil);
  }
}

- (UIViewController *)topViewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan) Provide a non-deprecated codepath. See
  // https://github.com/flutter/flutter/issues/104117
  return [self topViewControllerFromViewController:[UIApplication sharedApplication]
                                                       .keyWindow.rootViewController];
#pragma clang diagnostic pop
}

/**
 * This method recursively iterate through the view hierarchy
 * to return the top most view controller.
 *
 * It supports the following scenarios:
 *
 * - The view controller is presenting another view.
 * - The view controller is a UINavigationController.
 * - The view controller is a UITabBarController.
 *
 * @return The top most view controller.
 */
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

@end
