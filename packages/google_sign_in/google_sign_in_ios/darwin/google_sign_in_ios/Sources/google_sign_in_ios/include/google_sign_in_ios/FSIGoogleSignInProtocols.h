// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <GoogleSignIn/GoogleSignIn.h>

NS_ASSUME_NONNULL_BEGIN

/// An abstraction around the GIDSignIn methods used by the plugin, to allow injecting an alternate
/// implementation in unit tests.
///
/// See GIDSignIn for documentation, as this should always be implemented as a direct passthrough
/// to GIDSignIn.
@protocol FSIGIDSignIn <NSObject>

@property(nonatomic, nullable) GIDConfiguration *configuration;

- (BOOL)handleURL:(NSURL *)url;

- (void)restorePreviousSignInWithCompletion:(nullable void (^)(GIDGoogleUser *_Nullable user,
                                                               NSError *_Nullable error))completion;

- (void)signOut;

- (void)disconnectWithCompletion:(nullable void (^)(NSError *_Nullable error))completion;

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)signInWithPresentingViewController:(UIViewController *)presentingViewController
                                      hint:(nullable NSString *)hint
                          additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                                     nonce:(nullable NSString *)nonce
                                completion:
                                    (nullable void (^)(GIDSignInResult *_Nullable signInResult,
                                                       NSError *_Nullable error))completion
    NS_EXTENSION_UNAVAILABLE("The sign-in flow is not supported in App Extensions.");

#elif TARGET_OS_OSX

- (void)signInWithPresentingWindow:(NSWindow *)presentingWindow
                              hint:(nullable NSString *)hint
                  additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                             nonce:(nullable NSString *)nonce
                        completion:(nullable void (^)(GIDSignInResult *_Nullable signInResult,
                                                      NSError *_Nullable error))completion;

#endif

@end

NS_ASSUME_NONNULL_END
