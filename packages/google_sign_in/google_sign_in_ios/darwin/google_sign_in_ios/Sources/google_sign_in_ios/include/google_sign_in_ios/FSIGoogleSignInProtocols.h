// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <GoogleSignIn/GoogleSignIn.h>

@protocol FSIGIDGoogleUser;

NS_ASSUME_NONNULL_BEGIN

/// An abstraction around the GIDProfileData methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDProfileData for documentation, as this should always be implemented as a direct
/// passthrough to GIDProfileData.
@protocol FSIGIDProfileData <NSObject>

@property(nonatomic, readonly) NSString *email;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) BOOL hasImage;
- (nullable NSURL *)imageURLWithDimension:(NSUInteger)dimension;

@end

#pragma mark -

/// An abstraction around the GIDToken methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDToken for documentation, as this should always be implemented as a direct
/// passthrough to GIDToken.
@protocol FSIGIDToken <NSObject>

@property(nonatomic, readonly) NSString *tokenString;
@property(nonatomic, readonly, nullable) NSDate *expirationDate;

@end

#pragma mark -

/// An abstraction around the GIDSignInResult methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDSignInResult for documentation, as this should always be implemented as a direct
/// passthrough to GIDSignInResult.
@protocol FSIGIDSignInResult <NSObject>

@property(nonatomic, readonly) NSObject<FSIGIDGoogleUser> *user;
@property(nonatomic, readonly, nullable) NSString *serverAuthCode;

@end

#pragma mark -

/// An abstraction around the GIDGoogleUser methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDGoogleUser for documentation, as this should always be implemented as a direct
/// passthrough to GIDGoogleUser.
@protocol FSIGIDGoogleUser <NSObject>

@property(nonatomic, readonly, nullable) NSString *userID;
@property(nonatomic, readonly, nullable) NSObject<FSIGIDProfileData> *profile;
@property(nonatomic, readonly, nullable) NSArray<NSString *> *grantedScopes;
@property(nonatomic, readonly) NSObject<FSIGIDToken> *accessToken;
@property(nonatomic, readonly) NSObject<FSIGIDToken> *refreshToken;
@property(nonatomic, readonly, nullable) NSObject<FSIGIDToken> *idToken;

- (void)refreshTokensIfNeededWithCompletion:(void (^)(NSObject<FSIGIDGoogleUser> *_Nullable user,
                                                      NSError *_Nullable error))completion;

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)addScopes:(NSArray<NSString *> *)scopes
    presentingViewController:(UIViewController *)presentingViewController
                  completion:(nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable result,
                                                NSError *_Nullable error))completion
    NS_EXTENSION_UNAVAILABLE("The add scopes flow is not supported in App Extensions.");

#elif TARGET_OS_OSX

- (void)addScopes:(NSArray<NSString *> *)scopes
    presentingWindow:(NSWindow *)presentingWindow
          completion:(nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable result,
                                        NSError *_Nullable error))completion;

#endif

@end

#pragma mark -

/// An abstraction around the GIDSignIn methods used by the plugin, to allow injecting an alternate
/// implementation in unit tests.
///
/// See GIDSignIn for documentation, as this should always be implemented as a direct passthrough
/// to GIDSignIn.
@protocol FSIGIDSignIn <NSObject>

@property(nonatomic, nullable) GIDConfiguration *configuration;

- (BOOL)handleURL:(NSURL *)url;

- (void)restorePreviousSignInWithCompletion:
    (nullable void (^)(NSObject<FSIGIDGoogleUser> *_Nullable user,
                       NSError *_Nullable error))completion;

- (void)signOut;

- (void)disconnectWithCompletion:(nullable void (^)(NSError *_Nullable error))completion;

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)signInWithPresentingViewController:(UIViewController *)presentingViewController
                                      hint:(nullable NSString *)hint
                          additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                                     nonce:(nullable NSString *)nonce
                                completion:(nullable void (^)(
                                               NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                               NSError *_Nullable error))completion
    NS_EXTENSION_UNAVAILABLE("The sign-in flow is not supported in App Extensions.");

#elif TARGET_OS_OSX

- (void)signInWithPresentingWindow:(NSWindow *)presentingWindow
                              hint:(nullable NSString *)hint
                  additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                             nonce:(nullable NSString *)nonce
                        completion:
                            (nullable void (^)(NSObject<FSIGIDSignInResult> *_Nullable signInResult,
                                               NSError *_Nullable error))completion;

#endif

@end

NS_ASSUME_NONNULL_END
