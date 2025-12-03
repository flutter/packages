// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/google_sign_in_ios/WrapperProtocolImplementations.h"

#import "./include/google_sign_in_ios/FSIViewProvider.h"

@import GoogleSignIn;

@implementation FSIDefaultViewProvider

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

#if TARGET_OS_OSX
- (NSView *)view {
  return self.registrar.view;
}
#else
- (UIViewController *)viewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan) Provide a non-deprecated codepath. See
  // https://github.com/flutter/flutter/issues/104117
  return UIApplication.sharedApplication.keyWindow.rootViewController;
#pragma clang diagnostic pop
}
#endif

@end

#pragma mark -

@implementation FSIGIDSignInWrapper

- (instancetype)init {
  self = [super init];
  if (self) {
    _signIn = GIDSignIn.sharedInstance;
  }
  return self;
}

- (GIDConfiguration *)configuration {
  return self.signIn.configuration;
}

- (void)setConfiguration:(GIDConfiguration *)configuration {
  self.signIn.configuration = configuration;
}

- (BOOL)handleURL:(NSURL *)url {
  return [self.signIn handleURL:url];
}

- (void)restorePreviousSignInWithCompletion:
    (nullable void (^)(NSObject<FSIGIDGoogleUser> *_Nullable user,
                       NSError *_Nullable error))completion {
  [self.signIn restorePreviousSignInWithCompletion:^(GIDGoogleUser *user, NSError *error) {
    if (completion) {
      completion([[FSIGIDGoogleUserWrapper alloc] initWithUser:user], error);
    }
  }];
}

- (void)signOut {
  [self.signIn signOut];
}

- (void)disconnectWithCompletion:(nullable void (^)(NSError *_Nullable error))completion {
  [self.signIn disconnectWithCompletion:completion];
}

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)signInWithPresentingViewController:(UIViewController *)presentingViewController
                                      hint:(nullable NSString *)hint
                          additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                                     nonce:(nullable NSString *)nonce
                                completion:(nullable void (^)(
                                               NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                               NSError *_Nullable error))completion {
  [self.signIn signInWithPresentingViewController:presentingViewController
                                             hint:hint
                                 additionalScopes:additionalScopes
                                            nonce:nonce
                                       completion:^(GIDSignInResult *result, NSError *error) {
                                         if (completion) {
                                           completion([[FSIGIDSignInResultWrapper alloc]
                                                          initWithResult:result],
                                                      error);
                                         }
                                       }];
}

#elif TARGET_OS_OSX

- (void)signInWithPresentingWindow:(NSWindow *)presentingWindow
                              hint:(nullable NSString *)hint
                  additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                             nonce:(nullable NSString *)nonce
                        completion:
                            (nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                               NSError *_Nullable error))completion {
  [self.signIn
      signInWithPresentingWindow:presentingWindow
                            hint:hint
                additionalScopes:additionalScopes
                           nonce:nonce
                      completion:^(GIDSignInResult *result, NSError *error) {
                        if (completion) {
                          completion([[FSIGIDSignInResultWrapper alloc] initWithResult:result],
                                     error);
                        }
                      }];
}

#endif

@end

#pragma mark -

@implementation FSIGIDSignInResultWrapper

- (instancetype)initWithResult:(GIDSignInResult *)result {
  if (result == nil) {
    return nil;
  }
  self = [super init];
  if (self) {
    _result = result;
  }
  return self;
}

- (NSObject<FSIGIDGoogleUser> *)user {
  return [[FSIGIDGoogleUserWrapper alloc] initWithUser:self.result.user];
}

- (NSString *)serverAuthCode {
  return self.result.serverAuthCode;
}

@end

#pragma mark -

@implementation FSIGIDGoogleUserWrapper

- (instancetype)initWithUser:(GIDGoogleUser *)user {
  if (user == nil) {
    return nil;
  }
  self = [super init];
  if (self) {
    _user = user;
  }
  return self;
}

- (NSString *)userID {
  return self.user.userID;
}

- (NSObject<FSIGIDProfileData> *)profile {
  return [[FSIGIDProfileDataWrapper alloc] initWithProfileData:self.user.profile];
}

- (NSArray<NSString *> *)grantedScopes {
  return self.user.grantedScopes;
}

- (NSObject<FSIGIDToken> *)accessToken {
  return [[FSIGIDTokenWrapper alloc] initWithToken:self.user.accessToken];
}

- (NSObject<FSIGIDToken> *)refreshToken {
  return [[FSIGIDTokenWrapper alloc] initWithToken:self.user.refreshToken];
}

- (NSObject<FSIGIDToken> *)idToken {
  return [[FSIGIDTokenWrapper alloc] initWithToken:self.user.idToken];
}

- (void)refreshTokensIfNeededWithCompletion:(void (^)(NSObject<FSIGIDGoogleUser> *_Nullable user,
                                                      NSError *_Nullable error))completion {
  [self.user refreshTokensIfNeededWithCompletion:^(GIDGoogleUser *user, NSError *error) {
    if (completion) {
      completion([[FSIGIDGoogleUserWrapper alloc] initWithUser:user], error);
    }
  }];
}

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)addScopes:(NSArray<NSString *> *)scopes
    presentingViewController:(UIViewController *)presentingViewController
                  completion:
                      (nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                         NSError *_Nullable error))completion {
  [self.user addScopes:scopes
      presentingViewController:presentingViewController
                    completion:^(GIDSignInResult *result, NSError *error) {
                      if (completion) {
                        completion([[FSIGIDSignInResultWrapper alloc] initWithResult:result],
                                   error);
                      }
                    }];
}

#elif TARGET_OS_OSX

- (void)addScopes:(NSArray<NSString *> *)scopes
    presentingWindow:(NSWindow *)presentingWindow
          completion:(nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                        NSError *_Nullable error))completion {
  [self.user addScopes:scopes
      presentingWindow:presentingWindow
            completion:^(GIDSignInResult *result, NSError *error) {
              if (completion) {
                completion([[FSIGIDSignInResultWrapper alloc] initWithResult:result], error);
              }
            }];
}

#endif

@end

#pragma mark -

@implementation FSIGIDProfileDataWrapper

- (instancetype)initWithProfileData:(GIDProfileData *)profileData {
  if (profileData == nil) {
    return nil;
  }
  self = [super init];
  if (self) {
    _profileData = profileData;
  }
  return self;
}

- (NSString *)email {
  return self.profileData.email;
}

- (NSString *)name {
  return self.profileData.name;
}

- (BOOL)hasImage {
  return self.profileData.hasImage;
}

- (NSURL *)imageURLWithDimension:(NSUInteger)dimension {
  return [self.profileData imageURLWithDimension:dimension];
}

@end

#pragma mark -

@implementation FSIGIDTokenWrapper

- (instancetype)initWithToken:(GIDToken *)token {
  if (token == nil) {
    return nil;
  }
  self = [super init];
  if (self) {
    _token = token;
  }
  return self;
}

- (NSString *)tokenString {
  return self.token.tokenString;
}

- (NSDate *)expirationDate {
  return self.token.expirationDate;
}

@end
